// Local noon avoids DST transitions around midnight. Let Date normalize
// month/year boundaries instead of adding fixed 24-hour millisecond intervals.
function monthCells(year, month, firstWeekday) {
    var first = new Date(year, month, 1, 12);
    var offset = (first.getDay() - firstWeekday + 7) % 7;
    var cells = [];
    for (var i = 0; i < 42; i++) {
        var date = new Date(year, month, 1 - offset + i, 12);
        cells.push({
            year: date.getFullYear(),
            month: date.getMonth(),
            day: date.getDate(),
            inMonth: date.getMonth() === month
        });
    }
    return cells;
}

function shiftMonth(year, month, delta) {
    var date = new Date(year, month + delta, 1, 12);
    return { year: date.getFullYear(), month: date.getMonth() };
}
