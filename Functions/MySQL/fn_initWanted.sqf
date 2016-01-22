

private["_query","_queryResult"];

diag_log "DEBUG:fn_initWanted:: Server Start Load Wanted List";

_query = "SELECT wanted_list FROM wanted";
_queryResult = [_query,2,true] call DB_fnc_asyncCall;
diag_log format["DEBUG:fn_initWanted:: _queryResult=%1",_queryResult];

life_wanted_list = [(_queryResult select 0) select 0] call DB_fnc_mresToArray;

diag_log format["DEBUG:fn_initWanted:: life_wanted_list=%1",life_wanted_list];
