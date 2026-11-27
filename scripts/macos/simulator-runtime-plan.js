// Pure selection logic plus a JXA entry point; uses only macOS built-ins.
function object(value) {
    return value !== null && typeof value === "object" && !Array.isArray(value);
}
function validateImages(images) {
    if (!object(images)) throw new Error("Expected runtime image dictionary");
    Object.keys(images).forEach(function (id) {
        var image = images[id];
        if (!/^[0-9A-F]{8}(-[0-9A-F]{4}){3}-[0-9A-F]{12}$/i.test(id) ||
            !object(image) || image.identifier !== id || typeof image.state !== "string") {
            throw new Error("Unrecognized runtime image schema");
        }
    });
}
function compare(a, b) {
    var aa = a.match(/[0-9]+|[^0-9]+/g), bb = b.match(/[0-9]+|[^0-9]+/g);
    for (var i = 0; i < Math.max(aa.length, bb.length); i++) {
        var x = aa[i] || "0", y = bb[i] || "0";
        if (/^\d+$/.test(x) && /^\d+$/.test(y)) { x = Number(x); y = Number(y); }
        if (x !== y) return x > y ? 1 : -1;
    }
    return 0;
}
function planRuntimes(images, payload, now) {
    validateImages(images);
    if (!object(payload) || !object(payload.devices) || !isFinite(now) || now <= 0) {
        throw new Error("Missing device states or invalid clock");
    }
    var busy = false;
    Object.keys(payload.devices).forEach(function (runtime) {
        if (!Array.isArray(payload.devices[runtime])) throw new Error("Invalid device list");
        payload.devices[runtime].forEach(function (device) {
            if (!object(device) || typeof device.state !== "string") throw new Error("Invalid device state");
            // Unknown/transitional states are protected, not treated as shutdown.
            if (device.state !== "Shutdown") busy = true;
        });
    });
    var groups = {}, entries = [], transitioning = false;
    Object.keys(images).sort().forEach(function (id) {
        var image = images[id];
        if (image.state !== "Ready") {
            transitioning = true;
            entries.push({ id: id, keep: "image-not-ready", size: 0 });
            return;
        }
        if (typeof image.platformIdentifier !== "string" || !/^[a-zA-Z0-9.]+$/.test(image.platformIdentifier) ||
            typeof image.version !== "string" || !/^\d+(\.\d+)*$/.test(image.version) ||
            typeof image.build !== "string" || !/^[a-zA-Z0-9]+$/.test(image.build) ||
            typeof image.runtimeIdentifier !== "string" || !/^com\.apple\.CoreSimulator\.SimRuntime\.[a-zA-Z0-9.-]+$/.test(image.runtimeIdentifier) ||
            typeof image.deletable !== "boolean" || !Number.isSafeInteger(image.sizeBytes) || image.sizeBytes < 0) {
            throw new Error("Missing or invalid runtime selection metadata: " + id);
        }
        var group = image.platformIdentifier + ":" + image.version.split(".")[0];
        var entry = { id: id, image: image, size: image.sizeBytes, group: group };
        entries.push(entry);
        var winner = groups[group];
        if (!winner || compare(image.version, winner.image.version) > 0 ||
            (compare(image.version, winner.image.version) === 0 && compare(image.build, winner.image.build) > 0)) {
            groups[group] = entry;
        }
    });
    return entries.map(function (entry) {
        var image = entry.image, reason = entry.keep, remove = false;
        if (!reason) {
            var age;
            if (image.lastUsedAt !== undefined) {
                if (typeof image.lastUsedAt !== "string" || !/^\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d(\.\d+)?Z$/.test(image.lastUsedAt)) {
                    throw new Error("Invalid lastUsedAt: " + entry.id);
                }
                age = Date.parse(image.lastUsedAt) / 1000;
                // A zero/year-one sentinel is not evidence of old usage.
                if (!isFinite(age) || new Date(age * 1000).toISOString().slice(0, 19) !== image.lastUsedAt.slice(0, 19)) {
                    throw new Error("Invalid lastUsedAt date: " + entry.id);
                }
            }
            if (busy) reason = "simulator-device-active-or-unknown";
            else if (transitioning) reason = "runtime-installation-or-transition";
            else if (!image.deletable) reason = "not-deletable";
            else if (groups[entry.group].id !== entry.id) { remove = true; reason = "superseded-in-platform-major"; }
            else if (age > 0 && age < now - 30 * 86400) { remove = true; reason = "unused-over-30-days"; }
            else reason = "newest-in-platform-major";
        }
        return [remove ? "delete" : "keep", entry.id, entry.size, reason].join("\t");
    }).join("\n");
}
function run(argv) {
    ObjC.import("Foundation");
    function readJSON(path) {
        var data = $.NSData.dataWithContentsOfFile(path);
        if (!data) throw new Error("Cannot read " + path);
        var str = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding);
        return JSON.parse(ObjC.unwrap(str));
    }
    if (argv[0] === "--verify-absent") {
        var images = readJSON(argv[1]);
        validateImages(images);
        if (Object.prototype.hasOwnProperty.call(images, argv[2])) throw new Error("Image is still registered");
        return;
    }
    return planRuntimes(readJSON(argv[0]), readJSON(argv[1]), Number(argv[2]));
}
if (typeof module !== "undefined") module.exports = { planRuntimes: planRuntimes };
