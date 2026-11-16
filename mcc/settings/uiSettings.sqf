if (count (allMissionObjects "MCC_Module_inGameUI") == 0) then {
    //View Distance
    [
        "MCC_Settings_ViewDistance",
        "SLIDER",
        [localize "STR_UI_VIEWDISTANCE", "Your view distance in meters. 0 = keep your own game setting (default)"],
        "MCC User Interface",
        [0, 15000, 0, 0],
        false,
        {
            params ["_value"];
            //0 = leave the player's own video setting alone
            if (_value > 0) then {setViewDistance _value};
        }
    ] call CBA_fnc_addSetting;

    //Grass
    [
        "MCC_Settings_terrainDetail",
        "LIST",
        [localize "STR_UI_GRASSDETAIL", "Terrain and grass detail. Keep game setting (default) never changes your own video settings"],
        "MCC User Interface",
        [[0, 50, 25, 12.5, 6.25, 3.125], ["Keep game setting", "Lowest (no grass)", "Low", "Standard", "High", "Ultra"], 0],
        false,
        {
            params ["_value"];
            //setTerrainGrid also sets terrain mesh detail: only when the player or mission maker picks a level
            if (_value > 0) then {setTerrainGrid _value};
        }
    ] call CBA_fnc_addSetting;

    //MCC Action in mouse wheel
    [
        "MCC_showActionKey",
        "CHECKBOX",
        ["Action Menu","Show MCC action in mouse wheel actions"],
        "MCC User Interface",
        true,
        true
    ] call CBA_fnc_addSetting;

    //3D person view
    [
        "MCC_Settings_forceCamera",
        "LIST",
        ["Allow 3rd Person","Force first person camera"],
        "MCC User Interface",
        [[0,1,2,3], ["Never","In all vehicles","In aircrafts only","Always"], 3],
        true,
        {
            params ["_value"];
            [_value] call MCC_fnc_forceCamera;
        }
    ] call CBA_fnc_addSetting;

    //Compass
    [
        "MCC_Settings_compassEnabled",
        "LIST",
        "Interactive Compass HUD",
        ["MCC User Interface","Compass"],
        [[0,1,2],["Only Compass","Show group's units","Disabled"],2],
        true,
        {
            params ["_value"];
            switch (_value) do
            {
                case 2:
                {
                    missionNamespace setVariable ["MCC_initCompassHUD",false];
                    (["MCC_hud"] call BIS_fnc_rscLayer) cutText ["","Plain"];
                    ["MCC_fnc_compHudEVH", "onEachFrame"] call BIS_fnc_removeStackedEventHandler;
                };

                default
                {
                    (_value == 1) spawn MCC_fnc_initCompassHUD;
                };
            };
        }
    ] call CBA_fnc_addSetting;

    //Group Markers
    [
        "MCC_groupMarkers",
        "CHECKBOX",
        ["Group Markers","Group markers show on map"],
        ["MCC User Interface","Map"],
        false,
        true
    ] call CBA_fnc_addSetting;

    //Group Markers
    [
        "MCC_indevidualMarkers",
        "CHECKBOX",
        ["Unit Markers","Unit markers show on map"],
        ["MCC User Interface","Map"],
        false,
        true
    ] call CBA_fnc_addSetting;

    //name Tags
    [
        "MCC_nameTags",
        "CHECKBOX",
        ["Name Tags","Show nearby units names"],
        ["MCC User Interface","Name Tags"],
        false,
        false
    ] call CBA_fnc_addSetting;

    //name Tags Direct
    [
        "MCC_NameTags_direct",
        "CHECKBOX",
        ["Name Tags only when pointing","Show nearby units names only when pointing"],
        ["MCC User Interface","Name Tags"],
        false,
        false
    ] call CBA_fnc_addSetting;

    //Move to server
    //suppression
    [
        "MCC_suppressionOn",
        "CHECKBOX",
        "Suppression Effects",
        ["MCC User Interface","suppression"],
        false,
        true,
        {
            params ["_value"];

            if (_value) then {
                if !(missionNamespace getVariable ["MCC_initSupression",false]) then {[] spawn MCC_fnc_supressionInit};
            } else {
                missionNamespace setVariable ["MCC_initSupression",false];
                ["MCC_initSupression", "onEachFrame"] call BIS_fnc_removeStackedEventHandler;
            };
        }
    ] call CBA_fnc_addSetting;

    //MCC_hitRadar
    [
        "MCC_hitRadar",
        "LIST",
        "Hit direction Effects",
        ["MCC User Interface","suppression"],
        [[0,1,2],["Realistics","Arcade","Off"],0],
        true,
        {
            params ["_value"];

            if (_value != 2) then {
                if !(missionNamespace getVariable ["MCC_initSupression",false]) then {[] spawn MCC_fnc_supressionInit};
            } else {
                missionNamespace setVariable ["MCC_initSupression",false];
                ["MCC_initSupression", "onEachFrame"] call BIS_fnc_removeStackedEventHandler;
            };
        }
    ] call CBA_fnc_addSetting;

    //MCC_hitRadar
    [
        "MCC_UIModuleTickets",
        "CHECKBOX",
        "PvP Interface",
        "MCC User Interface",
        false,
        true,
        {
            params ["_value"];

            if (_value) then {
                [] spawn MCC_fnc_PvPInterface
            };
        }
    ] call CBA_fnc_addSetting;
};