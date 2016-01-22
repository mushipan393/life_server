
private["_vehicle","_hitPtsCfg","_dbInfo","_uid","_plate","_inventory","_pos","_hitpoints","_fuel","_damage","_trunk","_query","_thread","_magsAmmoCargoMinimized","_cargoIndex"];

diag_log "DEBUG: fn_updateVehicle: ------START SCRIPT---------------";


_vehicle = [_this,0,ObjNull,[ObjNull]] call BIS_fnc_param;
if(_vehicle == ObjNull) exitWith{diag_log "ERROR:fn_updateVehicle:_vehicle is ObjNull";};


_dbInfo = _vehicle getVariable ["dbInfo",[]];
if((count _dbInfo) isEqualTo 0) exitWith{diag_log "ERROR:fn_updateVehicle:_dbInfo is NULL";};

_uid = _dbInfo param [0,""];
_plate = _dbInfo param [1,0];

_hitpoints = (getAllHitPointsDamage _vehicle) param [2,[]];


_trunk = _vehicle getVariable ["Trunk",[]];

_wepsItemsCargo = weaponsItemsCargo _vehicle;
if (isNil "_wepsItemsCargo") then {
	_wepsItemsCargo = [];
};
_magsAmmoCargo = magazinesAmmoCargo _vehicle;
if (isNil "_magsAmmoCargo") then {
	_magsAmmoCargo = [];
};

// minimize magazine ammo cargo
_magsAmmoCargoMinimized = [[],[]];
{
	// find cargo in temp var
	_cargoIndex = _magsAmmoCargoMinimized find (_x select 0);
	if (_cargoIndex >= 0) then {
		(_magsAmmoCargoMinimized select 1) set [_cargoIndex, ((_magsAmmoCargoMinimized select 1) select _cargoIndex) + (_x select 1)]; // get count & add current
	}
	else {
		(_magsAmmoCargoMinimized select 0) pushBack (_x select 0); // classname
		(_magsAmmoCargoMinimized select 1) pushBack (_x select 1); // count
	};
} forEach _magsAmmoCargo;

_inventory = [
	_wepsItemsCargo,
	_magsAmmoCargoMinimized,
	getBackpackCargo _vehicle,
	getItemCargo _vehicle,
	_trunk
];

_pos = [getPosATL _vehicle,vectordir _vehicle,vectorup _vehicle];
_fuel = fuel _vehicle;
_damage = damage _vehicle;


//Get to those error checks.
if(_uid == "" || _plate == 0) exitWith {diag_log "fn_updateVehicle::Error: _uid = null OR _classname = null";};

_inventory = [_inventory] call DB_fnc_mresArray;
_pos = [_pos] call DB_fnc_mresArray;
_hitpoints = [_hitpoints] call DB_fnc_mresArray;

_query = format["UPDATE vehicles SET inventory='%1', pos='%2', hitpoint='%3', fuel='%4', damage='%5' WHERE pid='%6' AND plate='%7'",_inventory,_pos,_hitpoints,_fuel,_damage,_uid,_plate];
[_query,1] call DB_fnc_asyncCall;



