USE data_b1
go
CREATE TABLE groups(
	id int PRIMARY KEY IDENTITY(1,1),
	name varchar(40) NOT NULL
)
CREATE TABLE students(
	id int PRIMARY KEY IDENTITY(1,1),
	full_name varchar(100) NOT NULL,
	group_id int FOREIGN KEY REFERENCES groups(id)
)
CREATE TABLE teacher_disciplines(
	id int PRIMARY KEY IDENTITY(1,1),
)
CREATE TABLE teachers(
	id int PRIMARY KEY IDENTITY(1,1),
	teahcer_disciplines_id int FOREIGN KEY REFERENCES teacher_disciplines(id)
)
CREATE TABLE disciplines(
	id int PRIMARY KEY IDENTITY(1,1),
	teahcer_id int FOREIGN KEY REFERENCES teachers(id)
)