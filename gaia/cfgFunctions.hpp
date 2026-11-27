class GAIA
{
    tag = "GAIA";

    class ambient
    {
        #ifdef MCCMODE
        file = "\mcc_sandbox_mod\gaia\functions\ambient";
        #else
        file = "gaia\functions\ambient";
        #endif

        class ambientCombat {};
        class ambientCombatServer {};
        class ambientCombatClient {};
        class getPlayers {};
        class isInMarker {};
        class getsideratio {};
        class SpawnGroup {};
        class ShowLocationOwner {};

    };


    class Core
    {
        #ifdef MCCMODE
        file = "\mcc_sandbox_mod\gaia\functions\core";
        #else
        file = "gaia\functions\core";
        #endif

        class breadcrumbAdd {};
        class breadcrumbNear {};
        class breadcrumbPrune {};
        class cacheRestoreTick {};
        class contactTick {};
        class dsSetup {};
        class getClassInfo {};
        class getGroups {};
        class groupMaintenance {};
        class groupReveal {};
        class groupSet {};
        class groupTick {};
        class hasLambsWaypoint {};
        class inZone {};
        class marchAI {};
        class perFrame {};
        class registerGroup {};
        class registrySweep {};
        class reportTargets {};
        class sideCycle {};
        class sideSuffix {};
        class unregisterGroup {};
    };

    class Cache
    {
        #ifdef MCCMODE
        file = "\mcc_sandbox_mod\gaia\functions\cache";
        #else
        file = "gaia\functions\cache";
        #endif

        class cache {};
        class cacheFar {};
        class cacheOriginalGroup {};
        class isNearPlayer {};
        class startGaiaCache {};
        class syncCachedGroup {};
        class uncache {};
        class uncacheFar {};
        class uncacheOriginalGroup {};
        class respawnKey {};
        class respawnSet {};
    };

    class General
    {
        #ifdef MCCMODE
        file = "\mcc_sandbox_mod\gaia\functions\general";
        #else
        file = "gaia\functions\general";
        #endif

        class getMarkerShape {};
        class getMarkerVertices {};
        class isInCircle {};
        class isInEllipse {};
        class isInRectangle {};
        class isPositionInMarker {};
        class isSamePosition {};
        class randomPositionInEllipseMarker {};
        class randomPositionInRectangleMarker {};
        class rotatePosition {};
        class startGaia {};
    };

    class Control
    {
        #ifdef MCCMODE
        file = "\mcc_sandbox_mod\gaia\functions\control";
        #else
        file = "gaia\functions\control";
        #endif

        class addAttackWaypoint {};
        class addWaypoint {};
        class analyzeForces {};
        class analyzeTargets {};
        class analyzeTerrain {};
        class calculateOptimalPosition {};
        class classifySide {};
        class fireFlare {};
        class generateBuildingPatrolWaypoints {};
        class generateWaypoints {};
        class getConflictAreaCost {};
        class getConflictAreas {};
        class getDistanceToClosestZone {};
        class getTurretWeapons {};
        class getUnitAssets {};
        class getUnitTypeAmounts {};
        class getUnitsClassification {};
        class getZoneIntendOfGroup {};
        class getZoneStatusBehavior {};
        class hasLineOfSight {};
        class isBlacklisted {};
        class isCleared {};
        class issueOrders {};
        class occupy {};
        class removeWaypoints {};

    };

    class Orders
    {
        #ifdef MCCMODE
        file = "\mcc_sandbox_mod\gaia\functions\control\orders";
        #else
        file = "gaia\functions\control\orders";
        #endif

        class doArtillery {};
        class doAttack {};
        class doAttackCar {};
        class doAttackHelicopter {};
        class doAttackInfantry {};
        class doAttackMotorizeInfantry {};
        class doAttackMotorizedRecon {};
        class doAttackRecon {};
        class doAttackShip {};
        class doAttackTank {};
        class doClear {};
        class doClearInfantry {};
        class doClearRecon {};
        class doFortify {};
        class doHide {};
        class doMortar {};
        class doOrganizeTransportation {};
        class doPark {};
        class doPatrol {};
        class doPatrolCar {};
        class doPatrolHelicopter {};
        class doPatrolInfantry {};
        class doPatrolMechanizedInfantry {};
        class doPatrolMotorizedInfantry {};
        class doPatrolRecon {};
        class doPatrolShip {};
        class doSupport {};
        class doTransportCar {};
        class doTransportHelicopter {};
        class doTransportTank {};
        class doWait {};
    };

    //Support requests, coordinated roles, unstick, headless client balancing
    class Support
    {
        #ifdef MCCMODE
        file = "\mcc_sandbox_mod\gaia\functions\support";
        #else
        file = "gaia\functions\support";
        #endif

        class airSupport {};
        class artyMayFire {};
        class assignRoles {};
        class dangerClose {};
        class doFlank {};
        class doHold {};
        class doSupportByFire {};
        class findLZ {};
        class findOverwatch {};
        class fireMission {};
        class hcBalance {};
        class prioritizeCAs {};
        class requestSupport {};
        class unstick {};
    };

    class Fortify
    {
        #ifdef MCCMODE
        file = "\mcc_sandbox_mod\gaia\functions\control\fortify";
        #else
        file = "gaia\functions\control\fortify";
        #endif

        class taskDefend {};
    };
};
