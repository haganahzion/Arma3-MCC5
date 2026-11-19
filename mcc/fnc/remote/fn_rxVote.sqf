/*
	MCC_fnc_rxVote  (server)
	Counts a "yes" vote, or shares the current count with everyone. Only the MCC vote variables can be used,
	and each player counts once per vote.
	Params:
		0: STRING - the vote variable ("CP_mutiny")
		1: STRING - "yes" to add this player's vote, "share" to send the count to every machine
	Example:
		["CP_mutiny", "yes"] remoteExec ["MCC_fnc_rxVote", 2];
*/
#define MCC_VOTE_VARS ["CP_mutiny"]

params [["_name", "", [""]], ["_mode", "", [""]]];

if (!isServer || {!(_name in MCC_VOTE_VARS)}) exitWith {};

private _sender = if (isRemoteExecuted) then {remoteExecutedOwner} else {clientOwner};
private _votersKey = "MCC_voters_" + _name;

switch (_mode) do {
	case "start": {
		localNamespace setVariable [_votersKey, []];
		missionNamespace setVariable [_name, 0];
		publicVariable _name;
	};
	case "yes": {
		private _voters = localNamespace getVariable [_votersKey, []];
		if (_sender in _voters) exitWith {};
		_voters pushBack _sender;
		localNamespace setVariable [_votersKey, _voters];
		missionNamespace setVariable [_name, (missionNamespace getVariable [_name, 0]) + 1];
	};
	case "share": {
		publicVariable _name;
	};
};
