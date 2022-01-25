import pymysql
from utils.config import mysql
from utils.request_helper import *
from flask import jsonify, request, session, redirect, url_for
import utils.requests_string as request_str

conn = None
cursor = None

#region helpers
def is_set_and_not_empty(arg):
	"""
	Check if an argument exist in the request args and if it's not empty
	here an usage example : if is_set_and_not_empty("mail"):
	:param arg: checked argument
	:type arg: str
	:return: a boolean, True if arg exist and isn't empty
	"""
	return arg in request.args and request.args[arg]

def response(result, isSuccess=True):
	if isSuccess:
		return {"success":result}
	else:
		return {"error":result}

def connection_db(dict_cursor=True):
	global conn, cursor
	conn = mysql.connect()
	if dict_cursor :
		cursor = conn.cursor(pymysql.cursors.DictCursor)
	else:
		cursor = conn.cursor()

def close_db():
	global conn, cursor
	cursor.close()
	conn.close()

#[String, {"field":String, "required":Boolean}, ...]
#maybe if method POST, PATCH, PUT, DELETE, use request.json; else if methode= GET use request.params
def handle_req_body(wanted):
	return treat_req_params(wanted, request.json)

def handle_req_args(wanted):
	return treat_req_params(wanted, request.args)

def treat_req_params(wanted, _json):
	_args = []
	_tuple = []
	_dict = {}
	_required = 0
	try :
		for el in wanted:
			if (isinstance(el, str)):
				if (el in _json):
					val = str(_json[el])
					_args.append({"key":el, "value":val, "type":None})
					_tuple.append(val)
					_dict[el] = val
					_required += 1
			elif(el["field"] in _json or el.get("value")):
				_exact = el.get("exact", True)
				_type = el.get("type", None)
				_raw_val = str(_json.get(el["field"], el.get("value")))
				val = get_exact_val(_exact, _raw_val)
				_key = el.get("column", el["field"])
				_args.append({"key":_key, "value":val, "type":_type, "exact":_exact, "comparison":el.get("comparison", "=")})
				if (isinstance(_key, str)):
					append_req_tuple(_tuple, _type, _raw_val, _exact)
				else :
					append_req_tuple(_tuple, _type, _raw_val, _exact, len(_key))

				_dict[el["field"]] = val
				if(el.get("required", True)):
					_required +=1
		return {"isAllExist":len(wanted)==len(_args), "isAllRequiredExist":len(_args)>=_required,"tuple":tuple(_tuple),"args":_args, "dict":_dict, "required":_required}
	except Exception as e:
		print("here the error msg : ", e)

def append_req_tuple(_tuple, _type, _val, _exact, nb_repeat=1):
	if(_type=="keywords"):
		_all_val = _val.split(",")
		for _keyword in _all_val:
			i=0
			while i<nb_repeat:
				_tuple.append(get_exact_val(_exact, _keyword.strip()))
				i+=1
	else:
		_tuple.append(get_exact_val(_exact, _val))

def get_exact_val(_exact, _val):
	return ("" if _exact else "%") + _val + ("" if _exact else "%")
#endregion

def location_req():
	try:
		_args_location = handle_req_body(["lat", "lon", "address", "country", "city"])
		print(_args_location)
		if _args_location["isAllExist"] and (request.method == 'POST' or request.method == 'PUT'):
			connection_db()
			sql_query_get_location = f"""SELECT id from {TABLE_LOCATIONS} 
			WHERE city=%s AND country=%s AND address=%s """
			cursor.execute(sql_query_get_location, (_args_location["dict"]["city"], _args_location["dict"]["country"], _args_location["dict"]["address"]))
			row = cursor.fetchone()
			if row and row["id"]:
				_location_id = row["id"]
			else:
				sql_query_location = insert_request(TABLE_LOCATIONS, _args_location["args"]) 
				cursor.execute(sql_query_location, _args_location["tuple"])
				_location_id = conn.insert_id()
			conn.commit()
			close_db()
			return _location_id
		else:
			return None
	except Exception as e:
		print("msg error = ", e)
		return None

#region activity
def add_activity_req():
	try:
		_location_id = location_req()
		if _location_id and request.method == 'POST':
			connection_db()
			_args = handle_req_body(["idHostUser", "dateStart", "dateEnd", "attendeesNumber", "idLevel", "idSport", "description", {"field":"idLocation", "required":False, "value":_location_id}])
			sql_query = insert_request(TABLE_ACTIVITIES, _args["args"])
			cursor.execute(sql_query, _args["tuple"])
			_activity_id = conn.insert_id()
			conn.commit()

			cursor.execute(request_str.get_activity_req_base() + " WHERE A.id =%s;", _activity_id)
			empRows = cursor.fetchone()
			_res = jsonify(response({"message":"Activity added successfully", "id":_activity_id, "last_insert":empRows}))
			_res.status_code = 201
			return _res
		else:
			return not_found()
	except Exception as e:
		print(e)
	finally:
		close_db()

def update_activity_req(id):
	_location_id = location_req()
	wanted = [{"field":"idHostUser", "required":False}, {"field":"dateStart", "required":False}, {"field":"dateEnd", "required":False},
		{"field":"attendeesNumber", "required":False}, {"field":"idLevel", "required":False}, {"field":"description", "required":False}]
	if _location_id:
		wanted.append({"field":"idLocation", "required":False, "value":_location_id})
	return api_update(wanted, TABLE_ACTIVITIES, id=id)

def cancel_activity_req(idActivity):
	try:
		connection_db()
		sql_query = update_request(TABLE_ACTIVITIES, ["isCanceled"], " id=%s")
		cursor.execute(sql_query, ("1", str(idActivity)))
		conn.commit()
		_res = jsonify(response("Activity added successfully"))
		_res.status_code = 200
		return _res
	except Exception as e:
		print(e)
	finally:
		close_db()

def joining_activity_req():
	try:
		_args = handle_req_body(["idUser", "idActivity"])
		isJoining = request.json["isJoining"]
		if _args["isAllExist"] and request.method == 'POST':
			_activity_id = _args["dict"]["idActivity"]
			connection_db()
			if (isJoining):
				sql_query = insert_request(TABLE_ACTIVITIES_USERS, _args["args"])
			else:
				sql_query = delete_request(TABLE_ACTIVITIES_USERS, " idUser = %s AND idActivity = %s ")
			cursor.execute(sql_query, _args["tuple"])
			conn.commit()

			cursor.execute(request_str.get_activity_req_base() + " WHERE A.id =%s;", _activity_id)
			empRows = cursor.fetchone()
			_res = jsonify(response({"message":("Joining" if isJoining  else "Quit") + " activity successfully", "id":_activity_id, "last_insert":empRows}))
			_res.status_code = 200
			return _res
		else:
			return not_found()
	except Exception as e:
		print(e)
	finally:
		close_db()
#endregion

#region common bdd
def api_select(get_request, rep_tuple=None, where="", is_unique=False):
	try:
		connection_db()
		if len(rep_tuple) and len(where):
			cursor.execute(get_request + where, rep_tuple)
		else:
			cursor.execute(get_request + where)

		if (is_unique):
			empRows = cursor.fetchone()
		else:
			empRows = cursor.fetchall()
		_res = jsonify(response(empRows))
		_res.status_code = 200
		return _res
	except Exception as e:
		print(e)
		return None
	finally:
		close_db()

def api_insert(wanted,table=TABLE_USER, message="added successfully!", get_request=None):
	try:
		_args = handle_req_body(wanted)
		if _args["isAllExist"] and request.method == 'POST':
			sql_query = insert_request(table, _args["args"]) 
			connection_db()
			cursor.execute(sql_query, _args["tuple"])
			_id = conn.insert_id()
			conn.commit()
			if(get_request is None):
				_res = jsonify(response(message))
			else:
				print("REQUEST : ", get_request, str(_id))
				cursor.execute(get_request, str(_id))
				empRows = cursor.fetchone()
				_res = jsonify(response({"message":"Activity added successfully", "id":_id, "last_insert":empRows}))

			_res.status_code = 201
			return _res
		else:
			return not_found()
	except Exception as e:
		print(e)
	finally:
		close_db()

def api_update(wanted, table=TABLE_USER, message="updated successfully!", id=None):
	try:
		_args = handle_req_body(wanted)
		if _args["isAllRequiredExist"] and  len(_args["tuple"])>0 and id is not None and request.method == 'PUT':
			sql_query = update_request(table, _args["args"], " id=%s") 
			connection_db()
			cursor.execute(sql_query, _args["tuple"] + (id, ))
			conn.commit()
			_res = jsonify(response(message))
			_res.status_code = 200
			return _res
		else:
			return not_found()
	except Exception as e:
		print(e)
	finally:
		close_db()

def api_delete(id, table=TABLE_USER, message="deleted successfully!"):
	try:
		if id is not None and request.method == 'DELETE':
			sql_query = delete_request(table, " id=%s") 
			connection_db()
			cursor.execute(sql_query, (id, ))
			conn.commit()
			_res = jsonify(response(message))
			_res.status_code = 200
			return _res
		else:
			return not_found()
	except Exception as e:
		print(e)
	finally:
		close_db()


#endregion