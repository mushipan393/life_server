

private["_list","_query"];



//DELETE data
_query = "DELETE FROM wanted";
[_query,1] call DB_fnc_asyncCall;

//INSERT
_list = [life_wanted_list] call DB_fnc_mresArray;
_query = format["INSERT INTO wanted (wanted_list) VALUES ('%1')",_list];
[_query,1] call DB_fnc_asyncCall;

diag_log format["DEBUG:fn_updateWanted: life_wanted_list = %1",life_wanted_list];