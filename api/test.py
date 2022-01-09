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

def handle_req_args(wanted):
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


t = handle_req_args(["hey", "mail", {"field":"hi", "required":False, "value":"testVak"}])
print("args req = ", t)
"""
exemple de retour =
args req =  {'isAllExist': True, 'isAllRequiredExist': True, 'tuple': ('heyVal', 'gwen@gmail.com', 'hiVal'), 'args': [{'key': 'hey', 'value': 'heyVal'}, {'key': 'mail', 'value': 'gwen@gmail.com'}, {'key': 'hi', 'value': 'hiVal'}], 'dict': {'hey': 'heyVal', 'mail': 'gwen@gmail.com', 'hi': 'hiVal'}, 'required': 2}
zefezfzef {'a': 121}
('r', 'fzef')
"""

#t = get_req_args(["hey"], z="dezd")
#print(t)
