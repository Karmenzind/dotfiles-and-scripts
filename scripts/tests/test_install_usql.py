import hashlib
import importlib.util
import io
from pathlib import Path
import tarfile
import tempfile
import unittest
import zipfile


SCRIPT = Path(__file__).resolve().parents[1] / "install_usql.py"
SPEC = importlib.util.spec_from_file_location("install_usql", SCRIPT)
installer = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(installer)


class UsqlInstallerTests(unittest.TestCase):
    def release(self, name, payload):
        return {"tag_name": "v1.2.3", "assets": [{
            "name": name,
            "digest": "sha256:" + hashlib.sha256(payload).hexdigest(),
        }]}

    def archive(self, windows=False, member=None):
        result = io.BytesIO()
        member = member or ("usql.exe" if windows else "usql")
        if windows:
            with zipfile.ZipFile(result, "w") as archive:
                archive.writestr(member, b"fixture executable")
        else:
            with tarfile.open(fileobj=result, mode="w:bz2") as archive:
                info = tarfile.TarInfo(member)
                info.size = len(b"fixture executable")
                archive.addfile(info, io.BytesIO(b"fixture executable"))
        return result.getvalue()

    def test_installs_linux_and_windows_executables(self):
        for system, name, windows in [
            ("Linux", "usql_static-1.2.3-linux-amd64.tar.bz2", False),
            ("Windows", "usql-1.2.3-windows-amd64.zip", True),
        ]:
            with self.subTest(system=system), tempfile.TemporaryDirectory() as tmp:
                payload = self.archive(windows)
                urls = []
                def download(url):
                    urls.append(url)
                    return payload
                target = installer.install_release(self.release(name, payload), system,
                                                   "AMD64", Path(tmp) / "bin", download)
                self.assertEqual(target.read_bytes(), b"fixture executable")
                self.assertEqual(urls, [f"https://github.com/xo/usql/releases/download/v1.2.3/{name}"])
                self.assertEqual(list(target.parent.iterdir()), [target])

    def test_checksum_failure_preserves_existing_binary(self):
        with tempfile.TemporaryDirectory() as tmp:
            target = Path(tmp) / "usql.exe"
            target.write_bytes(b"existing executable")
            release = self.release("usql-1.2.3-windows-amd64.zip", self.archive(True))
            with self.assertRaisesRegex(ValueError, "SHA-256 mismatch"):
                installer.install_release(release, "Windows", "x86_64", tmp,
                                          lambda _: b"corrupt download")
            self.assertEqual(target.read_bytes(), b"existing executable")

    def test_missing_digest_does_not_download(self):
        release = self.release("usql-1.2.3-windows-amd64.zip", b"")
        release["assets"][0]["digest"] = None
        with tempfile.TemporaryDirectory() as tmp:
            with self.assertRaisesRegex(ValueError, "no valid SHA-256"):
                installer.install_release(release, "Windows", "AMD64", tmp,
                                          lambda _: self.fail("unexpected download"))

    def test_archive_traversal_is_not_extracted_and_preserves_existing_file(self):
        for windows in (True, False):
            with self.subTest(windows=windows), tempfile.TemporaryDirectory() as tmp:
                bin_dir = Path(tmp) / "bin"
                bin_dir.mkdir()
                target = bin_dir / ("usql.exe" if windows else "usql")
                target.write_bytes(b"existing executable")
                payload = self.archive(windows, "../escaped")
                name = "usql-1.2.3-windows-amd64.zip" if windows else "usql_static-1.2.3-linux-amd64.tar.bz2"
                with self.assertRaisesRegex(ValueError, "Expected one usql"):
                    installer.install_release(self.release(name, payload),
                                              "Windows" if windows else "Linux", "AMD64",
                                              bin_dir, lambda _: payload)
                self.assertEqual(target.read_bytes(), b"existing executable")
                self.assertFalse((Path(tmp) / "escaped").exists())
                self.assertEqual(list(bin_dir.iterdir()), [target])

    def test_linux_prefers_static_and_maps_arm64(self):
        regular = "usql-1.2.3-linux-arm64.tar.bz2"
        static = "usql_static-1.2.3-linux-arm64.tar.bz2"
        release = {"tag_name": "v1.2.3", "assets": [{"name": regular}, {"name": static}]}
        self.assertEqual(installer.select_asset(release, "Linux", "aarch64")["name"], static)

    def test_missing_architecture_is_not_silently_substituted(self):
        release = self.release("usql-1.2.3-windows-amd64.zip", b"")
        with self.assertRaisesRegex(ValueError, "No upstream usql release"):
            installer.select_asset(release, "Windows", "ARM64")


if __name__ == "__main__":
    unittest.main()
