CREATE TABLE perMINUTE (
	ts DATETIME,
	rec INT PRIMARY KEY,
	ws DECIMAL(5,3),
	wd DECIMAL(4,1),
	srad DECIMAL(4,3),
	temp DECIMAL(4,2),
	rh DECIMAL(4,2),
	rain DECIMAL(4,3),
	vis INT,
	bp DECIMAL(4,1)
)

CREATE TABLE perHOUR (
	ts DATETIME,
	rec INT PRIMARY KEY,
	ws DECIMAL(5,3),
	wd DECIMAL(4,1),
	srad DECIMAL(4,3),
	temp DECIMAL(4,2),
	rh DECIMAL(4,2),
	rain DECIMAL(4,3),
	vis INT,
	bp DECIMAL(4,1)
)