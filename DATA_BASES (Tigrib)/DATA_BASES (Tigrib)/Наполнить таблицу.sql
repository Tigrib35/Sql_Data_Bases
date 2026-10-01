use data_b1

insert INTO users(first_name, email, age)
values (N'Petr', 'pedro@google.gmail', 19),
	   (N'Alice','alice@google.gmail', 19),
	   (N'Issac', 'issac@google.gmail', 34),
	   (N'Albert', 'albert228@google.gmail', 9),
	   (N'Victor', 'vitya@google.gmail', 49)

select *
from users