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


def handle_req_args(wanted):
	_json = request.json
	_args = []
	_tuple = []
	_required = 0
	for el in wanted:
		if (isinstance(el, str)):
			if (el in _json):
				_args.append({"key":el, "value":_json[el]})
				_tuple.append(_json[el])
				_required += 1
		elif(el["field"] in _json):
			_args.append({"key":el["field"], "value":_json[el["field"]]})
			_tuple.append(_json[el["field"]])
			if(el.get("required", True)):
				_required +=1
	return {"isAllExist":len(wanted)==len(_args), "isAllRequiredExist":len(_args)>=_required,"tuple":tuple(_tuple),"args":_args, "required":_required}



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
			sqlQuery = insert_request(table, _args["args"]) 
			conn = mysql.connect()
			cursor = conn.cursor()
			cursor.execute(sqlQuery, _args["tuple"])
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
			sqlQuery = update_request(table, _args["args"], " id=%s") 
			conn = mysql.connect()
			cursor = conn.cursor()
			cursor.execute(sqlQuery, _args["tuple"] + (id, ))
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
			sqlQuery = delete_request(table, " id=%s") 
			conn = mysql.connect()
			cursor = conn.cursor()
			cursor.execute(sqlQuery, (id, ))
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


