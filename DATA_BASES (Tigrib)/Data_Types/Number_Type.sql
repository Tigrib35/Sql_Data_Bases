-- это создание переменной
DECLARE @num int;
DECLARE @num2 int = 20;
-- это мы задаем значение
SET @num = 100
-- это вывод переменной
SELECT @num + @num2 AS number


DECLARE @bit bit = 1;
SELECT @bit AS flag