#include "\life_server\script_macros.hpp"
/*
	File: fn_queryRequest.sqf
	Author: Bryan "Tonic" Boardwine
	
	Description:
	Handles the incoming request and sends an asynchronous query 
	request to the database.
	
	Return:
	ARRAY - If array has 0 elements it should be handled as an error in client-side files.
	STRING - The request had invalid handles or an unknown error and is logged to the RPT.
*/
private["_uid","_side","_query","_return","_queryResult","_qResult","_handler","_thread","_tickTime","_loops","_returnCount","_client","_idx"];
_uid = [_this,0,"",[""]] call BIS_fnc_param;
_side = [_this,1,sideUnknown,[civilian]] call BIS_fnc_param;
_ownerID = [_this,2,ObjNull,[ObjNull]] call BIS_fnc_param;

if(isNull _ownerID) exitWith {};

//SIDE CHANGE CHECK
_idx = [_uid,life_logInOut_list] call TON_fnc_friendIdx;
if(_idx != -1) then {
	if( (((life_logInOut_list select _idx) select 1) select 0) != (faction _ownerID) && (diag_ticktime - (((life_logInOut_list select _idx) select 1) select 1)) < (15 * 60)) exitWith {
		["SIDE_CHANGE_GUARD",false,true] remoteExec ["BIS_fnc_endMission",owner _ownerID];
	};
};

_client = _ownerID;
_ownerID = owner _ownerID;

/*
	_returnCount is the count of entries we are expecting back from the async call.
	The other part is well the SQL statement.
*/
_query = switch(_side) do {
	case west: {_returnCount = 15; format["SELECT playerid, name, cop_cash, cop_bankacc, adminlevel, donatorlvl, cop_licenses, coplevel, cop_gear, blacklist, pos, alive,hunger,thirst,damage,gettotalbounty FROM players WHERE playerid='%1'",_uid];};
	case civilian: {_returnCount = 14; format["SELECT playerid, name, cash, bankacc, adminlevel, donatorlvl, civ_licenses, arrested, civ_gear, pos, alive,hunger,thirst,damage,gettotalbounty FROM players WHERE playerid='%1'",_uid];};
	case independent: {_returnCount = 14; format["SELECT playerid, name, med_cash, med_bankacc, adminlevel, donatorlvl, med_licenses, mediclevel, med_gear, pos, alive,hunger,thirst,damage,gettotalbounty FROM players WHERE playerid='%1'",_uid];};
};


_tickTime = diag_tickTime;
_queryResult = [_query,2] call DB_fnc_asyncCall;

diag_log "------------- Client Query Request -------------";
diag_log format["QUERY: %1",_query];
diag_log format["Time to complete: %1 (in seconds)",(diag_tickTime - _tickTime)];
diag_log format["Result: %1",_queryResult];
diag_log "------------------------------------------------";

if(typeName _queryResult == "STRING") exitWith {
	[] remoteExecCall ["SOCK_fnc_insertPlayerInfo",_ownerID];
};

if(count _queryResult == 0) exitWith {
	[] remoteExecCall ["SOCK_fnc_insertPlayerInfo",_ownerID];
};

//Blah conversion thing from a2net->extdb
private["_tmp","_tmp2","_hunger","_thirst","_damage","_gettotalbounty"];
_tmp = _queryResult select 2;
_queryResult set[2,[_tmp] call DB_fnc_numberSafe];
_tmp = _queryResult select 3;
_queryResult set[3,[_tmp] call DB_fnc_numberSafe];

//save pos
switch (_side) do {
	case west: {
		_tmp = _queryResult select 10;
		_tmp2 = _queryResult select 11;
		_hunger = _queryResult select 12;
		_thirst = _queryResult select 13;
		_damage = _queryResult select 14;
		_gettotalbounty = _queryResult select 15;
	};
	case civilian: {
		_tmp = _queryResult select 9;
		_tmp2 = _queryResult select 10;
		_hunger = _queryResult select 11;
		_thirst = _queryResult select 12;
		_damage = _queryResult select 13;
		_gettotalbounty = _queryResult select 14;

	};
	case independent: {
		_tmp = _queryResult select 9;
		_tmp2 = _queryResult select 10;
		_hunger = _queryResult select 11;
		_thirst = _queryResult select 12;
		_damage = _queryResult select 13;
		_gettotalbounty = _queryResult select 14;
	};
};
_queryResult set[13,[_tmp] call DB_fnc_mresToArray];

//set alive
_queryResult set[14,([_tmp2,1] call DB_fnc_bool)];

//hunger,thirst,damage
_queryResult set[15,_hunger];
_queryResult set[16,_thirst];
_queryResult set[17,_damage];
_queryResult set[18,_gettotalbounty];

//Parse licenses (Always index 6)
_new = [(_queryResult select 6)] call DB_fnc_mresToArray;
if(typeName _new == "STRING") then {_new = call compile format["%1", _new];};
_queryResult set[6,_new];

//Convert tinyint to boolean
_old = _queryResult select 6;
for "_i" from 0 to (count _old)-1 do
{
	_data = _old select _i;
	_old set[_i,[_data select 0, ([_data select 1,1] call DB_fnc_bool)]];
};

_queryResult set[6,_old];

_new = [(_queryResult select 8)] call DB_fnc_mresToArray;
if(typeName _new == "STRING") then {_new = call compile format["%1", _new];};
_queryResult set[8,_new];
//Parse data for specific side.
switch (_side) do {
	case west: {
		_queryResult set[9,([_queryResult select 9,1] call DB_fnc_bool)];
	};
	
	case civilian: {
		_queryResult set[7,([_queryResult select 7,1] call DB_fnc_bool)];
		_houseData = _uid spawn TON_fnc_fetchPlayerHouses;
		waitUntil {scriptDone _houseData};
		//_queryResult pushBack (missionNamespace getVariable[format["houses_%1",_uid],[]]);
		_queryResult set[9, (missionNamespace getVariable[format["houses_%1",_uid],[]])];
		_gangData = _uid spawn TON_fnc_queryPlayerGang;
		waitUntil{scriptDone _gangData};
		//_queryResult pushBack (missionNamespace getVariable[format["gang_%1",_uid],[]]);
		_queryResult set[10, (missionNamespace getVariable[format["gang_%1",_uid],[]])];
	};
};

_keyArr = missionNamespace getVariable [format["%1_KEYS_%2",_uid,_side],[]];
_queryResult set[12,_keyArr];


_queryResult remoteExec ["SOCK_fnc_requestReceived",_ownerID];
[_uid] call life_fnc_getMyBounty;

_idx = [_uid,life_friend_list] call TON_fnc_friendIdx;
if(_idx == -1) then {
	life_friend_list pushBack [_uid,[]];
};



