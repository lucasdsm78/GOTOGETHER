from enum import Enum

"""
ce fichier devras contenir toute nos tables
l'idée serait de normée les noms 
"""

class DbTypes(Enum):
    INT = 1,
    FLOAT = 2 ,
    STRING = 3,
    DATE = 4,
    BOOL = 5,
    
ALIAS = "alias"
IDENTIFIER = "identifier"
TABLE = "table"
COLUMNS = "columns"

"""
Enum call, with a Color enum
print(Color.RED)
print(repr(Color.RED))
isinstance(Color.GREEN, Color)
print(Color.RED.name)
Color(1)
Color['RED']
"""



MODEL_LOCATIONS = {
    ALIAS:"LOC",
    IDENTIFIER:"Location",
    TABLE:"locations",
    COLUMNS:[
        { "name":"id", "type":DbTypes.INT},
        { "name":"lat", "type":DbTypes.FLOAT},
        { "name":"lon", "type":DbTypes.FLOAT},
        { "name":"address", "type":DbTypes.STRING},
        { "name":"country", "type":DbTypes.STRING},
        { "name":"city", "type":DbTypes.STRING},
        { "name":"createdAt", "type":DbTypes.DATE},
        { "name":"updatedAt", "type":DbTypes.DATE},
           
    ]
}
MODEL_USERS = {
    ALIAS:"A",
    IDENTIFIER:"User",
    TABLE:"users",
    COLUMNS:[
        { "name":"id", "type":DbTypes.INT},
        { "name":"username", "type":DbTypes.STRING},
        { "name":"mail", "type":DbTypes.STRING},
        { "name":"password", "type":DbTypes.STRING},
        { "name":"role", "type":DbTypes.STRING},
        { "name":"gender", "type":DbTypes.STRING},
        { "name":"birthday", "type":DbTypes.DATE},
        { "name":"idLocation", "type":DbTypes.INT, "ref":MODEL_LOCATIONS[TABLE]},
        { "name":"monday", "type":DbTypes.BOOL},
        { "name":"tuesday", "type":DbTypes.BOOL},
        { "name":"wednesday", "type":DbTypes.BOOL},
        { "name":"thursday", "type":DbTypes.BOOL},
        { "name":"friday", "type":DbTypes.BOOL},
        { "name":"saturday", "type":DbTypes.BOOL},
        { "name":"sunday", "type":DbTypes.BOOL},
    ]
}

DB_TABLES = {
    MODEL_USERS[TABLE]: MODEL_USERS,
    MODEL_LOCATIONS[TABLE] : MODEL_LOCATIONS
}


def get_table_columns(table, firstCol=False):
    
    columns = DB_TABLES[table][COLUMNS]
    alias = DB_TABLES[table][ALIAS]
    identifier = DB_TABLES[table][IDENTIFIER]

    sql_request = "" if firstCol else " , "
    i=0
    while i < len(columns):
        sql_request += " " + alias + "." + columns[i]["name"] + identifier  + ("," if i < len(columns)-1 else " " )
        i +=1

    return sql_request

print(get_table_columns("locations"))
        





