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

	"get_activities": {"path":"/get/activities", "label":"provide db activities", "example_args":"?sport=football&location=3&begin=2021-12-22_10:30&end=2021-12-22_12:30&description=foot,friends,itescia"},
	"get_activity_id": {"path":"/get/activity/<int:id>", "label":"provide db activity by its id", "example_args":""},
	"get_participants_id": {"path":"/get/participants/<int:idActivity>", "label":"provide db activity's participants by its id", "example_args":""},
}

#@todo : rename connection_select/insert/.... into bdd_select/insert/....
#region user routes
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
def update_user(id):
	return connection_update([{"field":"username", "required":False}, {"field":"mail", "required":False}, {"field":"password", "required":False}], id=id)


@app.route('/delete/user/<int:id>', methods=['DELETE'])
def delete_user(id):
	return connection_delete(id)
#endregion

#region activity
def get_activity_req_base():
	return """SELECT U.id as hostId,  U.username as hostName, U.mail as hostMail, 
		A.id as activityId, A.dateStart, A.dateEnd, A.participantsNumber, A.description, 
		A.isCanceled, A.updatedAt,
		L.name as level, LOC.id as locationId, LOC.lat , LOC.lon, LOC.address, LOC.country, LOC.city

		FROM activities as A 
		LEFT JOIN users as U on U.id = A.idHostUser 
		LEFT JOIN _level as L on L.id = A.idLevel 
		LEFT JOIN locations as LOC on LOC.id = A.idLocation
		"""

@app.route(get_routes["get_activities"]["path"], methods=["GET"])
def get_activities():
	#@todo : permettre de faire un where en fonction de donné fournie en param dans l'url (ex plus haut)
	return connection_select(get_activity_req_base())

@app.route(get_routes["get_activity_id"]["path"], methods=["GET"])
def get_activity_by_id(id):
	return connection_select(get_activity_req_base() + """ WHERE A.id =%s;""", id)

@app.route('/add/activity', methods=['POST'])
def add_activity():
	try:
		_location_id = location_req()
		if _location_id and request.method == 'POST':
			conn = mysql.connect()
			cursor = conn.cursor()
			_args = handle_req_args(["idHostUser", "dateStart", "dateEnd", "participantsNumber", "idLevel", "description", {"field":"idLocation", "required":False, "value":_location_id}])
			sql_query = insert_request(TABLE_ACTIVITIES, _args["args"]) 
			cursor.execute(sql_query, _args["tuple"])
			_activity_id = conn.insert_id()
			conn.commit()
			respone = jsonify(response({"message":"Activity added successfully", "idActivity":_activity_id}))
			respone.status_code = 201
			return respone
		else:
			return not_found()
	except Exception as e:
		print(e)
	finally:
		cursor.close() 
		conn.close()


@app.route('/update/activity/<int:id>', methods=['PUT'])
def update_activity(id):
	_location_id = location_req()
	wanted = [{"field":"idHostUser", "required":False}, {"field":"dateStart", "required":False}, {"field":"dateEnd", "required":False}, 
		{"field":"participantsNumber", "required":False}, {"field":"idLevel", "required":False}, {"field":"description", "required":False}]
	if _location_id:
		wanted.append({"field":"idLocation", "required":False, "value":_location_id})
	return connection_update(wanted, TABLE_ACTIVITIES, id=id)

@app.route('/cancel/activity/<int:idActivity>', methods=['PATCH'])
def cancel_activity(idActivity):
	try:
		conn = mysql.connect()
		cursor = conn.cursor()
		sql_query = update_request(TABLE_ACTIVITIES, ["isCanceled"], " id=%s") 
		cursor.execute(sql_query, ("1", str(idActivity)))
		conn.commit()
		respone = jsonify(response("Activity added successfully"))
		respone.status_code = 200
		return respone
	except Exception as e:
		print(e)
	finally:
		cursor.close() 
		conn.close()

@app.route('/joining/activity', methods=['POST'])
def joining_activity():
	try:
		_args = handle_req_args(["idUser", "idActivity"])
		isJoining = request.json["isJoining"]
		if _args["isAllExist"] and request.method == 'POST':
			conn = mysql.connect()
			cursor = conn.cursor()
			if (isJoining):
				sql_query = insert_request(TABLE_ACTIVITIES_USERS, _args["args"]) 
			else:
				sql_query = delete_request(TABLE_ACTIVITIES_USERS, " idUser = %s AND idActivity = %s ") 

			cursor.execute(sql_query, _args["tuple"])
			conn.commit()
			respone = jsonify(response( ("Joining" if isJoining  else "Quit") + " activity successfully"))
			respone.status_code = 200
			return respone
		else:
			return not_found()
	except Exception as e:
		print(e)
	finally:
		cursor.close() 
		conn.close()


@app.route(get_routes["get_participants_id"]["path"], methods=['GET'])
def get_activity_participant_by_id(idActivity):
	return connection_select(f"""SELECT U.mail, U.username, U.id
		FROM activitiesUsers as AU
		LEFT JOIN users as U ON U.id = AU.idUser
		WHERE AU.idActivity = {idActivity}
		""")

#endregion


@app.errorhandler(404)
def not_found(error=None):
	message = {
		'status': 404,
		'message': 'Record not found: ' + request.url,
	}
	respone = jsonify(message)
	respone.status_code = 404
	return respone

def bad_request(error=None):
	message = {
		'status': 400,
		'message': 'Bad request : ' + request.url,
	}
	respone = jsonify(message)
	respone.status_code = 400
	return respone


if __name__ == "__main__":
	app.run(host=HOST)
