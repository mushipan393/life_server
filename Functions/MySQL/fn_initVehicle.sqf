#include "\life_server\script_macros.hpp"

/***************************************************
 * when server startup, vehicles.active=1 data
 * ALL Vehicles create on MAP
 ***************************************************/

private["_query","_queryResult","_vehicle","_side","_classname","_pid","_plate","_color","_inventory","_trunk","_pos","_worldspace","_hitpoint","_allHitpoints","_actualHitpoints","_dmg","_name","_objType","_objTypes","_objQty","_attachments","_wMags","_wMagsArray","_magazineName","_magazineSize","_qty","_initVehicleCount","_config","_veh"];


diag_log "DEBUG:fn_initVehicle:: Server Start Load ALL Vehicle of active=1";

_query = "SELECT v.side,v.classname,v.pid,v.plate,v.color,v.inventory,v.pos,v.hitpoint,v.fuel,v.damage,p.name FROM vehicles v, players p WHERE v.active=1 AND v.alive=1 AND v.pos!='[]' AND p.playerid=v.pid";
_queryResult = [_query,2,true] call DB_fnc_asyncCall;

if(count _queryResult == 0) exitWith {};
if(EQUAL(typeName _queryResult,typeName "")) exitWith {};

_initVehicleCount = 0;
{
	_side = _x select 0;
	_side = switch(_side) do {
		case "cop":{west};
		case "civ": {civilian};
		case "med": {independent};
		default {"Error"};
	};
	_classname = _x select 1;
	_pid = _x select 2;
	_plate = _x select 3;
	_color = _x select 4;
	_inventory = [(_x select 5)] call DB_fnc_mresToArray;
	_worldspace = [(_x select 6)] call DB_fnc_mresToArray;
	_hitpoint = [(_x select 7)] call DB_fnc_mresToArray;
	_name = _x select 10;

	_pos = _worldspace deleteAt 0;
	if (count _pos == 2) then {
		_pos = (_pos select 0) vectorAdd (_pos select 1);
	};

	_vehicle = createVehicle [_classname, _pos, [], 0, "CAN_COLLIDE"];


	_vehicle setposATL _pos;
	_vehicle setVectorDirAndUp _worldspace;
	_vehicle setFuel (_x select 8);


	_vehicle setDamage (_x select 9);

	_allHitpoints = getAllHitPointsDamage _vehicle;
	if !(_allHitpoints isEqualTo []) then{
		_actualHitpoints = _allHitpoints select 0;
		if ((count _actualHitpoints) == (count _hitpoint)) then{
			{
				_dmg = _hitpoint param [_forEachIndex,0];
				if (_x in ["HitFuel", "HitEngine"]) then {
					_dmg = _dmg min 0.9;
				};
				_vehicle setHitIndex [_forEachIndex, _dmg];
			} forEach _actualHitpoints;
		};
	};

	_vehicle allowDamage false;

	clearWeaponCargoGlobal    _vehicle;
	clearMagazineCargoGlobal  _vehicle;
	clearBackpackCargoGlobal  _vehicle;
	clearItemCargoGlobal      _vehicle;



	if !(_inventory isEqualTo []) then{
		{



			_objType  = _forEachIndex;
			_objTypes = _x;
			_objQty = [];

			if(_objType in [1,2,3]) then {

				_objTypes = _x select 0;
				_objQty = _x select 1;
			};

			{

				switch _objType do {
					//Weapon Cargo
					case 0: {
						if (typeName _x == "ARRAY") then {
							if ((count _x) >= 4) then {
								_vehicle addWeaponCargoGlobal[_x deleteAt 0, 1];
								_attachments = [];
								_wMags = false;
								_wMagsArray = [];

								{
									// magazines
									if (typeName(_x) == "ARRAY") then{
										_wMags = true;
										_wMagsArray = _x;
									}
									else {
										// attachments
										if (_x != "") then{
											_attachments pushBack _x;
										};
									};
								} foreach _x;

								{
									_vehicle addItemCargoGlobal[_x, 1];
								} forEach _attachments;

								if (_wMags) then{
									if (typeName _wMagsArray == "ARRAY" && (count _wMagsArray) >= 2) then{
										_vehicle addMagazineAmmoCargo[_wMagsArray select 0, 1, _wMagsArray select 1];
									};
								};
							};
						};
					};
					
					// Magazine cargo
					case 1: {
						_magazineName = _x;
						_magazineSize = _objQty select _forEachIndex;

						if ((typeName _magazineName == "STRING") && (typeName _magazineSize == "SCALAR")) then {
							_magazineSizeMax = getNumber (configFile >> "CfgMagazines" >> _magazineName >> "count");

							// Add full magazines cargo
							_vehicle addMagazineAmmoCargo [_magazineName, floor (_magazineSize / _magazineSizeMax), _magazineSizeMax];

							// Add last non full magazine
							if ((_magazineSize % _magazineSizeMax) > 0) then {
								_vehicle addMagazineAmmoCargo [_magazineName, 1, floor (_magazineSize % _magazineSizeMax)];
							};
						};
					};

					// Backpack cargo
					case 2: {
						if (typeName _x == "STRING") then {
							_qty = _objQty select _forEachIndex;
							_vehicle addBackpackCargoGlobal [_x, _qty];
						};
					};
					// Item cargo
					case 3: {
						if (typeName _x == "STRING") then {
							_qty = _objQty select _forEachIndex;
							_vehicle addItemCargoGlobal [_x, _qty];
						};
					};

				};

			} foreach _objTypes;
		} foreach _inventory;

		_trunk = _inventory param [4,[]];
		_vehicle setVariable["Trunk",_trunk,true];
	};

	
	

	_vehicle lock 2;
	[_vehicle,_color] remoteExec ["life_fnc_colorVehicle",RANY];

	if(EQUAL(_side,civilian) && EQUAL(_classname,"B_Heli_Light_01_F") && !(EQUAL(_color,13))) then {
		[_vehicle,"civ_littlebird",true] remoteExecCall ["life_fnc_vehicleAnimate",RANY];
	};

	if(EQUAL(_side,west) && (_classname) in ["C_Offroad_01_F","B_MRAP_01_F","C_SUV_01_F"]) then {
		[_vehicle,"cop_offroad",true] remoteExecCall ["life_fnc_vehicleAnimate",RANY];
	};

	if(EQUAL(_side,independent) && EQUAL(_classname,"C_Offroad_01_F")) then {
		[_vehicle,"med_offroad",true] remoteExecCall ["life_fnc_vehicleAnimate",RANY];
	};


	[_pid,_side,_vehicle,1] call TON_fnc_keyManagement;


	_vehicle setVariable["vehicle_info_owners",[[_pid,_name]],true];
	_vehicle setVariable["dbInfo",[_pid,_plate]];
	//_vehicle addEventHandler["Killed",{_this spawn TON_fnc_vehicleDead}];
	[_vehicle] call TON_fnc_setupVehicleEH;


	//[_vehicle] call life_fnc_clearVehicleAmmo;

	_veh = typeOf _vehicle;

	if(EQUAL(_veh,"B_Boat_Armed_01_minigun_F")) then {
		_vehicle removeMagazinesTurret ["200Rnd_40mm_G_belt",[0]];
	};

	if(EQUAL(_veh,"B_APC_Wheeled_01_cannon_F")) then  {
		_vehicle removeMagazinesTurret ["60Rnd_40mm_GPR_Tracer_Red_shells",[0]];
		_vehicle removeMagazinesTurret ["40Rnd_40mm_APFSDS_Tracer_Red_shells",[0]];
	};

	if(EQUAL(_veh,"O_Heli_Attack_02_black_F")) then {
		_vehicle removeMagazinesTurret ["250Rnd_30mm_APDS_shells",[0]];
		_vehicle removeMagazinesTurret ["8Rnd_LG_scalpel",[0]];
		_vehicle removeMagazinesTurret ["38Rnd_80mm_rockets",[0]];
	};

	if(EQUAL(_veh,"B_Heli_Transport_01_F")) then 
	{
		_vehicle removeMagazinesTurret ["2000Rnd_65x39_Belt_Tracer_Red",[1]];
		_vehicle removeMagazinesTurret ["2000Rnd_65x39_Belt_Tracer_Red",[2]];
	};

	_vehicle allowDamage true;


	_initVehicleCount = _initVehicleCount + 1;
} foreach _queryResult;

diag_log format["DEBUG:fn_initVehicle:: END Load ALL Vehicle Count= [ %1 ]",_initVehicleCount];

