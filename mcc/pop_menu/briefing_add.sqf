disableSerialization;
private ["_type","_string"];
_string = _this select 0;
_type = _this select 1;

private _title = ["Situation","Enemy Forces","Friendly Forces","Mission","Special Tasks","Fire Support"] param [_type, ""];
if (_title == "") exitWith {};
player createDiaryRecord ["diary", [_title,_string]];

// MCC_sync is a list of diary entries for players who join later (see MCC_fnc_sync).
if !((missionNamespace getVariable ["MCC_sync", []]) isEqualType []) then {MCC_sync = []};
MCC_sync pushBack [_title, _string];
publicVariable "MCC_sync"; 



 
		