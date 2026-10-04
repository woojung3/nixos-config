function percentage(ratio) {
    if (!Number.isFinite(ratio)) return "—";
    return Math.round(Math.max(0, Math.min(1, ratio)) * 100) + "%";
}

function duration(seconds) {
    if (!Number.isFinite(seconds) || seconds <= 0) return "";
    if (seconds < 60) return "<1 min";
    var minutes = Math.round(seconds / 60);
    var hours = Math.floor(minutes / 60);
    minutes %= 60;
    return hours ? hours + " h" + (minutes ? " " + minutes + " min" : "") : minutes + " min";
}

function stateLabel(state) {
    switch (state) {
    case 1: return "Charging";
    case 2: return "On battery";
    case 3: return "Battery empty";
    case 4: return "Fully charged";
    case 5: return "Charging paused";
    case 6: return "Discharging paused";
    default: return "Status unavailable";
    }
}

function detail(state, onBattery, timeToEmpty, timeToFull) {
    if (state === 1) {
        var full = duration(timeToFull);
        return full ? "About " + full + " until full" : "Estimating time until full…";
    }
    if (state === 2) {
        var empty = duration(timeToEmpty);
        return empty ? "About " + empty + " remaining" : "Estimating remaining time…";
    }
    return onBattery ? "Battery power" : "Connected to power";
}
