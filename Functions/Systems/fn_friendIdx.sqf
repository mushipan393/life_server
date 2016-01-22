
private["_uid","_return"];
_uid = [_this,0,"",[""]] call BIS_fnc_param;
_list = [_this,1,[],[[]]] call BIS_fnc_param;


_return = -1;
{
	if((_x select 0) == _uid) exitWith {
		_return = _forEachIndex;
	};
} foreach _list;

_return;