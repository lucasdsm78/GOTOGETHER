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
	"get_users": {"path":"/get/users", "label":"provide db users", "example_args":"?mail=gwen@gmail.com&username=gwen"},
	"get_user_id": {"path":"/get/user/<int:id>", "label":"provide db user by its id", "example_args":""},

	"get_activities": {"path":"/get/activities", "label":"provide db activities", "example_args":"?sportId=1&keywords=cergy,france&dateStart=2021-12-22 10:30&dateEnd=2021-12-22 12:30"},
	"get_activity_id": {"path":"/get/activity/<int:id>", "label":"provide db activity by its id", "example_args":""},
	"get_participants_id": {"path":"/get/participants/<int:idActivity>", "label":"provide db activity's participants by its id", "example_args":""},
	"get_sports":{"path":"/get/sports", "label":"provide sports from DB", "example_args":"?name=foot"},
	"get_sport_id":{"path":"/get/sport/<int:idSport>", "label":"provide sports from DB by its id", "example_args":""},
}

#@todo : add a secret key required to use api ()
#@todo : DB users table should have more fields,  insert/update user request too
#@todo : all string request in constant, into a new file request.py 

#region user routes
@app.route(get_routes["get_users"]["path"], methods=["GET"])
def get_users():
	_args = handle_req_args([{"field":"id", "required":False, "column":"users.id"}, {"field":"mail", "required":False, "column":"users.mail"}])
	_where = where_clause(_args.get("args"))
	#print(request_str.get_all_users(), _where, _args.get("tuple"))
	return api_select(request_str.get_all_users(), where=_where, rep_tuple=_args.get("tuple"))

@app.route(get_routes["get_user_id"]["path"])
def get_user_by_id(id):
	return api_select(request_str.get_user_by_id(), rep_tuple=(id,), is_unique=True)

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
	_args = handle_req_args([
	{"field":"sportId", "required":False, "column":"S.id"},
	{"field":"keywords", "required":False, "column":["A.description", "S.name", "LOC.city", "LOC.country", "U.mail", "U.username"], "type":"keywords", "exact":False, "comparison":"LIKE"},
	{"field":"dateStart", "required":False, "column":"A.dateStart", "type":"date", "comparison":">="},
	{"field":"dateEnd", "required":False, "column":"A.dateEnd", "type":"date", "comparison":"<="},
	])
	_where = where_clause(_args.get("args"))
	print(request_str.get_activity_req_base(), _where, _args.get("tuple"))
	return api_select(request_str.get_activity_req_base(), where=_where, rep_tuple=_args.get("tuple"))

@app.route(get_routes["get_activity_id"]["path"], methods=["GET"])
def get_activity_by_id(id):
	return api_select(request_str.get_activity_req_base(),  where=" WHERE A.id =%s;", rep_tuple=(id,), is_unique=True)

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
	return api_select(request_str.get_activity_participant_by_id(), where=" WHERE AU.idActivity = %s", rep_tuple=(str(idActivity), ), is_unique=True)

#endregion

#region others (like sports)
@app.route(get_routes["get_sports"]["path"], methods=['GET'])
def get_sports():
	_args = handle_req_args([{"field":"id", "required":False}, {"field":"name", "required":False, "exact":False, "comparison":"LIKE"}])
	_where = where_clause(_args.get("args"))
	print(request_str.get_all_sports(), _where, _args.get("tuple"))
	return api_select(request_str.get_all_sports(), where=_where, rep_tuple=_args.get("tuple"))

@app.route(get_routes["get_sport_id"]["path"], methods=['GET'])
def get_sport_by_id(idSport):
	return api_select(request_str.get_all_sports(), where=" WHERE id=%s", rep_tuple=(str(idSport), ), is_unique=True)
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
