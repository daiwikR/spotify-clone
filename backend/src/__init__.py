from flask import Flask, jsonify
from flask_mysqldb import MySQL
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = 'Daiwik@2004'
app.config['MYSQL_DB'] = 'spotty'


mysql = MySQL(app)
