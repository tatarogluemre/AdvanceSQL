CREATE TABLE film
(
id int ,
title VARCHAR(50),
type VARCHAR(50),
length int
);
INSERT INTO film VALUES (1, 'Kuzuların Sessizliği', 'Korku',130);
INSERT INTO film VALUES (2, 'Esaretin Bedeli', 'Macera', 125);
INSERT INTO film VALUES (3, 'Kısa Film', 'Macera',40);
INSERT INTO film VALUES (4, 'Shrek', 'Animasyon',85);

CREATE TABLE actor
(
id int ,
isim VARCHAR(50),
soyisim VARCHAR(50)
);
INSERT INTO actor VALUES (1, 'Christian', 'Bale');
INSERT INTO actor VALUES (2, 'Kevin', 'Spacey');
INSERT INTO actor VALUES (3, 'Edward', 'Norton');

-- ****** ADVANCE SQL ********
do $$
declare
	film_count integer :=0;	
	max_film_length integer :=0;
	
begin
	select count(*) --kaçtane film varsa sayısını getirir.
	into film_count --query den gelen neticeyi film_count isimli değişkene atar
	from film; --tabloyu seçer
	
	select max(length) 
	into max_film_length
	from film;
	
	raise notice 'The Number of Films is %', film_count;
	raise notice 'Max Film Uzunluk %' ,max_film_length;
	
end $$;


do $$
declare
	counter integer :=1;
	first_name varchar(50) :='John';
	last_name varchar(50) :='Doe';
	payment numeric(4,2) :=20.5;
begin
	raise notice '% % % has been paid % USD',
	 			counter,
				first_name,
				last_name,
				payment;
end $$;
	
--TASK  Ahmet ve Mehmet Beyler 120 Tl ödediler.					  
do $$
declare
	
	first_name varchar(50) :='Ahmet';
	first_name2 varchar(50) :='Mehmet';
	payment integer :=120;
begin
	raise notice '% ve % beyler % TL ödediler',	 			
				first_name,
				first_name2,
				payment;
end $$;
	
--*******************BEKLETME KOMUTU ************
do $$
declare
	
	created_at time := now();
begin
	raise notice '%', created_at;
	perform pg_sleep(10); -- 10 saniye bekleniyor
	raise notice '%', created_at; --çıktıda aynı değer görünecek
				
end $$;

 --********************* TABLODAN DATA TIPINI KOPYALAMA *********************
	/*
		-> variable_name  table_name.column_name%type;
		->( Tablodaki datanın aynı data türünde variable oluşturmaya yarıyor)
	*/

do $$
declare
film_title film.title%type; --varchar
begin
 	-- 1 id li filmin ismini getirelim
	select title from film
	into film_title
	where id=1;
	
	raise notice 'Film title id 1 : %' ,film_title;
end $$;

-- *******İÇ İÇE BLOK YAPILARI****************** 

do $$
<<outher_block>>
declare
	counter integer :=0;
begin 
	counter := counter +1;
	raise notice 'The current value of counter is %', counter;
	
	declare
	counter integer :=0;	
	begin
	counter := counter +10;
	raise notice'Counter in the subBlock is %', counter;
	raise notice 'Counter in the OutherBlock is %', outher_block.counter;
	
	end;
	
	raise notice'Counter in the outherBlock is %', counter;
end outher_block $$;

-- ******* ROW TYPE *****************
do $$
declare
	selected_actor	actor%rowtype;
begin
	select * 
	from actor
	into selected_actor  --id,isim, soyisim
	where id=1;
    
	raise notice 'The actor name is % %',
					selected_actor.isim,
					selected_actor.soyisim;
end $$;


-- ***********************RECORD TYPE *******************

/*
		-> Row Type gibi çalışır ama record un tamamı değilde belli başlıkları almak
		istersek kullanılabilir
	*/
do $$
declare
	rec	record; -- record data türünde rec isminde değişken oluşturuldu
begin
	select id,title,type
	into rec
	from film
	where id = 1;
	
	raise notice '% % %' , rec.id, rec.title, rec.type;
end $$ ;


-- ************ CONSTANT *****************
do $$
declare
	vat constant numeric :=0.1; -- final keywordü gibi değiştirilemeyen variable için kullanılır.
	net_price numeric := 20.5;
begin
	raise notice 'Satış Fiyatı : %' , net_price*(1+vat);
	--vat :=0.05; --constant bir ifadeyi ilk setleme işleminden sonra değer değiştirmeye çalışırsak hata alırız.
end $$;

--constant bir ifadeye RT da değer verebilir miyiz?

do $$
declare
	start_at constant time :=now();
	
begin 
	raise notice 'bloğun çalışma zamanı: %',start_at;
end $$;

-- //////////////////// Control Structures ///////////////////////

-- ******************** If Statement ****************

-- syntax : 
/*

	if condition  then
			statement;
	end if ;

*/
---- Task : 1 id li filmi bulalım eğer yoksa ekrana uyarı yazısı verelim
do $$
declare
select_film film%rowtype;
istenen_filmid film.id%type :=10;

begin
 	select * from film
	into select_film
	where id =istenen_filmid;
    
	if not found then
		raise notice 'Girdiğiniz id li film bulunamadı : %', istenen_filmid;
	end if;
end $$;
 
-- *********************** IF-THEN-ELSE **************
--syntax:
/*

	IF condition THEN
			statement;
	ELSE
			alternative statement;
	END IF
	
*/

-- TASK : 1 id li film varsa title bilgisini yazınız yoksa uyarı yazısını ekrana basınız.

do $$
declare
select_film film%rowtype;
istenen_filmid film.id%type :=1;

begin
 	select * from film
	into select_film
	where id =istenen_filmid;
    
	if not found then
		raise notice 'Girdiğiniz  % id nolu film bulunamadı',istenen_filmid;
	else
	    raise notice 'Girdiğiniz % id  nolu film  title: %', istenen_filmid, select_film.title;
	end if;
end $$;

-- *********************** IF-THEN-ELSE-IF **************
--syntax:
/*

	IF condition_1 THEN
			statement;_1;
	ELSEIF condition_2 THEN
			 statement_2;
	ELSEIF condition_3 THEN
			 statement_3;
	ELSE
			statement_final;
	END IF;
	
*/

--Task :  1 id li film varsa ;
			--süresi 50 dakikanın altında ise Short,
			--50<length<120 ise Medium,
			--length>120 ise Long yazalım


do $$
declare
	v_film film%rowtype;
	len_description varchar(50);

begin 

	select * from film
	into v_film  --- v_film.id = 1  / v_film.title ='Kuzuların Sessizliği'
	where id = 1;
	
	if not found then
		raise notice 'Filim bulunamadı';
	else
		if v_film.length > 0 and v_film.length <=50 then
				len_description='Short';
			elseif v_film.length>50 and v_film.length<120 then
				len_description='Medium';
			elseif v_film.length>120 then
				len_description='Long';
			else
				len_description='Tanımlanamıyor';
	     end if;
	 raise notice ' % filminin süresi : %', v_film.title, len_description;
	 end if;			

end $$;


do $$
declare
 select_film film%rowtype;
 select_filmid film.id%type := 1;

 begin
 	select * from film
 	into select_film
	where id = select_filmid;
	
	if not found then
		raise notice 'Film bulunamadı';
	else 
		if select_film.length>0 and select_film.length<50 then
			raise notice 'short';
		elseif select_film.length>50 and select_film.length<120 then
			raise notice 'medium';
		elseif select_film.length>120 then
	    	raise notice 'Long';
		else
			raise notice 'tanımlanamıyor';
	end if;
	        raise notice 'Film %',select_film.title;
end if;	

end $$;


-- ******** Case Statement **************************
-- syntax :
 /*
 	CASE search-expression
	 WHEN expression_1 [, expression_2,..] THEN
	 	statement
	 [..]
	 [ELSE
	 	else-statement]
	 END case;
 */
 -- Task : Filmin türüne göre çocuklara uygun olup olmadığını ekrana yazalım
​
do $$
declare
	uyari varchar(50);
	tur film.type%type;
begin
	select type from film
	into tur
	where id = 4;
	
	if found then 
		case tur
			when 'Korku' then uyari='Çocuklar için uygun değildir';
			when 'Macera' then uyari='Çocuklar için uygun';
			when 'Animasyon' then uyari ='Çocuklar için tavsiye edilir';
			else
				uyari='Tanımlanamadı';
		end case;
        raise notice '%', uyari;
	end if;
end $$;


--Task 1 : Film tablosundaki film sayısı 10 dan az ise "Film sayısı az" yazdırın, 
--         10 dan çok ise "Film sayısı yeterli" yazdıralım

do $$
declare
sayi integer:=0;
begin
select count(*) from film
into sayi;

 
 if (sayi>10)  then
   raise notice 'Film sayısı yeterli';
   else 
   raise notice'Film sayisi az';
   end if;

end $$;

-- Task 2: user_age isminde integer data türünde bir değişken tanımlayıp 
--         default olarak bir değer verelim, 
--        If yapısı ile girilen değer 18 den büyük ise Access Granted, küçük ise Access Denied yazdıralım

do $$
declare
user_age integer:=25;

begin
 	if (user_age >18) then
	 raise notice 'Acces Granted';
	else
	 raise notice 'Acces Denied';
   end if;
   
end $$;

-- Task 3: a ve b isimli integer türünde 2 değişken tanımlayıp default değerlerini verelim, 
--        eğer a nın değeri b den büyükse "a , b den büyüktür" yazalım, 
--        tam tersi durum için "b, a dan büyüktür" yazalım, iki değer birbirine eşit ise 
-----     " a,  b'ye eşittir" yazalım:

do $$
declare
a integer:=12;
b integer:=25;

begin
 	if (a >b) then
	 raise notice 'a b den büyük';
	elseif(a<b) then
	 raise notice 'b a dan büyük';
	 else
	 raise notice 'Eşit';
   end if;
   
end $$;

-- Task 4 : kullaniciYasi isimli bir değişken oluşturup default değerini verin, 
--          girilen yaş 18 den büyükse "Oy kullanabilirsiniz", 18 den küçük ise "Oy kullanamazsınız" yazısını yazalım.

do $$
declare
yas integer:=22;

begin
 	if (yas>18 and yas<120) then
	 raise notice 'kullanabilir';
	elseif yas>0 and yas<18 then
	 raise notice 'kullanamaz';
	 else 
	 raise notice 'Tanımsız';
   end if;
   
end $$;

-- ********************** LOOP *****************************
--syntax
LOOP
 statement;
END LOOP;

--loopu sonlandırmak için loop içine if yapısını kullanabliriz.

LOOP
	statements;
	IF condition THEN
	   exit; --loop dan çıkmayı sağlar
	END IF;
END LOOP;

--   nested LOOP

<<outher>>
LOOP
	statements;
	<<inner>>
	LOOP
		.......
		exit <<inner>>
		END LOOP;
END LOOP;

-- Task : Fibonacci serisinde, belli bir sıradaki sayıyı ekrana getirelim

do $$
declare
i integer :=0;
j integer :=1;
toplam integer :=0;
counter integer :=0;
n integer :=8;
begin
	if(n<1) then
	 toplam :=0;
	 end if;
	 loop
	 	exit when counter =n;
		counter := counter +1;
		select j, (i+j) into i,j;
	end loop;
	toplam :=i;
	raise notice '%' ,toplam;
end $$;

-- **************** WHILE LOOP *****************
syntax :

while condition loop
	statements;
end loop;

-- Task : 1 dan 4 e kadar counter değerlerini ekrana basalım
do $$
declare
counter integer :=0;
begin 
	while (counter<4) loop
	counter =counter+1;
	raise notice '%',counter;
	end loop;

end$$;
