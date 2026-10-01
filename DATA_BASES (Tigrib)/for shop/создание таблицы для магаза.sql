USE [data_b for shop]
go

CREATE TABLE providers(
	id int PRIMARY KEY IDENTITY(1,1),
	product_id int FOREIGN KEY REFERENCES products(id)
)
CREATE TABLE products(
	id int PRIMARY KEY IDENTITY(1,1),
	seller_id int FOREIGN KEY REFERENCES sellers(id)
)
CREATE TABLE sellers(
	id int PRIMARY KEY IDENTITY(4,4),
	buyer_id int FOREIGN KEY REFERENCES buyers(id)
)
CREATE TABLE buyers(
	id int PRIMARY KEY IDENTITY(5,5),
	manager_id int FOREIGN KEY REFERENCES managers(id)
	seller_id int FOREIGN KEY REFERENCES sellers(id)
	product_id int FOREIGN KEY REFERENCES product(id)
)
CREATE TABLE managers(
	id int PRIMARY KEY IDENTITY(6 ,6),
	provider_id int FOREIGN KEY REFERENCES providers(id)
	seller_id int FOREIGN KEY REFERENCES sellers(id)
	product_id int FOREIGN KEY REFERENCES products(id)
	byuer_id int FOREIGN KEY REFERENCES buyers(id)
)


INSERT managers