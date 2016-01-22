#include "\life_server\script_macros.hpp"
/*
	File: fn_wantedBounty.sqf
	Author: Bryan "Tonic" Boardwine"
	
	Description:
	Checks if the person is on the bounty list and awards the cop for killing them.
*/
private["_civ","_cop","_id","_half","_value","_query","_idx"];
_civ = [_this,0,Objnull,[Objnull]] call BIS_fnc_param;
_cop = [_this,1,Objnull,[Objnull]] call BIS_fnc_param;
_half = [_this,2,false,[false]] call BIS_fnc_param;
if(isNull _civ OR isNull _cop) exitWith {};

//TODO Friend check
_idx = [getPlayerUID _civ,life_friend_list] call TON_fnc_friendIdx;
if( getPlayerUID _cop in ((life_friend_list select _idx) select 1)) exitWith {
	diag_log format["DEBUG:fn_wantedBounty:** BOUNTY ABUSE ** [%1] and [%2] is Friend",_cop GVAR ["realname","unknown"],_civ GVAR ["realname","unknown"]];
};

_id = [(getPlayerUID _civ),life_wanted_list] call TON_fnc_index;
if(_id != -1) then {

	if(_half) then {
		_value = ((life_wanted_list select _id) select 3) / 2;
	} else {
		_value = (life_wanted_list select _id) select 3;
	};
	[_value,(life_wanted_list select _id) select 3] remoteExecCall ["life_fnc_bountyReceive",(owner _cop)];

	[getPlayerUID _civ] call life_fnc_wantedRemove;

	_query = format["INSERT INTO bountyHistory (h_name,uid,cri_name,cri_uid,money,half) VALUES ('%1', '%2', '%3', '%4', '%5', '%6')",_cop GVAR ["realname","unknown"],getPlayerUID _cop,_civ GVAR ["realname","unknown"],getPlayerUID _civ,_value,[_half] call DB_fnc_bool];

	[_query,1] call DB_fnc_asyncCall;

	diag_log format["DEBUG:fn_wantedBounty:INSERT HISTORY: Hunter=%1 HunterUID=%2 Criminal=%3 CriminalUID=%4 value=%5 half=%6",_cop GVAR ["realname","unknown"],getPlayerUID _cop,_civ GVAR ["realname","unknown"],getPlayerUID _civ,_value,[_half] call DB_fnc_bool];

};