/*
	MCC_fnc_accessRights  (Access Rights module, server)
	Sets who may use MCC: the UIDs typed in the module, plus the players in the units synced to it.
	The server keeps the lists in localNamespace (read by MCC_fnc_isAuthorizedOwner) and shares
	MCC_allowedPlayers with the clients for their menus.
	Params:
		0: OBJECT - the module logic
*/
params [["_logic", objNull, [objNull]]];

if (!isServer || {isRemoteExecuted} || {isNull _logic}) exitWith {};

private _names = [_logic getVariable ["names", "[]"]] call MCC_fnc_arrayFromString;
_names = (_names apply {if (_x isEqualType 0) then {str _x} else {_x}}) select {_x isEqualType "" && {_x != ""}};
// The module limits access, so the default "all" from elsewhere is never carried over.
_names append ((localNamespace getVariable ["MCC_allowedPlayers_server", missionNamespace getVariable ["MCC_allowedPlayers", []]]) - ["all"]);

private _allowAdmin = _logic getVariable ["allowAdmin", true];
if !(_allowAdmin isEqualType true) then {_allowAdmin = true};

localNamespace setVariable ["MCC_accessNames", (localNamespace getVariable ["MCC_accessNames", []]) + _names];
localNamespace setVariable ["MCC_accessUnits", (localNamespace getVariable ["MCC_accessUnits", []]) + (synchronizedObjects _logic)];
localNamespace setVariable ["MCC_accessAdmin", _allowAdmin];

_logic setPos [1000, 10, 0];

// One loop for all modules: keep the shared list up to date with the players in the synced units.
if (localNamespace getVariable ["MCC_accessLoop", false]) exitWith {};
localNamespace setVariable ["MCC_accessLoop", true];
[] spawn {
	private _first = true;
	while {true} do {
		private _list = (localNamespace getVariable ["MCC_accessNames", []]) + (((localNamespace getVariable ["MCC_accessUnits", []]) select {isPlayer _x}) apply {getPlayerUID _x});
		_list = _list arrayIntersect _list;
		private _admin = localNamespace getVariable ["MCC_accessAdmin", true];
		if (_first || {!(_list isEqualTo (localNamespace getVariable ["MCC_allowedPlayers_server", []]))
			|| {!(_admin isEqualTo (localNamespace getVariable ["MCC_allowAdmin_server", true]))}}) then {
			_first = false;
			[_list, _admin] call MCC_fnc_setAllowedPlayers;
		};
		sleep 10;
	};
};
