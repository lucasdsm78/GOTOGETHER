from flask import Flask
from flask_cors import CORS, cross_origin

app = Flask(__name__)
CORS(app)

if __name__ == '__main__':
	if __package__ is None:
		import sys
		from os import path
		sys.path.append( path.dirname( path.dirname( path.abspath(__file__) ) ) )
		from components.core import GameLoopEvents
	else:
		from ..components.core import GameLoopEvents