import time
import sys
import dbus
import argparse
#  import threading as thread
import _thread as thread

"""Receiver related functionality."""
import dbus.service
import dbus.glib
from gi.repository import GObject
import dbus
import os

parser = argparse.ArgumentParser()
parser.add_argument(
    '-t',
    '--trunclen',
    type=int,
    metavar='trunclen'
)
parser.add_argument(
    '-f',
    '--format',
    type=str,
    metavar='custom format',
    dest='custom_format'
)
args = parser.parse_args()

# Default parameters
output = '{artist} : {song}'
trunclen = 15

# parameters can be overwritten by args
if args.trunclen is not None:
    trunclen = args.trunclen
if args.custom_format is not None:
    output = args.custom_format
mydir = os.path.dirname(__file__)
if mydir != '':
    os.chdir(mydir) # change the current working directory

session_bus = dbus.SessionBus()
def echo():
    try:
        cloud_music_bus = session_bus.get_object(
            'org.mpris.MediaPlayer2.netease-cloud-music',
            '/org/mpris/MediaPlayer2'
        )

        cloud_music_properties = dbus.Interface(
            cloud_music_bus,
            'org.freedesktop.DBus.Properties'
        )

        metadata = cloud_music_properties.Get('org.mpris.MediaPlayer2.Player', 'Metadata')

        playback_status = str(cloud_music_properties.Get('org.mpris.MediaPlayer2.Player', 'PlaybackStatus'))
        #  volume = float(cloud_music_properties.Get('org.mpris.MediaPlayer2.Player', 'Volume'))
        if 'mpris:length' in metadata:
            length = float(metadata['mpris:length'])
            position = float(cloud_music_properties.Get('org.mpris.MediaPlayer2.Player', 'Position'))
        else:
            length = 1.
            position = 0.
        percent = position / length

        if 'xesam:artist' in metadata:
            artist = metadata['xesam:artist'][0]
            if len(artist) > trunclen:
                artist = artist[0:trunclen]
                artist += '...' 
                if ('(' in artist) and (')' not in artist):
                    artist += ')'

            song = metadata['xesam:title']

            if len(song) > trunclen:
                song = song[0:trunclen]
                song += '...' 
                if ('(' in song) and (')' not in song):
                    song += ')'

            output = '{artist} : {song}'
            if sys.version_info.major == 3:
                output = output.format(artist=artist, song=song)
            else:
                output = output.format(artist=artist, song=song).encode('UTF-8')
            percent = int((len(output) + 1) * percent)
            output = '%{o#EA2202}%{+o}' + output[: percent] + '%{-o}' + output[percent:]
        else:
            output = '网易云正在打开...'
        #  output = '%{F#EA2202} %{F-}' + output
        output = '📻 ' + output
        output += '  '

        output += '%{A1:dbus-send --print-reply --dest=org.mpris.MediaPlayer2.netease-cloud-music /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Previous:}    %{A}'
        if playback_status == 'Playing':
            output += '%{A1:dbus-send --print-reply --dest=org.mpris.MediaPlayer2.netease-cloud-music /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause:}    %{A}'
        else:
            output += '%{A1:dbus-send --print-reply --dest=org.mpris.MediaPlayer2.netease-cloud-music /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause:}    %{A}'
        #  output += '%{A1:dbus-send --print-reply --dest=org.mpris.MediaPlayer2.netease-cloud-music /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Next:}    %{A}'
        output += '%{A1:dbus-send --print-reply --dest=org.mpris.MediaPlayer2.netease-cloud-music /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Next:}    %{A}'

        print(output, flush=True)
        #  print('%{o#EA2202}%{+o}%{F#EA2202} %{F-}' + output + '%{o-}')

    except Exception as e:
        if isinstance(e, dbus.exceptions.DBusException):
            print('%{A1:i3-msg workspace number 7 Netease; netease-cloud-music& :}📻 打开网易云音乐 %{A}', flush=True)
        else:
            print(e, flush=True)

def event_handler(*args, **kwargs):
    echo()

loop = GObject.MainLoop()

bus = dbus.SessionBus()
# bus = dbus.SystemBus()
bus_name = dbus.service.BusName('sub.domain.tld', bus=bus)

bus.add_signal_receiver(event_handler,
                        dbus_interface='org.freedesktop.DBus.Properties',
                        member_keyword='PropertiesChanged')

thread.start_new_thread(loop.run, tuple())

while True:
    echo()
    time.sleep(1)
