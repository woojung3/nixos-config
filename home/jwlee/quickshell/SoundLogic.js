function boundedVolume(percent) {
    return Number.isFinite(percent) ? Math.max(0, Math.min(100, percent)) / 100 : 0;
}

function mediaPlayers(players) {
    // Keep paused tracks, but do not show empty players merely because an app
    // has registered an MPRIS service.
    return players.filter(p => p.isPlaying || p.trackTitle || p.trackArtist || p.trackAlbum || p.trackArtUrl);
}

function choosePlayer(players, chosenName) {
    return players.find(p => p.dbusName === chosenName)
        || players.find(p => p.isPlaying) || players[0] || null;
}
