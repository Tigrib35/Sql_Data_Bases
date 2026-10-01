USE data_b1

CREATE TABLE users(
	id int identity, 
	first_name nvarchar(MAX) not null,
	last_name nvarchar(MAX) not null,
	email varchar(MAX) unique,
	age tinyint,
	balance real
)

