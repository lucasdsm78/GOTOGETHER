#import utils.requests_string as request
#print(request.get_all_users())

defa = ["hey"]
def get_req_args(wanted, a="tss", z=""):
	_json = {"hey":1, "hi":2 ,"mail":"gwen@"}
	print(a,z)
	_args = []
	for el in wanted:
		if el in _json:
			print(_json[el])
			_args.append(_json[el])
	return {"isAllExist":len(wanted)==len(_args),"tuple":tuple(_args)}


def get_req_args2(wanted):
	#_json = {"hey":"heyVal", "hi":"hiVal" ,"mail":"gwen@gmail.com"}
	_json = {"hey":"heyVal", "hi":"hiVal","mail":"gwen@gmail.com"}
	_args = []
	_required = []
	for el in wanted:
		if (isinstance(el, str)):
			if (el in _json):
				_args.append(_json[el])
				_required.append({"key":el, "value":_json[el]})
		elif(el["field"] in _json):
			_args.append(_json[el["field"]])
			if(el.get("required", True)):
				required.append({"key":el, "value":_json[el]["field"]})
	return {"isAllExist":len(wanted)==len(_args), "isAllRequiredExist":len(_args)>=len(_required),"tuple":tuple(_args), "required":_required}



def get_req_args3(wanted):
	#_json = {"hey":"heyVal", "hi":"hiVal" ,"mail":"gwen@gmail.com"}
	_json = {"hey":"heyVal", "mail":"gwen@gmail.com"}
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

def handle_req_body(wanted):
	_json = {"hey":"heyVal", "hi":"hiVal","mail":"gwen@gmail.com"}
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


t = handle_req_body(["hey", "mail", {"field":"hi", "required":False, "value":"testVak"}])
print("args req = ", t)
"""
exemple de retour =
args req =  {'isAllExist': True, 'isAllRequiredExist': True, 'tuple': ('heyVal', 'gwen@gmail.com', 'hiVal'), 'args': [{'key': 'hey', 'value': 'heyVal'}, {'key': 'mail', 'value': 'gwen@gmail.com'}, {'key': 'hi', 'value': 'hiVal'}], 'dict': {'hey': 'heyVal', 'mail': 'gwen@gmail.com', 'hi': 'hiVal'}, 'required': 2}
zefezfzef {'a': 121}
('r', 'fzef')
"""

#t = get_req_args(["hey"], z="dezd")
#print(t)




t= {'isAllExist': True, 'isAllRequiredExist': True, 'tuple': ('1',), 'args': [{'key': 'id', 'value': '1'}], 'dict': {'id': '1'}, 'required': 1}
print(len(t.get("args")))
def where_clause(wanted):
	if (len(wanted)==0):
		return ""
	where_clause = " WHERE "
	total_len = len(wanted)
	i=0
	for el in wanted:
		if (isinstance(el, str)):
			where_clause += el + "=%s" + (" AND " if i < total_len-1 else " " )
		else:
			where_clause += el["key"] + "=%s" + (" AND " if i < total_len-1 else " " )
		i +=1
	return where_clause

print("where clause= ", where_clause(t.get("args")))
