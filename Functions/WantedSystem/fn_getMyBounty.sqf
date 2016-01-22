

private["_uid","_unit","_id","_value"];
_uid = [_this,0,"",[""]] call BIS_fnc_param;
_value = 0;
if(_uid == "") exitWith {};

diag_log format["DEBUG:fn_getMyBounty uid=%1",_uid];

_id = [_uid,life_wanted_list] call TON_fnc_index;

if(_id != -1) then {
	_value = (life_wanted_list select _id) select 3;
};
diag_log format["DEBUG:fn_getMyBounty value=%1",_value];
{
	if( _uid == getPlayerUID _x) exitWith{
		[_value] remoteExecCall ["life_fnc_setMyBounty",(owner _x)];
		diag_log format["DEBUG:fn_getMyBounty name=%1 value=%2",name _x ,_value];
	};
} foreach allPlayers;
