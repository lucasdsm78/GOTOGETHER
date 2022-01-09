
//#region Handle Promise Fetch
/**
 * @param promise : Promise<Response> :
 */
function fetchLogJson(promise){
    return promise
        .then(response => response.json())
        .then(response =>{
            console.log(response);
            return response})
        .catch(e=>console.error(e));
}

/**
 * @param promise : Promise<Response> :
 */
function fetchLogAll(promise){
    promise
        .then(response => response.json())
        .then(response => {
            console.log(response)
            return response
        })
        .catch(e=>console.error(e));
}

/**
 * @param promise : Promise<Response> :
 */
function fetchJsonify(promise){
    return promise
        .then(response => response.json())
        .then(response => {return response})
        .catch(e=>console.error(e));
}

/**
 * @param promise : Promise<Response> :
 */
function fetchGetSuccess(promise){
    return promise
        .then(response => response.json())
        .then(response => {return response.success})
        .catch(e=>console.error(e));
}
/**
 * @param promise : Promise<Response> :
 */
function fetchGetResponse(promise){
    return promise
        .then(response => response.json() )
        .catch(e=>console.error(e));
}
//#endregion

/**
 * Write all params in a get query (exemple : ?search=js&name=delete)
 * You can specify the field to ignore from params
 * @param isFirstParam
 * @param params {Object} : exemple {search:js, name:delete}
 * @param ignored {Array} : exemple ["name"]
 * @return {string}
 */
function handleUrlParams(isFirstParam, params={}, ignored=[]){
    let paramsTxt = "";
    let count = 0;
    Object.keys(params).forEach((el)=>{
        if(!ignored.includes(el) && !isNullOrUndefined(params[el])) {
            paramsTxt += (isFirstParam && count === 0 ? "?" : "&") + el + "=" + params[el];
            count++;
        }
    })
    return paramsTxt;
}

URL_BASE = "http://51.255.51.106:5000/"

function apiInsertUser(body){
	//body is JSON.stringify()
    return fetchJsonify(fetch( URL_BASE + 'add/user', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body
    }));
}

function apiUpUser(id, body){ 
    return fetchJsonify(fetch( URL_BASE + 'update/user/' + id, {
        method: 'PUT',
        headers: {
            'Content-Type': 'application/json'
        },
        body
    }));
}

function apiDelUser(id){ 
    return fetchJsonify(fetch( URL_BASE + 'delete/' + id, {
        method: 'DELETE',
        headers: {
            'Content-Type': 'application/json'
        }
    }));
}


bodyActivity = JSON.stringify({
	lat:10, lon:15, address:"5 rue l'Oise", country:"France", city:"Cergy",
	idHostUser:2, dateStart:"2021-12-30 10:30", dateEnd:"2021-12-30 11:30", participantsNumber:22, 
	idLevel:3, description:"match de foot entre amis et amateur"
})
function apiAddActivity(body){ 
    return fetchJsonify(fetch( URL_BASE + 'add/activity', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body
    }));
}

bodyActivityUpdate = JSON.stringify({
	lat:10, lon:15, address:"5 rue l'Oise", country:"France", city:"Cergy",
	idHostUser:2, dateStart:"2021-12-30 10:45", dateEnd:"2021-12-30 11:30", participantsNumber:22, 
	idLevel:3, description:"match de foot entre amis et amateur"
})
bodyActivityUpdateUncomplete = JSON.stringify({
	participantsNumber:44,
})
function apiUpdateActivity(idActivity, body){ 
    return fetchJsonify(fetch( URL_BASE + 'update/activity/' + idActivity, {
        method: 'PUT',
        headers: {
            'Content-Type': 'application/json'
        },
        body
    }));
}

function apiCancelActivity(idActivity){ 
    return fetchJsonify(fetch( URL_BASE + 'cancel/activity/' + idActivity, {
        method: 'PATCH',
        headers: {
            'Content-Type': 'application/json'
        }
    }));
}


bodyJoinActivity = JSON.stringify({
	idUser:1, idActivity:1, isJoining:1
})
function apiJoinActivity(body){ 
    return fetchJsonify(fetch( URL_BASE + 'joining/activity' , {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body
    }));
}

function apiGetParticipants(idActivity){ 
    return fetchJsonify(fetch( URL_BASE + 'get/participants/' + idActivity))
}

