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
	
end $$


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