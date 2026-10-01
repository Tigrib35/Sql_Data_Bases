declare @DT2 datetime2 = SysDateTime()

select Cast(@DT2 AS varchar),
		TRY_CONVERT(varchar, @DT2, 100)
		Parse(@DT2 AS varchar(100))
