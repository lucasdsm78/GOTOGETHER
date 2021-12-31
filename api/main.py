import pymysql #would be removed
from app import app
from utils.config import mysql
from flask import jsonify, flash, request, session, redirect, url_for
from utils.api_helper import *

HOST = "51.255.51.106"
PORT = 5000
API_URL = f"http://{HOST}:{PORT}"
	
get_routes = {
	"get_users": {"path":"/get/users", "label":"provide db users", "example_args":""},
	"get_user_id": {"path":"/get/user/<int:id>", "label":"provide db user by its id", "example_args":""},
}


@app.route(get_routes["get_users"]["path"], methods=["GET"])
def get_users():
	return connection_select("SELECT id, username, mail, role FROM users")


@app.route(get_routes["get_user_id"]["path"])
def get_user_by_id(id):
	return connection_select("SELECT id, username, mail, role FROM users WHERE id =%s", id)

@app.route('/add/user', methods=['POST'])
def add_user():
	return connection_insert(["username", "mail", "password"], message="User added successfully!")


@app.route('/update/user/<int:id>', methods=['PUT'])
def update_get_emp(id):
	return connection_update([{"field":"username", "required":False}, {"field":"mail", "required":False}, {"field":"password", "required":False}], id=id)


@app.route('/delete/user/<int:id>', methods=['DELETE'])
def delete_get_emp(id):
	return connection_delete(id)

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
