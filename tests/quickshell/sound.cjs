const {assert, loadScript} = require('./testlib.cjs');
const sound = loadScript('SoundLogic.js');
for (const [value, expected] of [[-1, 0], [0, 0], [1, 0.01], [68, 0.68], [100, 1], [150, 1], [NaN, 0]])
  assert.equal(sound.boundedVolume(value), expected);
const paused = {dbusName: 'paused', trackTitle: 'A track', isPlaying: false};
const playing = {dbusName: 'playing', trackTitle: 'Another track', isPlaying: true};
const empty = {dbusName: 'empty', trackTitle: '', isPlaying: false};
assert.equal(sound.mediaPlayers([empty]).length, 0);
assert.equal(sound.mediaPlayers([paused, empty]).length, 1);
assert.equal(sound.choosePlayer([], ''), null);
assert.equal(sound.choosePlayer([paused, playing], ''), playing);
assert.equal(sound.choosePlayer([paused, playing], 'paused'), paused);
assert.equal(sound.choosePlayer([playing], 'paused'), playing);
assert.equal(sound.choosePlayer([paused], 'disconnected'), paused);
console.log('PASS: volume bounds, empty/paused players, automatic/manual selection and disconnect fallback');
