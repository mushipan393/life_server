#define COLLISION_DMG_SCALE 0.2
#define PLANE_COLLISION_DMG_SCALE 0.5
#define WHEEL_COLLISION_DMG_SCALE 0.05
#define MRAP_MISSILE_DMG_SCALE 4.0 // Temporary fix for http://feedback.arma3.com/view.php?id=21743
#define HELI_MISSILE_DMG_SCALE 5.0
#define PLANE_MISSILE_DMG_SCALE 1.5


private["_vehicle","_selection","_damage","_source","_ammo"];


_vehicle = _this select 0;
_selection = _this select 1;
_damage = _this select 2;
_source = _this select 3;
_ammo = _this select 4;

/*
	diag_log format["DEBUG:fn_vehicleHandleDamage:: _vehicle=%1",_vehicle];
	diag_log format["DEBUG:fn_vehicleHandleDamage:: _selection=%1",_selection];
	diag_log format["DEBUG:fn_vehicleHandleDamage:: _damage=%1",_damage];
	diag_log format["DEBUG:fn_vehicleHandleDamage:: _source=%1",_source];
	diag_log format["DEBUG:fn_vehicleHandleDamage:: _ammo=%1",_ammo];
*/

if (_selection != "?") then {
	_oldDamage = if (_selection == "") then { damage _vehicle } else { _vehicle getHit _selection };

	if (!isNil "_oldDamage") then {
		_isPlane = _vehicle isKindOf "Plane";
		if (isNull _source && _ammo == "") exitWith // Reduce collision damage
		{
			_scale = switch (true) do
			{
				case (_selection select [0,5] == "wheel"): { WHEEL_COLLISION_DMG_SCALE };
				case (_isPlane):                           { PLANE_COLLISION_DMG_SCALE };
				default                                    { COLLISION_DMG_SCALE };
			};

			_damage = ((_damage - _oldDamage) * _scale) + _oldDamage;
		};
	};
};

diag_log format["DEBUG:fn_vehicleHandleDamage:: FINAL classname=%4 _damage=%1 _selection=%2 _source=%3",_damage,_selection,_source,typeOf _vehicle];
_damage;