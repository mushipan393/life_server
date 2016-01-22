
private["_list","_query"];



//DELETE data
_query = "DELETE FROM groupHistory";
[_query,1] call DB_fnc_asyncCall;

//INSERT
_list = [life_friend_list] call DB_fnc_mresArray;
_query = format["INSERT INTO groupHistory (friend_list) VALUES ('%1')",_list];
[_query,1] call DB_fnc_asyncCall;

diag_log format["DEBUG:fn_updateFriends: life_friend_list = %1",life_friend_list];