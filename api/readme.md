
##notre api ovh
pour lancer l'api, executer `python3 /var/www/html/api/main.py` sur le server 

sur ovh ; on a mis les fichiers sur /var/www/html/api
il faut lancer la commande aprés connection sur centos, et on pourra faire des requete type:
http://51.255.51.106:5000/get/users


s'il faut kill le process : 
fuser -k 5000/tcp 


##pour l'api google maps
besoin d'une API KEY

pour obtenir le nom de ville, pays ...
exemple : http://maps.googleapis.com/maps/api/geocode/json?latlng=40.714224,-73.961452&sensor=false
address="" //will be nb of street + route name
res.results[0]["address_components"].forEach({el=>
	if(el.types.includes("locality")){
		city = el.long_name
	}
	if(el.types.includes("country")){
		country = el.long_name
	}
	if(el.types.includes("postal_code")){
		postalCode = el.long_name
	}
	if(el.types.includes("street_number")){
		address += el.long_name
	}
	if(el.types.includes("route")){
		address = el.long_name + address
	}
	
})