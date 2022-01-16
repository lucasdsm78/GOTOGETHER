"""
These 'requests' are just a base common between some routes,
it don't handle complex where expression
"""

def get_activity_req_base():
	return """SELECT  U.id as hostId,  U.username as hostName, U.mail as hostMail, 
		A.id as activityId, A.dateStart, A.dateEnd, A.participantsNumber, A.description, 
		A.isCanceled, A.updatedAt,
		S.name as sport, S.id as sportId, 
		L.name as level, LOC.id as locationId, LOC.lat , LOC.lon, LOC.address, LOC.country, LOC.city,
		(SELECT GROUP_CONCAT(AU.idUser) from activitiesUsers as AU WHERE AU.idActivity = A.id GROUP BY A.id ) as participantsIdConcat,
		(SELECT COUNT(AU.idUser) from activitiesUsers as AU WHERE AU.idActivity = A.id GROUP BY A.id ) as nbCurrentParticipants

		FROM activities as A 
		LEFT JOIN users as U on U.id = A.idHostUser 
		LEFT JOIN _level as L on L.id = A.idLevel 
		LEFT JOIN _sports as S on S.id = A.idSport 
		LEFT JOIN locations as LOC on LOC.id = A.idLocation
		"""

def get_all_users():
	return "SELECT id, username, mail, role FROM users"

def get_user_by_id():
	return "SELECT id as id, username as username, mail as mail, role as role FROM users WHERE id =%s"

def get_all_sports():
	return "SELECT id, name  FROM _sports"


def get_activity_participant_by_id():
	return """SELECT U.mail, U.username, U.id
		FROM activitiesUsers as AU
		LEFT JOIN users as U ON U.id = AU.idUser"""