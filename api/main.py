import pymysql #would be removed
from app import app
from utils.config import mysql
from flask import jsonify, flash, request, session, redirect, url_for
from utils.api_helper import *
from utils.request_helper import *
import utils.requests_string as request_str

HOST = "51.255.51.106"
PORT = 5000
API_URL = f"http://{HOST}:{PORT}"
	
get_routes = {
	"get_users": {"path":"/get/users", "label":"provide db users", "example_args":""},
	"get_user_id": {"path":"/get/user/<int:id>", "label":"provide db user by its id", "example_args":""},

	"get_activities": {"path":"/get/activities", "label":"provide db activities", "example_args":"?sport=football&location=3&begin=2021-12-22_10:30&end=2021-12-22_12:30&description=foot,friends,itescia"},
	"get_activity_id": {"path":"/get/activity/<int:id>", "label":"provide db activity by its id", "example_args":""},
	"get_participants_id": {"path":"/get/participants/<int:idActivity>", "label":"provide db activity's participants by its id", "example_args":""},
}

#@todo : add a secret key required to use api ()
#@todo : rename api_select/insert/.... into bdd_select/insert/....
#@todo : DB users table should have more fields,  insert/update user request too
#@todo : all string request in constant, into a new file request.py 
#@todo : permettre de faire un where en fonction de donné fournie en param dans l'url (ex plus haut dans get_routes)

#region user routes
@app.route(get_routes["get_users"]["path"], methods=["GET"])
def get_users():
	return api_select(request_str.get_all_users())


@app.route(get_routes["get_user_id"]["path"])
def get_user_by_id(id):
	return api_select(request_str.get_user_by_id(), id)

@app.route('/add/user', methods=['POST'])
def add_user():
	return api_insert(["username", "mail", "password"], message="User added successfully!", get_request=request_str.get_user_by_id())


@app.route('/update/user/<int:id>', methods=['PUT'])
def update_user(id):
	return api_update([{"field":"username", "required":False}, {"field":"mail", "required":False}, {"field":"password", "required":False}], id=id)


@app.route('/delete/user/<int:id>', methods=['DELETE'])
def delete_user(id):
	return api_delete(id)
#endregion

#region activity
@app.route(get_routes["get_activities"]["path"], methods=["GET"])
def get_activities():
	return api_select(request_str.get_activity_req_base())

@app.route(get_routes["get_activity_id"]["path"], methods=["GET"])
def get_activity_by_id(id):
	return api_select(request_str.get_activity_req_base() + " WHERE A.id =%s;", id)

@app.route('/add/activity', methods=['POST'])
def add_activity():
	return add_activity_req()

@app.route('/update/activity/<int:id>', methods=['PUT'])
def update_activity(id):
	return update_activity_req(id)

@app.route('/cancel/activity/<int:idActivity>', methods=['PATCH'])
def cancel_activity(idActivity):
	return cancel_activity_req(idActivity)

@app.route('/joining/activity', methods=['POST'])
def joining_activity():
	return joining_activity_req()

@app.route(get_routes["get_participants_id"]["path"], methods=['GET'])
def get_activity_participant_by_id(idActivity):
	return api_select(request_str.get_activity_participant_by_id() + f" WHERE AU.idActivity = {idActivity}")

#endregion


#region errors
@app.errorhandler(404)
def not_found(error=None):
	message = {
		'status': 404,
		'message': 'Record not found: ' + request.url,
	}
	_res = jsonify(message)
	_res.status_code = 404
	return _res

def bad_request(error=None):
	message = {
		'status': 400,
		'message': 'Bad request : ' + request.url,
	}
	_res = jsonify(message)
	_res.status_code = 400
	return _res

#endregion

if __name__ == "__main__":
	app.run(host=HOST)
