--
-- PostgreSQL database dump
--

-- Dumped from database version 9.4.15
-- Dumped by pg_dump version 9.4.0
-- Started on 2020-04-16 01:15:05

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 213 (class 3079 OID 11861)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2230 (class 0 OID 0)
-- Dependencies: 213
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- TOC entry 232 (class 1255 OID 327693)
-- Name: all_machin(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION all_machin() RETURNS TABLE(id integer, model character varying, age integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN QUERY
  select m.id, m.model, m.age from machines m;
END;
$$;


ALTER FUNCTION public.all_machin() OWNER TO postgres;

--
-- TOC entry 244 (class 1255 OID 327700)
-- Name: form_brigada(integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION form_brigada(p_id_z integer, p_id_serv integer, p_id_emp integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare 
	did integer;
    dig integer;
BEGIN
      INSERT INTO ispolnit_brigada
      (
        id_emp,
        id_servis
      )
      VALUES (
        p_id_emp,
        p_id_serv
      ) RETURNING id into did;
      
      
      INSERT INTO brigada
      (
        id_zayavki,
        id_ispolnit
      )
      VALUES (
        p_id_z,
        did
      );
      
      select id into dig from brigada where id_zayavki = p_id_z and id_ispolnit = did;
      
      UPDATE jurnal_obslujivaniya 
      SET 
        date_postuplenya = timenow(),
        id_brigady = dig
      WHERE 
        id_zayavki = p_id_z
      ;
      
      UPDATE jurnal_zayavok 
      SET 
        state = 2
      WHERE 
        id = p_id_z
      ;
END;
$$;


ALTER FUNCTION public.form_brigada(p_id_z integer, p_id_serv integer, p_id_emp integer) OWNER TO postgres;

--
-- TOC entry 247 (class 1255 OID 327714)
-- Name: form_brigada_1(integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION form_brigada_1(p_id_z integer, p_id_serv integer, p_id_emp integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare 
	did integer;
    dig integer;
BEGIN
      INSERT INTO ispolnit_brigada
      (
        id_emp,
        id_servis
      )
      VALUES (
        p_id_emp,
        p_id_serv
      ) RETURNING id into did;
      
      
      INSERT INTO brigada
      (
        id_zayavki,
        id_ispolnit
      )
      VALUES (
        p_id_z,
        did
      );
      
      select id into dig from brigada where id_zayavki = p_id_z 
                                      and id_ispolnit = did;
                    
		INSERT INTO jurnal_obslujivaniya
      (
        date_postuplenya,
        id_brigady,
        id_zayavki
      )
      VALUES (
		timenow(),
        dig,
        p_id_z
      );
      
      
      UPDATE jurnal_zayavok 
      SET 
        state = 2
      WHERE 
        id = p_id_z
      ;
END;
$$;


ALTER FUNCTION public.form_brigada_1(p_id_z integer, p_id_serv integer, p_id_emp integer) OWNER TO postgres;

--
-- TOC entry 249 (class 1255 OID 319504)
-- Name: func_jurnal_obslujivaniya(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION func_jurnal_obslujivaniya() RETURNS TABLE(id_zayavki integer, vidzayavki character varying, id_brigady integer, date_postuplenya date, prioritet character varying, id integer, model character varying, nameuzel character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
  
return QUERY
    with aa as(
        select distinct( xx.id), xx.model, xx.nameuzel from (
         select z.id, m.model, 
                (select string_agg(xx.fdate,'; ') str from (
                      select concat_ws(' ', ii.datetime, ii.failure) fdate
                      from public.import_ii ii where ii."machineID" = z.id_machines and ii.failure <> 'none'
                  ) as xx
                ) nameuzel , 
                (case when isvid = true then 'Срочная' else 'Плановая' end) namevid ,
                 z.state,  z.date_postuplenya, z.date_ispolnenya
            from jurnal_zayavok z, machines m 
            where z.id_machines = m.id
        ) as xx , brigada bb
        where xx.id = bb.id_zayavki   
    ),
    bb as (
      select o.id_zayavki,
               (case when isvid = true then 'Срочная' else 'Плановая' end) vidzayavki, 
              o.id_brigady, 
              o.date_postuplenya, 
              z.prioritet 
       from jurnal_obslujivaniya o, jurnal_zayavok z
          where o.id_zayavki = z.id
    ) 
    select bb.id_zayavki, bb.vidzayavki::varchar, bb.id_brigady , bb.date_postuplenya, bb.prioritet,
            aa.id, aa.model, aa.nameuzel::varchar
    from bb
        full join aa
        on aa.id = bb.id_zayavki
        where aa.id is not null
;

        
END;
$$;


ALTER FUNCTION public.func_jurnal_obslujivaniya() OWNER TO postgres;

--
-- TOC entry 245 (class 1255 OID 327713)
-- Name: func_jurnal_obslujivaniya_2(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION func_jurnal_obslujivaniya_2() RETURNS TABLE(id_zayavki integer, vidzayavki character varying, id_brigady integer, date_postuplenya date, prioritet character varying, id integer, model character varying, nameuzel character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
  
return QUERY
    with aa as(
        select *--distinct( xx.id), xx.model, xx.nameuzel 
        from (
         select z.id, m.model, 
                (select string_agg(xx.fdate,'; ') str from (
                      select concat_ws(' ', ii.datetime, ii.failure) fdate
                      from public.import_ii ii where ii."machineID" = z.id_machines and ii.failure <> 'none'
                  ) as xx
                ) nameuzel , 
                (case when isvid = true then 'Срочная' else 'Плановая' end) namevid ,
                 z.state,  z.date_postuplenya, z.date_ispolnenya
            from jurnal_zayavok z, machines m 
            where z.id_machines = m.id
        ) as xx , brigada bb
        where xx.id = bb.id_zayavki   
    ),
    cc as (
    
              			  
           select xx.id, xx.model, xx.nameuzel, xx.namevid, xx.state, 
                   0 idbrigada, 
                   xx.date_postuplenya 
           from (
                   select z.id, m.model, 
                          (select string_agg(xx.fdate,'; ')::varchar str from (
                                select concat_ws(' ', ii.datetime, ii.failure) fdate
                                from import_ii ii where ii."machineID" = z.id_machines and ii.failure <> 'none'
                            ) as xx
                          ) nameuzel, 
                          (case when isvid = true then 'Срочная'::varchar else 'Плановая'::varchar end) namevid ,
                           z.state,  z.date_postuplenya
                      from jurnal_zayavok z, machines m 
                      where z.id_machines = m.id
                  ) as xx --, brigada bb
                  where (not EXISTS (select bb.id_zayavki from brigada bb where xx.id = bb.id_zayavki))   --xx.id = bb.id_zayavki
          union all
           select xx.id, xx.model, xx.nameuzel, xx.namevid, xx.state, 
                   bb.id idbrigada, 
                   xx.date_postuplenya 
           from (
                   select z.id, m.model, 
                          (select string_agg(xx.fdate,'; ')::varchar str from (
                                select concat_ws(' ', ii.datetime, ii.failure) fdate
                                from import_ii ii where ii."machineID" = z.id_machines and ii.failure <> 'none'
                            ) as xx
                          ) nameuzel, 
                          (case when isvid = true then 'Срочная'::varchar else 'Плановая'::varchar end) namevid ,
                           z.state,  z.date_postuplenya
                      from jurnal_zayavok z, machines m 
                      where z.id_machines = m.id
                  ) as xx , brigada bb
                  where xx.id = bb.id_zayavki
    
    ),
    
    bb as (
      select o.id_zayavki,
               (case when isvid = true then 'Срочная' else 'Плановая' end) vidzayavki, 
              o.id_brigady, 
              o.date_postuplenya, 
              z.prioritet 
       from jurnal_obslujivaniya o, jurnal_zayavok z
          where o.id_zayavki = z.id
    ) 
    select bb.id_zayavki, bb.vidzayavki::varchar, bb.id_brigady , bb.date_postuplenya, bb.prioritet,
            cc.id, cc.model, cc.nameuzel::varchar
    from bb
        full join cc
        on cc.id = bb.id_zayavki
        where cc.id is not null
;

        
END;
$$;


ALTER FUNCTION public.func_jurnal_obslujivaniya_2() OWNER TO postgres;

--
-- TOC entry 229 (class 1255 OID 327690)
-- Name: func_note(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION func_note(p_id_serv integer) RETURNS TABLE(note character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY
  SELECT s.note FROM servis s where s.id = p_id_serv;
END;
$$;


ALTER FUNCTION public.func_note(p_id_serv integer) OWNER TO postgres;

--
-- TOC entry 230 (class 1255 OID 327699)
-- Name: function(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION function() RETURNS TABLE(id integer, first_name character varying, second_name character varying, otchestvo character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN QUERY
  select e.id, e.first_name, e.second_name, e.otchestvo from employee e;
END;
$$;


ALTER FUNCTION public.function() OWNER TO postgres;

--
-- TOC entry 227 (class 1255 OID 327684)
-- Name: insert_zayavka(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION insert_zayavka(p_id_machines integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
	INSERT INTO jurnal_zayavok
(
  state,
  prioritet,
  id_machines,
  date_postuplenya,
  isvid
)
VALUES (
  1,
  1,
  p_id_machines,
  timenow(),
  FALSE
);
END;
$$;


ALTER FUNCTION public.insert_zayavka(p_id_machines integer) OWNER TO postgres;

--
-- TOC entry 250 (class 1255 OID 319506)
-- Name: jurnal_plans(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION jurnal_plans() RETURNS TABLE(id integer, model character varying, nameuzel character varying, state character varying, prioritet character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN QUERY
  
     select * from (
    select z.id, m.model, 
    	(select string_agg(xx.fdate,'; ')::varchar str from (
              select concat_ws(' ', ii.datetime, ii.failure) fdate
              from public.import_ii ii where ii."machineID" = z.id_machines and ii.failure <> 'none'
          ) as xx
        ) nameuzel , 
         z.state,
         z.prioritet
    from jurnal_zayavok z, machines m 
    where z.id_machines = m.id
) as xx
where xx.nameuzel is not null;
  
END;
$$;


ALTER FUNCTION public.jurnal_plans() OWNER TO postgres;

--
-- TOC entry 251 (class 1255 OID 327704)
-- Name: jurnal_plans_1(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION jurnal_plans_1() RETURNS TABLE(id integer, model character varying, nameuzel character varying, state character varying, prioritet character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN QUERY
  
     select z.id, m.model, 
    	(select string_agg(xx.fdate,'; ')::varchar str from (
              select concat_ws(' ', ii.datetime, ii.failure) fdate
              from public.import_ii ii where ii."machineID" = z.id_machines and ii.failure <> 'none'
          ) as xx
        ) nameuzel , 
         z.state,
         z.prioritet
    from jurnal_zayavok z, machines m 
    where z.id_machines = m.id;
  
END;
$$;


ALTER FUNCTION public.jurnal_plans_1() OWNER TO postgres;

--
-- TOC entry 234 (class 1255 OID 327705)
-- Name: jurnal_plans_2(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION jurnal_plans_2() RETURNS TABLE(id integer, model character varying, nameuzel character varying, state character varying, prioritet character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN QUERY
  
         select z.id, m.model, 
    	(select string_agg(xx.fdate,'; ')::varchar str from (
              select concat_ws(' ', ii.datetime, ii.failure) fdate
              from public.import_ii ii where ii."machineID" = z.id_machines and ii.failure <> 'none'
          ) as xx
        ) nameuzel , 
         z.state,
         z.prioritet
    from jurnal_zayavok z, machines m 
    where z.id_machines = m.id
    	and z.state != '5';
  
END;
$$;


ALTER FUNCTION public.jurnal_plans_2() OWNER TO postgres;

--
-- TOC entry 235 (class 1255 OID 327706)
-- Name: jurnal_plans_3(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION jurnal_plans_3() RETURNS TABLE(id integer, model character varying, nameuzel character varying, state character varying, prioritet character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN QUERY
  
             select z.id, m.model, 
    	(select string_agg(xx.fdate,'; ')::varchar str from (
              select concat_ws(' ', ii.datetime, ii.failure) fdate
              from public.import_ii ii where ii."machineID" = z.id_machines and ii.failure <> 'none'
          ) as xx
        ) nameuzel , 
         z.state,
         z.prioritet
    from jurnal_zayavok z, machines m 
    where z.id_machines = m.id
    	and z.state != '5'
        and z.state != '4';
  
END;
$$;


ALTER FUNCTION public.jurnal_plans_3() OWNER TO postgres;

--
-- TOC entry 248 (class 1255 OID 327707)
-- Name: jurnal_plans_4(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION jurnal_plans_4() RETURNS TABLE(id integer, model character varying, nameuzel character varying, state character varying, prioritet character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN QUERY
  
             select z.id, m.model, 
    	(select string_agg(xx.fdate,'; ')::varchar str from (
              select concat_ws(' ', ii.datetime, ii.failure) fdate
              from public.import_ii ii where ii."machineID" = z.id_machines and ii.failure <> 'none'
          ) as xx
        ) nameuzel , 
         z.state,
         z.prioritet
    from jurnal_zayavok z, machines m 
    where z.id_machines = m.id
    	and z.state != '5'
        and z.state != '4'
        and z.state != '3';
  
END;
$$;


ALTER FUNCTION public.jurnal_plans_4() OWNER TO postgres;

--
-- TOC entry 237 (class 1255 OID 319497)
-- Name: jurnal_zayavok(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION jurnal_zayavok() RETURNS TABLE(id integer, model character varying, nameuzel character varying, namevid character varying, state character varying, date_postuplenya date, date_ispolnenya date)
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN QUERY
  
      select z.id, m.model, 
    	(select string_agg(xx.fdate,'; ')::varchar str from (
              select concat_ws(' ', ii.datetime, ii.failure) fdate
              from public.import_ii ii where ii."machineID" = z.id_machines and ii.failure <> 'none'
          ) as xx
        ) nameuzel , 
        (case when isvid = true then 'Срочная'::varchar else 'Плановая'::varchar end) namevid ,
         z.state,  z.date_postuplenya, z.date_ispolnenya
    from jurnal_zayavok z, machines m 
    where z.id_machines = m.id;
  
END;
$$;


ALTER FUNCTION public.jurnal_zayavok() OWNER TO postgres;

--
-- TOC entry 242 (class 1255 OID 319502)
-- Name: jurnal_zayavok_nach_sluj(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION jurnal_zayavok_nach_sluj() RETURNS TABLE(id integer, model character varying, nameuzel character varying, namevid character varying, state character varying, idbrigada integer, date_postuplenya date)
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN QUERY
  
      select xx.id, xx.model, xx.nameuzel, xx.namevid, xx.state, bb.id idbrigada, xx.date_postuplenya from (
         select z.id, m.model, 
                (select string_agg(xx.fdate,'; ')::varchar str from (
                      select concat_ws(' ', ii.datetime, ii.failure) fdate
                      from public.import_ii ii where ii."machineID" = z.id_machines and ii.failure <> 'none'
                  ) as xx
                ) nameuzel, 
                (case when isvid = true then 'Срочная'::varchar else 'Плановая'::varchar end) namevid ,
                 z.state,  z.date_postuplenya
            from jurnal_zayavok z, machines m 
            where z.id_machines = m.id
        ) as xx , brigada bb
        where xx.id = bb.id_zayavki
  ;
END;
$$;


ALTER FUNCTION public.jurnal_zayavok_nach_sluj() OWNER TO postgres;

--
-- TOC entry 233 (class 1255 OID 327701)
-- Name: jurnal_zayavok_nach_sluj_1(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION jurnal_zayavok_nach_sluj_1() RETURNS TABLE(id integer, model character varying, nameuzel character varying, namevid character varying, state character varying, idbrigada integer, date_postuplenya date)
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN QUERY
  
      select xx.id, xx.model, xx.nameuzel, xx.namevid, xx.state, 
         0 idbrigada, 
         xx.date_postuplenya 
 from (
         select z.id, m.model, 
                (select string_agg(xx.fdate,'; ')::varchar str from (
                      select concat_ws(' ', ii.datetime, ii.failure) fdate
                      from import_ii ii where ii."machineID" = z.id_machines and ii.failure <> 'none'
                  ) as xx
                ) nameuzel, 
                (case when isvid = true then 'Срочная'::varchar else 'Плановая'::varchar end) namevid ,
                 z.state,  z.date_postuplenya
            from jurnal_zayavok z, machines m 
            where z.id_machines = m.id
        ) as xx --, brigada bb
        where (not EXISTS (select bb.id_zayavki from brigada bb where xx.id = bb.id_zayavki))   --xx.id = bb.id_zayavki
union all
 select xx.id, xx.model, xx.nameuzel, xx.namevid, xx.state, 
         bb.id idbrigada, 
         xx.date_postuplenya 
 from (
         select z.id, m.model, 
                (select string_agg(xx.fdate,'; ')::varchar str from (
                      select concat_ws(' ', ii.datetime, ii.failure) fdate
                      from import_ii ii where ii."machineID" = z.id_machines and ii.failure <> 'none'
                  ) as xx
                ) nameuzel, 
                (case when isvid = true then 'Срочная'::varchar else 'Плановая'::varchar end) namevid ,
                 z.state,  z.date_postuplenya
            from jurnal_zayavok z, machines m 
            where z.id_machines = m.id
        ) as xx , brigada bb
        where xx.id = bb.id_zayavki
  ;
END;
$$;


ALTER FUNCTION public.jurnal_zayavok_nach_sluj_1() OWNER TO postgres;

--
-- TOC entry 243 (class 1255 OID 327712)
-- Name: opis_servis(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION opis_servis(p_id_z integer) RETURNS TABLE(name character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE
  did INTEGER;
BEGIN

  select xx.id_ispolnit into did from (
          select * from jurnal_zayavok z, brigada b
                  where z.id = b.id_zayavki
                  and  z.id = p_id_z
  ) as xx;
   
return QUERY
  select s.name from servis s where s.id = did;

  
END;
$$;


ALTER FUNCTION public.opis_servis(p_id_z integer) OWNER TO postgres;

--
-- TOC entry 246 (class 1255 OID 327716)
-- Name: opis_servis_1(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION opis_servis_1() RETURNS TABLE(id_emp integer, name character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY
  select i.id_emp, s.name from ispolnit_brigada i
	join servis s
	on s.id = i.id_servis;
END;
$$;


ALTER FUNCTION public.opis_servis_1() OWNER TO postgres;

--
-- TOC entry 228 (class 1255 OID 311362)
-- Name: parser(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION parser() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  dvievs RECORD;
  dtimest TIMESTAMP;
  dcomp  integer;
  
BEGIN
  
	for dvievs in select * from maint_table d LOOP
    		
    	select concat_ws(' ', xx.nn::date, xx.mm)::TIMESTAMP into dtimest
        from (
            select a[1] as nn,
                    a[2] as mm
                    from (select regexp_split_to_array(dvievs.date_timevarchar, ' ')) as dt(a)
        ) as xx;
        
        /*select c.id into dcomp from comp c where c.name = dvievs.comp;
        if dcomp is null then 
        	INSERT INTO comp( name, id_machins, pred_otkaz)
            VALUES (dvievs.comp, dvievs.id_machins, 'f')
            RETURNING id into dcomp;
        
        end if;*/
    
    	raise NOTICE 'id_comp=%   date_time=%', dcomp, dtimest;
    	
    	INSERT INTO maint
        (
          comp,
          date_time,
          id_machines
        )
        VALUES (
          dvievs.comp,
          dtimest,
          dvievs.id_machins
        );
    
    end loop;

END;
$$;


ALTER FUNCTION public.parser() OWNER TO postgres;

--
-- TOC entry 240 (class 1255 OID 311453)
-- Name: parser_errors(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION parser_errors() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  dvievs RECORD;
  dtimest TIMESTAMP;
  dcomp  integer;
  
BEGIN
  
	for dvievs in select * from errors_table d LOOP
    		
    	select concat_ws(' ', xx.nn::date, xx.mm)::TIMESTAMP into dtimest
        from (
            select a[1] as nn,
                    a[2] as mm
                    from (select regexp_split_to_array(dvievs.date_timevarchar, ' ')) as dt(a)
        ) as xx;
        
 
    
    	raise NOTICE 'id_comp=%   date_time=%', dcomp, dtimest;
    	
    	INSERT INTO errors
        (
          datetime,
          "errorID",
          id_machines
        )
        VALUES (
          dtimest,
          dvievs."errorID",
          dvievs.id_machines
        );
    
    end loop;

END;
$$;


ALTER FUNCTION public.parser_errors() OWNER TO postgres;

--
-- TOC entry 239 (class 1255 OID 311426)
-- Name: parser_failers(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION parser_failers() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  dvievs RECORD;
  dtimest TIMESTAMP;
  dcomp  integer;
  
BEGIN
  
	for dvievs in select * from failures_table d LOOP
    		
    	select concat_ws(' ', xx.nn::date, xx.mm)::TIMESTAMP into dtimest
        from (
            select a[1] as nn,
                    a[2] as mm
                    from (select regexp_split_to_array(dvievs.date_timevarchar, ' ')) as dt(a)
        ) as xx;
        
 
    
    	raise NOTICE 'id_comp=%   date_time=%', dcomp, dtimest;
    	
    	INSERT INTO failures
        (
          comp,
          datetime,
          id_machines
        )
        VALUES (
          dvievs.comp,
          dtimest,
          dvievs.id_machines
        );
    
    end loop;

END;
$$;


ALTER FUNCTION public.parser_failers() OWNER TO postgres;

--
-- TOC entry 238 (class 1255 OID 311476)
-- Name: parser_import(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION parser_import() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  dvievs RECORD;
  dtimest TIMESTAMP;
  dcomp  integer;
  
BEGIN
  
	for dvievs in select * from public.import_ii_table d LOOP
    		
    	select concat_ws(' ', xx.nn::date, xx.mm)::TIMESTAMP into dtimest
        from (
            select a[1] as nn,
                    a[2] as mm
                    from (select regexp_split_to_array(dvievs.date_timevarchar, ' ')) as dt(a)
        ) as xx;
        
 
    
    	raise NOTICE 'id_comp=%   date_time=%', dcomp, dtimest;
        
        INSERT INTO import_ii
        (
          datetime,
          "machineID",
          failure,
          predicted_failure
        )
        VALUES (
          dtimest,
          dvievs."machineID",
          dvievs.failure,
          dvievs.predicted_failure
        );
        
    
    
    end loop;

END;
$$;


ALTER FUNCTION public.parser_import() OWNER TO postgres;

--
-- TOC entry 241 (class 1255 OID 311825)
-- Name: parser_telemetry(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION parser_telemetry() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  dvievs RECORD;
  dtimest TIMESTAMP;
  dcomp  integer;
  
BEGIN
  
	for dvievs in select * from public.telemetry_table d LOOP
    		
    	select concat_ws(' ', xx.nn::date, xx.mm)::TIMESTAMP into dtimest
        from (
            select a[1] as nn,
                    a[2] as mm
                    from (select regexp_split_to_array(dvievs.date_timevarchar, ' ')) as dt(a)
        ) as xx;
        
 
    
    	raise NOTICE 'id_comp=%   date_time=%', dcomp, dtimest;
        
        
        INSERT INTO telemetry
        (
          id_machines,
          volt,
          rotate,
          pressure,
          vibration,
          datetime
        )
        VALUES (
          dvievs.id_machines,
          dvievs.volt,
          dvievs.rotate,
          dvievs.pressure,
          dvievs.vibration,
          dtimest
        );
        
        

    
    
    end loop;

END;
$$;


ALTER FUNCTION public.parser_telemetry() OWNER TO postgres;

--
-- TOC entry 236 (class 1255 OID 327685)
-- Name: proveril(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION proveril(p_id_z integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  UPDATE jurnal_zayavok 
  SET 
    state = 5,
    date_ispolnenya = timenow()
  WHERE 
    id = p_id_z
  ;

	UPDATE jurnal_obslujivaniya 
    SET 
      date_ispolnenya = timenow()
    WHERE 
      id_zayavki = p_id_z
    ;
END;
$$;


ALTER FUNCTION public.proveril(p_id_z integer) OWNER TO postgres;

--
-- TOC entry 231 (class 1255 OID 327692)
-- Name: upd_prior(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION upd_prior(p_id integer, p_prior integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  update jurnal_zayavok set prioritet = p_prior where id = p_id;
END;
$$;


ALTER FUNCTION public.upd_prior(p_id integer, p_prior integer) OWNER TO postgres;

--
-- TOC entry 226 (class 1255 OID 327683)
-- Name: upd_state(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION upd_state(p_id integer, p_state integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  update jurnal_zayavok set state = p_state where id = p_id;
END;
$$;


ALTER FUNCTION public.upd_state(p_id integer, p_state integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 191 (class 1259 OID 270447)
-- Name: brigada; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE brigada (
    id integer NOT NULL,
    id_zayavki integer,
    id_ispolnit integer
);


ALTER TABLE brigada OWNER TO postgres;

--
-- TOC entry 190 (class 1259 OID 270445)
-- Name: brigada_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE brigada_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE brigada_id_seq OWNER TO postgres;

--
-- TOC entry 2231 (class 0 OID 0)
-- Dependencies: 190
-- Name: brigada_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE brigada_id_seq OWNED BY brigada.id;


--
-- TOC entry 187 (class 1259 OID 270425)
-- Name: cex; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE cex (
    id integer NOT NULL,
    name character varying(50),
    id_parent integer
);


ALTER TABLE cex OWNER TO postgres;

--
-- TOC entry 186 (class 1259 OID 270423)
-- Name: cex_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE cex_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE cex_id_seq OWNER TO postgres;

--
-- TOC entry 2232 (class 0 OID 0)
-- Dependencies: 186
-- Name: cex_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE cex_id_seq OWNED BY cex.id;


--
-- TOC entry 196 (class 1259 OID 286839)
-- Name: comp_old; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE comp_old (
    id integer NOT NULL,
    name character varying(10),
    id_machins integer,
    pred_otkaz character(1) NOT NULL
);


ALTER TABLE comp_old OWNER TO postgres;

--
-- TOC entry 195 (class 1259 OID 286837)
-- Name: comp_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE comp_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE comp_id_seq OWNER TO postgres;

--
-- TOC entry 2233 (class 0 OID 0)
-- Dependencies: 195
-- Name: comp_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE comp_id_seq OWNED BY comp_old.id;


--
-- TOC entry 194 (class 1259 OID 286739)
-- Name: emp_brigada_id_brigada_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE emp_brigada_id_brigada_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE emp_brigada_id_brigada_seq OWNER TO postgres;

--
-- TOC entry 189 (class 1259 OID 270438)
-- Name: employee; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE employee (
    id integer NOT NULL,
    first_name character varying(25),
    second_name character varying(25),
    otchestvo character varying(25),
    id_cech integer
);


ALTER TABLE employee OWNER TO postgres;

--
-- TOC entry 188 (class 1259 OID 270436)
-- Name: employee_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE employee_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE employee_id_seq OWNER TO postgres;

--
-- TOC entry 2234 (class 0 OID 0)
-- Dependencies: 188
-- Name: employee_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE employee_id_seq OWNED BY employee.id;


--
-- TOC entry 173 (class 1259 OID 270365)
-- Name: errors; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE errors (
    datetime timestamp without time zone,
    id integer DEFAULT nextval(('public.errors_id_seq'::text)::regclass) NOT NULL,
    "errorID" character varying(10),
    id_machines integer
);


ALTER TABLE errors OWNER TO postgres;

--
-- TOC entry 176 (class 1259 OID 270379)
-- Name: errors_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE errors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE errors_id_seq OWNER TO postgres;

--
-- TOC entry 206 (class 1259 OID 311437)
-- Name: errors_table; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE errors_table (
    datetime timestamp without time zone,
    id integer NOT NULL,
    "errorID" character varying(10),
    id_machines integer,
    date_timevarchar character varying
);


ALTER TABLE errors_table OWNER TO postgres;

--
-- TOC entry 205 (class 1259 OID 311435)
-- Name: errors_table_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE errors_table_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE errors_table_id_seq OWNER TO postgres;

--
-- TOC entry 2235 (class 0 OID 0)
-- Dependencies: 205
-- Name: errors_table_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE errors_table_id_seq OWNED BY errors_table.id;


--
-- TOC entry 179 (class 1259 OID 270391)
-- Name: failures; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE failures (
    id integer NOT NULL,
    datetime timestamp without time zone,
    comp character varying,
    id_machines integer
);


ALTER TABLE failures OWNER TO postgres;

--
-- TOC entry 178 (class 1259 OID 270389)
-- Name: failures_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE failures_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE failures_id_seq OWNER TO postgres;

--
-- TOC entry 2236 (class 0 OID 0)
-- Dependencies: 178
-- Name: failures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE failures_id_seq OWNED BY failures.id;


--
-- TOC entry 204 (class 1259 OID 311366)
-- Name: failures_table; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE failures_table (
    id integer NOT NULL,
    datetime date,
    comp character varying,
    date_timevarchar character varying,
    id_machines integer
);


ALTER TABLE failures_table OWNER TO postgres;

--
-- TOC entry 203 (class 1259 OID 311364)
-- Name: failures_table_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE failures_table_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE failures_table_id_seq OWNER TO postgres;

--
-- TOC entry 2237 (class 0 OID 0)
-- Dependencies: 203
-- Name: failures_table_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE failures_table_id_seq OWNED BY failures_table.id;


--
-- TOC entry 208 (class 1259 OID 311456)
-- Name: import_ii; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE import_ii (
    id integer NOT NULL,
    datetime timestamp without time zone,
    "machineID" integer,
    failure character varying,
    predicted_failure character varying
);


ALTER TABLE import_ii OWNER TO postgres;

--
-- TOC entry 207 (class 1259 OID 311454)
-- Name: import_ii_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE import_ii_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE import_ii_id_seq OWNER TO postgres;

--
-- TOC entry 2238 (class 0 OID 0)
-- Dependencies: 207
-- Name: import_ii_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE import_ii_id_seq OWNED BY import_ii.id;


--
-- TOC entry 210 (class 1259 OID 311467)
-- Name: import_ii_table; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE import_ii_table (
    id integer NOT NULL,
    datetime timestamp without time zone,
    "machineID" integer,
    failure character varying,
    predicted_failure character varying,
    date_timevarchar character varying
);


ALTER TABLE import_ii_table OWNER TO postgres;

--
-- TOC entry 209 (class 1259 OID 311465)
-- Name: import_ii_table_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE import_ii_table_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE import_ii_table_id_seq OWNER TO postgres;

--
-- TOC entry 2239 (class 0 OID 0)
-- Dependencies: 209
-- Name: import_ii_table_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE import_ii_table_id_seq OWNED BY import_ii_table.id;


--
-- TOC entry 192 (class 1259 OID 270453)
-- Name: ispolnit_brigada; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE ispolnit_brigada (
    id_emp integer,
    id integer NOT NULL,
    id_servis integer
);


ALTER TABLE ispolnit_brigada OWNER TO postgres;

--
-- TOC entry 198 (class 1259 OID 294932)
-- Name: ispolnit_brigada_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE ispolnit_brigada_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ispolnit_brigada_id_seq OWNER TO postgres;

--
-- TOC entry 2240 (class 0 OID 0)
-- Dependencies: 198
-- Name: ispolnit_brigada_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE ispolnit_brigada_id_seq OWNED BY ispolnit_brigada.id;


--
-- TOC entry 183 (class 1259 OID 270403)
-- Name: jurnal_obslujivaniya; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE jurnal_obslujivaniya (
    id integer NOT NULL,
    date_postuplenya date,
    date_ispolnenya date,
    id_brigady integer,
    id_zayavki integer
);


ALTER TABLE jurnal_obslujivaniya OWNER TO postgres;

--
-- TOC entry 182 (class 1259 OID 270401)
-- Name: jurnal_obslujivaniya_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE jurnal_obslujivaniya_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE jurnal_obslujivaniya_id_seq OWNER TO postgres;

--
-- TOC entry 2241 (class 0 OID 0)
-- Dependencies: 182
-- Name: jurnal_obslujivaniya_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE jurnal_obslujivaniya_id_seq OWNED BY jurnal_obslujivaniya.id;


--
-- TOC entry 185 (class 1259 OID 270409)
-- Name: jurnal_zayavok; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE jurnal_zayavok (
    id integer NOT NULL,
    state character varying(15),
    prioritet character varying(10),
    id_machines integer,
    date_postuplenya date,
    date_ispolnenya date,
    isvid boolean
);


ALTER TABLE jurnal_zayavok OWNER TO postgres;

--
-- TOC entry 2242 (class 0 OID 0)
-- Dependencies: 185
-- Name: COLUMN jurnal_zayavok.isvid; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN jurnal_zayavok.isvid IS 'true - пришло от ии
false - заполнено самостоятельно';


--
-- TOC entry 184 (class 1259 OID 270407)
-- Name: jurnal_zayavok_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE jurnal_zayavok_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE jurnal_zayavok_id_seq OWNER TO postgres;

--
-- TOC entry 2243 (class 0 OID 0)
-- Dependencies: 184
-- Name: jurnal_zayavok_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE jurnal_zayavok_id_seq OWNED BY jurnal_zayavok.id;


--
-- TOC entry 200 (class 1259 OID 311300)
-- Name: jurnal_zayavok_new; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE jurnal_zayavok_new (
    id integer NOT NULL,
    state character varying(15),
    prioritet character varying(10),
    id_brigady integer,
    id_machines integer,
    date_postuplenya date,
    date_ispolnenya date
);


ALTER TABLE jurnal_zayavok_new OWNER TO postgres;

--
-- TOC entry 199 (class 1259 OID 311298)
-- Name: jurnal_zayavok_new_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE jurnal_zayavok_new_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE jurnal_zayavok_new_id_seq OWNER TO postgres;

--
-- TOC entry 2244 (class 0 OID 0)
-- Dependencies: 199
-- Name: jurnal_zayavok_new_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE jurnal_zayavok_new_id_seq OWNED BY jurnal_zayavok_new.id;


--
-- TOC entry 172 (class 1259 OID 270346)
-- Name: machines; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE machines (
    id integer DEFAULT nextval(('public.macines_machineid_seq'::text)::regclass) NOT NULL,
    model character varying(8),
    planoviy_remont date,
    age integer
);


ALTER TABLE machines OWNER TO postgres;

--
-- TOC entry 177 (class 1259 OID 270384)
-- Name: macines_machineid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE macines_machineid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE macines_machineid_seq OWNER TO postgres;

--
-- TOC entry 175 (class 1259 OID 270375)
-- Name: maint; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE maint (
    id integer NOT NULL,
    comp character varying,
    date_time timestamp without time zone,
    id_machines integer
);


ALTER TABLE maint OWNER TO postgres;

--
-- TOC entry 174 (class 1259 OID 270373)
-- Name: maint_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE maint_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maint_id_seq OWNER TO postgres;

--
-- TOC entry 2245 (class 0 OID 0)
-- Dependencies: 174
-- Name: maint_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE maint_id_seq OWNED BY maint.id;


--
-- TOC entry 202 (class 1259 OID 311353)
-- Name: maint_table; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE maint_table (
    id integer NOT NULL,
    date_time timestamp without time zone,
    comp character varying,
    id_machins integer,
    date_timevarchar character varying
);
ALTER TABLE ONLY maint_table ALTER COLUMN id SET STATISTICS 0;


ALTER TABLE maint_table OWNER TO postgres;

--
-- TOC entry 201 (class 1259 OID 311351)
-- Name: maint_table_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE maint_table_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE maint_table_id_seq OWNER TO postgres;

--
-- TOC entry 2246 (class 0 OID 0)
-- Dependencies: 201
-- Name: maint_table_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE maint_table_id_seq OWNED BY maint_table.id;


--
-- TOC entry 193 (class 1259 OID 270458)
-- Name: servis; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE servis (
    name character varying,
    id integer NOT NULL,
    note character varying
);


ALTER TABLE servis OWNER TO postgres;

--
-- TOC entry 197 (class 1259 OID 286868)
-- Name: servis_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE servis_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE servis_id_seq OWNER TO postgres;

--
-- TOC entry 2247 (class 0 OID 0)
-- Dependencies: 197
-- Name: servis_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE servis_id_seq OWNED BY servis.id;


--
-- TOC entry 212 (class 1259 OID 311755)
-- Name: telemetry; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE telemetry (
    id integer NOT NULL,
    id_machines integer,
    volt numeric,
    rotate numeric,
    pressure numeric,
    vibration numeric,
    date character varying
);


ALTER TABLE telemetry OWNER TO postgres;

--
-- TOC entry 181 (class 1259 OID 270397)
-- Name: telemetry_old; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE telemetry_old (
    id integer NOT NULL,
    id_machines integer,
    volt numeric,
    rotate numeric,
    pressure numeric,
    vibration numeric,
    datetime timestamp without time zone
);


ALTER TABLE telemetry_old OWNER TO postgres;

--
-- TOC entry 180 (class 1259 OID 270395)
-- Name: telemetry_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE telemetry_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE telemetry_id_seq OWNER TO postgres;

--
-- TOC entry 2248 (class 0 OID 0)
-- Dependencies: 180
-- Name: telemetry_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE telemetry_id_seq OWNED BY telemetry_old.id;


--
-- TOC entry 211 (class 1259 OID 311753)
-- Name: telemetry_table_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE telemetry_table_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE telemetry_table_id_seq OWNER TO postgres;

--
-- TOC entry 2249 (class 0 OID 0)
-- Dependencies: 211
-- Name: telemetry_table_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE telemetry_table_id_seq OWNED BY telemetry.id;


--
-- TOC entry 2046 (class 2604 OID 270450)
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY brigada ALTER COLUMN id SET DEFAULT nextval('brigada_id_seq'::regclass);


--
-- TOC entry 2044 (class 2604 OID 270428)
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY cex ALTER COLUMN id SET DEFAULT nextval('cex_id_seq'::regclass);


--
-- TOC entry 2049 (class 2604 OID 286842)
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY comp_old ALTER COLUMN id SET DEFAULT nextval('comp_id_seq'::regclass);


--
-- TOC entry 2045 (class 2604 OID 270441)
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY employee ALTER COLUMN id SET DEFAULT nextval('employee_id_seq'::regclass);


--
-- TOC entry 2053 (class 2604 OID 311440)
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY errors_table ALTER COLUMN id SET DEFAULT nextval('errors_table_id_seq'::regclass);


--
-- TOC entry 2040 (class 2604 OID 270394)
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY failures ALTER COLUMN id SET DEFAULT nextval('failures_id_seq'::regclass);


--
-- TOC entry 2052 (class 2604 OID 311369)
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY failures_table ALTER COLUMN id SET DEFAULT nextval('failures_table_id_seq'::regclass);


--
-- TOC entry 2054 (class 2604 OID 311459)
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY import_ii ALTER COLUMN id SET DEFAULT nextval('import_ii_id_seq'::regclass);


--
-- TOC entry 2055 (class 2604 OID 311470)
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY import_ii_table ALTER COLUMN id SET DEFAULT nextval('import_ii_table_id_seq'::regclass);


--
-- TOC entry 2047 (class 2604 OID 294934)
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY ispolnit_brigada ALTER COLUMN id SET DEFAULT nextval('ispolnit_brigada_id_seq'::regclass);


--
-- TOC entry 2042 (class 2604 OID 270406)
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY jurnal_obslujivaniya ALTER COLUMN id SET DEFAULT nextval('jurnal_obslujivaniya_id_seq'::regclass);


--
-- TOC entry 2043 (class 2604 OID 270412)
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY jurnal_zayavok ALTER COLUMN id SET DEFAULT nextval('jurnal_zayavok_id_seq'::regclass);


--
-- TOC entry 2050 (class 2604 OID 311303)
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY jurnal_zayavok_new ALTER COLUMN id SET DEFAULT nextval('jurnal_zayavok_new_id_seq'::regclass);


--
-- TOC entry 2039 (class 2604 OID 270378)
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY maint ALTER COLUMN id SET DEFAULT nextval('maint_id_seq'::regclass);


--
-- TOC entry 2051 (class 2604 OID 311356)
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY maint_table ALTER COLUMN id SET DEFAULT nextval('maint_table_id_seq'::regclass);


--
-- TOC entry 2048 (class 2604 OID 286870)
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY servis ALTER COLUMN id SET DEFAULT nextval('servis_id_seq'::regclass);


--
-- TOC entry 2056 (class 2604 OID 311758)
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY telemetry ALTER COLUMN id SET DEFAULT nextval('telemetry_table_id_seq'::regclass);


--
-- TOC entry 2041 (class 2604 OID 270400)
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY telemetry_old ALTER COLUMN id SET DEFAULT nextval('telemetry_id_seq'::regclass);


--
-- TOC entry 2076 (class 2606 OID 270452)
-- Name: brigada_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY brigada
    ADD CONSTRAINT brigada_pkey PRIMARY KEY (id);


--
-- TOC entry 2072 (class 2606 OID 270430)
-- Name: cex_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY cex
    ADD CONSTRAINT cex_pkey PRIMARY KEY (id);


--
-- TOC entry 2082 (class 2606 OID 286846)
-- Name: comp_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY comp_old
    ADD CONSTRAINT comp_name_key UNIQUE (name);


--
-- TOC entry 2084 (class 2606 OID 286844)
-- Name: comp_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY comp_old
    ADD CONSTRAINT comp_pkey PRIMARY KEY (id);


--
-- TOC entry 2088 (class 2606 OID 311361)
-- Name: comp_table_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY maint_table
    ADD CONSTRAINT comp_table_pkey PRIMARY KEY (id);


--
-- TOC entry 2074 (class 2606 OID 270443)
-- Name: employee_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY employee
    ADD CONSTRAINT employee_pkey PRIMARY KEY (id);


--
-- TOC entry 2060 (class 2606 OID 270382)
-- Name: errors_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY errors
    ADD CONSTRAINT errors_pkey PRIMARY KEY (id);


--
-- TOC entry 2092 (class 2606 OID 311444)
-- Name: errors_table_datetime_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY errors_table
    ADD CONSTRAINT errors_table_datetime_key UNIQUE (datetime);


--
-- TOC entry 2094 (class 2606 OID 311442)
-- Name: errors_table_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY errors_table
    ADD CONSTRAINT errors_table_pkey PRIMARY KEY (id);


--
-- TOC entry 2064 (class 2606 OID 270416)
-- Name: failures_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY failures
    ADD CONSTRAINT failures_pkey PRIMARY KEY (id);


--
-- TOC entry 2090 (class 2606 OID 311371)
-- Name: failures_table_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY failures_table
    ADD CONSTRAINT failures_table_pkey PRIMARY KEY (id);


--
-- TOC entry 2096 (class 2606 OID 311464)
-- Name: import_ii_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY import_ii
    ADD CONSTRAINT import_ii_pkey PRIMARY KEY (id);


--
-- TOC entry 2098 (class 2606 OID 311475)
-- Name: import_ii_table_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY import_ii_table
    ADD CONSTRAINT import_ii_table_pkey PRIMARY KEY (id);


--
-- TOC entry 2078 (class 2606 OID 294942)
-- Name: ispolnit_brigada_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY ispolnit_brigada
    ADD CONSTRAINT ispolnit_brigada_pkey PRIMARY KEY (id);


--
-- TOC entry 2068 (class 2606 OID 270418)
-- Name: jurnal_obslujivaniya_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY jurnal_obslujivaniya
    ADD CONSTRAINT jurnal_obslujivaniya_pkey PRIMARY KEY (id);


--
-- TOC entry 2086 (class 2606 OID 311305)
-- Name: jurnal_zayavok_new_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY jurnal_zayavok_new
    ADD CONSTRAINT jurnal_zayavok_new_pkey PRIMARY KEY (id);


--
-- TOC entry 2070 (class 2606 OID 270414)
-- Name: jurnal_zayavok_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY jurnal_zayavok
    ADD CONSTRAINT jurnal_zayavok_pkey PRIMARY KEY (id);


--
-- TOC entry 2058 (class 2606 OID 270387)
-- Name: macines_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY machines
    ADD CONSTRAINT macines_pkey PRIMARY KEY (id);


--
-- TOC entry 2062 (class 2606 OID 270420)
-- Name: maint_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY maint
    ADD CONSTRAINT maint_pkey PRIMARY KEY (id);


--
-- TOC entry 2080 (class 2606 OID 286872)
-- Name: servis_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY servis
    ADD CONSTRAINT servis_pkey PRIMARY KEY (id);


--
-- TOC entry 2066 (class 2606 OID 270422)
-- Name: telemetry_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY telemetry_old
    ADD CONSTRAINT telemetry_pkey PRIMARY KEY (id);


--
-- TOC entry 2100 (class 2606 OID 311763)
-- Name: telemetry_table_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY telemetry
    ADD CONSTRAINT telemetry_table_pkey PRIMARY KEY (id);


--
-- TOC entry 2109 (class 2606 OID 311487)
-- Name: brigada_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY brigada
    ADD CONSTRAINT brigada_fk FOREIGN KEY (id_zayavki) REFERENCES jurnal_zayavok(id) ON DELETE RESTRICT;


--
-- TOC entry 2108 (class 2606 OID 294943)
-- Name: brigada_fk1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY brigada
    ADD CONSTRAINT brigada_fk1 FOREIGN KEY (id_ispolnit) REFERENCES ispolnit_brigada(id) ON DELETE RESTRICT;


--
-- TOC entry 2107 (class 2606 OID 286734)
-- Name: employee_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY employee
    ADD CONSTRAINT employee_fk FOREIGN KEY (id_cech) REFERENCES cex(id) ON DELETE RESTRICT;


--
-- TOC entry 2101 (class 2606 OID 270504)
-- Name: errors_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY errors
    ADD CONSTRAINT errors_fk FOREIGN KEY (id_machines) REFERENCES machines(id) ON DELETE RESTRICT;


--
-- TOC entry 2103 (class 2606 OID 311421)
-- Name: failures_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY failures
    ADD CONSTRAINT failures_fk FOREIGN KEY (id_machines) REFERENCES machines(id) ON DELETE RESTRICT;


--
-- TOC entry 2112 (class 2606 OID 311477)
-- Name: import_ii_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY import_ii
    ADD CONSTRAINT import_ii_fk FOREIGN KEY ("machineID") REFERENCES machines(id) ON DELETE RESTRICT;


--
-- TOC entry 2110 (class 2606 OID 294948)
-- Name: ispolnit_brigada_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY ispolnit_brigada
    ADD CONSTRAINT ispolnit_brigada_fk FOREIGN KEY (id_emp) REFERENCES employee(id) ON DELETE RESTRICT;


--
-- TOC entry 2111 (class 2606 OID 294953)
-- Name: ispolnit_brigada_fk1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY ispolnit_brigada
    ADD CONSTRAINT ispolnit_brigada_fk1 FOREIGN KEY (id_servis) REFERENCES servis(id) ON DELETE RESTRICT;


--
-- TOC entry 2104 (class 2606 OID 303106)
-- Name: jurnal_obslujivaniya_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY jurnal_obslujivaniya
    ADD CONSTRAINT jurnal_obslujivaniya_fk FOREIGN KEY (id_brigady) REFERENCES brigada(id) ON DELETE RESTRICT;


--
-- TOC entry 2105 (class 2606 OID 311492)
-- Name: jurnal_obslujivaniya_fk1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY jurnal_obslujivaniya
    ADD CONSTRAINT jurnal_obslujivaniya_fk1 FOREIGN KEY (id_zayavki) REFERENCES jurnal_zayavok(id) ON DELETE RESTRICT;


--
-- TOC entry 2106 (class 2606 OID 286813)
-- Name: jurnal_zayavok_fk1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY jurnal_zayavok
    ADD CONSTRAINT jurnal_zayavok_fk1 FOREIGN KEY (id_machines) REFERENCES machines(id) ON DELETE RESTRICT;


--
-- TOC entry 2102 (class 2606 OID 311416)
-- Name: maint_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY maint
    ADD CONSTRAINT maint_fk FOREIGN KEY (id_machines) REFERENCES machines(id) ON DELETE RESTRICT;


--
-- TOC entry 2113 (class 2606 OID 319490)
-- Name: telemetry_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY telemetry
    ADD CONSTRAINT telemetry_fk FOREIGN KEY (id_machines) REFERENCES machines(id) ON DELETE RESTRICT;


--
-- TOC entry 2229 (class 0 OID 0)
-- Dependencies: 5
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2020-04-16 01:15:08

--
-- PostgreSQL database dump complete
--

