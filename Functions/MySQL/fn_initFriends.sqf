

private["_query","_queryResult"];

diag_log "DEBUG:fn_initFriends:: Server Start Load Friend List";

_query = "SELECT friend_list FROM groupHistory";
_queryResult = [_query,2,true] call DB_fnc_asyncCall;
diag_log format["DEBUG:fn_initFriends:: _queryResult=%1",_queryResult];

life_friend_list = [(_queryResult select 0) select 0] call DB_fnc_mresToArray;

diag_log format["DEBUG:fn_initFriends:: life_friend_list=%1",life_friend_list];
