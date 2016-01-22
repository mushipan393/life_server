#include "\life_server\script_macros.hpp"

private["_vehicle","_class"];


_vehicle = _this select 0;
_class = typeOf _vehicle;

if !(_class isKindOf "AllVehicles") exitWith {};

_vehicle addEventHandler["Killed",{_this spawn TON_fnc_vehicleDead}];

_vehicle setVariable ["AL_hitPointSelections", true, true];

_vehicle setVariable ["AL_handleDamageEH", _vehicle addEventHandler ["HandleDamage", TON_fnc_vehicleHandleDamage]];

//_vehicle setVariable ["AL_dammagedEH", _vehicle addEventHandler ["Dammaged", vehicleDammagedEvent]];
//_vehicle setVariable ["AL_engineEH", _vehicle addEventHandler ["Engine", vehicleEngineEvent]];
