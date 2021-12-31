import pymysql
from app import app
from utils.config import mysql
from flask import jsonify, flash, request, session, redirect, url_for
import utils.request_helper as req_h

HOST = "51.255.51.106"
PORT = 5000
API_URL = f"http://{HOST}:{PORT}"
	
get_routes = {
	"get_users": {"path":"/get/users", "label":"provide db users", "example_args":""},
	"get_user_id": {"path":"/get/users/<int:id>", "label":"provide db user by its id", "example_args":""},

}


@app.route(get_routes["get_users"]["path"], methods=["GET"])
def get_users():
	"""
	This route get all users in DB.
	:return: a json
	"""
	#return jsonify(db.get_user_query())
	return connection_select("SELECT id, username, mail, role FROM users")


@app.route(get_routes["get_user_id"]["path"])
def get_user_by_id(id):
	connection_select("SELECT id, name, email, phone, address FROM rest_emp WHERE id =%s", id)

def get_req_args(wanted):
	wanted = list(dict.fromkeys(wanted))
	_json = request.json
	_args = []
	for el in wanted:
		if (isinstance(el, str)):
			if (el in _json):
				_args.append(_json[el])
		elif(el["field"] in _json):
			_args.append(_json[el["field"]])
	return {"isAllExist":len(wanted)==len(_args),"tuple":tuple(_args)}

@app.route('/add', methods=['POST'])
def add_user():
	try:
		_json = request.json
		_args = get_req_args(["username", "mail", "password"])
		_username = _json['username']
		_mail = _json['mail']
		_password = _json['password']
		if _username and _mail and _password and request.method == 'POST':
			sqlQuery = "INSERT INTO rest_get_emp(username, mail, password) VALUES(%s, %s, %s)"
			bindData = (_username, _mail, _password)
			conn = mysql.connect()
			cursor = conn.cursor()
			cursor.execute(sqlQuery, bindData)
			conn.commit()
			respone = jsonify('User added successfully!')
			respone.status_code = 200
			return respone
		else:
			return not_found()
	except Exception as e:
		print(e)
	finally:
		cursor.close() 
		conn.close()


@app.route('/update', methods=['PUT'])
def update_get_emp():
	try:
		_json = request.json
		_id = _json['id']
		_name = _json['name']
		_email = _json['email']
		_phone = _json['phone']
		_address = _json['address']
		if _name and _email and _phone and _address and _id and request.method == 'PUT':		
			sqlQuery = "UPDATE rest_emp SET name=%s, email=%s, phone=%s, address=%s WHERE id=%s"
			bindData = (_name, _email, _phone, _address, _id,)
			conn = mysql.connect()
			cursor = conn.cursor()
			cursor.execute(sqlQuery, bindData)
			conn.commit()
			respone = jsonify('Employee updated successfully!')
			respone.status_code = 200
			return respone
		else:
			return not_found()
	except Exception as e:
		print(e)
	finally:
	 cursor.close() 
	 conn.close()

@app.route('/delete/<int:id>', methods=['DELETE'])
def delete_get_emp(id):
	try:
		conn = mysql.connect()
		cursor = conn.cursor()
		cursor.execute("DELETE FROM rest_emp WHERE id =%s", (id,))
		conn.commit()
		respone = jsonify('Employee deleted successfully!')
		respone.status_code = 200
		return respone
	except Exception as e:
		print(e)
	finally:
		cursor.close() 
		conn.close()

@app.errorhandler(404)
def not_found(error=None):
	message = {
		'status': 404,
		'message': 'Record not found: ' + request.url,
	}
	respone = jsonify(message)
	respone.status_code = 404
	return respone

if __name__ == "__main__":
	app.run(host=HOST)
