/*
	MCC_fnc_rxAddHoldAction
	Adds one of MCC's fixed hold actions to an object on every machine (JIP too). The action code is built
	here from an id, so no code travels over the network.
	Send it to the server: the server checks the sender (MCC_fnc_remoteTrusted) and passes it on to every
	machine. Machines only add the action when it came from the server.
	Params:
		0: OBJECT - object that gets the action
		1: STRING - action id: "shop" or "hostageUntie"
		2: ARRAY - action data
			"shop": [title, box, prices] (title STRING, box OBJECT, prices NUMBER)
			"hostageUntie": []
		3: BOOL - internal, true when sent on by the server (default false)
	Example:
		[_object, "shop", ["Open Shop", _box, 0.5]] remoteExec ["MCC_fnc_rxAddHoldAction", 2];
*/
#define MCC_SHOP_ICON	"\a3\ui_f\data\IGUI\Cfg\Actions\reammo_ca.paa"
#define MCC_UNTIE_ICON	"\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa"
#define MCC_HOLD_IDS	["shop", "hostageUntie"]

params [["_object", objNull, [objNull]], ["_id", "", [""]], ["_data", [], [[]]], ["_relayed", false, [false]]];

if (isNull _object || {!(_id in MCC_HOLD_IDS)}) exitWith {};

// Request: the server checks the sender and sends it to every machine.
if (!_relayed) exitWith {
	if (!isServer) exitWith {};
	if !(["MCC_fnc_rxAddHoldAction"] call MCC_fnc_remoteTrusted) exitWith {};
	[_object, _id, _data, true] remoteExec ["MCC_fnc_rxAddHoldAction", 0, _object];
};

// remoteExecutedOwner is 0 in single player and for calls from a headless client.
if (isRemoteExecuted && {!(remoteExecutedOwner in [0, 2])}) exitWith {
	diag_log format ["MCC network security: refused MCC_fnc_rxAddHoldAction from owner %1", remoteExecutedOwner];
};
if (!hasInterface) exitWith {};

switch (_id) do {
	case "shop": {
		_data params [["_title", "Open Shop", [""]], ["_box", objNull, [objNull]], ["_prices", 0.5, [0]]];
		if (isNull _box) exitWith {};
		[
			_object,
			_title,
			MCC_SHOP_ICON,
			MCC_SHOP_ICON,
			"(alive _target) && (_target distance _this < 5)",
			"(alive _target) && (_target distance _this < 5)",
			{},
			{},
			{(_this select 3) spawn MCC_fnc_mainBoxInit},
			{},
			[_box, _prices],
			1,
			100,
			false,
			false
		] call BIS_fnc_holdActionAdd;
	};

	case "hostageUntie": {
		[
			_object,
			format ["Untie %1", name _object],
			MCC_UNTIE_ICON,
			MCC_UNTIE_ICON,
			"(alive _target) && {!(_target getVariable ['MCC_hostageFreed', false])} && {(_target distance _this) < 5}",
			"(alive _target) && {!(_target getVariable ['MCC_hostageFreed', false])} && {(_target distance _this) < 5}",
			{
				[name _target, "Oh thank you, Please hurry up!"] remoteExec ["BIS_fnc_showSubtitle", _caller];
			},
			{},
			{
				// The flag hides the action for everyone, also for players who join later.
				_target setVariable ["MCC_hostageFreed", true, true];
				_null = [_target, player, 0, [0]] spawn MCC_fnc_s_hostage;
				[name _target, "Thank you!"] remoteExec ["BIS_fnc_showSubtitle", _caller];
			},
			{
				[name _target, "Why did you stopped?"] remoteExec ["BIS_fnc_showSubtitle", _caller];
			},
			[],
			3,
			0,
			true,
			false
		] call BIS_fnc_holdActionAdd;
	};
};
