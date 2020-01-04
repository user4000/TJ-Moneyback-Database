USE [moneyback]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

 
CREATE function dbo.f_money_as_phrase
(
 @summa money
)
returns varchar(255)
begin
Declare @res Varchar(255), @A1 Varchar(40),@A2 char(3), @b1 char(1), @b2 char(1), @b3 char(1)
Declare @i integer
--Declare @res Varchar(255)
select @a1=Convert(VarChar(255), abs( @summa ) )
select @i=CharIndex('.',@a1)
if @i>0
 select @a1=Substring(@a1,1,@i-1)
select @a1=Replicate(' ',20)+@a1
Select @a2=Right(@a1,3)
Select @b1=Substring(@a2,1,1)
Select @b2=Substring(@a2,2,1)
Select @b3=Substring(@a2,3,1)
-- единицы
if @b3='1' and @b2<>'1' 
 select @Res=' манат' 
else if @b3 in ('2','3','4') and @b2<>'1' 
 select @Res=' маната'
else 
 select @Res=' манатов'
if @b2='1' 
  begin
    if @b3='0'  select @Res=' десять'+@Res else
    if @b3='1'  select @Res=' одиннадцать'+@Res else
    if @b3='2'  select @Res=' двенадцать'+@Res else
    if @b3='3'  select @Res=' тринадцать'+@Res else
    if @b3='4'  select @Res=' четырнадцать'+@Res else
    if @b3='5'  select @Res=' пятнадцать'+@Res else
    if @b3='6'  select @Res=' шестнадцать'+@Res else
    if @b3='7'  select @Res=' семнадцать'+@Res else
    if @b3='8'  select @Res=' восемнадцать'+@Res else
    if @b3='9'  select @Res=' девятнадцать'+@Res
  end
else
  begin
    if @b3='1'  select @Res=' один'+@Res else
    if @b3='2'  select @Res=' два'+@Res else
    if @b3='3'  select @Res=' три'+@Res else
    if @b3='4'  select @Res=' четыре'+@Res else
    if @b3='5'  select @Res=' пять'+@Res else
    if @b3='6'  select @Res=' шесть'+@Res else
    if @b3='7'  select @Res=' семь'+@Res else
    if @b3='8'  select @Res=' восемь'+@Res else
    if @b3='9'  select @Res=' девять'+@Res
    if @b2='2'  select @Res=' двадцать'+@Res else
    if @b2='3'  select @Res=' тридцать'+@Res else
    if @b2='4'  select @Res=' сорок'+@Res else
    if @b2='5'  select @Res=' пятьдесят'+@Res else
    if @b2='6'  select @Res=' шестьдесят'+@Res else
    if @b2='7'  select @Res=' семьдесят'+@Res else
    if @b2='8'  select @Res=' восемьдесят'+@Res else
    if @b2='9'  select @Res=' девяносто'+@Res
  end
    if @b1='1'  select @Res=' сто'+@Res else
    if @b1='2'  select @Res=' двести'+@Res else
    if @b1='3'  select @Res=' триста'+@Res else
    if @b1='4'  select @Res=' четыреста'+@Res else
    if @b1='5'  select @Res=' пятьсот'+@Res else
    if @b1='6'  select @Res=' шестьсот'+@Res else
    if @b1='7'  select @Res=' семьсот'+@Res else
    if @b1='8'  select @Res=' восемьсот'+@Res else
    if @b1='9'  select @Res=' девятьсот'+@Res
Select @a1=Substring(@a1,1,datalength(@a1)-3)
Select @a2=Right(@a1,3)
Select @b1=Substring(@a2,1,1)
Select @b2=Substring(@a2,2,1)
Select @b3=Substring(@a2,3,1)
if @b3 = '0' and @b2 = '0' and @b1 = '0'
 select @res = @res
else
begin
 if @b3='1' and @b2<>'1' 
  select @Res=' тысяча'+@Res 
 else if @b3 in ('2','3','4') and @b2<>'1' 
  select @Res=' тысячи'+@Res
 else if @a2 <> '   '
  select @Res=' тысяч'+@Res
end
if @b2='1' 
  begin
    if @b3='0'  select @Res=' десять'+@Res else
    if @b3='1'  select @Res=' одиннадцать'+@Res else
    if @b3='2'  select @Res=' двенадцать'+@Res else
    if @b3='3'  select @Res=' тринадцать'+@Res else
    if @b3='4'  select @Res=' четырнадцать'+@Res else
    if @b3='5'  select @Res=' пятнадцать'+@Res else
    if @b3='6'  select @Res=' шестнадцать'+@Res else
    if @b3='7'  select @Res=' семнадцать'+@Res else
    if @b3='8'  select @Res=' восемнадцать'+@Res else
    if @b3='9'  select @Res=' девятнадцать'+@Res
  end
else
  begin
    if @b3='1'  select @Res=' одна'+@Res else
    if @b3='2'  select @Res=' две'+@Res else
    if @b3='3'  select @Res=' три'+@Res else
    if @b3='4'  select @Res=' четыре'+@Res else
    if @b3='5'  select @Res=' пять'+@Res else
    if @b3='6'  select @Res=' шесть'+@Res else
    if @b3='7'  select @Res=' семь'+@Res else
    if @b3='8'  select @Res=' восемь'+@Res else
    if @b3='9'  select @Res=' девять'+@Res
    if @b2='2'  select @Res=' двадцать'+@Res else
    if @b2='3'  select @Res=' тридцать'+@Res else
    if @b2='4'  select @Res=' сорок'+@Res else
    if @b2='5'  select @Res=' пятьдесят'+@Res else
    if @b2='6'  select @Res=' шестьдесят'+@Res else
    if @b2='7'  select @Res=' семьдесят'+@Res else
    if @b2='8'  select @Res=' восемьдесят'+@Res else
    if @b2='9'  select @Res=' девяносто'+@Res
  end
    if @b1='1'  select @Res=' сто'+@Res else
    if @b1='2'  select @Res=' двести'+@Res else
    if @b1='3'  select @Res=' триста'+@Res else
    if @b1='4'  select @Res=' четыреста'+@Res else
    if @b1='5'  select @Res=' пятьсот'+@Res else
    if @b1='6'  select @Res=' шестьсот'+@Res else
    if @b1='7'  select @Res=' семьсот'+@Res else
    if @b1='8'  select @Res=' восемьсот'+@Res else
    if @b1='9'  select @Res=' девятьсот'+@Res
-- миллионы
Select @a1=Substring(@a1,1,datalength(@a1)-3)
Select @a2=Right(@a1,3)
Select @b1=Substring(@a2,1,1)
Select @b2=Substring(@a2,2,1)
Select @b3=Substring(@a2,3,1)
if @b3 = '0' and @b2 = '0' and @b1 = '0'
 select @res = @res
else
begin
if @b3='1' and @b2<>'1' 
 select @Res=' миллион' +@Res
else if @b3 in ('2','3','4') and @b2<>'1' 
 select @Res=' миллиона'+@Res
else if @a2 <> '   '
 select @Res=' миллионов'+@Res
end
if @b2='1' 
  begin
    if @b3='0'  select @Res=' десять'+@Res else
    if @b3='1'  select @Res=' одиннадцать'+@Res else
    if @b3='2'  select @Res=' двенадцать'+@Res else
    if @b3='3'  select @Res=' тринадцать'+@Res else
    if @b3='4'  select @Res=' четырнадцать'+@Res else
    if @b3='5'  select @Res=' пятнадцать'+@Res else
    if @b3='6'  select @Res=' шестнадцать'+@Res else
    if @b3='7'  select @Res=' семнадцать'+@Res else
    if @b3='8'  select @Res=' восемнадцать'+@Res else
    if @b3='9'  select @Res=' девятнадцать'+@Res
  end
else
  begin
    if @b3='1'  select @Res=' один'+@Res else
    if @b3='2'  select @Res=' два'+@Res else
    if @b3='3'  select @Res=' три'+@Res else
    if @b3='4'  select @Res=' четыре'+@Res else
    if @b3='5'  select @Res=' пять'+@Res else
    if @b3='6'  select @Res=' шесть'+@Res else
    if @b3='7'  select @Res=' семь'+@Res else
    if @b3='8'  select @Res=' восемь'+@Res else
    if @b3='9'  select @Res=' девять'+@Res
    if @b2='2'  select @Res=' двадцать'+@Res else
    if @b2='3'  select @Res=' тридцать'+@Res else
    if @b2='4'  select @Res=' сорок'+@Res else
    if @b2='5'  select @Res=' пятьдесят'+@Res else
    if @b2='6'  select @Res=' шестьдесят'+@Res else
    if @b2='7'  select @Res=' семьдесят'+@Res else
    if @b2='8'  select @Res=' восемьдесят'+@Res else
    if @b2='9'  select @Res=' девяносто'+@Res
  end
    if @b1='1'  select @Res=' сто'+@Res else
    if @b1='2'  select @Res=' двести'+@Res else
    if @b1='3'  select @Res=' триста'+@Res else
    if @b1='4'  select @Res=' четыреста'+@Res else
    if @b1='5'  select @Res=' пятьсот'+@Res else
    if @b1='6'  select @Res=' шестьсот'+@Res else
    if @b1='7'  select @Res=' семьсот'+@Res else
    if @b1='8'  select @Res=' восемьсот'+@Res else
    if @b1='9'  select @Res=' девятьсот'+@Res
-- миллиарды
Select @a1=Substring(@a1,1,datalength(@a1)-3)
Select @a2=Right(@a1,3)
Select @b1=Substring(@a2,1,1)
Select @b2=Substring(@a2,2,1)
Select @b3=Substring(@a2,3,1)
if @b3 = '0' and @b2 = '0' and @b1 = '0'
 select @res = @res
else
begin
if @b3='1' and @b2<>'1' 
 select @Res=' миллиард' +@Res
else if @b3 in ('2','3','4') and @b2<>'1' 
 select @Res=' миллиарда'+@Res
else if @a2 <> '   '
 select @Res=' миллиардов'+@Res
end
if @b2='1' 
  begin
    if @b3='0'  select @Res=' десять'+@Res else
    if @b3='1'  select @Res=' одиннадцать'+@Res else
    if @b3='2'  select @Res=' двенадцать'+@Res else
    if @b3='3'  select @Res=' тринадцать'+@Res else
    if @b3='4'  select @Res=' четырнадцать'+@Res else
    if @b3='5'  select @Res=' пятнадцать'+@Res else
    if @b3='6'  select @Res=' шестнадцать'+@Res else
    if @b3='7'  select @Res=' семнадцать'+@Res else
    if @b3='8'  select @Res=' восемнадцать'+@Res else
    if @b3='9'  select @Res=' девятнадцать'+@Res
  end
else
  begin
    if @b3='1'  select @Res=' один'+@Res else
    if @b3='2'  select @Res=' два'+@Res else
    if @b3='3'  select @Res=' три'+@Res else
    if @b3='4'  select @Res=' четыре'+@Res else
    if @b3='5'  select @Res=' пять'+@Res else
    if @b3='6'  select @Res=' шесть'+@Res else
    if @b3='7'  select @Res=' семь'+@Res else
    if @b3='8'  select @Res=' восемь'+@Res else
    if @b3='9'  select @Res=' девять'+@Res
    if @b2='2'  select @Res=' двадцать'+@Res else
    if @b2='3'  select @Res=' тридцать'+@Res else
    if @b2='4'  select @Res=' сорок'+@Res else
    if @b2='5'  select @Res=' пятьдесят'+@Res else
    if @b2='6'  select @Res=' шестьдесят'+@Res else
    if @b2='7'  select @Res=' семьдесят'+@Res else
    if @b2='8'  select @Res=' восемьдесят'+@Res else
    if @b2='9'  select @Res=' девяносто'+@Res
  end
    if @b1='1'  select @Res=' сто'+@Res else
    if @b1='2'  select @Res=' двести'+@Res else
    if @b1='3'  select @Res=' триста'+@Res else
    if @b1='4'  select @Res=' четыреста'+@Res else
    if @b1='5'  select @Res=' пятьсот'+@Res else
    if @b1='6'  select @Res=' шестьсот'+@Res else
    if @b1='7'  select @Res=' семьсот'+@Res else
    if @b1='8'  select @Res=' восемьсот'+@Res else
    if @b1='9'  select @Res=' девятьсот'+@Res
declare @mb char(50), @bb char(50)
select @mb='абвгдеёжзийклмнопрстуфхцчшщьыъэюя'
select @bb='АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЬЫЪЭЮЯ'
select @i=CharIndex(substring(@Res,1,1),@mb)
select @Res=Substring(@bb,@i,1)+Substring(@Res,2,255)
select @Res=upper(Substring(@Res,1,1)) + Substring(@Res,2, 254)
--select @Res=@Res+' '+Right(convert(varchar(255),abs(@summa)),2)+' коп.'
--select kop
declare @kop varchar(2)
declare @mkop money
declare @suffix varchar(20)
select @kop=right(convert(varchar(255),abs(@summa)),2)
select @mkop=convert(money,@kop)
select @suffix=
case
 when @mkop=0 then 'тенге'
 when @mkop>10 and @mkop<20 then 'тенге'
 when right(@kop,1)='1' then 'тенге'
 when right(@kop,1)>'1' and  right(@kop,1)<'5' then 'тенге'
 else 'тенге'
end
select @Res=@Res+' '+case when @mkop=0 then '00 тенге' else @kop+' '+@suffix end
select @Res= upper(Substring(Ltrim(@Res),1,1)) + Substring(ltrim(@Res),2, 254)
 
return @Res;
end

GO

