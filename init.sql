--
-- PostgreSQL database dump
--

-- Dumped from database version 13.7
-- Dumped by pg_dump version 13.7

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: car_condition; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN public.car_condition AS character(3)
	CONSTRAINT car_condition_check CHECK ((VALUE = ANY (ARRAY['old'::bpchar, 'new'::bpchar])));


ALTER DOMAIN public.car_condition OWNER TO postgres;

--
-- Name: car_gearbox; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN public.car_gearbox AS character varying(10)
	CONSTRAINT car_gearbox_check CHECK (((VALUE)::text = ANY ((ARRAY['manual'::character varying, 'auto'::character varying])::text[])));


ALTER DOMAIN public.car_gearbox OWNER TO postgres;

--
-- Name: gender; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN public.gender AS character(1)
	CONSTRAINT gender_check CHECK ((VALUE = ANY (ARRAY['F'::bpchar, 'M'::bpchar])));


ALTER DOMAIN public.gender OWNER TO postgres;

--
-- Name: addcar(integer, character varying, character varying, integer, character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.addcar(owner_id integer, brand character varying, conditions character varying, year integer, gearbox character varying, price integer) RETURNS void
    LANGUAGE plpgsql LEAKPROOF
    AS $$
begin
	if conditions not in ('old', 'new') then
	raise exception 'there is no such % condition', conditions;
	rollback;
	end if;
	if gearbox not in ('manual', 'auto') then 
	raise exception 'there is no such % gearbox', gearbox;
	rollback;
	end if;
	insert into car (owner_id, brand, condition, year, gearbox, price, for_sale) 
	values (owner_id, brand, conditions, year, gearbox, price, 'true');
end; $$;


ALTER FUNCTION public.addcar(owner_id integer, brand character varying, conditions character varying, year integer, gearbox character varying, price integer) OWNER TO postgres;

--
-- Name: adduser(character varying, character varying, date, character, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.adduser(first_name character varying, last_name character varying, dob date, sex character, address character varying, phone_number character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
	if sex not in ('M', 'F') then
	raise exception 'there is no such % gender', sex;
	rollback;
	end if;
	insert into people (first_name, last_name, dob, sex, address, phone_number, coin) 
	values (first_name, last_name, dob, sex, address, phone_number, '0');
end; 
$$;


ALTER FUNCTION public.adduser(first_name character varying, last_name character varying, dob date, sex character, address character varying, phone_number character varying) OWNER TO postgres;

--
-- Name: backup_data(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.backup_data() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
   copy (select * from all_data_of_transact) 
   to '/tmp/backup.csv' with csv header;
   return new;
END;
$$;


ALTER FUNCTION public.backup_data() OWNER TO postgres;

--
-- Name: countboughtcars(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.countboughtcars(user_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
begin
	return (select count(car_id) 
		from transact
		where (buyer_id = user_id)
		);
end; $$;


ALTER FUNCTION public.countboughtcars(user_id integer) OWNER TO postgres;

--
-- Name: countownedcars(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.countownedcars(user_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
begin
	return (select count(car_id) 
		from car
		where (owner_id = user_id)
		);
end; $$;


ALTER FUNCTION public.countownedcars(user_id integer) OWNER TO postgres;

--
-- Name: countsalecar(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.countsalecar() RETURNS TABLE(for_sale_car bigint)
    LANGUAGE plpgsql
    AS $$
	BEGIN
	RETURN QUERY 
	SELECT count(*) as for_sale_car
	FROM car
	WHERE car.for_sale = true;
	END;
	$$;


ALTER FUNCTION public.countsalecar() OWNER TO postgres;

--
-- Name: countsoldcars(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.countsoldcars(user_id integer) RETURNS integer
    LANGUAGE plpgsql LEAKPROOF
    AS $$
begin
	return (select count(car_id) 
		from transact
		where (seller_id = user_id)
		);
end; $$;


ALTER FUNCTION public.countsoldcars(user_id integer) OWNER TO postgres;

--
-- Name: deleteuser(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.deleteuser(user1_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
	delete from people
	where people.user_id = user1_id;
end; 
$$;


ALTER FUNCTION public.deleteuser(user1_id integer) OWNER TO postgres;

--
-- Name: findbuyertrans(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.findbuyertrans(user_id integer) RETURNS TABLE(trans_id integer, seller_name text, buyer_name text, car_id integer, brand character varying, price integer, trans_time date)
    LANGUAGE plpgsql
    AS $$
	BEGIN
	RETURN QUERY 
select 

all_data_of_transact.trans_code, all_data_of_transact.seller_name, all_data_of_transact.buyer_name, all_data_of_transact.car_id,all_data_of_transact.brand, all_data_of_transact.price, all_data_of_transact.transaction_time 

from 

all_data_of_transact 
where 

transact.buyer_id = user_id;

end;
$$;


ALTER FUNCTION public.findbuyertrans(user_id integer) OWNER TO postgres;

--
-- Name: findbuytrans(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.findbuytrans(user_id integer) RETURNS TABLE(trans_id integer, seller_name text, buyer_name text, car_id integer, brand character varying, price integer, trans_time date)
    LANGUAGE plpgsql
    AS $$
	BEGIN
	RETURN QUERY 
select 

all_data_of_transact.trans_code, all_data_of_transact.seller_name, all_data_of_transact.buyer_name, all_data_of_transact.car_id,all_data_of_transact.brand, all_data_of_transact.price, all_data_of_transact.transaction_time 

from 

all_data_of_transact 
	WHERE transact.buyer_id = user_id; 
	END;
	
$$;


ALTER FUNCTION public.findbuytrans(user_id integer) OWNER TO postgres;


CREATE OR REPLACE FUNCTION public.findcarwithgearboxandcondition(
	gearb character varying,
	con character varying)
    RETURNS TABLE(car_id integer, owner_id integer, brand character varying, condition public.car_condition, year integer, gearbox public.car_gearbox, price integer, for_sale boolean, description character varying) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
	BEGIN
	RETURN QUERY 
	SELECT car.car_id, car.owner_id, car.brand, car.condition, car.year, car.gearbox, car.price, car.for_sale, car.description
	FROM car
	WHERE (car.gearbox = GearB and car.condition = con) order by car_id asc;
	END;
	
$BODY$;

ALTER FUNCTION public.findcarwithgearboxandcondition(gearb character varying, con character varying) OWNER TO postgres;

CREATE OR REPLACE FUNCTION public.findcarwithpriceandgearbox(
	p1 integer,
	p2 integer,
	gb character varying)
    RETURNS TABLE(car_id integer, owner_id integer, brand character varying, condition public.car_condition, year integer, gearbox public.car_gearbox, price integer, for_sale boolean, description character varying) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
	BEGIN
	RETURN QUERY 
	SELECT car.car_id, car.owner_id, car.brand, car.condition, car.year, car.gearbox, car.price, car.for_sale, car.description
	FROM car
	WHERE (car.price BETWEEN p1 AND p2 and car.gearbox = gb) order by car_id asc;
	END;
	
$BODY$;

ALTER FUNCTION public.findcarwithpriceandgearbox(p1 integer, p2 integer, gb character varying) OWNER TO postgres;

--
-- Name: findcarwithcity(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.findcarwithcity(city character varying) RETURNS TABLE(car_id integer, owner_id integer, brand character varying, condition public.car_condition, year integer, gearbox public.car_gearbox, price integer, for_sale boolean, description character varying)
    LANGUAGE plpgsql
    AS $$
	BEGIN
	RETURN QUERY 
	SELECT car.car_id, car.owner_id, car.brand, car.condition, car.year, car.gearbox, car.price, car.for_sale, car.description
	FROM car
	WHERE car.owner_id in (select user_id from people where address ilike ('%'||city||'%')
	order by car_id asc;
	END;
	
$$;


ALTER FUNCTION public.findcarwithcity(city character varying) OWNER TO postgres;

--
-- Name: findcarwithcondition(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.findcarwithcondition(condi character varying) RETURNS TABLE(car_id integer, owner_id integer, brand character varying, condition public.car_condition, year integer, gearbox public.car_gearbox, price integer, for_sale boolean, description character varying)
    LANGUAGE plpgsql
    AS $$
	BEGIN
	RETURN QUERY 
	SELECT car.car_id, car.owner_id, car.brand, car.condition, car.year, car.gearbox, car.price, car.for_sale, car.description
	FROM car
	WHERE (car.condition = condi) order by car_id asc;
	END;
	
$$;


ALTER FUNCTION public.findcarwithcondition(condi character varying) OWNER TO postgres;

--
-- Name: findcarwithgearbox(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.findcarwithgearbox(gearb character varying) RETURNS TABLE(car_id integer, owner_id integer, brand character varying, condition public.car_condition, year integer, gearbox public.car_gearbox, price integer, for_sale boolean, description character varying)
    LANGUAGE plpgsql
    AS $$
	BEGIN
	RETURN QUERY 
	SELECT car.car_id, car.owner_id, car.brand, car.condition, car.year, car.gearbox, car.price, car.for_sale, car.description
	FROM car
	WHERE (car.gearbox = GearB) order by car_id asc;
	END;
	
$$;


ALTER FUNCTION public.findcarwithgearbox(gearb character varying) OWNER TO postgres;

--
-- Name: findcarwithprice(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.findcarwithprice(p1 integer, p2 integer) RETURNS TABLE(car_id integer, owner_id integer, brand character varying, condition public.car_condition, year integer, gearbox public.car_gearbox, price integer, for_sale boolean, description character varying)
    LANGUAGE plpgsql
    AS $$
	BEGIN
	RETURN QUERY 
	SELECT car.car_id, car.owner_id, car.brand, car.condition, car.year, car.gearbox, car.price, car.for_sale, car.description
	FROM car
	WHERE (car.price BETWEEN p1 AND p2) order by car_id asc;
	END;
	
$$;


ALTER FUNCTION public.findcarwithprice(p1 integer, p2 integer) OWNER TO postgres;

--
-- Name: findcarwithyear(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.findcarwithyear(y1 integer, y2 integer) RETURNS TABLE(car_id integer, owner_id integer, brand character varying, condition public.car_condition, year integer, gearbox public.car_gearbox, price integer, for_sale boolean, description character varying)
    LANGUAGE plpgsql
    AS $$
	BEGIN
	RETURN QUERY 
	SELECT car.car_id, car.owner_id, car.brand, car.condition, car.year, car.gearbox, car.price, car.for_sale, car.description
	FROM car
	WHERE (car.year BETWEEN y1 and y2) order by car_id asc;
	END;
	
$$;


ALTER FUNCTION public.findcarwithyear(y1 integer, y2 integer) OWNER TO postgres;

--
-- Name: findsalecar(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.findsalecar() RETURNS TABLE(car_id integer, owner_id integer, brand character varying, condition public.car_condition, year integer, gearbox public.car_gearbox, price integer, for_sale boolean, description character varying)
    LANGUAGE plpgsql
    AS $$
	BEGIN
	RETURN QUERY 
	SELECT car.car_id, car.owner_id, car.brand, car.condition, car.year, car.gearbox, car.price, car.for_sale, car.description
	FROM car
	WHERE (car.for_sale = true) order by car_id asc;
	END;
	
$$;


ALTER FUNCTION public.findsalecar() OWNER TO postgres;

--
-- Name: findsellertrans(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.findsellertrans(user_id integer) RETURNS TABLE(trans_id integer,seller_id integer, seller_name text, buyer_id integer, buyer_name text, car_id integer, brand character varying, price integer, trans_time date)
    LANGUAGE plpgsql
    AS $$
	BEGIN
	RETURN QUERY 
select 

all_data_of_transact.trans_code, all_data_of_transact.seller_id, all_data_of_transact.seller_name, all_data_of_transact.buyer_id, all_data_of_transact.buyer_name, all_data_of_transact.car_id,all_data_of_transact.brand, all_data_of_transact.price, all_data_of_transact.transaction_time 
from 

all_data_of_transact 

where 

all_data_of_transact.seller_id = user_id;

end;
$$;


ALTER FUNCTION public.findsellertrans(user_id integer) OWNER TO postgres;

--
-- Name: findselltrans(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.findselltrans(user_id integer) RETURNS TABLE(trans_id integer,seller_id integer, seller_name text, buyer_id integer, buyer_name text, car_id integer, brand character varying, price integer, trans_time date)
    LANGUAGE plpgsql
    AS $$
	BEGIN
	RETURN QUERY 
select 

all_data_of_transact.trans_code, all_data_of_transact.seller_id, all_data_of_transact.seller_name, all_data_of_transact.buyer_id, all_data_of_transact.buyer_name, all_data_of_transact.car_id,all_data_of_transact.brand, all_data_of_transact.price, all_data_of_transact.transaction_time 
from 

all_data_of_transact 
	WHERE all_data_of_transact.seller_id = user_id; 
	END;
	
$$;


ALTER FUNCTION public.findselltrans(user_id integer) OWNER TO postgres;

--
-- Name: findtranswithcarid(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.findtranswithcarid(carid integer) RETURNS TABLE(trans_id integer,seller_id integer, seller_name text, buyer_id integer, buyer_name text, car_id integer, brand character varying, price integer, trans_time date)
    LANGUAGE plpgsql
    AS $$
	BEGIN
	RETURN QUERY 
select 

all_data_of_transact.trans_code, all_data_of_transact.seller_id, all_data_of_transact.seller_name, all_data_of_transact.buyer_id, all_data_of_transact.buyer_name, all_data_of_transact.car_id,all_data_of_transact.brand, all_data_of_transact.price, all_data_of_transact.transaction_time 

from 

all_data_of_transact 
	WHERE all_data_of_transact.car_id = CarID; 
	END;
	
$$;


ALTER FUNCTION public.findtranswithcarid(carid integer) OWNER TO postgres;

--
-- Name: findtranswithdate(date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.findtranswithdate(d1 date, d2 date) RETURNS TABLE(trans_id integer,seller_id integer, seller_name text, buyer_id integer, buyer_name text, car_id integer, brand character varying, price integer, trans_time date)
    LANGUAGE plpgsql
    AS $$
	BEGIN
	RETURN QUERY 
select 

all_data_of_transact.trans_code, all_data_of_transact.seller_id, all_data_of_transact.seller_name, all_data_of_transact.buyer_id, all_data_of_transact.buyer_name, all_data_of_transact.car_id,all_data_of_transact.brand, all_data_of_transact.price, all_data_of_transact.transaction_time 

from 

all_data_of_transact 
	WHERE all_data_of_transact.transaction_time BETWEEN d1 AND d2; 
	END;
	
$$;


ALTER FUNCTION public.findtranswithdate(d1 date, d2 date) OWNER TO postgres;

--
-- Name: findtranswithid(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.findtranswithid(qtrans_id integer) RETURNS TABLE(trans_id integer,seller_id integer, seller_name text, buyer_id integer, buyer_name text, car_id integer, brand character varying, price integer, trans_time date)
    LANGUAGE plpgsql
    AS $$
	BEGIN
	RETURN QUERY 
select 

all_data_of_transact.trans_code, all_data_of_transact.seller_id, all_data_of_transact.seller_name, all_data_of_transact.buyer_id, all_data_of_transact.buyer_name, all_data_of_transact.car_id,all_data_of_transact.brand, all_data_of_transact.price, all_data_of_transact.transaction_time 

from 

all_data_of_transact 

where 

all_data_of_transact.trans_id = Qtrans_id;

end;
$$;


ALTER FUNCTION public.findtranswithid(qtrans_id integer) OWNER TO postgres;

--
-- Name: finduserwithage(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.finduserwithage(age1 integer, age2 integer) RETURNS TABLE(user_id integer, first_name character varying, last_name character varying, dob date, sex public.gender, address character varying, phone_number character varying, coin integer, note character varying)
    LANGUAGE plpgsql
    AS $$
	BEGIN
	RETURN QUERY 
	SELECT people.user_id, people.first_name, people.last_name, people.dob, people.sex, people.address, people.phone_number, people.coin, people.note  
	FROM people
	WHERE EXTRACT(YEAR FROM age(cast (people.dob as date))) BETWEEN age1 and age2;
	END;
	$$;


ALTER FUNCTION public.finduserwithage(age1 integer, age2 integer) OWNER TO postgres;

--
-- Name: finduserwithcity(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.finduserwithcity(city character varying) RETURNS TABLE(user_id integer, first_name character varying, last_name character varying, dob date, sex public.gender, address character varying, phone_number character varying, coin integer, note character varying)
    LANGUAGE plpgsql
    AS $$
	BEGIN
	RETURN QUERY 
	SELECT people.user_id, people.first_name, people.last_name, people.dob, people.sex, people.address, people.phone_number, people.coin, people.note  
	FROM people
	WHERE people.address ilike ('%'||city||'%');
	END;
	$$;


ALTER FUNCTION public.finduserwithcity(city character varying) OWNER TO postgres;

--
-- Name: finduserwithname(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.finduserwithname(name character varying) RETURNS TABLE(user_id integer, first_name character varying, last_name character varying, dob date, sex public.gender, address character varying, phone_number character varying, coin integer, note character varying)
    LANGUAGE plpgsql
    AS $$
	BEGIN
	RETURN QUERY 
	SELECT people.user_id, people.first_name, people.last_name, people.dob, people.sex, people.address, people.phone_number, people.coin, people.note  
	FROM people
	WHERE people.last_name ILIKE ('%' || name || '%')
	OR people.first_name ILIKE ('%' || name || '%')	;
	END;
	$$;


ALTER FUNCTION public.finduserwithname(name character varying) OWNER TO postgres;

--
-- Name: maketrans(integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.maketrans(user1_id integer, user2_id integer, cars_id integer) RETURNS void
    LANGUAGE plpgsql LEAKPROOF
    AS $$
declare money integer;
Begin
	if ((select count(car_id)::int from car where owner_id = user1_id and for_sale = 'true') = 0) then 
		raise exception 'car not found ---> %', cars_id 
		using hint = 'please check car_id again';
		rollback;
	end if;
	if (cars_id not in (select car_id from car where owner_id = user1_id and for_sale = 'true')) then 
		raise exception 'car not found ---> %', cars_id 
		using hint = 'please check car_id again';
		rollback;
	end if;
	
	money := (select price from car where car_id = cars_id); 
	update people
	set coin = coin - money
	where user_id = user2_id;
	if ((select coin from people where user_id = user2_id) < 0) then 
		raise exception 'buyer don’t have % dong', money;
		rollback;
		end if;
		
	update people
		set coin = coin + money
		where user_id = user1_id;
	Update car
		set owner_id = user2_id, for_sale = 'false'
		where (car_id = cars_id);
		insert into Transact (seller_id, buyer_id, car_id, trans_time)
		values (user1_id, user2_id, cars_id, now());
end; $$;


ALTER FUNCTION public.maketrans(user1_id integer, user2_id integer, cars_id integer) OWNER TO postgres;

--
-- Name: showalltrans(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.showalltrans(user_id integer) RETURNS TABLE(trans_id integer, seller_name text, buyer_name text, car_id integer, brand character varying, price integer, trans_time date)
    LANGUAGE plpgsql
    AS $$
	BEGIN
	RETURN QUERY 
select 

all_data_of_transact.trans_code, all_data_of_transact.seller_name, all_data_of_transact.buyer_name, all_data_of_transact.car_id,all_data_of_transact.brand, all_data_of_transact.price, all_data_of_transact.transaction_time 

from 

all_data_of_transact ;

	END;
	
$$;


ALTER FUNCTION public.showalltrans(user_id integer) OWNER TO postgres;

--
-- Name: showownedcars(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.showownedcars(user_id integer) RETURNS TABLE(brand character varying, condtion public.car_condition, year integer, gearbox public.car_gearbox, price integer, description character varying)
    LANGUAGE plpgsql
    AS $$
begin
	return query
		select
			car.brand, car.condition, car.year, car.gearbox, car.price, car.description	
		from
			car
		where
			car.owner_id = user_id
		order by car_id asc;
end;
$$;


ALTER FUNCTION public.showownedcars(user_id integer) OWNER TO postgres;

--
-- Name: updatecoin(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.updatecoin(user1_id integer, money integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
Begin
	Update people
	Set coin = coin + money
	Where user_id = user1_id;
End; $$;


ALTER FUNCTION public.updatecoin(user1_id integer, money integer) OWNER TO postgres;

CREATE OR REPLACE FUNCTION public.show_list_buyer()
  RETURNS TABLE(user_id integer, username text, number_of_bought_cars bigint) AS
$$
BEGIN

RETURN QUERY SELECT * FROM public.show_list_buyer ORDER BY public.show_list_buyer.number_of_bought_cars DESC;

END;
  $$
  LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION public.show_list_buyer() OWNER TO postgres;

CREATE OR REPLACE FUNCTION public.show_list_seller()
  RETURNS TABLE(user_id integer, username text, number_of_sold_cars bigint) AS
$$
BEGIN

RETURN QUERY SELECT * FROM public.show_list_seller ORDER BY public.show_list_seller.number_of_sold_cars DESC;
END;
  $$
  LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION public.show_list_seller() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: car; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.car (
    car_id integer NOT NULL,
    owner_id integer,
    brand character varying(255) NOT NULL,
    condition public.car_condition NOT NULL,
    year integer NOT NULL,
    gearbox public.car_gearbox NOT NULL,
    price integer NOT NULL,
    for_sale boolean DEFAULT false NOT NULL,
    description character varying(1000)
);


ALTER TABLE public.car OWNER TO postgres;

--
-- Name: people; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.people (
    user_id integer NOT NULL,
    first_name character varying(255) NOT NULL,
    last_name character varying(255) NOT NULL,
    dob date NOT NULL,
    sex public.gender NOT NULL,
    address character varying(255) NOT NULL,
    phone_number character varying(11) NOT NULL,
    note character varying(255),
    coin integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.people OWNER TO postgres;

--
-- Name: transact; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.transact (
    trans_id integer NOT NULL,
    seller_id integer,
    buyer_id integer,
    car_id integer,
    trans_time date
);


ALTER TABLE public.transact OWNER TO postgres;

--
-- Name: all_data_of_transact; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.all_data_of_transact AS
 WITH buyer AS (
         SELECT transact.trans_id AS trans_code,
            (((people.first_name)::text || ' '::text) || (people.last_name)::text) AS buyer_name,
            people.phone_number AS buyer_phone_number
           FROM (public.people
             JOIN public.transact ON ((transact.buyer_id = people.user_id)))
        )
 SELECT data.trans_code,
    data.seller_id,
    (((data.first_name)::text || ' '::text) || (data.last_name)::text) AS seller_name,
    data.phone_number AS seller_number,
    data.buyer_id,
    data.buyer_name,
    data.buyer_phone_number,
    data.car_id,
    data.brand,
    data.condition,
    data.gearbox,
    data.price,
    data.transaction_time
   FROM ( SELECT seller.user_id,
            seller.first_name,
            seller.last_name,
            seller.dob,
            seller.sex,
            seller.address,
            seller.phone_number,
            seller.note,
            seller.coin,
            seller.trans_id,
            seller.seller_id,
            seller.buyer_id,
            seller.car_id,
            seller.trans_time,
            buyer.trans_code,
            buyer.buyer_name,
            buyer.buyer_phone_number,
            car.car_id,
            car.owner_id,
            car.brand,
            car.condition,
            car.year,
            car.gearbox,
            car.price,
            car.for_sale,
            car.description,
            seller.trans_time AS transaction_time
           FROM (((public.people
             JOIN public.transact ON ((transact.seller_id = people.user_id))) seller
             LEFT JOIN buyer ON ((seller.trans_id = buyer.trans_code)))
             LEFT JOIN public.car ON ((seller.car_id = car.car_id)))) data(user_id, first_name, last_name, dob, sex, address, phone_number, note, coin, trans_id, seller_id, buyer_id, car_id, trans_time, trans_code, buyer_name, buyer_phone_number, car_id_1, owner_id, brand, condition, year, gearbox, price, for_sale, description, transaction_time);


ALTER TABLE public.all_data_of_transact OWNER TO postgres;

--
-- Name: car_car_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.car_car_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.car_car_id_seq OWNER TO postgres;

--
-- Name: car_car_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.car_car_id_seq OWNED BY public.car.car_id;


--
-- Name: people_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.people_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.people_user_id_seq OWNER TO postgres;

--
-- Name: people_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.people_user_id_seq OWNED BY public.people.user_id;


--
-- Name: show_list_buyer; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.show_list_buyer AS
 SELECT people.user_id, (((people.first_name)::text || ' '::text) || (people.last_name)::text) AS user_name,
    count(transact.car_id) AS number_of_bought_cars
   FROM (public.people
     LEFT JOIN public.transact ON ((people.user_id = transact.buyer_id)))
  GROUP BY (people.user_id, ((people.first_name)::text || ' '::text) || (people.last_name)::text)
  HAVING (count(transact.car_id)!=0)
ORDER BY (count(transact.car_id)) DESC;


ALTER TABLE public.show_list_buyer OWNER TO postgres;

--
-- Name: show_list_seller; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.show_list_seller AS
 SELECT people.user_id, (((people.first_name)::text || ' '::text) || (people.last_name)::text) AS user_name,
    count(transact.car_id) AS number_of_sold_cars
   FROM (public.people
     LEFT JOIN public.transact ON ((people.user_id = transact.seller_id)))
  GROUP BY (people.user_id, ((people.first_name)::text || ' '::text) || (people.last_name)::text)
	HAVING (count(transact.car_id)!=0)
  ORDER BY (count(transact.car_id)) DESC;


ALTER TABLE public.show_list_seller OWNER TO postgres;

--
-- Name: transact_trans_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.transact_trans_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.transact_trans_id_seq OWNER TO postgres;

--
-- Name: transact_trans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.transact_trans_id_seq OWNED BY public.transact.trans_id;


--
-- Name: car car_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.car ALTER COLUMN car_id SET DEFAULT nextval('public.car_car_id_seq'::regclass);


--
-- Name: people user_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.people ALTER COLUMN user_id SET DEFAULT nextval('public.people_user_id_seq'::regclass);


--
-- Name: transact trans_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transact ALTER COLUMN trans_id SET DEFAULT nextval('public.transact_trans_id_seq'::regclass);


--
-- Data for Name: car; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.car (car_id, owner_id, brand, condition, year, gearbox, price, for_sale, description) FROM stdin;
3	1	mitsubishi	old	2005	manual	2000	t	\N
4	2	huyndai	new	2021	auto	6000	t	\N
5	6	lamboghini	old	2022	manual	200000000	t	\N
1	3	toyota	old	2000	manual	1000	f	\N
2	3	honda	new	2020	auto	5000	f	\N
\.


--
-- Data for Name: people; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.people (user_id, first_name, last_name, dob, sex, address, phone_number, note, coin) FROM stdin;
3	hieu	do	2002-06-15	M	Ha noi	0987654321	\N	14000
1	thanh	nguyen	2002-11-10	M	Ha noi	0123456789	\N	17000
2	hieu	ta	2002-01-01	M	Ha noi	0123576789	\N	20000
5	linh	le	2002-12-10	F	Nam dinh	024681357	\N	0
6	Nguyen	Quynh Trang	2002-04-10	F	truong dinh	0356486145	\N	0
\.


--
-- Data for Name: transact; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.transact (trans_id, seller_id, buyer_id, car_id, trans_time) FROM stdin;
2	1	3	2	2022-07-04
3	3	1	2	2022-07-04
9	1	3	1	2022-07-06
10	3	1	1	2022-07-06
12	1	3	1	2022-07-06
13	1	3	2	2022-07-06
\.


--
-- Name: car_car_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.car_car_id_seq', 5, true);


--
-- Name: people_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.people_user_id_seq', 6, true);


--
-- Name: transact_trans_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.transact_trans_id_seq', 13, true);


--
-- Name: car car_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.car
    ADD CONSTRAINT car_pkey PRIMARY KEY (car_id);


--
-- Name: people people_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.people
    ADD CONSTRAINT people_pkey PRIMARY KEY (user_id);


--
-- Name: transact transact_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transact
    ADD CONSTRAINT transact_pkey PRIMARY KEY (trans_id);


--
-- Name: car_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX car_idx ON public.transact USING btree (car_id);


--
-- Name: transact backup_transact; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER backup_transact AFTER INSERT ON public.transact FOR EACH ROW EXECUTE FUNCTION public.backup_data();


--
-- Name: transact fk_buyer; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transact
    ADD CONSTRAINT fk_buyer FOREIGN KEY (buyer_id) REFERENCES public.people(user_id);


--
-- Name: transact fk_car; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transact
    ADD CONSTRAINT fk_car FOREIGN KEY (car_id) REFERENCES public.car(car_id);


--
-- Name: car fk_owner; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.car
    ADD CONSTRAINT fk_owner FOREIGN KEY (owner_id) REFERENCES public.people(user_id);


--
-- Name: transact fk_seller; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transact
    ADD CONSTRAINT fk_seller FOREIGN KEY (seller_id) REFERENCES public.people(user_id);

insert into public.people values (default, 'tram','pham','2-10-2002','F','Ha nam', '013572468',default,10000);
insert into public.people values (default, 'kien','hoang','12-09-2002','M','Ha noi', '014681357',default,25000);
insert into public.people values (default, 'Phuong','Pham','9-10-1990','F','ha noi', '024655357',default,30000);
insert into public.people values (default, 'Trang','Tran','1-5-2000','F','Nam dinh', '024881366',default,60000);
insert into public.people values (default, 'Hoang','Tran','1-12-2001','M','Phu tho', '024683838',default,50000);
insert into public.people values (default, 'Lam','Nguyen','11-11-1998','M','Ninh binh', '0887654327',default,23000);
insert into public.people values (default, 'Minh','Dinh','5-8-1988','M','ha nam', '08733125487',default,80000);
insert into public.people values (default, 'Huyen','Ngoc','12-8-2002','F','Ha noi', '0348867894',default,60000);
insert into public.people values (default, 'Lan','Nguyen','11-11-2002','F','Lao cai', '0345682556',default,26000);
insert into public.people values (default, 'Nam','Tran','10-5-1999','M','Nam dinh', '0683586789',default,28000);
insert into public.people values (default, 'Cuong','Tran','2-3-1996','M','ha nam', '0248722368',default,55000);
insert into public.people values (default, 'Tam','Nguyen','5-7-2002','M','ha noi', '08869543586',default,45000);
insert into public.people values (default, 'Tung','Ta','6-1-1989','M','quang ninh', '0865384876',default,90000);
insert into public.people values (default, 'Hung','Nguyen','3-1-2002','M','Thanh Hoa', '0247866378',default,24000);
insert into public.people values (default, 'Khanh','Nguyen','2-7-2002','M','Ha Nam', '0867984358',default,48000);
insert into public.people values (default, 'Hung','Phan','1-4-1988','M','Thanh hoa', '0578533221',default,36000);
insert into public.people values (default, 'Truong','Hoang','9-7-2002','M','Thai Binh', '087955453',default,40000);
insert into public.people values (default, 'Quan','le','8-9-1980','M','ha noi', '0587867865',default,37000);
insert into public.people values (default, 'Tien','Nguyen','1-11-1982','M','ha nam', '087986868',default,37000);
insert into public.people values (default, 'Hien','Nguyen','5-7-2002','F','Hoa binh', '086796686',default,45000);
insert into public.people values (default, 'Linh','Hoang','2-1-2002','F','vinh phuc', '055788964',default,74000);
insert into public.people values (default, 'Dung','Phan','5-10-2002','M','vinh phuc', '0869766846',default,36000);
insert into public.people values (default, 'Huan','Le','6-9-1987','M','ninh binh', '0897668658',default,37000);
insert into public.people values (default, 'Tuan','Tran','8-10-2002','M','Thai Binh', '0879853453',default,40000);
insert into public.people values (default, 'Ngoc','Le','12-2-2002','M','Hoa Binh', '0578867653',default,50000);

insert into public.car values (default, '1','toyota','old','2000','manual', '1000','yes');
insert into public.car values (default, '1','honda','new','2020','auto', '5000','yes');
insert into public.car values (default, '3','mitsubishi','old','2005','manual', '2000','yes');
insert into public.car values (default, '2','huyndai','new','2021','auto', '6000','yes');

insert into public.car values (default, '6','toyota','old','2000','auto', '1000','yes');
insert into public.car values (default, '11','honda','old','2019','manual', '4000','yes');
insert into public.car values (default, '8','mitsubishi','old','2005','auto', '5000','yes');
insert into public.car values (default, '10','huyndai','new','2021','manual', '5000','yes');

insert into public.car values (default, '9','toyota','old','2014','manual', '3000','yes');
insert into public.car values (default, '16','honda','new','2021','auto', '6000','yes');
insert into public.car values (default, '23','mitsubishi','old','2021','auto', '7000','yes');
insert into public.car values (default, '20','huyndai','new','2021','auto', '9000','yes');


insert into public.car values (default, '13','mercedes','new','2020','auto', '15000','yes');
insert into public.car values (default, '19','mercedes','old','2016','auto', '18000','yes');
insert into public.car values (default, '20','mercedes','new','2021','auto', '20000','yes');
insert into public.car values (default, '23','mercedes','old','2012','manual', '12000','yes');
insert into public.car values (default, '15','mercedes','new','2022','auto', '30000','yes');

insert into public.car values (default, '11','lexus','new','2022','auto', '30000','yes');
insert into public.car values (default, '12','lexus','new','2022','auto', '30000','yes');
insert into public.car values (default, '21','lexus','new','2022','auto', '30000','yes');
insert into public.car values (default, '23','lexus','old','2010','manual', '12000','yes');
insert into public.car values (default, '8','lexus','old','2009','manual', '10000','yes');
insert into public.car values (default, '7','lexus','old','2017','manual', '20000','yes');

insert into public.car values (default, '22','lamborghini','new','2020','auto', '50000','yes');
insert into public.car values (default, '24','lamborghini','old','2019','auto', '41000','yes');
insert into public.car values (default, '26','lamborghini','new','2019','auto', '45000','yes');

insert into public.car values (default, '5','kia','new','2019','auto', '3000','yes');
insert into public.car values (default, '8','kia','new','2020','auto', '4000','yes');
insert into public.car values (default, '14','kia','new','2019','manual', '3000','yes');
insert into public.car values (default, '28','kia','old','2015','manual', '2000','yes');
insert into public.car values (default, '29','kia','old','2014','manual', '1000','yes');

insert into public.car values (default, '27','vinfast','old','2019','manual', '5000','yes');
insert into public.car values (default, '20','vinfast','old','2020','manual', '6000','yes');
insert into public.car values (default, '30','vinfast','old','2021','auto', '4000','yes');
insert into public.car values (default, '31','vinfast','new','2021','manual', '7000','yes');
insert into public.car values (default, '2','vinfast','new','2021','manual', '8000','yes');
insert into public.car values (default, '1','vinfast','new','2020','auto', '6000','yes');




--
-- PostgreSQL database dump complete
--

