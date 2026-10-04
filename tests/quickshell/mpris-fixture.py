"""Silent MPRIS fixture for manual integration tests (requires dbus-next).

Run with a temporary log path. Exports two players; no audio is played.
Ctrl+C removes both players. Commands received are recorded as JSON lines.
"""
import asyncio
import json
import pathlib
import sys
import tempfile

from dbus_next import Variant
from dbus_next.aio import MessageBus
from dbus_next.constants import PropertyAccess
from dbus_next.service import ServiceInterface, dbus_property, method


class Root(ServiceInterface):
    def __init__(self, identity):
        super().__init__('org.mpris.MediaPlayer2')
        self.identity = identity

    @dbus_property(access=PropertyAccess.READ)
    def Identity(self) -> 's': return self.identity
    @dbus_property(access=PropertyAccess.READ)
    def DesktopEntry(self) -> 's': return 'bloom-fixture'
    @dbus_property(access=PropertyAccess.READ)
    def CanQuit(self) -> 'b': return False
    @dbus_property(access=PropertyAccess.READ)
    def CanRaise(self) -> 'b': return False
    @dbus_property(access=PropertyAccess.READ)
    def HasTrackList(self) -> 'b': return False
    @dbus_property(access=PropertyAccess.READ)
    def SupportedUriSchemes(self) -> 'as': return ['file']
    @dbus_property(access=PropertyAccess.READ)
    def SupportedMimeTypes(self) -> 'as': return ['audio/ogg']


class Player(ServiceInterface):
    def __init__(self, identity, art, log, controllable=True):
        super().__init__('org.mpris.MediaPlayer2.Player')
        self.identity, self.art, self.log = identity, art, log
        self.controllable = controllable
        self.status = 'Playing' if controllable else 'Paused'
        self.track = 1

    def record(self, action):
        with open(self.log, 'a') as output:
            output.write(json.dumps([self.identity, action]) + '\n')

    @dbus_property(access=PropertyAccess.READ)
    def PlaybackStatus(self) -> 's': return self.status
    @dbus_property(access=PropertyAccess.READ)
    def Metadata(self) -> 'a{sv}':
        return {
            'mpris:trackid': Variant('o', f'/track/{self.track}'),
            'mpris:length': Variant('x', 180000000),
            'xesam:title': Variant('s', f'Bloom test track {self.track}'),
            'xesam:artist': Variant('as', ['Bloom artist']),
            'xesam:album': Variant('s', 'Bloom album'),
            'mpris:artUrl': Variant('s', self.art),
        }
    @dbus_property(access=PropertyAccess.READ)
    def Position(self) -> 'x': return 0
    @dbus_property(access=PropertyAccess.READ)
    def Rate(self) -> 'd': return 1.0
    @dbus_property(access=PropertyAccess.READ)
    def MinimumRate(self) -> 'd': return 1.0
    @dbus_property(access=PropertyAccess.READ)
    def MaximumRate(self) -> 'd': return 1.0
    @dbus_property(access=PropertyAccess.READ)
    def CanControl(self) -> 'b': return True
    @dbus_property(access=PropertyAccess.READ)
    def CanPlay(self) -> 'b': return True
    @dbus_property(access=PropertyAccess.READ)
    def CanPause(self) -> 'b': return True
    @dbus_property(access=PropertyAccess.READ)
    def CanGoNext(self) -> 'b': return self.controllable
    @dbus_property(access=PropertyAccess.READ)
    def CanGoPrevious(self) -> 'b': return self.controllable
    @dbus_property(access=PropertyAccess.READ)
    def CanSeek(self) -> 'b': return False

    @method()
    def PlayPause(self):
        self.record('PlayPause')
        self.status = 'Paused' if self.status == 'Playing' else 'Playing'
        self.emit_properties_changed({'PlaybackStatus': self.status})

    @method()
    def Next(self):
        self.record('Next')
        self.track += 1
        self.emit_properties_changed({'Metadata': self.Metadata})

    @method()
    def Previous(self):
        self.record('Previous')
        self.track = max(1, self.track - 1)
        self.emit_properties_changed({'Metadata': self.Metadata})

    @method()
    def Play(self):
        self.record('Play')
        self.status = 'Playing'
        self.emit_properties_changed({'PlaybackStatus': self.status})

    @method()
    def Pause(self):
        self.record('Pause')
        self.status = 'Paused'
        self.emit_properties_changed({'PlaybackStatus': self.status})


async def main():
    with tempfile.TemporaryDirectory(prefix='bloom-mpris-') as directory:
        art = pathlib.Path(directory) / 'cover.svg'
        art.write_text('<svg xmlns="http://www.w3.org/2000/svg" width="152" height="152">'
                       '<rect width="152" height="152" fill="#db8e9d"/>'
                       '<circle cx="76" cy="76" r="46" fill="#171b1b"/>'
                       '<circle cx="76" cy="76" r="10" fill="#db8e9d"/></svg>')
        buses = []
        for name, has_art in [('BloomFixture', True), ('BloomFixtureOther', False)]:
            bus = await MessageBus().connect()
            bus.export('/org/mpris/MediaPlayer2', Root(name))
            bus.export('/org/mpris/MediaPlayer2', Player(name, art.as_uri() if has_art else '', sys.argv[1], has_art))
            await bus.request_name('org.mpris.MediaPlayer2.' + name)
            buses.append(bus)
        print('READY', flush=True)
        try:
            await asyncio.Future()
        finally:
            for bus in buses:
                bus.disconnect()


if __name__ == '__main__':
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        pass
