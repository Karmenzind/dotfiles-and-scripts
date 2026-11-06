import os, pathlib, shutil, subprocess, tempfile, unittest, time
REPO = pathlib.Path(__file__).resolve().parents[2]

class SessionTests(unittest.TestCase):

    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = pathlib.Path(self.tmp.name)
        self.bin = self.root / 'bin'
        self.bin.mkdir()
        self.home = self.root / 'home'
        self.home.mkdir()
        self.log = self.root / 'calls'
        self.env = {**os.environ, 'HOME': str(self.home), 'PATH': str(self.bin), 'TEST_LOG': str(self.log), 'XDG_RUNTIME_DIR': str(self.root), 'XDG_CACHE_HOME': str(self.root / 'cache'), 'POWER_SUPPLY_DIR': str(self.root / 'supplies'), 'POLKIT_AGENT': str(self.bin / 'polkit-agent')}
        for name in ['SWAYSOCK', 'WAYLAND_DISPLAY', 'ENABLE_ONEKO', 'WALLPAPER_DIR', 'WALLPAPER_PNG']:
            self.env.pop(name, None)
        for name in ['find', 'shuf', 'dirname', 'readlink', 'bash', 'mkdir', 'sort', 'cut', 'flock', 'sleep', 'basename', 'python3']:
            (self.bin / name).symlink_to(shutil.which(name))

    def tearDown(self):
        self.tmp.cleanup()

    def stub(self, name, body='exit 0'):
        p = self.bin / name
        p.write_text('#!/bin/bash\nprintf -v arguments \' <%s>\' "$@"\nprintf \'%s%s\\n\' "' + name + '" "$arguments" >> "$TEST_LOG"\n' + body + '\n')
        p.chmod(493)

    def run_script(self, path):
        result = subprocess.run(['/bin/bash', str(REPO / path)], env=self.env, text=True, capture_output=True)
        time.sleep(0.15)
        return result

    def calls(self):
        return self.log.read_text().splitlines() if self.log.exists() else []

    def test_lock_missing_empty_and_spaces(self):
        self.stub('i3lock')
        p = self.home / 'Pictures/LOCKSCREENS'
        r = self.run_script('home_k/.config/i3/lock.sh')
        self.assertEqual(r.returncode, 0)
        self.assertIn('i3lock <-c> <000000>', self.calls())
        p.mkdir(parents=True)
        self.log.unlink()
        self.run_script('home_k/.config/i3/lock.sh')
        self.assertEqual(self.calls(), ['i3lock <-c> <000000>'])
        (p / 'a b.png').touch()
        self.log.unlink()
        self.run_script('home_k/.config/i3/lock.sh')
        self.assertEqual(self.calls(), [f'i3lock <-t> <-i> <{p}/a b.png>'])

    def test_lock_invalid_image_falls_back(self):
        self.stub('i3lock', '[[ $1 == -c ]]')
        p = self.home / 'Pictures'
        p.mkdir()
        (p / 'LOCKSCREEN.png').touch()
        r = self.run_script('home_k/.config/i3/lock.sh')
        self.assertEqual(r.returncode, 0)
        self.assertEqual(len(self.calls()), 2)
        self.assertEqual(self.calls()[-1], 'i3lock <-c> <000000>')

    def test_wayland_lock_flags(self):
        self.stub('swaylock')
        self.env.update(SWAYSOCK='test', WAYLAND_DISPLAY='wayland-1')
        self.assertEqual(self.run_script('home_k/.config/i3/lock.sh').returncode, 0)
        self.assertEqual(self.calls(), ['swaylock <-c> <000000>'])

    def test_oneko_switch(self):
        self.stub('oneko')
        self.stub('pgrep', 'exit 1')
        for value in [None, '0', '1']:
            if self.log.exists():
                self.log.unlink()
            if value is None:
                self.env.pop('ENABLE_ONEKO', None)
            else:
                self.env['ENABLE_ONEKO'] = value
            self.assertEqual(self.run_script('home_k/.config/i3/run_oneko.sh').returncode, 0)
            self.assertEqual(sum((x.startswith('oneko ') for x in self.calls())), 2 if value == '1' else 0)

    def test_three_monitors_and_battery_types(self):
        self.stub('pgrep', 'exit 1')
        self.stub('pkill', 'exit 1')
        self.stub('polybar', 'if [[ $1 == --list-monitors ]]; then\nprintf \'right: 1920x1080+4480+0\\nleft: 2560x1440+0+0\\nmiddle: 1920x1080+2560+0\\n\'\nelse\nprintf \'ENV %s %s %s\\n\' "$MONITOR" "$POLY_BATTERY" "$POLY_BATTERY_ADAPTER" >> "$TEST_LOG"\nfi')
        for name, kind in [('AAA', 'Battery'), ('ZZZ', 'Mains'), ('USB', 'USB')]:
            p = self.root / 'supplies' / name
            p.mkdir(parents=True)
            (p / 'type').write_text(kind + '\n')
        self.assertEqual(self.run_script('home_k/.config/polybar/launch.sh').returncode, 0)
        for m in ['left', 'middle', 'right']:
            self.assertIn(f'ENV {m} AAA ZZZ', self.calls())
        for bar in ['trileft', 'tricenter', 'triright']:
            self.assertTrue(any((f'<{bar}>' in x for x in self.calls())))

    def test_wallpaper_single_symlink_spaces(self):
        self.stub('feh')
        self.stub('notify-send')
        target = self.root / 'real pictures'
        target.mkdir()
        (target / 'a b.png').touch()
        p = self.home / 'Pictures'
        p.mkdir()
        (p / 'LOCKSCREENS').symlink_to(target)
        for _ in range(2):
            self.assertEqual(self.run_script('home_k/.config/i3/change_background.sh').returncode, 0)
        self.assertEqual(sum((x.startswith('feh ') for x in self.calls())), 2)

    def test_startup_existing_terminal_and_order(self):
        self.stub('pgrep', 'exit 1')
        self.stub('pkill', 'exit 1')
        self.stub('i3-msg', 'if [[ $1 == -t ]]; then printf \'%s\\n\' \'{"floating_nodes":[{"window_properties":{"title":"my-init-terminal"}}]}\'; fi')
        self.stub('polybar', "[[ $1 != --list-monitors ]] || printf 'test: 1920x1080+0+0\\n' ")
        self.stub('xautolock')
        self.stub('feh')
        p = self.home / '.screenlayout'
        p.mkdir()
        (p / 'default.sh').write_text('printf "LAYOUT\\n" >> "$TEST_LOG"\n')
        self.assertEqual(self.run_script('home_k/.config/i3/post_start.sh').returncode, 0)
        calls = self.calls()
        self.assertLess(calls.index('LAYOUT'), next((i for i, x in enumerate(calls) if x == 'polybar <--list-monitors>')))
        self.assertFalse(any((x.startswith('i3-msg <exec') for x in calls)))
        self.assertTrue(any(('lock.sh' in x for x in calls if x.startswith('xautolock'))))

    def test_sway_keeps_automount_without_x11_services(self):
        self.env.update(SWAYSOCK='test', WAYLAND_DISPLAY='wayland-1')
        self.stub('pgrep', 'exit 1')
        self.stub('udiskie')
        self.stub('xautolock')
        self.stub('polybar')
        self.assertEqual(self.run_script('home_k/.config/i3/post_start.sh').returncode, 0)
        self.assertTrue(any((x.startswith('udiskie ') for x in self.calls())))
        self.assertFalse(any((x.startswith(('xautolock ', 'polybar ')) for x in self.calls())))
if __name__ == '__main__':
    unittest.main(verbosity=2)
