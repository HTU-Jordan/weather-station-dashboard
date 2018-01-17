#######################################################################
# Import Libraries
import pyodbc
import pandas as pd
import numpy as np
from sqlalchemy import create_engine

#######################################################################
# # Define sqlalchemy engine
# cnxn = pyodbc.connect(r"DRIVER={ODBC Driver 13 for SQL Server};Authentication=ActiveDirectoryIntegrated;TrustServerCertificate=Yes;Encrypt=Yes;DATABASE=weatherDB;WSID=HTU-SQLDEV;APP={Microsoft® Windows® Operating System};SERVER=HTU-SQLDEV"
# )

# engine = create_engine("pyodbc://@192.168.20.16:1433/?{driver};Trusted_Connection=yes"
#                       .format(driver="{SQL Server Native Client 11.0}"))

# engine = create_engine('pyodbc://', creator=cnxn, echo=True)

# def connect():
#     return pyodbc.connect('DSN=weather-ODBC;driver=C:\Windows\system32\odbc32.dll;Database=weatherDB')

# engine = create_engine('sybase+pyodbc://', creator=connect, echo=True)
#def connect_to_db():
	#return pyodbc.connect(r'Driver={ODBC Driver 13 for SQL Server};Server=HTU-SQLDEV;Database=weatherDB;Trusted_Connection=yes;')


# Open Connection to SQL-Server
# def connect_to_db():
# 	cnxn = pyodbc.connect(r"Driver={SQL Server Native Client 11.0};"
# 						  r"Server=192.168.20.16:1433;"
# 						  r"Database=weatherDB;"
# 						  r"Trusted_Connection=yes;")
# 	cursor = cnxn.cursor()
# 	return(cursor)


import pyodbc, sqlalchemy

def connect():
    return pyodbc.connect('DSN=weather-ODBC;Trusted_Connection=yes')

def create_eng():
	engine = sqlalchemy.create_engine('mssql+pyodbc://', creator=connect, echo=True)
	return(engine)
#######################################################################
# Get Record from DB
# def get_data():
#     cursor = connect_to_db()
#     record = cursor.execute("SELECT * from perFIFTEENSEC").fetchall()
#     return(record[-1])
    


#######################################################################
# Read data from file and get last record
def read_data():
   	# Choose Columns
	col_indexes = [0, 1, 2, 3, 4, 6, 7, 8, 9, 10] # 9 Columns
	c_names = ['ts', 'rec', 'ws', 'wd', 'srad', 'temp', 'rh', 'rain', 'vis', 'bp']
	# Read data - begin @ #5th row - no headers
	file_loc = "C:/Campbellsci/LoggerNet/CR1000_OneMin.dat"
	df_minute = pd.read_csv(file_loc, skiprows=4, usecols=col_indexes, names=c_names)
	rec_minute = df_minute.tail(1)['rec']
	df_minute.set_index('rec', inplace=True)   
	file_loc = "C:/Campbellsci/LoggerNet/CR1000_OneHour.dat"
	df_hour = pd.read_csv(file_loc, skiprows=4, usecols=col_indexes, names=c_names)
	rec_hour = df_hour.tail(1)['rec']
	df_hour.set_index('rec', inplace=True)
	return(df_minute, df_hour)

#######################################################################
# Append to DB
def append_to_db_perHOUR(x):
    x.to_sql(con=engine, name="perHOUR", if_exists="replace")

def append_to_db_perMINUTE(x):
    x.to_sql(con=engine, name="perMINUTE", if_exists="replace")



#######################################################################
# MAIN LOOP
#######################################################################
if __name__ == '__main__':
	#connect_to_db()
	connect()
	engine = create_eng()
	df_minute, df_hour = read_data()
	append_to_db_perMINUTE(df_minute)
	append_to_db_perHOUR(df_hour)
	

