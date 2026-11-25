#!/usr/bin/env python3
"""Install an upstream usql binary when no supported package manager provides it."""

import hashlib
import io
import json
import os
from pathlib import Path, PurePosixPath
import platform
import re
import shutil
import sys
import tarfile
import tempfile
from urllib.request import Request, urlopen
import zipfile


RELEASE_API = "https://api.github.com/repos/xo/usql/releases/latest"


def fetch(url):
    request = Request(url, headers={"User-Agent": "dotfiles-and-scripts"})
    with urlopen(request, timeout=60) as response:
        return response.read()


def select_asset(release, system, machine):
    systems = {"Linux": "linux", "Windows": "windows", "Darwin": "darwin"}
    arches = {
        "amd64": "amd64", "x86_64": "amd64",
        "arm64": "arm64", "aarch64": "arm64", "armv7l": "arm",
    }
    if system not in systems or machine.lower() not in arches:
        raise ValueError(f"Unsupported usql platform: {system}/{machine}")
    tag = release["tag_name"]
    version = tag[1:] if tag.startswith("v") else tag
    if not re.fullmatch(r"\d+\.\d+\.\d+", version):
        raise ValueError(f"Unexpected usql release tag: {release['tag_name']}")
    suffix = "zip" if system == "Windows" else "tar.bz2"
    name = f"usql-{version}-{systems[system]}-{arches[machine.lower()]}.{suffix}"
    names = [name]
    if system == "Linux":
        # Prefer upstream's static build to avoid distribution-specific libc requirements.
        names.insert(0, name.replace("usql-", "usql_static-", 1))
    assets = {asset["name"]: asset for asset in release["assets"]}
    for name in names:
        if name in assets:
            return assets[name]
    raise ValueError(f"No upstream usql release for {system}/{machine}")


def install_release(release, system, machine, bin_dir, download=fetch):
    asset = select_asset(release, system, machine)
    digest = asset.get("digest") or ""
    if not re.fullmatch(r"sha256:[0-9a-fA-F]{64}", digest):
        raise ValueError("The usql release asset has no valid SHA-256 digest")
    url = f"https://github.com/xo/usql/releases/download/{release['tag_name']}/{asset['name']}"
    data = download(url)
    if hashlib.sha256(data).hexdigest() != digest.split(":", 1)[1].lower():
        raise ValueError("usql archive SHA-256 mismatch; existing installation preserved")

    executable = "usql.exe" if system == "Windows" else "usql"
    bin_dir = Path(bin_dir)
    bin_dir.mkdir(parents=True, exist_ok=True)
    target = bin_dir / executable
    # Stage beside the destination, then atomically replace only this executable.
    with tempfile.NamedTemporaryFile(prefix=".usql-", dir=bin_dir, delete=False) as staged:
        staged_path = Path(staged.name)
    try:
        with staged_path.open("wb") as output:
            if asset["name"].endswith(".zip"):
                with zipfile.ZipFile(io.BytesIO(data)) as archive:
                    members = [m for m in archive.infolist()
                               if not m.is_dir() and PurePosixPath(m.filename).name == executable]
                    if len(members) != 1:
                        raise ValueError("Expected one usql executable in the release archive")
                    with archive.open(members[0]) as source:
                        shutil.copyfileobj(source, output)
            else:
                with tarfile.open(fileobj=io.BytesIO(data), mode="r:bz2") as archive:
                    members = [m for m in archive.getmembers()
                               if m.isfile() and PurePosixPath(m.name).name == executable]
                    if len(members) != 1:
                        raise ValueError("Expected one usql executable in the release archive")
                    with archive.extractfile(members[0]) as source:
                        shutil.copyfileobj(source, output)
        staged_path.chmod(0o755)
        os.replace(staged_path, target)
    finally:
        staged_path.unlink(missing_ok=True)
    return target


def main():
    if shutil.which("usql"):
        print("usql is already available.")
        return 0
    try:
        release = json.loads(fetch(RELEASE_API))
        target = install_release(release, platform.system(), platform.machine(),
                                 Path.home() / ".local" / "bin")
    except (OSError, ValueError, KeyError, tarfile.TarError, zipfile.BadZipFile) as error:
        print(f"usql installation failed: {error}", file=sys.stderr)
        return 1
    print(f"Installed usql {release['tag_name']} at {target}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
