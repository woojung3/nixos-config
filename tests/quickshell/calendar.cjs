const {assert, loadScript} = require('./testlib.cjs');
const calendar = loadScript('CalendarMath.js');
let grids = 0;
for (const timezone of ['Asia/Seoul', 'America/New_York', 'Europe/Berlin']) {
  process.env.TZ = timezone;
  for (const year of [1900, 2000, 2024, 2026, 2100]) {
    for (let month = 0; month < 12; month++) {
      for (let firstDay = 0; firstDay < 7; firstDay++) {
        const cells = calendar.monthCells(year, month, firstDay);
        assert.equal(cells.length, 42);
        const first = cells[0];
        assert.equal(new Date(first.year, first.month, first.day, 12).getDay(), firstDay);
        assert.equal(cells.filter(c => c.inMonth).length, new Date(year, month + 1, 0, 12).getDate());
        cells.forEach((cell, index) => {
          const expected = new Date(first.year, first.month, first.day + index, 12);
          assert.equal(cell.year, expected.getFullYear());
          assert.equal(cell.month, expected.getMonth());
          assert.equal(cell.day, expected.getDate());
          assert.equal(cell.inMonth, cell.year === year && cell.month === month);
        });
        grids++;
      }
    }
  }
}
for (const [year, month, delta, expectedYear, expectedMonth] of [
  [2026, 11, 1, 2027, 0], [2026, 0, -1, 2025, 11],
  [2024, 1, 1, 2024, 2], [2026, 5, 0, 2026, 5]
]) {
  const next = calendar.shiftMonth(year, month, delta);
  assert.equal(next.year, expectedYear);
  assert.equal(next.month, expectedMonth);
}
console.log(`PASS: ${grids} calendar grids (leap years, DST, week starts) and month/year navigation`);
