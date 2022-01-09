from app import app
from parser import *
from flaskext.mysql import MySQL

mysql = MySQL()

#.yaml shouldn't contains tab, use space
app.config['MYSQL_DATABASE_USER'] = get_data_config("user") #'root'
app.config['MYSQL_DATABASE_PASSWORD'] = get_data_config("password") #''
app.config['MYSQL_DATABASE_DB'] = get_data_config("db_name") #'goTogether'
app.config['MYSQL_DATABASE_HOST'] = get_data_config("host") #'localhost'

mysql.init_app(app)
