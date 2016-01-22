#include "\life_server\script_macros.hpp"
/*
	Author: Bryan "Tonic" Boardwine
	
	Description:
	When a client disconnects this will remove their corpse and
	clean up their storage boxes in their house.
*/
private["_unit","_id","_uid","_name","_idx"];

_unit = SEL(_this,0);
diag_log format["DEBUG:fn_clientDisconnect: _unit = %1",_unit];
diag_log format["DEBUG:fn_clientDisconnect: faction = %1",faction _unit];

if(isNull _unit) exitWith {};
_id = SEL(_this,1);
_uid = SEL(_this,2);
_name = SEL(_this,3);

_idx = [_uid,life_logInOut_list] call TON_fnc_friendIdx;
if(_idx != -1) then {
	if((faction _unit) == ((life_logInOut_list select _idx) select 1) select 0 || (diag_ticktime - (((life_logInOut_list select _idx) select 1) select 1)) > (15 * 60)) then {
		((life_logInOut_list select _idx) select 1) set [0, faction _unit];
		((life_logInOut_list select _idx) select 1) set [1, diag_tickTime];
	};
} else {
	life_logInOut_list pushBack [_uid,[faction _unit,diag_tickTime]];
};
diag_log format["DEBUG:fn_clientDisconnect: life_logInOut_list = %1",life_logInOut_list];

_containers = nearestObjects[_unit,["WeaponHolderSimulated"],5];
{deleteVehicle _x;} foreach _containers;
deleteVehicle _unit;

_uid spawn TON_fnc_houseCleanup;