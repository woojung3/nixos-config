const {assert, loadScript} = require('./testlib.cjs');
const info = loadScript('BatteryInfo.js');
for (const [value, expected] of [[0, '0%'], [0.456, '46%'], [1, '100%'], [-1, '0%'], [2, '100%'], [NaN, '—']])
  assert.equal(info.percentage(value), expected);
for (const [value, expected] of [[0, ''], [-1, ''], [NaN, ''], [Infinity, ''], [30, '<1 min'], [60, '1 min'], [3599, '1 h'], [5400, '1 h 30 min']])
  assert.equal(info.duration(value), expected);
assert.equal(info.detail(1, false, 0, 5400), 'About 1 h 30 min until full');
assert.equal(info.detail(2, true, 3600, 0), 'About 1 h remaining');
assert.equal(info.detail(1, false, 0, 0), 'Estimating time until full…');
assert.equal(info.detail(2, true, 0, 0), 'Estimating remaining time…');
assert.equal(info.detail(4, false, 0, 0), 'Connected to power');
assert.equal(info.stateLabel(4), 'Fully charged');
assert.equal(info.stateLabel(5), 'Charging paused');
assert.equal(info.stateLabel(99), 'Status unavailable');
console.log('PASS: battery percentages, durations, charging/discharging, unknown estimates and states');
