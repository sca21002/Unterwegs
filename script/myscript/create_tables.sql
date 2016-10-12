--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.4
-- Dumped by pg_dump version 9.5.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

SET search_path = public, pg_catalog;

ALTER TABLE ONLY public.tracks DROP CONSTRAINT tracks_travel_mode_id_fkey;
ALTER TABLE ONLY public.tracks DROP CONSTRAINT tracks_tour_id_fkey;
ALTER TABLE ONLY public.track_points DROP CONSTRAINT track_points_track_fid_fkey;
DROP INDEX public.tracks_geom_idx;
DROP INDEX public.track_points_geom_idx;
ALTER TABLE ONLY public.travel_modes DROP CONSTRAINT travel_mode_pkey;
ALTER TABLE ONLY public.travel_modes DROP CONSTRAINT travel_mode_name_key;
ALTER TABLE ONLY public.tracks DROP CONSTRAINT tracks_pkey;
ALTER TABLE ONLY public.track_points DROP CONSTRAINT track_points_pkey;
ALTER TABLE ONLY public.tours DROP CONSTRAINT tours_pkey;
ALTER TABLE ONLY public.tours DROP CONSTRAINT tours_name_key;
ALTER TABLE public.travel_modes ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.tracks ALTER COLUMN ogc_fid DROP DEFAULT;
ALTER TABLE public.track_points ALTER COLUMN ogc_fid DROP DEFAULT;
ALTER TABLE public.tours ALTER COLUMN tour_id DROP DEFAULT;
DROP SEQUENCE public.travel_modes_travel_mode_id_seq;
DROP TABLE public.travel_modes;
DROP SEQUENCE public.tracks_ogc_fid_seq;
DROP TABLE public.tracks;
DROP SEQUENCE public.track_points_ogc_fid_seq;
DROP TABLE public.track_points;
DROP SEQUENCE public.tours_tour_id_seq;
DROP TABLE public.tours;
DROP EXTENSION postgis;
DROP EXTENSION plpgsql;
DROP SCHEMA public;
--
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO postgres;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: tours; Type: TABLE; Schema: public; Owner: unterwegs
--

CREATE TABLE tours (
    tour_id integer NOT NULL,
    name character varying(255),
    start_date date,
    end_date date
);


ALTER TABLE tours OWNER TO unterwegs;

--
-- Name: tours_tour_id_seq; Type: SEQUENCE; Schema: public; Owner: unterwegs
--

CREATE SEQUENCE tours_tour_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE tours_tour_id_seq OWNER TO unterwegs;

--
-- Name: tours_tour_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: unterwegs
--

ALTER SEQUENCE tours_tour_id_seq OWNED BY tours.tour_id;


--
-- Name: track_points; Type: TABLE; Schema: public; Owner: unterwegs
--

CREATE TABLE track_points (
    ogc_fid integer NOT NULL,
    wkb_geometry geometry(Point,4326),
    track_fid integer,
    track_seg_id integer,
    track_seg_point_id integer,
    ele double precision,
    "time" timestamp with time zone,
    magvar double precision,
    geoidheight double precision,
    name character varying,
    cmt character varying,
    "desc" character varying,
    src character varying,
    link1_href character varying,
    link1_text character varying,
    link1_type character varying,
    link2_href character varying,
    link2_text character varying,
    link2_type character varying,
    sym character varying,
    type character varying,
    fix character varying,
    sat integer,
    hdop double precision,
    vdop double precision,
    pdop double precision,
    ageofdgpsdata double precision,
    dgpsid integer,
    hr integer,
    speed integer
);


ALTER TABLE track_points OWNER TO unterwegs;

--
-- Name: track_points_ogc_fid_seq; Type: SEQUENCE; Schema: public; Owner: unterwegs
--

CREATE SEQUENCE track_points_ogc_fid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE track_points_ogc_fid_seq OWNER TO unterwegs;

--
-- Name: track_points_ogc_fid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: unterwegs
--

ALTER SEQUENCE track_points_ogc_fid_seq OWNED BY track_points.ogc_fid;


--
-- Name: tracks; Type: TABLE; Schema: public; Owner: unterwegs
--

CREATE TABLE tracks (
    ogc_fid integer NOT NULL,
    wkb_geometry geometry(MultiLineString,4326),
    name character varying,
    cmt character varying,
    "desc" character varying,
    src character varying,
    link1_href character varying,
    link1_text character varying,
    link1_type character varying,
    link2_href character varying,
    link2_text character varying,
    link2_type character varying,
    number integer,
    type character varying,
    tour_id integer,
    file character varying,
    start timestamp with time zone,
    "end" timestamp with time zone,
    duration interval hour to second(0),
    len bigint,
    avg_speed double precision,
    travel_mode_id integer
);


ALTER TABLE tracks OWNER TO unterwegs;

--
-- Name: tracks_ogc_fid_seq; Type: SEQUENCE; Schema: public; Owner: unterwegs
--

CREATE SEQUENCE tracks_ogc_fid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE tracks_ogc_fid_seq OWNER TO unterwegs;

--
-- Name: tracks_ogc_fid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: unterwegs
--

ALTER SEQUENCE tracks_ogc_fid_seq OWNED BY tracks.ogc_fid;


--
-- Name: travel_modes; Type: TABLE; Schema: public; Owner: unterwegs
--

CREATE TABLE travel_modes (
    id integer NOT NULL,
    name character varying(255),
    icon character varying(255)
);


ALTER TABLE travel_modes OWNER TO unterwegs;

--
-- Name: travel_modes_travel_mode_id_seq; Type: SEQUENCE; Schema: public; Owner: unterwegs
--

CREATE SEQUENCE travel_modes_travel_mode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE travel_modes_travel_mode_id_seq OWNER TO unterwegs;

--
-- Name: travel_modes_travel_mode_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: unterwegs
--

ALTER SEQUENCE travel_modes_travel_mode_id_seq OWNED BY travel_modes.id;


--
-- Name: tour_id; Type: DEFAULT; Schema: public; Owner: unterwegs
--

ALTER TABLE ONLY tours ALTER COLUMN tour_id SET DEFAULT nextval('tours_tour_id_seq'::regclass);


--
-- Name: ogc_fid; Type: DEFAULT; Schema: public; Owner: unterwegs
--

ALTER TABLE ONLY track_points ALTER COLUMN ogc_fid SET DEFAULT nextval('track_points_ogc_fid_seq'::regclass);


--
-- Name: ogc_fid; Type: DEFAULT; Schema: public; Owner: unterwegs
--

ALTER TABLE ONLY tracks ALTER COLUMN ogc_fid SET DEFAULT nextval('tracks_ogc_fid_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: unterwegs
--

ALTER TABLE ONLY travel_modes ALTER COLUMN id SET DEFAULT nextval('travel_modes_travel_mode_id_seq'::regclass);


--
-- Name: tours_name_key; Type: CONSTRAINT; Schema: public; Owner: unterwegs
--

ALTER TABLE ONLY tours
    ADD CONSTRAINT tours_name_key UNIQUE (name);


--
-- Name: tours_pkey; Type: CONSTRAINT; Schema: public; Owner: unterwegs
--

ALTER TABLE ONLY tours
    ADD CONSTRAINT tours_pkey PRIMARY KEY (tour_id);


--
-- Name: track_points_pkey; Type: CONSTRAINT; Schema: public; Owner: unterwegs
--

ALTER TABLE ONLY track_points
    ADD CONSTRAINT track_points_pkey PRIMARY KEY (ogc_fid);


--
-- Name: tracks_pkey; Type: CONSTRAINT; Schema: public; Owner: unterwegs
--

ALTER TABLE ONLY tracks
    ADD CONSTRAINT tracks_pkey PRIMARY KEY (ogc_fid);


--
-- Name: travel_mode_name_key; Type: CONSTRAINT; Schema: public; Owner: unterwegs
--

ALTER TABLE ONLY travel_modes
    ADD CONSTRAINT travel_mode_name_key UNIQUE (name);


--
-- Name: travel_mode_pkey; Type: CONSTRAINT; Schema: public; Owner: unterwegs
--

ALTER TABLE ONLY travel_modes
    ADD CONSTRAINT travel_mode_pkey PRIMARY KEY (id);


--
-- Name: track_points_geom_idx; Type: INDEX; Schema: public; Owner: unterwegs
--

CREATE INDEX track_points_geom_idx ON track_points USING gist (wkb_geometry);


--
-- Name: tracks_geom_idx; Type: INDEX; Schema: public; Owner: unterwegs
--

CREATE INDEX tracks_geom_idx ON tracks USING gist (wkb_geometry);


--
-- Name: track_points_track_fid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: unterwegs
--

ALTER TABLE ONLY track_points
    ADD CONSTRAINT track_points_track_fid_fkey FOREIGN KEY (track_fid) REFERENCES tracks(ogc_fid);


--
-- Name: tracks_tour_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: unterwegs
--

ALTER TABLE ONLY tracks
    ADD CONSTRAINT tracks_tour_id_fkey FOREIGN KEY (tour_id) REFERENCES tours(tour_id);


--
-- Name: tracks_travel_mode_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: unterwegs
--

ALTER TABLE ONLY tracks
    ADD CONSTRAINT tracks_travel_mode_id_fkey FOREIGN KEY (travel_mode_id) REFERENCES travel_modes(id);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

