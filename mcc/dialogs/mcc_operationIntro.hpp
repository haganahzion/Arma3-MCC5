// Empty title layer for the operation intro. MCC_fnc_operationIntro creates every control on it at runtime.
class MCC_RscOperationIntro
{
	idd = -1;
	movingEnable = 0;
	enableSimulation = 1;
	duration = 1e+6;
	fadeIn = 0;
	fadeOut = 0;
	onLoad = "uiNamespace setVariable ['MCC_RscOperationIntro', _this select 0]";
	onUnload = "uiNamespace setVariable ['MCC_RscOperationIntro', displayNull]";
	class controls {};
};
