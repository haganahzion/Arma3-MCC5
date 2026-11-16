// F3 - Near Player Function
// Credits: Please see the F3 online manual (http://www.ferstaberinde.com/f3/en/)
// ====================================================================================
// In:  [position, distance]
// Out: true when a player is closer than distance to position
// On the server the player list comes from GAIA_PLAYER_LIST (refreshed every
// second by the GAIA per-frame handler).
// ====================================================================================

params ["_pos", "_distance"];

private _players = [];

if (isServer && {!isNil "GAIA_PLAYER_LIST_TIME"} && {(time - GAIA_PLAYER_LIST_TIME) < 2}) then {
	_players = GAIA_PLAYER_LIST;
} else {
	// Players without headless clients (the list may also hold Zeus camera positions on the server)
	_players = allPlayers - (entities "HeadlessClient_F");
	if (_players isEqualTo [] && {hasInterface}) then {_players = [player]};
};

// Check whether a player is in the given distance - return true if yes
(_players findIf {(_x distance _pos) < _distance}) > -1
