import pymysql
from utils.config import mysql
from utils.request_helper import *
from flask import jsonify, request, session, redirect, url_for

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


def handle_req_args_old(wanted):
	_json = request.json
	_args = []
	for el in wanted:
		if (isinstance(el, str)):
			if (el in _json):
				_args.append(_json[el])
		elif(el["field"] in _json):
			_args.append(_json[el["field"]])
	return {"isAllExist":len(wanted)==len(_args),"tuple":tuple(_args)}


#[String, {"field":String, "required":Boolean}, ...]
def handle_req_args(wanted):
	_json = request.json
	_args = []
	_tuple = []
	_dict = {}
	_required = 0
	for el in wanted:
		if (isinstance(el, str)):
			if (el in _json):
				val = str(_json[el])
				_args.append({"key":el, "value":val})
				_tuple.append(val)
				_dict[el] = val
				_required += 1
		elif(el["field"] in _json or el["value"]):
			val = str(_json.get(el["field"], el.get("value")))
			_args.append({"key":el["field"], "value":val})
			_tuple.append(val)
			_dict[el["field"]] = val

			if(el.get("required", True)):
				_required +=1

	return {"isAllExist":len(wanted)==len(_args), "isAllRequiredExist":len(_args)>=_required,"tuple":tuple(_tuple),"args":_args, "dict":_dict, "required":_required}


def location_req():
	try:
		_args_location = handle_req_args(["lat", "lon", "address", "country", "city"])
		if _args_location["isAllExist"] and request.method == 'POST':
			conn = mysql.connect()
			cursor = conn.cursor()
			sql_query_get_location = f"""SELECT id from {TABLE_LOCATIONS} 
			WHERE city=%s
			AND country=%s
			AND address=%s
			"""
			cursor.execute(sql_query_get_location, (_args_location["dict"]["city"], _args_location["dict"]["country"], _args_location["dict"]["address"]))
			row = cursor.fetchone()
			if row and row[0]:
				_location_id = row[0]
			else:
				sql_query_location = insert_request(TABLE_LOCATIONS, _args_location["args"]) 
				cursor.execute(sql_query_location, _args_location["tuple"])
				_location_id = conn.insert_id()
			conn.commit()
			return _location_id
		else:
			return None
	except Exception as e:
		print(e)
		return None
	finally:
		cursor.close() 
		conn.close()

def connection_select(request, id=None):
	try:
		conn = mysql.connect()
		cursor = conn.cursor(pymysql.cursors.DictCursor)
		if id:
			cursor.execute(request, id)
			empRows = cursor.fetchone()
		else:
			cursor.execute(request)
			empRows = cursor.fetchall()
		respone = jsonify(response(empRows))
		respone.status_code = 200
		return respone
	except Exception as e:
		print(e)
		return None
	finally:
		cursor.close() 
		conn.close()

def connection_insert(wanted,table=TABLE_USER, message="added successfully!"):
	try:
		_args = handle_req_args(wanted)
		if _args["isAllExist"] and request.method == 'POST':
			sql_query = insert_request(table, _args["args"]) 
			conn = mysql.connect()
			cursor = conn.cursor()
			cursor.execute(sql_query, _args["tuple"])
			conn.commit()
			respone = jsonify(response(message))
			respone.status_code = 200
			return respone
		else:
			return not_found()
	except Exception as e:
		print(e)
	finally:
		cursor.close() 
		conn.close()

def connection_update(wanted, table=TABLE_USER, message="updated successfully!", id=None):
	try:
		_args = handle_req_args(wanted)
		if _args["isAllRequiredExist"] and  len(_args["tuple"])>0 and id is not None and request.method == 'PUT':
			sql_query = update_request(table, _args["args"], " id=%s") 
			conn = mysql.connect()
			cursor = conn.cursor()
			cursor.execute(sql_query, _args["tuple"] + (id, ))
			conn.commit()
			respone = jsonify(response(message))
			respone.status_code = 200
			return respone
		else:
			return not_found()
	except Exception as e:
		print(e)
	finally:
		cursor.close() 
		conn.close()

def connection_delete(id, table=TABLE_USER, message="deleted successfully!"):
	try:
		if id is not None and request.method == 'DELETE':
			sql_query = delete_request(table, " id=%s") 
			conn = mysql.connect()
			cursor = conn.cursor()
			cursor.execute(sql_query, (id, ))
			conn.commit()
			respone = jsonify(response(message))
			respone.status_code = 200
			return respone
		else:
			return not_found()
	except Exception as e:
		print(e)
	finally:
		cursor.close() 
		conn.close()


