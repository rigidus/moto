--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: avatar; Type: TABLE; Schema: public; Owner: ylg; Tablespace: 
--

CREATE TABLE avatar (
    id integer NOT NULL,
    user_id integer NOT NULL,
    name character varying NOT NULL,
    origin character varying NOT NULL,
    ts_create bigint NOT NULL,
    state character varying
);


ALTER TABLE public.avatar OWNER TO ylg;

--
-- Name: avatar_id_seq; Type: SEQUENCE; Schema: public; Owner: ylg
--

CREATE SEQUENCE avatar_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.avatar_id_seq OWNER TO ylg;

--
-- Name: avatar_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ylg
--

ALTER SEQUENCE avatar_id_seq OWNED BY avatar.id;


--
-- Name: bratan; Type: TABLE; Schema: public; Owner: ylg; Tablespace: 
--

CREATE TABLE bratan (
    id integer NOT NULL,
    bratan_id integer,
    ts_last_upd bigint,
    name character varying NOT NULL,
    fio character varying,
    last_seen character varying,
    addr character varying,
    ts_reg character varying,
    age character varying,
    birthday character varying,
    blood character varying,
    moto_exp character varying,
    phone character varying,
    activityes character varying,
    interests character varying,
    photos character varying,
    avatar character varying,
    motos character varying
);


ALTER TABLE public.bratan OWNER TO ylg;

--
-- Name: bratan_id_seq; Type: SEQUENCE; Schema: public; Owner: ylg
--

CREATE SEQUENCE bratan_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.bratan_id_seq OWNER TO ylg;

--
-- Name: bratan_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ylg
--

ALTER SEQUENCE bratan_id_seq OWNED BY bratan.id;


--
-- Name: city; Type: TABLE; Schema: public; Owner: ylg; Tablespace: 
--

CREATE TABLE city (
    id integer NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE public.city OWNER TO ylg;

--
-- Name: city_id_seq; Type: SEQUENCE; Schema: public; Owner: ylg
--

CREATE SEQUENCE city_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.city_id_seq OWNER TO ylg;

--
-- Name: city_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ylg
--

ALTER SEQUENCE city_id_seq OWNED BY city.id;


--
-- Name: cmps; Type: TABLE; Schema: public; Owner: ylg; Tablespace: 
--

CREATE TABLE cmps (
    id integer NOT NULL,
    plex_id integer NOT NULL,
    name character varying
);


ALTER TABLE public.cmps OWNER TO ylg;

--
-- Name: cmps_id_seq; Type: SEQUENCE; Schema: public; Owner: ylg
--

CREATE SEQUENCE cmps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cmps_id_seq OWNER TO ylg;

--
-- Name: cmps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ylg
--

ALTER SEQUENCE cmps_id_seq OWNED BY cmps.id;


--
-- Name: cmpx; Type: TABLE; Schema: public; Owner: ylg; Tablespace: 
--

CREATE TABLE cmpx (
    id integer NOT NULL,
    name character varying NOT NULL,
    addr character varying,
    district_id integer,
    metro_id integer
);


ALTER TABLE public.cmpx OWNER TO ylg;

--
-- Name: cmpx_id_seq; Type: SEQUENCE; Schema: public; Owner: ylg
--

CREATE SEQUENCE cmpx_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cmpx_id_seq OWNER TO ylg;

--
-- Name: cmpx_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ylg
--

ALTER SEQUENCE cmpx_id_seq OWNED BY cmpx.id;


--
-- Name: color; Type: TABLE; Schema: public; Owner: ylg; Tablespace: 
--

CREATE TABLE color (
    id integer NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE public.color OWNER TO ylg;

--
-- Name: color_id_seq; Type: SEQUENCE; Schema: public; Owner: ylg
--

CREATE SEQUENCE color_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.color_id_seq OWNER TO ylg;

--
-- Name: color_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ylg
--

ALTER SEQUENCE color_id_seq OWNED BY color.id;


--
-- Name: crps; Type: TABLE; Schema: public; Owner: ylg; Tablespace: 
--

CREATE TABLE crps (
    id integer NOT NULL,
    plex_id integer NOT NULL,
    name character varying
);


ALTER TABLE public.crps OWNER TO ylg;

--
-- Name: crps_id_seq; Type: SEQUENCE; Schema: public; Owner: ylg
--

CREATE SEQUENCE crps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.crps_id_seq OWNER TO ylg;

--
-- Name: crps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ylg
--

ALTER SEQUENCE crps_id_seq OWNED BY crps.id;


--
-- Name: deadline; Type: TABLE; Schema: public; Owner: ylg; Tablespace: 
--

CREATE TABLE deadline (
    id integer NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE public.deadline OWNER TO ylg;

--
-- Name: deadline_id_seq; Type: SEQUENCE; Schema: public; Owner: ylg
--

CREATE SEQUENCE deadline_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.deadline_id_seq OWNER TO ylg;

--
-- Name: deadline_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ylg
--

ALTER SEQUENCE deadline_id_seq OWNED BY deadline.id;


--
-- Name: district; Type: TABLE; Schema: public; Owner: ylg; Tablespace: 
--

CREATE TABLE district (
    id integer NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE public.district OWNER TO ylg;

--
-- Name: district_id_seq; Type: SEQUENCE; Schema: public; Owner: ylg
--

CREATE SEQUENCE district_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.district_id_seq OWNER TO ylg;

--
-- Name: district_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ylg
--

ALTER SEQUENCE district_id_seq OWNED BY district.id;


--
-- Name: flat; Type: TABLE; Schema: public; Owner: ylg; Tablespace: 
--

CREATE TABLE flat (
    id integer NOT NULL,
    crps_id integer,
    rooms integer,
    area_sum character varying,
    area_living character varying,
    area_kitchen character varying,
    price integer,
    balcon character varying,
    sanuzel boolean
);


ALTER TABLE public.flat OWNER TO ylg;

--
-- Name: flat_id_seq; Type: SEQUENCE; Schema: public; Owner: ylg
--

CREATE SEQUENCE flat_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.flat_id_seq OWNER TO ylg;

--
-- Name: flat_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ylg
--

ALTER SEQUENCE flat_id_seq OWNED BY flat.id;


--
-- Name: group; Type: TABLE; Schema: public; Owner: ylg; Tablespace: 
--

CREATE TABLE "group" (
    id integer NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE public."group" OWNER TO ylg;

--
-- Name: group_id_seq; Type: SEQUENCE; Schema: public; Owner: ylg
--

CREATE SEQUENCE group_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.group_id_seq OWNER TO ylg;

--
-- Name: group_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ylg
--

ALTER SEQUENCE group_id_seq OWNED BY "group".id;


--
-- Name: metro; Type: TABLE; Schema: public; Owner: ylg; Tablespace: 
--

CREATE TABLE metro (
    id integer NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE public.metro OWNER TO ylg;

--
-- Name: metro_id_seq; Type: SEQUENCE; Schema: public; Owner: ylg
--

CREATE SEQUENCE metro_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.metro_id_seq OWNER TO ylg;

--
-- Name: metro_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ylg
--

ALTER SEQUENCE metro_id_seq OWNED BY metro.id;


--
-- Name: moto; Type: TABLE; Schema: public; Owner: ylg; Tablespace: 
--

CREATE TABLE moto (
    id integer NOT NULL,
    vendor_id integer,
    model_id integer,
    color_id integer,
    year integer,
    price integer,
    plate character varying,
    vin character varying,
    frame_num character varying,
    engine_num character varying,
    pts_data character varying,
    "desc" character varying,
    tuning character varying,
    state character varying
);


ALTER TABLE public.moto OWNER TO ylg;

--
-- Name: moto_id_seq; Type: SEQUENCE; Schema: public; Owner: ylg
--

CREATE SEQUENCE moto_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.moto_id_seq OWNER TO ylg;

--
-- Name: moto_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ylg
--

ALTER SEQUENCE moto_id_seq OWNED BY moto.id;


--
-- Name: msg; Type: TABLE; Schema: public; Owner: ylg; Tablespace: 
--

CREATE TABLE msg (
    id integer NOT NULL,
    snd_id integer NOT NULL,
    rcv_id integer NOT NULL,
    msg character varying NOT NULL,
    ts_create bigint NOT NULL,
    ts_delivery bigint NOT NULL,
    state character varying
);


ALTER TABLE public.msg OWNER TO ylg;

--
-- Name: msg_id_seq; Type: SEQUENCE; Schema: public; Owner: ylg
--

CREATE SEQUENCE msg_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.msg_id_seq OWNER TO ylg;

--
-- Name: msg_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ylg
--

ALTER SEQUENCE msg_id_seq OWNED BY msg.id;


--
-- Name: plex; Type: TABLE; Schema: public; Owner: ylg; Tablespace: 
--

CREATE TABLE plex (
    id integer NOT NULL,
    cmpx_id integer NOT NULL,
    name character varying,
    distance character varying,
    deadline_id integer,
    subsidy boolean,
    finishing character varying,
    ipoteka boolean,
    installment boolean
);


ALTER TABLE public.plex OWNER TO ylg;

--
-- Name: plex_id_seq; Type: SEQUENCE; Schema: public; Owner: ylg
--

CREATE SEQUENCE plex_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.plex_id_seq OWNER TO ylg;

--
-- Name: plex_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ylg
--

ALTER SEQUENCE plex_id_seq OWNED BY plex.id;


--
-- Name: que; Type: TABLE; Schema: public; Owner: ylg; Tablespace: 
--

CREATE TABLE que (
    id integer NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE public.que OWNER TO ylg;

--
-- Name: que_id_seq; Type: SEQUENCE; Schema: public; Owner: ylg
--

CREATE SEQUENCE que_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.que_id_seq OWNER TO ylg;

--
-- Name: que_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ylg
--

ALTER SEQUENCE que_id_seq OWNED BY que.id;


--
-- Name: quelt; Type: TABLE; Schema: public; Owner: ylg; Tablespace: 
--

CREATE TABLE quelt (
    id integer NOT NULL,
    que_id integer NOT NULL,
    text character varying NOT NULL
);


ALTER TABLE public.quelt OWNER TO ylg;

--
-- Name: quelt_id_seq; Type: SEQUENCE; Schema: public; Owner: ylg
--

CREATE SEQUENCE quelt_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.quelt_id_seq OWNER TO ylg;

--
-- Name: quelt_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ylg
--

ALTER SEQUENCE quelt_id_seq OWNED BY quelt.id;


--
-- Name: role; Type: TABLE; Schema: public; Owner: ylg; Tablespace: 
--

CREATE TABLE role (
    id integer NOT NULL,
    name character varying
);


ALTER TABLE public.role OWNER TO ylg;

--
-- Name: role_id_seq; Type: SEQUENCE; Schema: public; Owner: ylg
--

CREATE SEQUENCE role_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.role_id_seq OWNER TO ylg;

--
-- Name: role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ylg
--

ALTER SEQUENCE role_id_seq OWNED BY role.id;


--
-- Name: user; Type: TABLE; Schema: public; Owner: ylg; Tablespace: 
--

CREATE TABLE "user" (
    id integer NOT NULL,
    name character varying NOT NULL,
    password character varying NOT NULL,
    email character varying NOT NULL,
    ts_create bigint NOT NULL,
    ts_last bigint NOT NULL,
    role_id integer,
    state character varying
);


ALTER TABLE public."user" OWNER TO ylg;

--
-- Name: user2group; Type: TABLE; Schema: public; Owner: ylg; Tablespace: 
--

CREATE TABLE user2group (
    id integer NOT NULL,
    user_id integer NOT NULL,
    group_id integer NOT NULL
);


ALTER TABLE public.user2group OWNER TO ylg;

--
-- Name: user2group_id_seq; Type: SEQUENCE; Schema: public; Owner: ylg
--

CREATE SEQUENCE user2group_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user2group_id_seq OWNER TO ylg;

--
-- Name: user2group_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ylg
--

ALTER SEQUENCE user2group_id_seq OWNED BY user2group.id;


--
-- Name: user_id_seq; Type: SEQUENCE; Schema: public; Owner: ylg
--

CREATE SEQUENCE user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_id_seq OWNER TO ylg;

--
-- Name: user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ylg
--

ALTER SEQUENCE user_id_seq OWNED BY "user".id;


--
-- Name: vendor; Type: TABLE; Schema: public; Owner: ylg; Tablespace: 
--

CREATE TABLE vendor (
    id integer NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE public.vendor OWNER TO ylg;

--
-- Name: vendor_id_seq; Type: SEQUENCE; Schema: public; Owner: ylg
--

CREATE SEQUENCE vendor_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.vendor_id_seq OWNER TO ylg;

--
-- Name: vendor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ylg
--

ALTER SEQUENCE vendor_id_seq OWNED BY vendor.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: ylg
--

ALTER TABLE ONLY avatar ALTER COLUMN id SET DEFAULT nextval('avatar_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: ylg
--

ALTER TABLE ONLY bratan ALTER COLUMN id SET DEFAULT nextval('bratan_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: ylg
--

ALTER TABLE ONLY city ALTER COLUMN id SET DEFAULT nextval('city_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: ylg
--

ALTER TABLE ONLY cmps ALTER COLUMN id SET DEFAULT nextval('cmps_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: ylg
--

ALTER TABLE ONLY cmpx ALTER COLUMN id SET DEFAULT nextval('cmpx_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: ylg
--

ALTER TABLE ONLY color ALTER COLUMN id SET DEFAULT nextval('color_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: ylg
--

ALTER TABLE ONLY crps ALTER COLUMN id SET DEFAULT nextval('crps_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: ylg
--

ALTER TABLE ONLY deadline ALTER COLUMN id SET DEFAULT nextval('deadline_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: ylg
--

ALTER TABLE ONLY district ALTER COLUMN id SET DEFAULT nextval('district_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: ylg
--

ALTER TABLE ONLY flat ALTER COLUMN id SET DEFAULT nextval('flat_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: ylg
--

ALTER TABLE ONLY "group" ALTER COLUMN id SET DEFAULT nextval('group_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: ylg
--

ALTER TABLE ONLY metro ALTER COLUMN id SET DEFAULT nextval('metro_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: ylg
--

ALTER TABLE ONLY moto ALTER COLUMN id SET DEFAULT nextval('moto_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: ylg
--

ALTER TABLE ONLY msg ALTER COLUMN id SET DEFAULT nextval('msg_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: ylg
--

ALTER TABLE ONLY plex ALTER COLUMN id SET DEFAULT nextval('plex_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: ylg
--

ALTER TABLE ONLY que ALTER COLUMN id SET DEFAULT nextval('que_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: ylg
--

ALTER TABLE ONLY quelt ALTER COLUMN id SET DEFAULT nextval('quelt_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: ylg
--

ALTER TABLE ONLY role ALTER COLUMN id SET DEFAULT nextval('role_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: ylg
--

ALTER TABLE ONLY "user" ALTER COLUMN id SET DEFAULT nextval('user_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: ylg
--

ALTER TABLE ONLY user2group ALTER COLUMN id SET DEFAULT nextval('user2group_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: ylg
--

ALTER TABLE ONLY vendor ALTER COLUMN id SET DEFAULT nextval('vendor_id_seq'::regclass);


--
-- Data for Name: avatar; Type: TABLE DATA; Schema: public; Owner: ylg
--

COPY avatar (id, user_id, name, origin, ts_create, state) FROM stdin;
\.


--
-- Name: avatar_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ylg
--

SELECT pg_catalog.setval('avatar_id_seq', 1, false);


--
-- Data for Name: bratan; Type: TABLE DATA; Schema: public; Owner: ylg
--

COPY bratan (id, bratan_id, ts_last_upd, name, fio, last_seen, addr, ts_reg, age, birthday, blood, moto_exp, phone, activityes, interests, photos, avatar, motos) FROM stdin;
\.


--
-- Name: bratan_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ylg
--

SELECT pg_catalog.setval('bratan_id_seq', 1, false);


--
-- Data for Name: city; Type: TABLE DATA; Schema: public; Owner: ylg
--

COPY city (id, name) FROM stdin;
\.


--
-- Name: city_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ylg
--

SELECT pg_catalog.setval('city_id_seq', 1, false);


--
-- Data for Name: cmps; Type: TABLE DATA; Schema: public; Owner: ylg
--

COPY cmps (id, plex_id, name) FROM stdin;
\.


--
-- Name: cmps_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ylg
--

SELECT pg_catalog.setval('cmps_id_seq', 1, false);


--
-- Data for Name: cmpx; Type: TABLE DATA; Schema: public; Owner: ylg
--

COPY cmpx (id, name, addr, district_id, metro_id) FROM stdin;
1	чудеса света	Колтушское шоссе , д.60	23	22
2	тридевяткино царство	п. Мурино	23	13
3	Десяткино	САОЗТ «Ручьи», участок №47	23	13
4	Алфавит	Муринское сельское поселение	23	13
\.


--
-- Name: cmpx_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ylg
--

SELECT pg_catalog.setval('cmpx_id_seq', 4, true);


--
-- Data for Name: color; Type: TABLE DATA; Schema: public; Owner: ylg
--

COPY color (id, name) FROM stdin;
1	Синий
2	Черный
3	Красный
4	rel="nofollow
5	false
6	false
7	false
8	Серебряный
9	false
10	Белый
11	Голубой
12	Желтый
13	Зеленый
14	Фиолетовый
15	Бежевый
16	Оранжевый
17	Серый
18	Золотой
19	Коричневый
20	Пурпурный
21	Розовый
\.


--
-- Name: color_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ylg
--

SELECT pg_catalog.setval('color_id_seq', 21, true);


--
-- Data for Name: crps; Type: TABLE DATA; Schema: public; Owner: ylg
--

COPY crps (id, plex_id, name) FROM stdin;
1	1	Корпус 3
2	1	Корпус 2
3	1	Корпус 1
4	2	Корпус 3
5	2	Корпус 2
6	2	Корпус 1
7	3	Корпус 3
8	3	Корпус 2
9	3	Корпус 1
10	4	Корпус 3
11	4	Корпус 2
12	4	Корпус 1
13	5	Корпус 3
14	5	Корпус 2
15	5	Корпус 1
16	6	Корпус 3
17	6	Корпус 2
18	6	Корпус 1
19	7	Корпус 3
20	7	Корпус 2
21	7	Корпус 1
22	8	Корпус 3
23	8	Корпус 2
24	8	Корпус 1
25	9	Корпус 3
26	9	Корпус 2
27	9	Корпус 1
28	10	Корпус 3
29	10	Корпус 2
30	10	Корпус 1
\.


--
-- Name: crps_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ylg
--

SELECT pg_catalog.setval('crps_id_seq', 30, true);


--
-- Data for Name: deadline; Type: TABLE DATA; Schema: public; Owner: ylg
--

COPY deadline (id, name) FROM stdin;
1	1 квартал 2015
2	2 квартал 2015
3	3 квартал 2015
4	4 квартал 2015
5	1 квартал 2016
6	2 квартал 2016
7	3 квартал 2016
8	4 квартал 2016
9	1 квартал 2017
10	2 квартал 2017
11	3 квартал 2017
12	4 квартал 2017
13	1 квартал 2018
14	2 квартал 2018
15	3 квартал 2018
16	4 квартал 2018
17	1 квартал 2019
18	2 квартал 2019
19	3 квартал 2019
20	4 квартал 2019
\.


--
-- Name: deadline_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ylg
--

SELECT pg_catalog.setval('deadline_id_seq', 20, true);


--
-- Data for Name: district; Type: TABLE DATA; Schema: public; Owner: ylg
--

COPY district (id, name) FROM stdin;
1	Адмиралтейский
2	Василеостровский
3	Выборгский
4	Калининский
5	Кировский
6	Колпинский
7	Красногвардейский
8	Красносельский
9	Кронштадтский
10	Курортный
11	Московский
12	Невский
13	Петроградский
14	Петродворцовый
15	Приморский
16	Пушкинский
17	Фрунзенский
18	Центральный
19	Всеволожкси
20	Бокситогорский
21	Волосовский
22	Волховский
23	Всеволожский
24	Выборгский
25	Гатчинский
26	Кингисеппский
27	Киришский
28	Кировский
29	Лодейнопольский
30	Ломоносовский
31	Лужский
32	Подпорожский
33	Приозерский
34	Сланцевский
35	Тихвинский
36	Тосненский
\.


--
-- Name: district_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ylg
--

SELECT pg_catalog.setval('district_id_seq', 36, true);


--
-- Data for Name: flat; Type: TABLE DATA; Schema: public; Owner: ylg
--

COPY flat (id, crps_id, rooms, area_sum, area_living, area_kitchen, price, balcon, sanuzel) FROM stdin;
1	1	1	27.95	19.3	0	2383213		t
2	1	1	27.95	19.3	0	2383213		t
3	1	1	27.4	19.3	0	2336316		t
4	1	1	27.4	19.3	0	2336316		t
5	1	1	28.85	20.5	0	2459953		t
6	1	1	28.85	20.5	0	2459953		t
7	1	1	27.4	19.3	0	2336316		t
8	1	1	27.95	19.3	0	2383213		t
9	1	1	28.85	20.5	0	2459953		t
10	1	2	68.15	16,5+15,5	18	4148904		t
11	1	2	69.25	16,5+15,5	18	4215871		t
12	1	2	69.25	16,5+15,5	18	4215871		t
13	1	2	69.25	16,5+15,5	18	4215871		t
14	1	3	75.55	18,2+15,2+11,8	12	4516908		t
15	1	3	73.65	16,5+15,2+11,8	12	4403313		t
16	1	3	75.55	18,2+15,2+11,8	12	4516908		t
17	1	3	75.55	18,2+15,2+11,8	12	4516908		t
18	2	1	27.95	19.3	0	2383213		t
19	2	1	27.95	19.3	0	2383213		t
20	2	1	27.4	19.3	0	2336316		t
21	2	1	27.4	19.3	0	2336316		t
22	2	1	28.85	20.5	0	2459953		t
23	2	1	28.85	20.5	0	2459953		t
24	2	1	27.4	19.3	0	2336316		t
25	2	1	27.95	19.3	0	2383213		t
26	2	1	28.85	20.5	0	2459953		t
27	2	2	68.15	16,5+15,5	18	4148904		t
28	2	2	69.25	16,5+15,5	18	4215871		t
29	2	2	69.25	16,5+15,5	18	4215871		t
30	2	2	69.25	16,5+15,5	18	4215871		t
31	2	3	75.55	18,2+15,2+11,8	12	4516908		t
32	2	3	73.65	16,5+15,2+11,8	12	4403313		t
33	2	3	75.55	18,2+15,2+11,8	12	4516908		t
34	2	3	75.55	18,2+15,2+11,8	12	4516908		t
35	3	1	27.95	19.3	0	2383213		t
36	3	1	27.95	19.3	0	2383213		t
37	3	1	27.4	19.3	0	2336316		t
38	3	1	27.4	19.3	0	2336316		t
39	3	1	28.85	20.5	0	2459953		t
40	3	1	28.85	20.5	0	2459953		t
41	3	1	27.4	19.3	0	2336316		t
42	3	1	27.95	19.3	0	2383213		t
43	3	1	28.85	20.5	0	2459953		t
44	3	2	68.15	16,5+15,5	18	4148904		t
45	3	2	69.25	16,5+15,5	18	4215871		t
46	3	2	69.25	16,5+15,5	18	4215871		t
47	3	2	69.25	16,5+15,5	18	4215871		t
48	3	3	75.55	18,2+15,2+11,8	12	4516908		t
49	3	3	73.65	16,5+15,2+11,8	12	4403313		t
50	3	3	75.55	18,2+15,2+11,8	12	4516908		t
51	3	3	75.55	18,2+15,2+11,8	12	4516908		t
52	4	1	27.95	19.3	0	2383213		t
53	4	1	27.95	19.3	0	2383213		t
54	4	1	27.4	19.3	0	2336316		t
55	4	1	27.4	19.3	0	2336316		t
56	4	1	28.85	20.5	0	2459953		t
57	4	1	28.85	20.5	0	2459953		t
58	4	1	27.4	19.3	0	2336316		t
59	4	1	27.95	19.3	0	2383213		t
60	4	1	28.85	20.5	0	2459953		t
61	4	2	68.15	16,5+15,5	18	4148904		t
62	4	2	69.25	16,5+15,5	18	4215871		t
63	4	2	69.25	16,5+15,5	18	4215871		t
64	4	2	69.25	16,5+15,5	18	4215871		t
65	4	3	75.55	18,2+15,2+11,8	12	4516908		t
66	4	3	73.65	16,5+15,2+11,8	12	4403313		t
67	4	3	75.55	18,2+15,2+11,8	12	4516908		t
68	4	3	75.55	18,2+15,2+11,8	12	4516908		t
69	5	1	27.95	19.3	0	2383213		t
70	5	1	27.95	19.3	0	2383213		t
71	5	1	27.4	19.3	0	2336316		t
72	5	1	27.4	19.3	0	2336316		t
73	5	1	28.85	20.5	0	2459953		t
74	5	1	28.85	20.5	0	2459953		t
75	5	1	27.4	19.3	0	2336316		t
76	5	1	27.95	19.3	0	2383213		t
77	5	1	28.85	20.5	0	2459953		t
78	5	2	68.15	16,5+15,5	18	4148904		t
79	5	2	69.25	16,5+15,5	18	4215871		t
80	5	2	69.25	16,5+15,5	18	4215871		t
81	5	2	69.25	16,5+15,5	18	4215871		t
82	5	3	75.55	18,2+15,2+11,8	12	4516908		t
83	5	3	73.65	16,5+15,2+11,8	12	4403313		t
84	5	3	75.55	18,2+15,2+11,8	12	4516908		t
85	5	3	75.55	18,2+15,2+11,8	12	4516908		t
86	6	1	27.95	19.3	0	2383213		t
87	6	1	27.95	19.3	0	2383213		t
88	6	1	27.4	19.3	0	2336316		t
89	6	1	27.4	19.3	0	2336316		t
90	6	1	28.85	20.5	0	2459953		t
91	6	1	28.85	20.5	0	2459953		t
92	6	1	27.4	19.3	0	2336316		t
93	6	1	27.95	19.3	0	2383213		t
94	6	1	28.85	20.5	0	2459953		t
95	6	2	68.15	16,5+15,5	18	4148904		t
96	6	2	69.25	16,5+15,5	18	4215871		t
97	6	2	69.25	16,5+15,5	18	4215871		t
98	6	2	69.25	16,5+15,5	18	4215871		t
99	6	3	75.55	18,2+15,2+11,8	12	4516908		t
100	6	3	73.65	16,5+15,2+11,8	12	4403313		t
101	6	3	75.55	18,2+15,2+11,8	12	4516908		t
102	6	3	75.55	18,2+15,2+11,8	12	4516908		t
103	7	1	27.95	19.3	0	2383213		t
104	7	1	27.95	19.3	0	2383213		t
105	7	1	27.4	19.3	0	2336316		t
106	7	1	27.4	19.3	0	2336316		t
107	7	1	28.85	20.5	0	2459953		t
108	7	1	28.85	20.5	0	2459953		t
109	7	1	27.4	19.3	0	2336316		t
110	7	1	27.95	19.3	0	2383213		t
111	7	1	28.85	20.5	0	2459953		t
112	7	2	68.15	16,5+15,5	18	4148904		t
113	7	2	69.25	16,5+15,5	18	4215871		t
114	7	2	69.25	16,5+15,5	18	4215871		t
115	7	2	69.25	16,5+15,5	18	4215871		t
116	7	3	75.55	18,2+15,2+11,8	12	4516908		t
117	7	3	73.65	16,5+15,2+11,8	12	4403313		t
118	7	3	75.55	18,2+15,2+11,8	12	4516908		t
119	7	3	75.55	18,2+15,2+11,8	12	4516908		t
120	8	1	27.95	19.3	0	2383213		t
121	8	1	27.95	19.3	0	2383213		t
122	8	1	27.4	19.3	0	2336316		t
123	8	1	27.4	19.3	0	2336316		t
124	8	1	28.85	20.5	0	2459953		t
125	8	1	28.85	20.5	0	2459953		t
126	8	1	27.4	19.3	0	2336316		t
127	8	1	27.95	19.3	0	2383213		t
128	8	1	28.85	20.5	0	2459953		t
129	8	2	68.15	16,5+15,5	18	4148904		t
130	8	2	69.25	16,5+15,5	18	4215871		t
131	8	2	69.25	16,5+15,5	18	4215871		t
132	8	2	69.25	16,5+15,5	18	4215871		t
133	8	3	75.55	18,2+15,2+11,8	12	4516908		t
134	8	3	73.65	16,5+15,2+11,8	12	4403313		t
135	8	3	75.55	18,2+15,2+11,8	12	4516908		t
136	8	3	75.55	18,2+15,2+11,8	12	4516908		t
137	9	1	27.95	19.3	0	2383213		t
138	9	1	27.95	19.3	0	2383213		t
139	9	1	27.4	19.3	0	2336316		t
140	9	1	27.4	19.3	0	2336316		t
141	9	1	28.85	20.5	0	2459953		t
142	9	1	28.85	20.5	0	2459953		t
143	9	1	27.4	19.3	0	2336316		t
144	9	1	27.95	19.3	0	2383213		t
145	9	1	28.85	20.5	0	2459953		t
146	9	2	68.15	16,5+15,5	18	4148904		t
147	9	2	69.25	16,5+15,5	18	4215871		t
148	9	2	69.25	16,5+15,5	18	4215871		t
149	9	2	69.25	16,5+15,5	18	4215871		t
150	9	3	75.55	18,2+15,2+11,8	12	4516908		t
151	9	3	73.65	16,5+15,2+11,8	12	4403313		t
152	9	3	75.55	18,2+15,2+11,8	12	4516908		t
153	9	3	75.55	18,2+15,2+11,8	12	4516908		t
154	10	1	27.95	19.3	0	2383213		t
155	10	1	27.95	19.3	0	2383213		t
156	10	1	27.4	19.3	0	2336316		t
157	10	1	27.4	19.3	0	2336316		t
158	10	1	28.85	20.5	0	2459953		t
159	10	1	28.85	20.5	0	2459953		t
160	10	1	27.4	19.3	0	2336316		t
161	10	1	27.95	19.3	0	2383213		t
162	10	1	28.85	20.5	0	2459953		t
163	10	2	68.15	16,5+15,5	18	4148904		t
164	10	2	69.25	16,5+15,5	18	4215871		t
165	10	2	69.25	16,5+15,5	18	4215871		t
166	10	2	69.25	16,5+15,5	18	4215871		t
167	10	3	75.55	18,2+15,2+11,8	12	4516908		t
168	10	3	73.65	16,5+15,2+11,8	12	4403313		t
169	10	3	75.55	18,2+15,2+11,8	12	4516908		t
170	10	3	75.55	18,2+15,2+11,8	12	4516908		t
171	11	1	27.95	19.3	0	2383213		t
172	11	1	27.95	19.3	0	2383213		t
173	11	1	27.4	19.3	0	2336316		t
174	11	1	27.4	19.3	0	2336316		t
175	11	1	28.85	20.5	0	2459953		t
176	11	1	28.85	20.5	0	2459953		t
177	11	1	27.4	19.3	0	2336316		t
178	11	1	27.95	19.3	0	2383213		t
179	11	1	28.85	20.5	0	2459953		t
180	11	2	68.15	16,5+15,5	18	4148904		t
181	11	2	69.25	16,5+15,5	18	4215871		t
182	11	2	69.25	16,5+15,5	18	4215871		t
183	11	2	69.25	16,5+15,5	18	4215871		t
184	11	3	75.55	18,2+15,2+11,8	12	4516908		t
185	11	3	73.65	16,5+15,2+11,8	12	4403313		t
186	11	3	75.55	18,2+15,2+11,8	12	4516908		t
187	11	3	75.55	18,2+15,2+11,8	12	4516908		t
188	12	1	27.95	19.3	0	2383213		t
189	12	1	27.95	19.3	0	2383213		t
190	12	1	27.4	19.3	0	2336316		t
191	12	1	27.4	19.3	0	2336316		t
192	12	1	28.85	20.5	0	2459953		t
193	12	1	28.85	20.5	0	2459953		t
194	12	1	27.4	19.3	0	2336316		t
195	12	1	27.95	19.3	0	2383213		t
196	12	1	28.85	20.5	0	2459953		t
197	12	2	68.15	16,5+15,5	18	4148904		t
198	12	2	69.25	16,5+15,5	18	4215871		t
199	12	2	69.25	16,5+15,5	18	4215871		t
200	12	2	69.25	16,5+15,5	18	4215871		t
201	12	3	75.55	18,2+15,2+11,8	12	4516908		t
202	12	3	73.65	16,5+15,2+11,8	12	4403313		t
203	12	3	75.55	18,2+15,2+11,8	12	4516908		t
204	12	3	75.55	18,2+15,2+11,8	12	4516908		t
205	13	1	27.95	19.3	0	2383213		t
206	13	1	27.95	19.3	0	2383213		t
207	13	1	27.4	19.3	0	2336316		t
208	13	1	27.4	19.3	0	2336316		t
209	13	1	28.85	20.5	0	2459953		t
210	13	1	28.85	20.5	0	2459953		t
211	13	1	27.4	19.3	0	2336316		t
212	13	1	27.95	19.3	0	2383213		t
213	13	1	28.85	20.5	0	2459953		t
214	13	2	68.15	16,5+15,5	18	4148904		t
215	13	2	69.25	16,5+15,5	18	4215871		t
216	13	2	69.25	16,5+15,5	18	4215871		t
217	13	2	69.25	16,5+15,5	18	4215871		t
218	13	3	75.55	18,2+15,2+11,8	12	4516908		t
219	13	3	73.65	16,5+15,2+11,8	12	4403313		t
220	13	3	75.55	18,2+15,2+11,8	12	4516908		t
221	13	3	75.55	18,2+15,2+11,8	12	4516908		t
222	14	1	27.95	19.3	0	2383213		t
223	14	1	27.95	19.3	0	2383213		t
224	14	1	27.4	19.3	0	2336316		t
225	14	1	27.4	19.3	0	2336316		t
226	14	1	28.85	20.5	0	2459953		t
227	14	1	28.85	20.5	0	2459953		t
228	14	1	27.4	19.3	0	2336316		t
229	14	1	27.95	19.3	0	2383213		t
230	14	1	28.85	20.5	0	2459953		t
231	14	2	68.15	16,5+15,5	18	4148904		t
232	14	2	69.25	16,5+15,5	18	4215871		t
233	14	2	69.25	16,5+15,5	18	4215871		t
234	14	2	69.25	16,5+15,5	18	4215871		t
235	14	3	75.55	18,2+15,2+11,8	12	4516908		t
236	14	3	73.65	16,5+15,2+11,8	12	4403313		t
237	14	3	75.55	18,2+15,2+11,8	12	4516908		t
238	14	3	75.55	18,2+15,2+11,8	12	4516908		t
239	15	1	27.95	19.3	0	2383213		t
240	15	1	27.95	19.3	0	2383213		t
241	15	1	27.4	19.3	0	2336316		t
242	15	1	27.4	19.3	0	2336316		t
243	15	1	28.85	20.5	0	2459953		t
244	15	1	28.85	20.5	0	2459953		t
245	15	1	27.4	19.3	0	2336316		t
246	15	1	27.95	19.3	0	2383213		t
247	15	1	28.85	20.5	0	2459953		t
248	15	2	68.15	16,5+15,5	18	4148904		t
249	15	2	69.25	16,5+15,5	18	4215871		t
250	15	2	69.25	16,5+15,5	18	4215871		t
251	15	2	69.25	16,5+15,5	18	4215871		t
252	15	3	75.55	18,2+15,2+11,8	12	4516908		t
253	15	3	73.65	16,5+15,2+11,8	12	4403313		t
254	15	3	75.55	18,2+15,2+11,8	12	4516908		t
255	15	3	75.55	18,2+15,2+11,8	12	4516908		t
256	16	1	27.95	19.3	0	2383213		t
257	16	1	27.95	19.3	0	2383213		t
258	16	1	27.4	19.3	0	2336316		t
259	16	1	27.4	19.3	0	2336316		t
260	16	1	28.85	20.5	0	2459953		t
261	16	1	28.85	20.5	0	2459953		t
262	16	1	27.4	19.3	0	2336316		t
263	16	1	27.95	19.3	0	2383213		t
264	16	1	28.85	20.5	0	2459953		t
265	16	2	68.15	16,5+15,5	18	4148904		t
266	16	2	69.25	16,5+15,5	18	4215871		t
267	16	2	69.25	16,5+15,5	18	4215871		t
268	16	2	69.25	16,5+15,5	18	4215871		t
269	16	3	75.55	18,2+15,2+11,8	12	4516908		t
270	16	3	73.65	16,5+15,2+11,8	12	4403313		t
271	16	3	75.55	18,2+15,2+11,8	12	4516908		t
272	16	3	75.55	18,2+15,2+11,8	12	4516908		t
273	17	1	27.95	19.3	0	2383213		t
274	17	1	27.95	19.3	0	2383213		t
275	17	1	27.4	19.3	0	2336316		t
276	17	1	27.4	19.3	0	2336316		t
277	17	1	28.85	20.5	0	2459953		t
278	17	1	28.85	20.5	0	2459953		t
279	17	1	27.4	19.3	0	2336316		t
280	17	1	27.95	19.3	0	2383213		t
281	17	1	28.85	20.5	0	2459953		t
282	17	2	68.15	16,5+15,5	18	4148904		t
283	17	2	69.25	16,5+15,5	18	4215871		t
284	17	2	69.25	16,5+15,5	18	4215871		t
285	17	2	69.25	16,5+15,5	18	4215871		t
286	17	3	75.55	18,2+15,2+11,8	12	4516908		t
287	17	3	73.65	16,5+15,2+11,8	12	4403313		t
288	17	3	75.55	18,2+15,2+11,8	12	4516908		t
289	17	3	75.55	18,2+15,2+11,8	12	4516908		t
290	18	1	27.95	19.3	0	2383213		t
291	18	1	27.95	19.3	0	2383213		t
292	18	1	27.4	19.3	0	2336316		t
293	18	1	27.4	19.3	0	2336316		t
294	18	1	28.85	20.5	0	2459953		t
295	18	1	28.85	20.5	0	2459953		t
296	18	1	27.4	19.3	0	2336316		t
297	18	1	27.95	19.3	0	2383213		t
298	18	1	28.85	20.5	0	2459953		t
299	18	2	68.15	16,5+15,5	18	4148904		t
300	18	2	69.25	16,5+15,5	18	4215871		t
301	18	2	69.25	16,5+15,5	18	4215871		t
302	18	2	69.25	16,5+15,5	18	4215871		t
303	18	3	75.55	18,2+15,2+11,8	12	4516908		t
304	18	3	73.65	16,5+15,2+11,8	12	4403313		t
305	18	3	75.55	18,2+15,2+11,8	12	4516908		t
306	18	3	75.55	18,2+15,2+11,8	12	4516908		t
307	19	1	27.95	19.3	0	2383213		t
308	19	1	27.95	19.3	0	2383213		t
309	19	1	27.4	19.3	0	2336316		t
310	19	1	27.4	19.3	0	2336316		t
311	19	1	28.85	20.5	0	2459953		t
312	19	1	28.85	20.5	0	2459953		t
313	19	1	27.4	19.3	0	2336316		t
314	19	1	27.95	19.3	0	2383213		t
315	19	1	28.85	20.5	0	2459953		t
316	19	2	68.15	16,5+15,5	18	4148904		t
317	19	2	69.25	16,5+15,5	18	4215871		t
318	19	2	69.25	16,5+15,5	18	4215871		t
319	19	2	69.25	16,5+15,5	18	4215871		t
320	19	3	75.55	18,2+15,2+11,8	12	4516908		t
321	19	3	73.65	16,5+15,2+11,8	12	4403313		t
322	19	3	75.55	18,2+15,2+11,8	12	4516908		t
323	19	3	75.55	18,2+15,2+11,8	12	4516908		t
324	20	1	27.95	19.3	0	2383213		t
325	20	1	27.95	19.3	0	2383213		t
326	20	1	27.4	19.3	0	2336316		t
327	20	1	27.4	19.3	0	2336316		t
328	20	1	28.85	20.5	0	2459953		t
329	20	1	28.85	20.5	0	2459953		t
330	20	1	27.4	19.3	0	2336316		t
331	20	1	27.95	19.3	0	2383213		t
332	20	1	28.85	20.5	0	2459953		t
333	20	2	68.15	16,5+15,5	18	4148904		t
334	20	2	69.25	16,5+15,5	18	4215871		t
335	20	2	69.25	16,5+15,5	18	4215871		t
336	20	2	69.25	16,5+15,5	18	4215871		t
337	20	3	75.55	18,2+15,2+11,8	12	4516908		t
338	20	3	73.65	16,5+15,2+11,8	12	4403313		t
339	20	3	75.55	18,2+15,2+11,8	12	4516908		t
340	20	3	75.55	18,2+15,2+11,8	12	4516908		t
341	21	1	27.95	19.3	0	2383213		t
342	21	1	27.95	19.3	0	2383213		t
343	21	1	27.4	19.3	0	2336316		t
344	21	1	27.4	19.3	0	2336316		t
345	21	1	28.85	20.5	0	2459953		t
346	21	1	28.85	20.5	0	2459953		t
347	21	1	27.4	19.3	0	2336316		t
348	21	1	27.95	19.3	0	2383213		t
349	21	1	28.85	20.5	0	2459953		t
350	21	2	68.15	16,5+15,5	18	4148904		t
351	21	2	69.25	16,5+15,5	18	4215871		t
352	21	2	69.25	16,5+15,5	18	4215871		t
353	21	2	69.25	16,5+15,5	18	4215871		t
354	21	3	75.55	18,2+15,2+11,8	12	4516908		t
355	21	3	73.65	16,5+15,2+11,8	12	4403313		t
356	21	3	75.55	18,2+15,2+11,8	12	4516908		t
357	21	3	75.55	18,2+15,2+11,8	12	4516908		t
358	22	1	27.95	19.3	0	2383213		t
359	22	1	27.95	19.3	0	2383213		t
360	22	1	27.4	19.3	0	2336316		t
361	22	1	27.4	19.3	0	2336316		t
362	22	1	28.85	20.5	0	2459953		t
363	22	1	28.85	20.5	0	2459953		t
364	22	1	27.4	19.3	0	2336316		t
365	22	1	27.95	19.3	0	2383213		t
366	22	1	28.85	20.5	0	2459953		t
367	22	2	68.15	16,5+15,5	18	4148904		t
368	22	2	69.25	16,5+15,5	18	4215871		t
369	22	2	69.25	16,5+15,5	18	4215871		t
370	22	2	69.25	16,5+15,5	18	4215871		t
371	22	3	75.55	18,2+15,2+11,8	12	4516908		t
372	22	3	73.65	16,5+15,2+11,8	12	4403313		t
373	22	3	75.55	18,2+15,2+11,8	12	4516908		t
374	22	3	75.55	18,2+15,2+11,8	12	4516908		t
375	23	1	27.95	19.3	0	2383213		t
376	23	1	27.95	19.3	0	2383213		t
377	23	1	27.4	19.3	0	2336316		t
378	23	1	27.4	19.3	0	2336316		t
379	23	1	28.85	20.5	0	2459953		t
380	23	1	28.85	20.5	0	2459953		t
381	23	1	27.4	19.3	0	2336316		t
382	23	1	27.95	19.3	0	2383213		t
383	23	1	28.85	20.5	0	2459953		t
384	23	2	68.15	16,5+15,5	18	4148904		t
385	23	2	69.25	16,5+15,5	18	4215871		t
386	23	2	69.25	16,5+15,5	18	4215871		t
387	23	2	69.25	16,5+15,5	18	4215871		t
388	23	3	75.55	18,2+15,2+11,8	12	4516908		t
389	23	3	73.65	16,5+15,2+11,8	12	4403313		t
390	23	3	75.55	18,2+15,2+11,8	12	4516908		t
391	23	3	75.55	18,2+15,2+11,8	12	4516908		t
392	24	1	27.95	19.3	0	2383213		t
393	24	1	27.95	19.3	0	2383213		t
394	24	1	27.4	19.3	0	2336316		t
395	24	1	27.4	19.3	0	2336316		t
396	24	1	28.85	20.5	0	2459953		t
397	24	1	28.85	20.5	0	2459953		t
398	24	1	27.4	19.3	0	2336316		t
399	24	1	27.95	19.3	0	2383213		t
400	24	1	28.85	20.5	0	2459953		t
401	24	2	68.15	16,5+15,5	18	4148904		t
402	24	2	69.25	16,5+15,5	18	4215871		t
403	24	2	69.25	16,5+15,5	18	4215871		t
404	24	2	69.25	16,5+15,5	18	4215871		t
405	24	3	75.55	18,2+15,2+11,8	12	4516908		t
406	24	3	73.65	16,5+15,2+11,8	12	4403313		t
407	24	3	75.55	18,2+15,2+11,8	12	4516908		t
408	24	3	75.55	18,2+15,2+11,8	12	4516908		t
409	25	1	27.95	19.3	0	2383213		t
410	25	1	27.95	19.3	0	2383213		t
411	25	1	27.4	19.3	0	2336316		t
412	25	1	27.4	19.3	0	2336316		t
413	25	1	28.85	20.5	0	2459953		t
414	25	1	28.85	20.5	0	2459953		t
415	25	1	27.4	19.3	0	2336316		t
416	25	1	27.95	19.3	0	2383213		t
417	25	1	28.85	20.5	0	2459953		t
418	25	2	68.15	16,5+15,5	18	4148904		t
419	25	2	69.25	16,5+15,5	18	4215871		t
420	25	2	69.25	16,5+15,5	18	4215871		t
421	25	2	69.25	16,5+15,5	18	4215871		t
422	25	3	75.55	18,2+15,2+11,8	12	4516908		t
423	25	3	73.65	16,5+15,2+11,8	12	4403313		t
424	25	3	75.55	18,2+15,2+11,8	12	4516908		t
425	25	3	75.55	18,2+15,2+11,8	12	4516908		t
426	26	1	27.95	19.3	0	2383213		t
427	26	1	27.95	19.3	0	2383213		t
428	26	1	27.4	19.3	0	2336316		t
429	26	1	27.4	19.3	0	2336316		t
430	26	1	28.85	20.5	0	2459953		t
431	26	1	28.85	20.5	0	2459953		t
432	26	1	27.4	19.3	0	2336316		t
433	26	1	27.95	19.3	0	2383213		t
434	26	1	28.85	20.5	0	2459953		t
435	26	2	68.15	16,5+15,5	18	4148904		t
436	26	2	69.25	16,5+15,5	18	4215871		t
437	26	2	69.25	16,5+15,5	18	4215871		t
438	26	2	69.25	16,5+15,5	18	4215871		t
439	26	3	75.55	18,2+15,2+11,8	12	4516908		t
440	26	3	73.65	16,5+15,2+11,8	12	4403313		t
441	26	3	75.55	18,2+15,2+11,8	12	4516908		t
442	26	3	75.55	18,2+15,2+11,8	12	4516908		t
443	27	1	27.95	19.3	0	2383213		t
444	27	1	27.95	19.3	0	2383213		t
445	27	1	27.4	19.3	0	2336316		t
446	27	1	27.4	19.3	0	2336316		t
447	27	1	28.85	20.5	0	2459953		t
448	27	1	28.85	20.5	0	2459953		t
449	27	1	27.4	19.3	0	2336316		t
450	27	1	27.95	19.3	0	2383213		t
451	27	1	28.85	20.5	0	2459953		t
452	27	2	68.15	16,5+15,5	18	4148904		t
453	27	2	69.25	16,5+15,5	18	4215871		t
454	27	2	69.25	16,5+15,5	18	4215871		t
455	27	2	69.25	16,5+15,5	18	4215871		t
456	27	3	75.55	18,2+15,2+11,8	12	4516908		t
457	27	3	73.65	16,5+15,2+11,8	12	4403313		t
458	27	3	75.55	18,2+15,2+11,8	12	4516908		t
459	27	3	75.55	18,2+15,2+11,8	12	4516908		t
460	28	1	27.95	19.3	0	2383213		t
461	28	1	27.95	19.3	0	2383213		t
462	28	1	27.4	19.3	0	2336316		t
463	28	1	27.4	19.3	0	2336316		t
464	28	1	28.85	20.5	0	2459953		t
465	28	1	28.85	20.5	0	2459953		t
466	28	1	27.4	19.3	0	2336316		t
467	28	1	27.95	19.3	0	2383213		t
468	28	1	28.85	20.5	0	2459953		t
469	28	2	68.15	16,5+15,5	18	4148904		t
470	28	2	69.25	16,5+15,5	18	4215871		t
471	28	2	69.25	16,5+15,5	18	4215871		t
472	28	2	69.25	16,5+15,5	18	4215871		t
473	28	3	75.55	18,2+15,2+11,8	12	4516908		t
474	28	3	73.65	16,5+15,2+11,8	12	4403313		t
475	28	3	75.55	18,2+15,2+11,8	12	4516908		t
476	28	3	75.55	18,2+15,2+11,8	12	4516908		t
477	29	1	27.95	19.3	0	2383213		t
478	29	1	27.95	19.3	0	2383213		t
479	29	1	27.4	19.3	0	2336316		t
480	29	1	27.4	19.3	0	2336316		t
481	29	1	28.85	20.5	0	2459953		t
482	29	1	28.85	20.5	0	2459953		t
483	29	1	27.4	19.3	0	2336316		t
484	29	1	27.95	19.3	0	2383213		t
485	29	1	28.85	20.5	0	2459953		t
486	29	2	68.15	16,5+15,5	18	4148904		t
487	29	2	69.25	16,5+15,5	18	4215871		t
488	29	2	69.25	16,5+15,5	18	4215871		t
489	29	2	69.25	16,5+15,5	18	4215871		t
490	29	3	75.55	18,2+15,2+11,8	12	4516908		t
491	29	3	73.65	16,5+15,2+11,8	12	4403313		t
492	29	3	75.55	18,2+15,2+11,8	12	4516908		t
493	29	3	75.55	18,2+15,2+11,8	12	4516908		t
494	30	1	27.95	19.3	0	2383213		t
495	30	1	27.95	19.3	0	2383213		t
496	30	1	27.4	19.3	0	2336316		t
497	30	1	27.4	19.3	0	2336316		t
498	30	1	28.85	20.5	0	2459953		t
499	30	1	28.85	20.5	0	2459953		t
500	30	1	27.4	19.3	0	2336316		t
501	30	1	27.95	19.3	0	2383213		t
502	30	1	28.85	20.5	0	2459953		t
503	30	2	68.15	16,5+15,5	18	4148904		t
504	30	2	69.25	16,5+15,5	18	4215871		t
505	30	2	69.25	16,5+15,5	18	4215871		t
506	30	2	69.25	16,5+15,5	18	4215871		t
507	30	3	75.55	18,2+15,2+11,8	12	4516908		t
508	30	3	73.65	16,5+15,2+11,8	12	4403313		t
509	30	3	75.55	18,2+15,2+11,8	12	4516908		t
510	30	3	75.55	18,2+15,2+11,8	12	4516908		t
\.


--
-- Name: flat_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ylg
--

SELECT pg_catalog.setval('flat_id_seq', 510, true);


--
-- Data for Name: group; Type: TABLE DATA; Schema: public; Owner: ylg
--

COPY "group" (id, name) FROM stdin;
1	oldman
2	newboy
3	veteran
4	traveler
5	troll
\.


--
-- Name: group_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ylg
--

SELECT pg_catalog.setval('group_id_seq', 5, true);


--
-- Data for Name: metro; Type: TABLE DATA; Schema: public; Owner: ylg
--

COPY metro (id, name) FROM stdin;
1	Автово
2	Адмиралтейская
3	Академическая
4	Балтийская
5	Бухарестская
6	Василеостровская
7	Владимирская
8	Волковская
9	Выборгская
10	Горьковская
11	Гостиный двор
12	Гражданский проспект
13	Девяткино
14	Достоевская
15	Елизаровская
16	Звёздная
17	Звенигородская
18	Кировский завод
19	Комендантский проспект
20	Крестовский остров
21	Купчино
22	Ладожская
23	Ленинский проспект
24	Лесная
25	Лиговский проспект
26	Ломоносовская
27	Маяковская
28	Международная
29	Московская
30	Московские ворота
31	Нарвская
32	Невский проспект
33	Новочеркасская
34	Обводный канал
35	Обухово
36	Озерки
37	Парк Победы
38	Парнас
39	Петроградская
40	Пионерская
41	Площадь Александра Невского
42	Площадь Александра Невского
43	Площадь Восстания
44	Площадь Ленина
45	Площадь Мужества
46	Политехническая
47	Приморская
48	Пролетарская
49	Проспект Большевиков
50	Проспект Ветеранов
51	Проспект Просвещения
52	Пушкинская
53	Рыбацкое
54	Садовая
55	Сенная площадь
56	Спасская
57	Спортивная
58	Старая Деревня
59	Технологический институт
60	Технологический институт
61	Удельная
62	Улица Дыбенко
63	Фрунзенская
64	Чёрная речка
65	Чернышевская
66	Чкаловская
67	Электросила
\.


--
-- Name: metro_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ylg
--

SELECT pg_catalog.setval('metro_id_seq', 67, true);


--
-- Data for Name: moto; Type: TABLE DATA; Schema: public; Owner: ylg
--

COPY moto (id, vendor_id, model_id, color_id, year, price, plate, vin, frame_num, engine_num, pts_data, "desc", tuning, state) FROM stdin;
\.


--
-- Name: moto_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ylg
--

SELECT pg_catalog.setval('moto_id_seq', 1, false);


--
-- Data for Name: msg; Type: TABLE DATA; Schema: public; Owner: ylg
--

COPY msg (id, snd_id, rcv_id, msg, ts_create, ts_delivery, state) FROM stdin;
1	2	3	Привет, Боб, это Алиса!	3626223404	0	:DELIVERED
\.


--
-- Name: msg_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ylg
--

SELECT pg_catalog.setval('msg_id_seq', 1, true);


--
-- Data for Name: plex; Type: TABLE DATA; Schema: public; Owner: ylg
--

COPY plex (id, cmpx_id, name, distance, deadline_id, subsidy, finishing, ipoteka, installment) FROM stdin;
1	1	1 очередь	3.5 км (40 мин пешком)	8	\N	евроотделка	\N	\N
2	2	8-я очередь	1.7 км (21 мин пешком)	9	\N	евроотделка	\N	\N
3	2	7-я очередь	1.7 км (21 мин пешком)	7	\N	евроотделка	\N	\N
4	2	6-я очередь	1.7 км (21 мин пешком)	4	\N	евроотделка	\N	\N
5	2	5-я очередь	1.7 км (21 мин пешком)	3	\N	евроотделка	\N	\N
6	3	3 очередь	1.7 км (21 мин пешком)	2	\N	предчистовая	\N	\N
7	3	2 очередь	1.7 км (21 мин пешком)	2	\N	предчистовая	\N	\N
8	3	1 очередь	1.7 км (21 мин пешком)	2	\N	предчистовая	\N	\N
9	4	2 очередь	1.7 км (21 мин пешком)	2	\N	предчистовая	\N	\N
10	4	1 очередь	1.7 км (21 мин пешком)	2	\N	предчистовая	\N	\N
\.


--
-- Name: plex_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ylg
--

SELECT pg_catalog.setval('plex_id_seq', 10, true);


--
-- Data for Name: que; Type: TABLE DATA; Schema: public; Owner: ylg
--

COPY que (id, name) FROM stdin;
1	Q-1
2	Q-2
3	Q-3
\.


--
-- Name: que_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ylg
--

SELECT pg_catalog.setval('que_id_seq', 3, true);


--
-- Data for Name: quelt; Type: TABLE DATA; Schema: public; Owner: ylg
--

COPY quelt (id, que_id, text) FROM stdin;
2	1	7
\.


--
-- Name: quelt_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ylg
--

SELECT pg_catalog.setval('quelt_id_seq', 2, true);


--
-- Data for Name: role; Type: TABLE DATA; Schema: public; Owner: ylg
--

COPY role (id, name) FROM stdin;
1	admin
2	manager
3	moderator
4	editor
5	robot
\.


--
-- Name: role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ylg
--

SELECT pg_catalog.setval('role_id_seq', 5, true);


--
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: ylg
--

COPY "user" (id, name, password, email, ts_create, ts_last, role_id, state) FROM stdin;
1	test-name	test-password	test-email	3626223403	3626223403	\N	:UNLOGGED
5	dave	6zt5GmvE	dave@mail.com	3626223404	3626223404	\N	:UNLOGGED
4	carol	zDgjGus7	carol@mail.com	3626223404	3626223404	\N	:UNLOGGED
3	bob	pDa84LAh	bob@mail.com	3626223404	3626223404	\N	:UNLOGGED
2	alice	aXJAVtBT	alice@mail.com	3626223404	3626223404	\N	:UNLOGGED
\.


--
-- Data for Name: user2group; Type: TABLE DATA; Schema: public; Owner: ylg
--

COPY user2group (id, user_id, group_id) FROM stdin;
\.


--
-- Name: user2group_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ylg
--

SELECT pg_catalog.setval('user2group_id_seq', 1, false);


--
-- Name: user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ylg
--

SELECT pg_catalog.setval('user_id_seq', 5, true);


--
-- Data for Name: vendor; Type: TABLE DATA; Schema: public; Owner: ylg
--

COPY vendor (id, name) FROM stdin;
1	Honda
2	Kawasaki
3	Suzuki
4	Yamaha
5	Черный
6	Derbi
7	KTM
8	Husqvarna
9	Ява
10	Harley-Davidson
11	Benelli
12	Днепр
13	Урал
14	Красный
15	Белый
16	Синий
17	Зеленый
18	BMW
19	Минск
20	Triumph
21	Фиолетовый
22	Серый
23	Коричневый
24	Серебряный
25	Желтый
26	Иж
27	Cagiva
28	Aprilia
29	Ducati
30	Baltmotors
31	Восход
32	Тула
33	Enfield
34	Sym
35	Gilera
36	BRP
37	Wels
38	Пурпурный
39	Рига
40	Irbis
41	Голубой
42	Карпаты
43	Yumbo
44	Buell
45	Husaberg
46	Оранжевый
47	Lifan
48	1986
49	Stels
50	2008
51	Ghezzi-Brian
52	Sagitta
53	Johnny
54	Hyosung
55	Daelim
56	Верховина
57	Kymco
58	X-Moto
59	CZ
60	MV
61	2009
62	Victory
63	1994
64	Sachs
65	Золотой
66	ABM
67	Патрон
68	Бежевый
69	2012
70	Gas
71	CFMoto
72	Titan
73	ЗиД
74	Дельта
75	1983
76	2006
77	Yamasaki
78	2011
79	Bajaj
80	2007
81	2001
82	Megelli
83	Regal
84	Polaris
85	Розовый
86	Boss
87	2010
88	MZ
89	TM
90	1997
91	HM
92	0
93	Moto
94	Bimota
95	Keeway
96	Factory
97	2000
98	1970
99	Italjet
100	Qianjiang
101	Indian
102	ATK
103	Qlink
104	2005
105	Skyteam
\.


--
-- Name: vendor_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ylg
--

SELECT pg_catalog.setval('vendor_id_seq', 105, true);


--
-- Name: avatar_pkey; Type: CONSTRAINT; Schema: public; Owner: ylg; Tablespace: 
--

ALTER TABLE ONLY avatar
    ADD CONSTRAINT avatar_pkey PRIMARY KEY (id);


--
-- Name: bratan_pkey; Type: CONSTRAINT; Schema: public; Owner: ylg; Tablespace: 
--

ALTER TABLE ONLY bratan
    ADD CONSTRAINT bratan_pkey PRIMARY KEY (id);


--
-- Name: city_pkey; Type: CONSTRAINT; Schema: public; Owner: ylg; Tablespace: 
--

ALTER TABLE ONLY city
    ADD CONSTRAINT city_pkey PRIMARY KEY (id);


--
-- Name: cmps_pkey; Type: CONSTRAINT; Schema: public; Owner: ylg; Tablespace: 
--

ALTER TABLE ONLY cmps
    ADD CONSTRAINT cmps_pkey PRIMARY KEY (id);


--
-- Name: cmpx_pkey; Type: CONSTRAINT; Schema: public; Owner: ylg; Tablespace: 
--

ALTER TABLE ONLY cmpx
    ADD CONSTRAINT cmpx_pkey PRIMARY KEY (id);


--
-- Name: color_pkey; Type: CONSTRAINT; Schema: public; Owner: ylg; Tablespace: 
--

ALTER TABLE ONLY color
    ADD CONSTRAINT color_pkey PRIMARY KEY (id);


--
-- Name: crps_pkey; Type: CONSTRAINT; Schema: public; Owner: ylg; Tablespace: 
--

ALTER TABLE ONLY crps
    ADD CONSTRAINT crps_pkey PRIMARY KEY (id);


--
-- Name: deadline_pkey; Type: CONSTRAINT; Schema: public; Owner: ylg; Tablespace: 
--

ALTER TABLE ONLY deadline
    ADD CONSTRAINT deadline_pkey PRIMARY KEY (id);


--
-- Name: district_pkey; Type: CONSTRAINT; Schema: public; Owner: ylg; Tablespace: 
--

ALTER TABLE ONLY district
    ADD CONSTRAINT district_pkey PRIMARY KEY (id);


--
-- Name: flat_pkey; Type: CONSTRAINT; Schema: public; Owner: ylg; Tablespace: 
--

ALTER TABLE ONLY flat
    ADD CONSTRAINT flat_pkey PRIMARY KEY (id);


--
-- Name: group_pkey; Type: CONSTRAINT; Schema: public; Owner: ylg; Tablespace: 
--

ALTER TABLE ONLY "group"
    ADD CONSTRAINT group_pkey PRIMARY KEY (id);


--
-- Name: metro_pkey; Type: CONSTRAINT; Schema: public; Owner: ylg; Tablespace: 
--

ALTER TABLE ONLY metro
    ADD CONSTRAINT metro_pkey PRIMARY KEY (id);


--
-- Name: moto_pkey; Type: CONSTRAINT; Schema: public; Owner: ylg; Tablespace: 
--

ALTER TABLE ONLY moto
    ADD CONSTRAINT moto_pkey PRIMARY KEY (id);


--
-- Name: msg_pkey; Type: CONSTRAINT; Schema: public; Owner: ylg; Tablespace: 
--

ALTER TABLE ONLY msg
    ADD CONSTRAINT msg_pkey PRIMARY KEY (id);


--
-- Name: plex_pkey; Type: CONSTRAINT; Schema: public; Owner: ylg; Tablespace: 
--

ALTER TABLE ONLY plex
    ADD CONSTRAINT plex_pkey PRIMARY KEY (id);


--
-- Name: que_pkey; Type: CONSTRAINT; Schema: public; Owner: ylg; Tablespace: 
--

ALTER TABLE ONLY que
    ADD CONSTRAINT que_pkey PRIMARY KEY (id);


--
-- Name: quelt_pkey; Type: CONSTRAINT; Schema: public; Owner: ylg; Tablespace: 
--

ALTER TABLE ONLY quelt
    ADD CONSTRAINT quelt_pkey PRIMARY KEY (id);


--
-- Name: role_pkey; Type: CONSTRAINT; Schema: public; Owner: ylg; Tablespace: 
--

ALTER TABLE ONLY role
    ADD CONSTRAINT role_pkey PRIMARY KEY (id);


--
-- Name: user2group_pkey; Type: CONSTRAINT; Schema: public; Owner: ylg; Tablespace: 
--

ALTER TABLE ONLY user2group
    ADD CONSTRAINT user2group_pkey PRIMARY KEY (id);


--
-- Name: user_pkey; Type: CONSTRAINT; Schema: public; Owner: ylg; Tablespace: 
--

ALTER TABLE ONLY "user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);


--
-- Name: vendor_pkey; Type: CONSTRAINT; Schema: public; Owner: ylg; Tablespace: 
--

ALTER TABLE ONLY vendor
    ADD CONSTRAINT vendor_pkey PRIMARY KEY (id);


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

