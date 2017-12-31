#######################################################################
# Import Libraries
import pyodbc
import pandas as pd
import numpy as np
from sqlalchemy import create_engine

#######################################################################
# Define sqlalchemy engine
engine = create_engine("mssql://{user}:{pw}@localhost/{db}?driver={driver}"
                      .format(user="**********",
                             pw="**********",
                             db="wsDB",
                             driver="/opt/microsoft/msodbcsql/lib64/libmsodbcsql-13.1.so.9.1"))

#######################################################################
# Read data from file and get last record
def read_data():
   	# Choose Columns
	col_indexes = [0, 1, 2, 3, 5, 6, 7, 8, 12, 13] # 9 Columns
	c_names = ['ts', 'rec', 'ws', 'wd', 'srad', 'temp', 'rh', 'rain', 'vis', 'bp']
	# Read data - begin @ #5th row - no headers
	file_loc = "/home/yanal/Documents/Career/HTU/weather-station-dashboard/CR1000_2_OneMin.csv"
	df_minute = pd.read_csv(file_loc, skiprows=4, usecols=col_indexes, names=c_names)
	rec_minute = df_minute.tail(1)['rec']
	df_minute.set_index('rec', inplace=True)   
	file_loc = "/home/yanal/Documents/Career/HTU/weather-station-dashboard/CR1000_2_Table1.csv"
	df_hour = pd.read_csv(file_loc, skiprows=4, usecols=col_indexes, names=c_names)
	rec_hour = df_hour.tail(1)['rec']
	df_hour.set_index('rec', inplace=True)
	return (df_minute, df_hour, rec_minute, rec_hour) 

#######################################################################
# Get rec_delta
def get_rec_delta(rec):
    df_minute, df_hour, rec_minute, rec_hour = read_data()
    return(rec_hour - rec, rec_minute - rec, df_minute, df_hour)



#######################################################################
# Append to DB
def append_to_db_perHOUR():
    x1.to_sql(con=engine, name="perHOUR", if_exists="replace")

def append_to_db_perMINUTE():
    x2.to_sql(con=engine, name="perMINUTE", if_exists="replace")



#######################################################################
# MAIN LOOP
#######################################################################
if __name__ == '__main__':
	rec = get_record()
	rec_delta_hour, rec_delta_min, df_minute, df_hour = get_rec_delta(rec)
	x1, x2 = subset_df(rec_delta_hour, rec_delta_min, df_hour, df_minute)
	append_to_db_perMINUTE()
	append_to_db_perHOUR()
	