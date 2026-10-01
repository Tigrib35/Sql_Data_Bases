declare @DT	datetime = GetDate()
declare @D date = '2022-04-19'
declare @T time(0) = GetDAte()
declare @DT2 datetime2 = SysDateTime()
declare @DTO datetimeoffset = GetDate()

set dateformat mdy;
select @DTO

