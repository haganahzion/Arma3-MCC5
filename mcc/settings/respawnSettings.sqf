// ==================== Respawn ==========================================

//Save Gear
[
    "MCC_saveGearIndex",
    "CHECKBOX",
    ["Save Gear","Players will respawn with the gear they had when they died"],
    ["MCC Respawn","Respawn"],
    false,
    true,
    {
        params ["_value"];
        //A Mission Settings module decides when one is placed
        if ((allMissionObjects "MCC_Module_settings") isEqualTo [] && {(allMissionObjects "MCC_Module_settingsCurator") isEqualTo []}) then {
            MCC_saveGear = _value;
        };
    }
] call CBA_fnc_addSetting;

//Delet players body
[
    "MCC_deletePlayersBody",
    "CHECKBOX",
    ["Delete players bodies","Automatically delete players bodies"],
    ["MCC Respawn","Respawn"],
    false,
    true
] call CBA_fnc_addSetting;


//Respawn menu
[
    "MCC_openRespawnMenu",
    "CHECKBOX",
    ["Respawn Menu","Custom MCC respawn menu"],
    ["MCC Respawn","Respawn"],
    true,
    true
] call CBA_fnc_addSetting;

//Respawn Cinematic
[
    "MCC_respawnCinematic",
    "CHECKBOX",
    "Respawn Cinematic",
    ["MCC Respawn","Respawn"],
    true,
    true
] call CBA_fnc_addSetting;

//Respawn on Leader
[
    "MCC_respawnOnGroupLeader",
    "CHECKBOX",
    ["Respawn On Leader","Allow player to select to respawn on team leader from the MCC respawn menu"],
    ["MCC Respawn","Respawn"],
    false,
    true
] call CBA_fnc_addSetting;

// ==================== Squad Switch ==========================================
[
    "MCC_squadSwitch",
    "CHECKBOX",
    ["Squad Switch","When you die you take over the nearest AI in your squad, or the nearest friendly AI if your squad is gone"],
    ["MCC Respawn","Squad Switch"],
    false,
    true
] call CBA_fnc_addSetting;

[
    "MCC_squadSwitchAvoidLeader",
    "CHECKBOX",
    ["Avoid Leadership Role","Squad Switch prefers soldiers who don't lead a group, and hands the lead to an AI when you would end up as leader"],
    ["MCC Respawn","Squad Switch"],
    false,
    true
] call CBA_fnc_addSetting;
