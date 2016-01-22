#include "\life_server\script_macros.hpp"
/*
	File: fn_wantedFetch.sqf
	Author: Bryan "Tonic" Boardwine"

	Description:
	Displays wanted list information sent from the server.
*/
private["_list","_jailedUnits","_query","_queryResult","_history"];
params [
	["_ret",ObjNull,[objNull]]
];
if(isNull _ret) exitWith {};

_ret = owner _ret;
_jailedUnits = [];
{if(_x distance (getMarkerPos "jail_marker") < 120) then {_jailedUnits pushBack getPlayerUID _x}} forEach playableUnits;

_list = [];
{
	_uid = _x select 1;
	if([_uid] call life_fnc_isUIDActive) then {
		if(!(_uid in _jailedUnits)) then {
			_list pushBack _x;
		};
	};
} foreach life_wanted_list;
[_list] remoteExec ["life_fnc_wantedList",_ret];

_query = "SELECT h_name,cri_name,money,half,indate FROM bountyHistory ORDER BY indate DESC LIMIT 10";
_queryResult = [_query,2,true] call DB_fnc_asyncCall;

diag_log format["DEBUG:fn_wantedFetch: _queryResult=%1",_queryResult];
_history = [];
{
	if([(_x select 3),1] call DB_fnc_bool) then {
		_history pushBack format["%1 was   Killed   by %2 Bounty:%3 [%4]",_x select 1,_x select 0,_x select 2,_x select 4];
	} else {
		_history pushBack format["%1 was SendToJail by %2 Bounty:%3 [%4]",_x select 1,_x select 0,_x select 2,_x select 4];
	};
		
} foreach _queryResult;
[_history] remoteExec ["life_fnc_wantedHistory",_ret];

diag_log format["DEBUG:fn_wantedFetch: _history=%1",_history];
