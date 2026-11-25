"""Offline checks of platform routing and official installer download failures."""

import os
from pathlib import Path
import shutil
import subprocess
import unittest


REPO = Path(__file__).resolve().parents[2]
GIT = shutil.which("git")
GIT_BASH = Path(GIT).resolve().parents[1] / "bin" / "bash.exe" if GIT else None
BASH = str(GIT_BASH) if os.name == "nt" and GIT_BASH and GIT_BASH.exists() else shutil.which("bash")
SOURCE = (REPO / "scripts/install_apps.sh").read_text(encoding="utf-8")
DEFINITIONS = SOURCE.split("\nif is_macos; then\n", 1)[0]


@unittest.skipUnless(BASH, "Bash is required for Unix installer routing checks")
class UnixInstallerTests(unittest.TestCase):
    def run_shell(self, body):
        script = "__loaded_commonrc=1\n" + DEFINITIONS + "\n" + r'''
echo_run() { :; }
echo_ok() { :; }
echo_error() { :; }
is_macos() { [[ $distro == macos ]]; }
''' + body
        return subprocess.run([BASH, "-s"], input=script, text=True,
                              encoding="utf-8", capture_output=True, cwd=REPO)

    def test_all_official_ai_installers_run_without_leaking_options_or_env(self):
        result = self.run_shell(r'''
unset CODEX_NON_INTERACTIVE
set +o pipefail
curl() {
    case "$*" in
        *chatgpt.com/codex/install.sh*)
            printf '%s\n' 'test "$CODEX_NON_INTERACTIVE" = 1 || exit 9' 'echo fixture-codex' ;;
        *cursor.com/install*) printf '%s\n' 'echo fixture-cursor' ;;
        *claude.ai/install.sh*) printf '%s\n' 'echo fixture-claude' ;;
        *) return 2 ;;
    esac
}
install_ai_clis || exit 1
test "${CODEX_NON_INTERACTIVE-unset}" = unset || exit 2
[[ $SHELLOPTS != *pipefail* ]] || exit 3
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.splitlines(),
                         ["fixture-codex", "fixture-cursor", "fixture-claude"])

    def test_failed_download_stops_before_other_installers(self):
        result = self.run_shell(r'''
curl() { return 23; }
install_ai_clis
exit $?
''')
        self.assertEqual(result.returncode, 1)
        self.assertEqual(result.stdout, "")

    def test_usql_uses_platform_specific_sources(self):
        mocks = r'''
command() {
    if [[ $1 == -v && $2 == usql ]]; then return 1; fi
    builtin command "$@"
}
do_install() { printf 'brew:%s\n' "$*"; }
install_yay() { return 0; }
yay() { printf 'yay:%s\n' "$*"; }
python3() { printf 'python:%s\n' "${1##*/}"; }
'''
        for distro, expected in [
            ("macos", "brew:xo/xo/usql"),
            ("arch", "yay:-S --needed --noconfirm usql-bin"),
            ("ubuntu", "python:install_usql.py"),
        ]:
            with self.subTest(distro=distro):
                result = self.run_shell(mocks + f"\ndistro={distro}\ncd /\ninstall_usql\n")
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(result.stdout.strip(), expected)

    def test_shell_entrypoints_parse(self):
        for path in [REPO / "install.sh", REPO / "scripts/install_apps.sh"]:
            with self.subTest(path=path):
                result = subprocess.run([BASH, "-n"], input=path.read_text(encoding="utf-8"),
                                        text=True, encoding="utf-8", capture_output=True)
                self.assertEqual(result.returncode, 0, result.stderr)


if __name__ == "__main__":
    unittest.main()
