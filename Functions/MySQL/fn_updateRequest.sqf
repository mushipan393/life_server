/*
	File: fn_updateRequest.sqf
	Author: Bryan "Tonic" Boardwine
	
	Description:
	Ain't got time to describe it, READ THE FILE NAME!
*/
private["_uid","_side","_cash","_bank","_licenses","_gear","_name","_query","_thread","_alive","_thirst","_hunger","_damage","_gettotalbounty"];
_uid = [_this,0,"",[""]] call BIS_fnc_param;
_name = [_this,1,"",[""]] call BIS_fnc_param;
_side = [_this,2,sideUnknown,[civilian]] call BIS_fnc_param;
_cash = [_this,3,0,[0]] call BIS_fnc_param;
_bank = [_this,4,5000,[0]] call BIS_fnc_param;
_licenses = [_this,5,[],[[]]] call BIS_fnc_param;
_gear = [_this,6,[],[[]]] call BIS_fnc_param;
_pos = [_this,7,[],[[]]] call BIS_fnc_param;
_alive = [_this,8,false,[bool]] call BIS_fnc_param;
_alive = [_alive] call DB_fnc_bool;
_thirst = [_this,9,0,[100]] call BIS_fnc_param;
_hunger = [_this,10,0,[100]] call BIS_fnc_param;
_damage = [_this,11,0,[0]] call BIS_fnc_param;
_gettotalbounty = [_this,12,0,[0]] call BIS_fnc_param;

//Get to those error checks.
if((_uid == "") OR (_name == "")) exitWith {};

//Parse and setup some data.
_name = [_name] call DB_fnc_mresString;
_gear = [_gear] call DB_fnc_mresArray;
_cash = [_cash] call DB_fnc_numberSafe;
_bank = [_bank] call DB_fnc_numberSafe;
_pos = [_pos] call DB_fnc_mresArray;

//Does something license related but I can't remember I only know it's important?
for "_i" from 0 to count(_licenses)-1 do {
	_bool = [(_licenses select _i) select 1] call DB_fnc_bool;
	_licenses set[_i,[(_licenses select _i) select 0,_bool]];
};

_licenses = [_licenses] call DB_fnc_mresArray;

switch (_side) do {
	case west: {_query = format["UPDATE players SET name='%1', cop_cash='%2', cop_bankacc='%3', cop_gear='%4', cop_licenses='%5',pos='%6',alive='%7',thirst='%8',hunger='%9',damage='%10',gettotalbounty='%11' WHERE playerid='%12'",_name,_cash,_bank,_gear,_licenses,_pos,_alive,_thirst,_hunger,_damage,_gettotalbounty,_uid];};

	case civilian: {_query = format["UPDATE players SET name='%1', cash='%2', bankacc='%3', civ_licenses='%4', civ_gear='%6', arrested='%7', pos='%8', alive='%9',thirst='%10',hunger='%11',damage='%12',gettotalbounty='%13' WHERE playerid='%5'",_name,_cash,_bank,_licenses,_uid,_gear,[_this select 12] call DB_fnc_bool,_pos,_alive,_thirst,_hunger,_damage,_gettotalbounty];};

	case independent: {_query = format["UPDATE players SET name='%1', med_cash='%2', med_bankacc='%3', med_licenses='%4', med_gear='%6', pos='%7', alive='%8',thirst='%9',hunger='%10',damage='%11',gettotalbounty='%12' WHERE playerid='%5'",_name,_cash,_bank,_licenses,_uid,_gear,_pos,_alive,_thirst,_hunger,_damage,_gettotalbounty];};
};


_queryResult = [_query,1] call DB_fnc_asyncCall;