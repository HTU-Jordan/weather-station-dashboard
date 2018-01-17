
#######################################################################
# Initialization Functions
#######################################################################

#######################################################################
# Import Libraries
from datetime import datetime
import pyodbc
import pandas as pd
import numpy as np
from sqlalchemy import create_engine

#######################################################################
# Open Connection to SQL-Server
def pycon():
	return pyodbc.connect('DSN=weather-ODBC;Trusted_Connection=yes;Driver={SQL Server Native Client 11.0}')


#######################################################################
# Define sqlalchemy engine and pyodbc cursor
def cursor_engine(cnxn):
	engine = create_engine('mssql+pyodbc://', creator=pycon, echo=True)
	cursor = cnxn.cursor()
	return(engine, cursor)
#######################################################################
# Get Record from DB
def get_record(cursor):
	record_hour = cursor.execute("SELECT MAX(rec) from perHOUR").fetchall()
	return(record_hour[-1][0])
	   
#######################################################################
# Read data from file and get last record
def read_data():
	# Choose Columns
	col_indexes = [0, 1, 2, 3, 4, 6, 7, 8, 9, 10] # 9 Columns
	c_names = ['ts', 'rec', 'ws', 'wd', 'srad', 'temp', 'rh', 'rain', 'vis', 'bp']
	# Read data - begin @ #5th row - no headers
	file_loc = "C:/Campbellsci/LoggerNet/CR1000_OneHour.dat"
	df_hour = pd.read_csv(file_loc, skiprows=4, usecols=col_indexes, names=c_names)
	rec_hour = df_hour.tail(1)['rec']
	df_hour.set_index('rec', inplace=True)
	return (df_hour, rec_hour) 

#######################################################################
def get_rec_delta(record_hour):
	df_hour, rec_hour = read_data()
	return(rec_hour - record_hour, df_hour)

#######################################################################
# Get df subset
def subset_df(rec_delta_hour, df_hour):
	return(df_hour.tail(int(rec_delta_hour)))

#######################################################################
# Append to DB
def append_to_db_perHOUR(x):
	x.to_sql(con=engine, name="perHOUR", if_exists="append")

#######################################################################
# MAIN LOOP
#######################################################################
if __name__ == '__main__':

	cnxn = pycon()
	engine, cursor = cursor_engine(cnxn)
	record_hour = get_record(cursor)  
	cursor.close()
	del cursor

	rec_delta_hour, df_hour = get_rec_delta(record_hour)
	x = subset_df(rec_delta_hour, df_hour)
			
	append_to_db_perHOUR(x)
	cnxn.close()   

	print("Database was last updated on: " + str(datetime.now()))
			





