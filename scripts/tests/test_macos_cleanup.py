"""Isolated macOS cleanup tests; never query or delete host simulator images."""
import datetime
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import time
import unittest

REPO = Path(__file__).resolve().parents[2]
SCRIPT = REPO / 'scripts/macos/cleanup-macos.sh'
PLANNER = REPO / 'scripts/macos/simulator-runtime-plan.js'


def image(number, version, platform='iphonesimulator', **extra):
    identifier = f'00000000-0000-0000-0000-{number:012d}'
    return dict(identifier=identifier, platformIdentifier=f'com.apple.platform.{platform}',
                version=version, build='24A123', state='Ready', deletable=True,
                sizeBytes=1024 * 1024, runtimeIdentifier=f'com.apple.CoreSimulator.SimRuntime.{platform}-{version}', **extra)


@unittest.skipUnless(sys.platform == 'darwin', 'Requires macOS stat and JXA')
class CleanupTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(prefix='test-macos-cleanup-')
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.home = self.root / 'home'
        self.home.mkdir()
        self.bin = self.root / 'bin'
        self.bin.mkdir()
        self.images = self.root / 'images.json'
        self.devices = self.root / 'devices.json'
        self.calls = self.root / 'calls'
        self.images.write_text('{}')
        self.devices.write_text('{"devices": {}}')
        self.env = {**os.environ, 'HOME': str(self.home), 'PATH': f'{self.bin}:/usr/bin:/bin',
                    'TEST_IMAGES': str(self.images), 'TEST_DEVICES': str(self.devices),
                    'TEST_CALLS': str(self.calls), 'TMPDIR': str(self.root)}
        self.env.pop('XCODE_ARCHIVES_ROOT', None)
        self.env.pop('XCODE_DEVICE_SUPPORT_ROOT', None)
        self.stub('ps', 'printf "/sbin/launchd\\n"')
        self.stub('xcrun', '''
case "$*" in
  'simctl runtime list -j') cat "$TEST_IMAGES" ;;
  'simctl list devices -j') cat "$TEST_DEVICES" ;;
  'simctl runtime delete '*)
    printf '%s\\n' "$*" >> "$TEST_CALLS"
    /usr/bin/python3 - "$TEST_IMAGES" "$4" <<'INNER'
import json, sys
from pathlib import Path
p = Path(sys.argv[1]); d = json.loads(p.read_text()); d.pop(sys.argv[2]); p.write_text(json.dumps(d))
INNER
    ;;
  *) exit 99 ;;
esac
''')

    def stub(self, name, code):
        path = self.bin / name
        path.write_text('#!/bin/bash\nset -eu\n' + code + '\n')
        path.chmod(0o755)

    def run_script(self, *args):
        return subprocess.run(['/bin/bash', str(SCRIPT), '--no-log', *args], env=self.env,
                              text=True, capture_output=True, timeout=30)

    def set_images(self, *entries):
        self.images.write_text(json.dumps({e['identifier']: e for e in entries}))

    def old_file(self):
        path = self.home / 'Pictures/Zappy/nested/old\n capture.png'
        path.parent.mkdir(parents=True)
        path.write_bytes(b'x' * 8192)
        old = time.time() - 73 * 3600
        os.utime(path, (old, old))
        return path

    def planner(self, now=None):
        return subprocess.run(['/usr/bin/osascript', '-l', 'JavaScript', str(PLANNER),
                               str(self.images), str(self.devices), str(now or time.time())],
                              text=True, capture_output=True, timeout=10)

    def test_zappy_dry_run_actual_and_capacity(self):
        old = self.old_file()
        fresh = old.parent / 'fresh.png'
        fresh.write_text('keep')
        outside = self.home / 'outside'
        outside.write_text('keep')
        link = old.parent / 'link'
        link.symlink_to(outside)
        result = self.run_script('--dry-run', '--retention-days', '1')
        self.assertEqual(result.returncode, 0, result.stderr + result.stdout)
        self.assertTrue(old.exists())
        self.assertIn('candidates: 1, removed: 0, failed: 0', result.stdout)
        result = self.run_script('--retention-days', '1')
        self.assertEqual(result.returncode, 0, result.stderr + result.stdout)
        self.assertFalse(old.exists())
        self.assertTrue(fresh.exists() and outside.exists() and link.is_symlink())
        self.assertIn('candidates: 1, removed: 1, failed: 0', result.stdout)
        self.assertIn('Free space before:', result.stdout)
        self.assertIn('Observed free-space change:', result.stdout)
        self.assertIn('removed size estimate:', result.stdout)

    def test_find_partial_failure_does_not_delete(self):
        old = self.old_file()
        self.stub('find', '/usr/bin/find "$@"\nexit 1')
        result = self.run_script()
        self.assertNotEqual(result.returncode, 0)
        self.assertTrue(old.exists())
        self.assertIn('Cannot completely scan:', result.stdout)

    def test_stat_failure_is_not_reported_as_success(self):
        old = self.old_file()
        self.stub('stat', 'exit 1')
        result = self.run_script()
        self.assertNotEqual(result.returncode, 0)
        self.assertTrue(old.exists())
        self.assertIn('Cannot read timestamp:', result.stdout)

    def test_size_failure_preserves_candidate(self):
        old = self.old_file()
        self.stub('du', 'exit 1')
        result = self.run_script()
        self.assertNotEqual(result.returncode, 0)
        self.assertTrue(old.exists())
        self.assertIn('Cannot measure candidate:', result.stdout)

    def test_free_space_failure_is_reported(self):
        self.stub('df', 'exit 1')
        result = self.run_script('--dry-run')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('failed: 2', result.stdout)

    def test_active_xcode_protects_developer_data_but_not_zappy(self):
        old = self.old_file()
        device = self.home / 'Library/Developer/Xcode/iOS DeviceSupport/old'
        device.mkdir(parents=True)
        (device / 'data').write_text('keep')
        os.utime(device, (time.time() - 20 * 86400,) * 2)
        self.set_images(image(1, '18.2'), image(2, '18.5'))
        self.stub('ps', 'printf "/Applications/Xcode.app/Contents/MacOS/Xcode\\n"')
        result = self.run_script()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(device.exists())
        self.assertFalse(old.exists())
        self.assertFalse(self.calls.exists())
        self.assertIn('Development tools are active', result.stdout)

    def test_unknown_process_state_fails_closed(self):
        self.stub('ps', 'exit 1')
        self.set_images(image(1, '18.2'), image(2, '18.5'))
        result = self.run_script()
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.calls.exists())

    def test_idle_xcode_data_cleanup_and_creation_time_rule(self):
        archives = self.home / 'Library/Developer/Xcode/Archives/2026-01-01'
        archive = archives / 'old.xcarchive'
        archive.mkdir(parents=True)
        (archive / 'data').write_text('old build')
        device = self.home / 'Library/Developer/Xcode/iOS DeviceSupport/old'
        device.mkdir(parents=True)
        (device / 'data').write_text('old symbols')
        os.utime(device, (time.time() - 20 * 86400,) * 2)
        self.stub('stat', '''if [[ $2 == %B && $4 == *.xcarchive ]]; then
printf '%s\\n' "$(( $(date +%s) - 20 * 86400 ))"
else /usr/bin/stat "$@"; fi''')
        result = self.run_script()
        self.assertEqual(result.returncode, 0, result.stderr + result.stdout)
        self.assertFalse(archive.exists() or device.exists())
        self.assertIn('removed: 2, failed: 0', result.stdout)

    def test_runtime_policy_per_platform_major_and_age(self):
        self.set_images(image(1, '18.2'), image(2, '18.10'), image(3, '27.0'),
                        image(4, '18.1', platform='appletvsimulator'),
                        image(5, '26.5', lastUsedAt='2026-09-01T00:00:00Z'))
        now = datetime.datetime(2026, 11, 24, tzinfo=datetime.timezone.utc).timestamp()
        result = self.planner(now)
        self.assertEqual(result.returncode, 0, result.stderr)
        rows = [line.split('\t') for line in result.stdout.splitlines()]
        self.assertEqual([row[0] for row in rows], ['delete', 'keep', 'keep', 'keep', 'delete'])

    def test_runtime_30_day_boundary_and_unknown_usage(self):
        now = 1800000000
        boundary = datetime.datetime.fromtimestamp(now - 30 * 86400, datetime.timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')
        self.set_images(image(1, '18.5', lastUsedAt=boundary), image(2, '27.0'))
        result = self.planner(now)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn('delete\t', result.stdout)

    def test_booted_or_unknown_device_protects_all_runtimes(self):
        self.set_images(image(1, '18.2'), image(2, '18.5'))
        for state in ('Booted', 'Booting', 'Unknown'):
            self.devices.write_text(json.dumps({'devices': {'runtime': [{'state': state}]}}))
            result = self.planner()
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertNotIn('delete\t', result.stdout)

    def test_invalid_runtime_schema_and_dates(self):
        for data in ([], {'error': 'unknown'}, {image(1, '18.2')['identifier']: image(1, '18.2', lastUsedAt='garbage')}):
            self.images.write_text(json.dumps(data))
            self.assertNotEqual(self.planner().returncode, 0)

    def test_installing_runtime_defers_other_runtime_deletion(self):
        installing = image(3, '27.0')
        installing['state'] = 'Installing'
        self.set_images(image(1, '18.2'), image(2, '18.5'), installing)
        result = self.planner()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn('delete\t', result.stdout)

    def test_non_deletable_and_newer_build(self):
        pinned = image(1, '18.2')
        pinned['deletable'] = False
        newer = image(3, '18.5')
        newer['build'] = '24A124'
        self.set_images(pinned, image(2, '18.5'), newer)
        result = self.planner()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual([line.split('\t')[0] for line in result.stdout.splitlines()], ['keep', 'delete', 'keep'])

    def test_runtime_real_delete_and_verification(self):
        old, new = image(1, '18.2'), image(2, '18.5')
        self.set_images(old, new)
        result = self.run_script('--dry-run')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(self.calls.exists())
        result = self.run_script()
        self.assertEqual(result.returncode, 0, result.stderr + result.stdout)
        self.assertEqual(list(json.loads(self.images.read_text())), [new['identifier']])
        self.assertIn('removed: 1, failed: 0', result.stdout)

    def test_runtime_query_failure_does_not_delete(self):
        self.stub('xcrun', 'exit 1')
        result = self.run_script()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('Cannot list simulator runtime images', result.stdout)

    def test_runtime_delete_success_without_removal_is_error(self):
        self.set_images(image(1, '18.2'), image(2, '18.5'))
        self.stub('xcrun', '''case "$*" in
'simctl runtime list -j') cat "$TEST_IMAGES" ;;
'simctl list devices -j') cat "$TEST_DEVICES" ;;
'simctl runtime delete '*) exit 0 ;;
*) exit 99 ;; esac''')
        result = self.run_script()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('Runtime deletion is incomplete or unverifiable', result.stdout)

    def test_runtime_rechecks_devices_before_removal(self):
        self.set_images(image(1, '18.2'), image(2, '18.5'))
        self.stub('osascript', '''/usr/bin/osascript "$@"
printf '%s' '{"devices":{"runtime":[{"state":"Booted"}]}}' > "$TEST_DEVICES"''')
        result = self.run_script()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(self.calls.exists())
        self.assertIn('Runtime eligibility changed', result.stdout)

    def test_symlink_entrypoint_finds_bundled_planner(self):
        link = self.root / 'cleanup-macos'
        link.symlink_to(SCRIPT)
        result = subprocess.run(['/bin/bash', str(link), '--dry-run', '--no-log'], env=self.env,
                                text=True, capture_output=True, timeout=30)
        self.assertEqual(result.returncode, 0, result.stderr)


if __name__ == '__main__':
    unittest.main()
