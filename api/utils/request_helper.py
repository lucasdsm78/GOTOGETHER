"""
use it for not to complex request (without join for now, and subquery)
"""

TABLE_USER = "users"
TABLE_LOCATIONS = "locations"
TABLE_ACTIVITIES = "activities"
TABLE_ACTIVITIES_USERS = "activitiesUsers"


def insert_request(table, columns):
	sql_request = "INSERT INTO " + table + " ("
	sql_values = " VALUES("
	i=0
	while i < len(columns):
		if (isinstance(columns[i], str)):
			sql_request += columns[i] + ("," if i < len(columns)-1 else ")" )
		else : #then should be a dict, can't have usage of array
			sql_request += columns[i]["key"] + ("," if i < len(columns)-1 else ")" )
		sql_values += "%s" + ("," if i < len(columns)-1 else ")" )
		i +=1

	return sql_request + sql_values

def select_all_request(table):
	return "SELECT * FROM " + table

"""
columns : string (example '*' or 'id, name' ) , array of string or dict ({col, alias} or {col})
"""
def select_request(table, columns,where=""):
	cols = ""
	i = 0
	if( isinstance(columns, str)):
		cols = columns
	else :
		while i < len(columns):
			if (isinstance(columns[i], str)):
				cols += columns[i]
			else:
				cols += " " + columns[i]["col"] + ( " as " + columns[i]["alias"] if "alias" in columns[i] else "")
			cols += (", " if i < len(columns)-1 else " " )
			i +=1

	return "SELECT " + cols + " FROM " + table + ( " WHERE " + where if where else "")
   
def update_request(table, columns, where):
	sql_request = "UPDATE " + table + " SET "
	i=0
	while i < len(columns):
		if (isinstance(columns[i], str)):
			sql_request += columns[i] + "=%s" + ("," if i < len(columns)-1 else " " )
		else:
			sql_request += columns[i]["key"] + "=%s" + ("," if i < len(columns)-1 else " " )
		i +=1

	return sql_request + ( " WHERE " + where if where else "")

def delete_request(table, where):
	sql_request = "DELETE FROM " + table
	return sql_request + ( " WHERE " + where if where else "")

#use args from my function in api_helper
def where_clause(wanted):
	if (len(wanted)==0):
		return ""
	where_clause = " WHERE "
	total_len = len(wanted)
	i=0
	for el in wanted:
		if (isinstance(el, str)):
			where_clause += el + "=%s" + (" AND " if i < total_len-1 else " " )
		else:
			if (isinstance(el["key"], str)):
				where_clause += el["key"] + " " + el.get("comparison") + " " + "%s" + (" AND " if i < total_len-1 else " " )
			else :
				where_clause += " ( "
				col_count=0
				col_total_len = len(el["key"])
				for col in el["key"]:
					#where_clause += col + "=%s" + (" OR " if col_count < col_total_len-1 else " ) " )
					where_clause += col + " " + el.get("comparison") + " " + "%s" + (" OR " if col_count < col_total_len-1 else " ) " )
					col_count += 1
				where_clause += (" AND " if i < total_len-1 else " " )
		i +=1
	return where_clause

def test_requests():
	print(insert_request(TABLE_USER, ["username", "role", "mail"]))
	print(insert_request(TABLE_USER, ("username", "role", "mail")))
	print(select_all_request(TABLE_USER))
	columns = [{"col":"role", "alias":"user_role"}, {"col":"mail"}, "id"]
	print(select_request(TABLE_USER, columns, "role='USER'"))
	print(select_request(TABLE_USER, "*"))
	mail = "gwen@gmail.com"
	print(select_request(TABLE_USER, ["role"], f"mail ='{mail}"))
	columns2 = ["role","mail"]
	print(update_request(TABLE_USER, columns2, "role='USER'"))


#test_requests()
