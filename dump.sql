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
-- Name: event; Type: TABLE; Schema: public; Owner: ylg; Tablespace: 
--

CREATE TABLE event (
    id integer NOT NULL,
    name character varying,
    tag character varying,
    msg character varying,
    author_id character varying,
    ts_create bigint NOT NULL
);


ALTER TABLE public.event OWNER TO ylg;

--
-- Name: event_id_seq; Type: SEQUENCE; Schema: public; Owner: ylg
--

CREATE SEQUENCE event_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.event_id_seq OWNER TO ylg;

--
-- Name: event_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ylg
--

ALTER SEQUENCE event_id_seq OWNED BY event.id;


--
-- Name: group; Type: TABLE; Schema: public; Owner: ylg; Tablespace: 
--

CREATE TABLE "group" (
    id integer NOT NULL,
    name character varying NOT NULL,
    descr character varying,
    ts_create bigint NOT NULL,
    author_id integer
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
    name character varying NOT NULL
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
    firstname character varying,
    lastname character varying,
    phone character varying,
    mobilephone character varying,
    sex character varying,
    birth_day character varying,
    birth_month character varying,
    birth_year character varying,
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
-- Name: vacancy; Type: TABLE; Schema: public; Owner: ylg; Tablespace: 
--

CREATE TABLE vacancy (
    id integer NOT NULL,
    src_id integer NOT NULL,
    archive boolean NOT NULL,
    name character varying NOT NULL,
    currency character varying,
    base_salary integer,
    salary integer,
    salary_text character varying,
    salary_max integer,
    salary_min integer,
    emp_id integer,
    emp_name character varying NOT NULL,
    city character varying NOT NULL,
    metro character varying NOT NULL,
    experience character varying NOT NULL,
    date character varying NOT NULL,
    descr character varying NOT NULL,
    notes character varying,
    response character varying,
    state character varying,
    respond character varying
);


ALTER TABLE public.vacancy OWNER TO ylg;

--
-- Name: vacancy_id_seq; Type: SEQUENCE; Schema: public; Owner: ylg
--

CREATE SEQUENCE vacancy_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.vacancy_id_seq OWNER TO ylg;

--
-- Name: vacancy_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ylg
--

ALTER SEQUENCE vacancy_id_seq OWNED BY vacancy.id;


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

ALTER TABLE ONLY cmps ALTER COLUMN id SET DEFAULT nextval('cmps_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: ylg
--

ALTER TABLE ONLY color ALTER COLUMN id SET DEFAULT nextval('color_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: ylg
--

ALTER TABLE ONLY event ALTER COLUMN id SET DEFAULT nextval('event_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: ylg
--

ALTER TABLE ONLY "group" ALTER COLUMN id SET DEFAULT nextval('group_id_seq'::regclass);


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

ALTER TABLE ONLY vacancy ALTER COLUMN id SET DEFAULT nextval('vacancy_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: ylg
--

ALTER TABLE ONLY vendor ALTER COLUMN id SET DEFAULT nextval('vendor_id_seq'::regclass);


--
-- Data for Name: avatar; Type: TABLE DATA; Schema: public; Owner: ylg
--

COPY avatar (id, user_id, origin, ts_create, state) FROM stdin;
1	6	2.png	3632721864	:ACTIVE
4	1	1.png	3632726064	:ACTIVE
5	1	1.jpg	3632737380	:ACTIVE
6	1	1.jpg	3632737734	:ACTIVE
\.


--
-- Name: avatar_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ylg
--

SELECT pg_catalog.setval('avatar_id_seq', 6, true);


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
-- Data for Name: cmps; Type: TABLE DATA; Schema: public; Owner: ylg
--

COPY cmps (id, plex_id, name) FROM stdin;
\.


--
-- Name: cmps_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ylg
--

SELECT pg_catalog.setval('cmps_id_seq', 1, false);


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
-- Data for Name: event; Type: TABLE DATA; Schema: public; Owner: ylg
--

COPY event (id, name, tag, msg, author_id, ts_create) FROM stdin;
\.


--
-- Name: event_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ylg
--

SELECT pg_catalog.setval('event_id_seq', 8, true);


--
-- Data for Name: group; Type: TABLE DATA; Schema: public; Owner: ylg
--

COPY "group" (id, name, descr, ts_create, author_id) FROM stdin;
1	Исполнитель желаний	Создатель штук, которых еще нет. Исправлятель штук, которые неправильно работают.	3632802473	1
2	Пропускать везде	Для этого пользователя нет запретных мест	3632802473	1
3	Острый глаз	Обладает способностью замечать недоработки	3632802473	1
4	Основатель	Был с нами еще до того как это стало мейнстримом	3632802473	1
5	Рулевой	Управляет пользователями и назначает права доступа	3632802473	1
6	Засыпающие в Мариинке	Группа товарисчей, которые категорически засыпают в Мариинском театре на вечерних спектаклях :)	3632802473	6
9	Эксперт	Проконсультирует по всем вопросам.	3632811985	6
11	Мизантроп	Не умеет общаться - не пишет и не получает сообщений от других пользователей. Большинство роботов - типичные мизантропы	3632912723	1
\.


--
-- Name: group_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ylg
--

SELECT pg_catalog.setval('group_id_seq', 11, true);


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
24	6	1	когда открываешь вкладку Сообщения - видно всего три сообщения.\r\nПри чем нижние два - очень старые, а верхнее меняется постоянно на последнее отправленное. Скрин я тебе в вк сидывала	3632725308	0	:UNDELIVERED
1	2	3	Привет, Боб, это Алиса!	3632713383	0	:DELIVERED
2	3	2	Здравствуй, Алиса, я получил твое письмо. Я напишу Кэрол что ты нашла меня	3632713384	0	:UNDELIVERED
3	3	4	Кэрол, передаю привет от Алисы. Боб.	3632713385	0	:UNDELIVERED
4	5	3	Привет, Боб, я хочу добавить тебя в друзья	3632713386	0	:UNDELIVERED
5	1	6	Ну как, видно меня?	3632719700	0	:UNDELIVERED
6	6	5	.	3632719911	0	:UNDELIVERED
7	6	0		3632719997	0	:UNDELIVERED
8	6	1	123581321	3632720015	0	:UNDELIVERED
9	1	6	Да вижу, пришло	3632720054	0	:UNDELIVERED
10	1	6	Тут все пока очень сыро, но я работаю над этим	3632720099	0	:UNDELIVERED
11	6	1	И как-то хорошо бы, чтобы сообщения выводились диалогом что ли, а то уходишь на страницу написания и чаво там раньше было...\r\nчто-то у тебя тут все в одном флаконе - и сервисы, и поиск работы.\r\n? 	3632720411	0	:UNDELIVERED
12	1	6	Пока да, я хочу поиск работы сделать как один из сервисов, вот как раз планировал сегодня после облагораживания сообщений заняться	3632720476	0	:UNDELIVERED
13	6	1	а почему твоя аватарка на меня распространилась?))	3632721104	0	:UNDELIVERED
14	6	1	пока ничего не меняется...\r\n	3632723615	0	:UNDELIVERED
15	6	1	Зато с появлением новых мои сообщений, старые два остаются на месте, а новое заменяет самое верхнее\r\n	3632723647	0	:UNDELIVERED
16	1	6	Кажись получилось?	3632724376	0	:UNDELIVERED
17	6	1	теперь выводится история переписки диалогом. В диалоге аватарки на месте.\r\nА вот открывая вкладку Сообщения - я вижу только три сообщения. При чем мои и с твоей аватаркой))\r\n	3632724542	0	:UNDELIVERED
18	1	6	test	3632725004	0	:UNDELIVERED
19	6	1	ну пока не меняеццо	3632725050	0	:UNDELIVERED
20	1	6	Еще один тест	3632725107	0	:UNDELIVERED
21	1	6	Ты там вообще?	3632725141	0	:UNDELIVERED
22	1	6	Я не очень понял из твоег описания, что там такое неправильное?	3632725170	0	:UNDELIVERED
23	6	1	теперь есть поле ввода)	3632725258	0	:UNDELIVERED
26	6	1	Урра!)\r\n	3632758452	0	:UNDELIVERED
27	6	1	А какими клавишами у нас можно отправить сообщение? \r\n\r\n	3632758468	0	:UNDELIVERED
28	1	6	У нас пока нет привязки к клавишам, но я думаю стоит это добавить в твой список. Однако я пишу это с мобилы и даже все работает ...	3632812574	0	:UNDELIVERED
\.


--
-- Name: msg_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ylg
--

SELECT pg_catalog.setval('msg_id_seq', 28, true);


--
-- Data for Name: que; Type: TABLE DATA; Schema: public; Owner: ylg
--

COPY que (id, name) FROM stdin;
\.


--
-- Name: que_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ylg
--

SELECT pg_catalog.setval('que_id_seq', 1, false);


--
-- Data for Name: quelt; Type: TABLE DATA; Schema: public; Owner: ylg
--

COPY quelt (id, que_id, text) FROM stdin;
\.


--
-- Name: quelt_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ylg
--

SELECT pg_catalog.setval('quelt_id_seq', 1, false);


--
-- Data for Name: role; Type: TABLE DATA; Schema: public; Owner: ylg
--

COPY role (id, name) FROM stdin;
1	webuser
2	timebot
3	autotester
4	system
\.


--
-- Name: role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ylg
--

SELECT pg_catalog.setval('role_id_seq', 4, true);


--
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: ylg
--

COPY "user" (id, name, password, email, firstname, lastname, phone, mobilephone, sex, birth_day, birth_month, birth_year, ts_create, ts_last, role_id, state) FROM stdin;
7	timer			\N	\N	\N	\N	\N	\N	\N	\N	3632900824	3632900824	2	\N
2	alice	aXJAVtBT	alice@mail.com	\N	\N	\N	\N	\N	\N	\N	\N	3632713383	3632713383	2	:UNLOGGED
3	bob	pDa84LAh	bob@mail.com	\N	\N	\N	\N	\N	\N	\N	\N	3632713383	3632713383	3	:UNLOGGED
4	carol	zDgjGus7	carol@mail.com	\N	\N	\N	\N	\N	\N	\N	\N	3632713383	3632713383	4	:UNLOGGED
5	dave	6zt5GmvE	dave@mail.com	\N	\N	\N	\N	\N	\N	\N	\N	3632713383	3632713383	4	:UNLOGGED
1	admin	tCDm4nFskcBqR7AN	nomail@mail.ru	\N	\N	\N	\N	\N	\N	\N	\N	3632713382	3632713382	1	:LOGGED
6	Aeternitas	b15zz09helm	lemyriets@gmail.com					female				3632719463	3632719463	1	:LOGGED
\.


--
-- Data for Name: user2group; Type: TABLE DATA; Schema: public; Owner: ylg
--

COPY user2group (id, user_id, group_id) FROM stdin;
8	6	2
9	6	3
10	6	5
11	1	1
12	1	2
13	1	4
14	1	5
15	1	6
16	2	11
17	3	11
18	4	11
19	5	11
20	7	11
\.


--
-- Name: user2group_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ylg
--

SELECT pg_catalog.setval('user2group_id_seq', 20, true);


--
-- Name: user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ylg
--

SELECT pg_catalog.setval('user_id_seq', 33, true);


--
-- Data for Name: vacancy; Type: TABLE DATA; Schema: public; Owner: ylg
--

COPY vacancy (id, src_id, archive, name, currency, base_salary, salary, salary_text, salary_max, salary_min, emp_id, emp_name, city, metro, experience, date, descr, notes, response, state, respond) FROM stdin;
2	11952884	f	Senior frontend-разработчик	RUR	80000	80000	от 80 000 до 130 000 руб.	130000	80000	707239	 Embria	false	Петроградская	1–3 года	3 февраля	((:P)\n ((:P) ((:B) "Компания YoulaMedia,")\n  " которая специализируется на баннерной рекламе в Интернет (входит в группу компаний Embria и является официальным партнером Google AdExchange в России) открывает вакансию"\n  ((:B) " Frontend разработчика ") "для "\n  ((:B) "создания и развития нашей новой партнерской программы") ".")\n ((:B) "Основные задачи, которые сейчас предполагается решать, следующие:")\n ((:UL)\n  ((:LI)\n   "Дизайн интерфейсов для пользователей в стиле Google Adsense/Adwords/Analytics;")\n  ((:LI) "Программирование интерфейсов со стороны фронтенда;")\n  ((:LI) "Взаимодействие с api;") ((:LI) "Оптимизация фронтэнда;")\n  ((:LI) "Развитие‚ поддержка и интеграция проектов компании."))\n ((:P)) ((:P) ((:B) "Что мы хотим видеть в вас:"))\n ((:UL) ((:LI) "Опыт работы Frontend программистом от 2 лет;")\n  ((:LI) "Знание" ((:B)) "JavaScript;")\n  ((:LI) "Знание БЭМ будет преимуществом;")\n  ((:LI) "Умение работать в команде."))\n ((:P) ((:B) "Обратите внимание, что:"))\n ((:UL)\n  ((:LI)\n   "Мы работаем с иностранными и российскими компаниями-рекламодателями, а также с сайтами входящими с ТОП 100 по версии Alexa и постоянно расширяем своё присутствие на рынке;")\n  ((:LI)\n   "Создаем адсервер, который по функциональности опережает конкурирующие на мировом рынке аналоги;")\n  ((:LI)\n   "Используем такие технологии как MySQL, Redis, Memcache, MongoDB, NodeJS, Hadoop, Nginx, Amazon Cloud EC2 и другие;")\n  ((:LI)\n   "Мы работаем с High-Load (800М запросов на показ рекламы (ad request), 100+ серверов, 15к записей в базу в секунду, 1000M записей в базу в сутки, 120 стран охват по GEO, в 20 раз - рост нагрузки за последний год, в 10 раз - прогноз роста нагрузки на ближайший год);")\n  ((:LI)\n   "Некоторые наши клиенты: Worldoftanks, Google, Mail.ru, Badoo, Fotostrana, Freelotto, Forex и.т."))\n ((:P) ((:B) "Что мы готовы предложить:"))\n ((:UL)\n  ((:LI)\n   "Проект активно развивается и будет возможность решать разные сложные задачи.")\n  ((:LI)\n   "Заработная плата: по договорённости. Мы готовы рассматривать кандидатов, отталкиваясь от их «зарплатных ожиданий».")\n  ((:LI)\n   "График работы, который позволяет высыпаться (пятидневка с 11:00 до 20:00);")\n  ((:LI) "Получение опыта работы с рекламными технологиями компании Google;")\n  ((:LI)\n   "Возможность изучения инструментов и принципов работы самых крутых международных технологий (Google, Amazon, BlueKai (retargeting));")\n  ((:LI)\n   "Комфортные условия работы: новый бизнес центр класса A недалеко от м. \\"Петроградская\\"; выделенные зоны отдыха (чай, кофе, орешки, йогурты, печенье и прочие «вкусности»); корпоративные праздники, выезды.")\n  ((:LI) "Официальное оформление по ТК РФ.")\n  ((:LI) "Испытательный срок - 2 месяца.")))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:UNINTERESTING	\N
17	12610960	f	UI/UX Designer / Дизайнер интерфейсов	RUR	80000	80000	от 80 000 до 120 000 руб.	120000	80000	1736560	ООО Аналитико-правовой центр Опора	false	Ладожская	3–6 лет	2 февраля	((:P)\n ((:P)\n  "В Tsarev Corporation занимающейся разработкой стартап проектов требуется опытный дизайнер.")\n ((:P)\n  "Нам нужен тот, кто будет придумывать как гигантские платформы и сервисы, так и промо сайты с миллионной посещаемостью.")\n ((:P)\n  "От Вашей работы будут зависеть эмоции и продуктивность миллионов пользователей.")\n ((:P) ((:B) "Требования :"))\n ((:UL) ((:LI) "Виртуозное владение Adobe Illustrator, Adobe Photoshop;")\n  ((:LI) "Опыт разработки и проектирование интерфейсов (iOS, Android);")\n  ((:LI) "Знание guidlines Apple и Android;"))\n ((:P) ((:B) "Обязанности") ":")\n ((:UL) ((:LI) "Разработка дизайн-концепции приложения;")\n  ((:LI) "Разработка дизайн-макетов всех страниц приложения;")\n  ((:LI) "Подготовка макетов к верстке (нарезка);")\n  ((:LI) "Создание уникальных решений.")))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:UNINTERESTING	\N
5	12457786	f	Team Lead / PHP программист	RUR	75000	75000	от 75 000 до 110 000 руб.	110000	75000	1040211	 eLama	false	Елизаровская	3–6 лет	3 февраля	((:P) ((:P) ((:B) "Требования:"))\n ((:UL)\n  ((:LI) "Опыт работы с PHP (ООП в т.ч. паттерны проектирования) от 3х лет")\n  ((:LI) "Опыт разработки с PHP фреймворками(symfony 2, Yii, laravel)")\n  ((:LI) "Знакомство с ORM (Doctrine 2)") ((:LI) "Знакомство с Symfony 2")\n  ((:LI) "Опыт использования PHPUnit и TDD (Test Driven Development)"))\n ((:P) ((:B) "Приветствуется") ":")\n ((:UL) ((:LI) "Знание других языков программирования JAVA, C++, python")\n  ((:LI) "Опыт работы над высоконагруженными проектами"))\n ((:P) ((:B) "Должностные обязанности:"))\n ((:UL) ((:LI) "Разработка и сопровождение проектов компании eLama.ru")\n  ((:LI) "Создание и модификация программных модулей")\n  ((:LI)\n   "Управление командой разработчиков(размер команды зависит от желания и успехов роста)")\n  ((:LI) ((:B) "Интересные задачи гарантируем!")))\n ((:P) ((:B) "Условия:"))\n ((:UL) ((:LI) "Веселый и дружный коллектив, оплачиваемый отпуск 1 месяц.")\n  ((:LI) "Индексация заработной платы") ((:LI) "Обучение сотрудников")\n  ((:LI)\n   "Полный рабочий день, офис в 7-ми минутах от м. Елизаровская, Бизнес-инкубатор Ингрия. (Санкт-Петербургская “кремниевая долина”)")\n  ((:LI) "Перспективы роста"))\n ((:P) ((:B) "Дополнительная информация:"))\n ((:P)\n  "Мы ищем талантливых специалистов! Если Вы уверены в себе и хотите заниматься любимым делом профессионально, пишите нам! Мы хотим видеть людей, готовых работать над серьезными проектами и добиваться отличных результатов. Мы предлагаем интересную работу в дружном и профессиональном коллективе, в котором ценится работа каждого. Вы можете стать частью нашей команды!"))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:RESPONDED	\N
65	12492787	f	Mobile Development Team Lead	USD	5500	5500	от 5 500 до 7 000 USD	7000	5500	250	 COMTEK Inc.	Санкт-Петербург	false	более 6 лет	4 февраля	((:P)\n ((:P)\n  "A leading USA provider of mobile messaging service (with more than 200 million registered members) is opening an offshore development office in St. Petersburg, Russia. We are looking for Engineering Team Lead (Mobile Development) for this office.")\n ((:P)) ((:P) ((:B) "Engineering Team Lead (Mobile Development)"))\n ((:P)\n  "The Engineering Team Lead is a Tech lead, Architect, and people manager, all in one, who is comfortable with both backend and mobile development (iOS and Android). The role entails 20-30% hands-on coding. The ideal candidate is a take-charge, “no BS”, ego-less technology enthusiast.")\n ((:P))\n ((:P) ((:B) "Responsibilities") ("br" NIL)\n  "Your mission is to create, contribute to, and manage Company products and features that usually span across both mobile and backend scopes and are likely to be deployed at very large scale.")\n ((:P)) ((:P) ((:B) "Requirements"))\n ((:P) "Some of the things this role will require:" ("br" NIL)\n  "• Mastery of complex software engineering and architecture design concepts, such as design patterns, object-oriented design and programming, concurrency, cross-compilation, managed vs unmanaged runtimes, databases, scalability patterns, constrained environments (embedded systems)"\n  ("br" NIL)\n  "• Understanding the benefits of good design and testing coverage. Have conviction to evangelize them persistently."\n  ("br" NIL) "• 7+ years programming experience" ("br" NIL)\n  "• 2+ years leading a team (as a tech lead or a manager)" ("br" NIL) "And"\n  ("br" NIL)\n  "• You understand all of the layers that it takes to build a production system and can quickly narrow down a problem to a root cause in any one of these layers, whether client or server"\n  ("br" NIL)\n  "• You are equally good at thinking, designing, and communicating coarse-grained abstract ideas and systems as the fine-grained concrete details that comprise these systems."\n  ("br" NIL)\n  "• Though not necessarily an expert in both client and server, you should at least comfortable with Java backend code or client Objective-C, Java and C++.")\n ((:P)) ((:P) "Good English is required.") ((:P))\n ((:P)\n  "3 months business trip for training in Company's headquarter (in California, USA) will be required.")\n ((:P))\n ((:P) ((:B) "Conditions:") ("br" NIL)\n  "Compensation: $5500 -$7000 per month depending on skill set and experience.")\n ((:P) ("br" NIL) "If you are interested in this opportunity "\n  ((:B) "please provide your detailed English resume (")\n  "preferably in Word format).")\n ((:P)) ((:P)) ((:P)) ((:P)))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:UNINTERESTING	
7	12590070	f	Senior Technical Delivery Manager	RUR	140000	140000	от 140 000 до 180 000 руб.	180000	140000	65024	 Enkata Technologies	false	Звенигородская	3–6 лет	3 февраля	((:P)\n ((:P)\n  "Enkata Technologies, leading International Software Development Corporation is looking for a talented "\n  ((:B) "Senior Technical Delivery Manager ")\n  "to join its Saint-Petersburg office")\n ("br" NIL)\n ((:P)\n  "We’re looking for someone with both the people skills and technical skills to make our talented Professional Services team even better! If you are an experienced Professional Services Manager or a senior technical individual contributor interested in moving into Professional Services leadership role, please consider this exciting opportunity! This role reports directly to the Director of Professional Services.The "\n  ((:B) "Sr. Technical Delivery Manager")\n  " will be in charge for successful delivery the new Enkata products to US based customers. The main activities will include active communication with our prospects, participation in pre-sale stage to identify and specify clients' requirements, creating technical specifications, coordinating efficient work of other team members to ensure delivery of our solution to customers and also carrying out comprehensive data mining in MS SQL Server databases when needed."\n  ("br" NIL) ("br" NIL) ((:B) "Responsibilities:"))\n ((:UL)\n  ((:LI)\n   "Interface with various functional groups, project teams and other stakeholders to effectively resolve issues and remove barriers to ‘Demo on Your Data’ program success")\n  ((:LI)\n   "Drive the coordination and execution of Saint Petersburg team’s day-to-day activities related to new releases, feature enhancements, on-going QA and Delivery for all Sales ‘Demo on Your Data’ Customers")\n  ((:LI)\n   "Manage prioritization and delivery of defect fixes, enhancements and customizations for the ‘Demo on Your Data’ Customers")\n  ((:LI)\n   "Manage, track and control project related items to ensure timely resolution of issues that could impact the timeline for delivery of solution to customers")\n  ((:LI)\n   "Implements and improves procedures and processes to optimize program effectiveness.")\n  ((:LI)\n   "Develop reports to track planning, scheduling, issues, risks, and report on weekly status")\n  ((:LI)\n   "Assist with technical issues and contribute to validating and prioritizing assigned bugs")\n  ((:LI)\n   "Facilitate the creation of new processes and tools as necessary to support growth and efficiency of the ‘Demo On Your Data’ Program")\n  ((:LI) "Develop and conduct internal training on processes and tools")\n  ((:LI) "Reports to Director of Professional Services and Operations"))\n ("br" NIL) ((:B) "Requirements & Skills:")\n ((:UL) ((:LI) "BA/BS in Computer Science or related technical field")\n  ((:LI) "Fluent English - oral and written")\n  ((:LI)\n   "Minimum 3 years of project management experience in software development")\n  ((:LI)\n   "Strong interpersonal skills and good judgment with an approachable communication style")\n  ((:LI)\n   "Ability to work in a fast-paced environment and consistently meet internal and external deadlines")\n  ((:LI)\n   "Proficiency communicating with clients and colleagues from other cultures and regions")\n  ((:LI)\n   "Strong history and track record of completing quality projects on time, as well as a proven track record coaching and mentoring others to success")\n  ((:LI)\n   "Ability to organize and oversee 8 – 10 small projects in various stages at the same time")\n  ((:LI) "Understanding of software product life cycles")\n  ((:LI)\n   "Ability to handle stressful situations with perseverance and professionalism")\n  ((:LI) "Ability to multi-task efficiently")\n  ((:LI) "Understanding SQL and relational DBs")\n  ((:LI) "Previous experience using collaboration tools such as Jira, Github")\n  ((:LI) "Proven experience in SQL coding")\n  ((:LI)\n   "Previous experience as a developer working as part of a larger team"))\n ("br" NIL) ((:B) "Desired knowledge and skill sets:")\n ((:UL)\n  ((:LI) "Experience developing enterprise Web applications will be a plus")\n  ((:LI)\n   "Understanding software testing processes and methodologies will be a plus"))\n ("br" NIL) ((:B) "Conditions: ")\n ((:UL)\n  ((:LI) "Competitive salary will depend on the skillset of final candidate")\n  ((:LI) "Proficient and friendly team")\n  ((:LI) "Encouragement toward best results")\n  ((:LI) "International and friendly working environment")\n  ((:LI) "Comfortable working conditions")\n  ((:LI)\n   "Extensive social package: Voluntary Medical Insurance, sport activity compensation, additional pay off for a sick leave, etc.")\n  ((:LI)\n   "Conveniently located A-class office within a 5-minute walk from a central subway stations, complete with onsite gym")))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:UNINTERESTING	\N
1	12438676	f	Senior .NET / Windows 8 Developer	RUR	130000	130000	от 130 000 руб.	130000	130000	745841	 AgileFusion	false	Московская	более 6 лет	3 февраля	((:P)\n ((:P)\n  "Agile Fusion - успешная динамичная международная компания, осуществляющая разработку программного обеспечения для устройств, работающих на платформе Андроид, iOS и Windows8 (смартфоны, e-readers, tablets). Agile Fusion помогает компаниям быстро и эффективно интегрировать успешные мобильные каналы в их бизнес уже более 8 лет. Среди наших партнеров такие компании как Dell, Barnes and Noble, SAP, Evernote, Esselte, JibeMobile, TheFind.com, Rhythm Newmedia, Discovery Channel, Tv.com, E!, ChefsFeed и другие. Наша компания постоянно развивается и укрепляет свои позиции на международном рынке IT-компаний. Поэтому мы ищем талантливых людей, готовых развиваться и расти вместе с нами.")\n ("br" NIL) ((:P) ((:B) "Условия:"))\n ((:UL)\n  ((:LI)\n   "Мы предлагаем работу в востребованной компании с современными технологиями и хорошие перспективы профессионального и карьерного роста. Наша цель собрать команду профессионалов, способных решать задачи, которые не могут решать другие люди...")\n  ((:LI) "...Ну и еще чуть-чуть: "\n   ("ul" NIL\n    ("li" NIL\n     "интересную и перспективную работу в дружном молодом коллективе;")\n    ("li" NIL "оформление по ТК (оплачиваемый отпуск и больничный лист);")\n    ("li" NIL\n     "карьерный рост и стажировки в США с оплачиваемым перелетом и проживанием;")\n    ("li" NIL "достойную оплату труда и систему премий и бонусов;")\n    ("li" NIL\n     "медицинское страхование в лучших клиниках Санкт-Петербурга (включая стоматологию);")\n    ("li" NIL "гибкий рабочий график с возможностью работы из дома;")\n    ("li" NIL\n     "современный уютный офис в бизнес центре класса “А” (открыт круглосуточно);")\n    ("li" NIL\n     "удобное расположение: от метро “Московская” до бизнес-центра каждые 15 минут курсирует бесплатный комфортабельный автобус;")\n    ("li" NIL "велопарковка и душевые для велосипедистов;")\n    ("li" NIL\n     "вкусные бесплатные обеды от шев-повара ресторана (в том числе пицца/ пироги/ сущи каждый месяц), а также на собственной кухне в офисе для сотрудников всегда есть свежесваренный, бодрящий, ароматный кофе, чай и сладости;")\n    ("li" NIL\n     "проведение корпоративных мероприятий, в том числе и с семьями сотрудников, а также подарки для именинников."))))\n ("br" NIL) ((:P) ((:B) "Кого мы ищем?"))\n ((:UL)\n  ((:LI)\n   "Мы ищем опытного C#/.NET джедая, способного решать сложные технические задачи, но не забывающего о том, что мобильные приложения пишутся для людей и красивый отзывчивый интерфейс приложения важен не меньше чем его функциональность."))\n ("br" NIL) ((:P) ((:B) "Обязательные требования:"))\n ((:UL)\n  ((:LI)\n   "Опыт разработки коммерческих приложений на C#, .NET не менее 3-х лет.")\n  ((:LI) "Опыт разработки под Windows 8.")\n  ((:LI)\n   "Умение быстро вникать в новые задачи и разбираться в большом объеме существующего кода")\n  ((:LI)\n   "Английский на уровне достаточном для переписки по почте и в скайпе, в идеале разговорный английский")))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:UNINTERESTING	\N
8	12664479	f	Инженер-программист (микроконтроллеры AVR)	RUR	55000	55000	от 55 000 до 120 000 руб.	120000	55000	101298	 Газпроект, конструкторско-технологический проектный институт	false	Гражданский проспект	3–6 лет	3 февраля	((:P)\n ((:P)\n  ((:B)\n   "В группе компаний \\"Диаконт\\" открыта вакансия \\"Инженер-программист\\""))\n ((:P)) ((:P) ((:B) "Д") ((:B) "олжностные обязанности:"))\n ((:UL)\n  ((:LI)\n   "разработка встраиваемых приложений на С/С++ для микроконтроллеров AVR, ARM, Altera NIOS, а также для РС-совместимых контроллеров под управлением Linux и DOS в роботизированных системах, системах телевидения и дефектоскопии."))\n ((:P) ((:B) "Требования:"))\n ((:UL)\n  ((:LI)\n   "оконченное высшее техническое образование в области вычислительной техники, информационных систем, робототехники, систем автоматического управления, систем автоматизированного проектирования;")\n  ((:LI) "опыт работы инженером-программистом от 2-х лет обязателен;")\n  ((:LI)\n   "обязательное знание языка программирования С, приветствуется знание С++;")\n  ((:LI) "обязателен опыт работы с периферией UART, SPI, I2C, PIO;")\n  ((:LI)\n   "желателен опыт разработки приложений для встраиваемых систем на базе контроллеров Atmel AVR (atmega1280, atmega168), AVR Cortex M3/M4, Altera NIOS II;")\n  ((:LI) "желателен опыт работы с Atmel Studio, Eclips+GCC, CodeVision AVR;")\n  ((:LI)\n   "приветствуется опыт работы с Renesas M16 и PC совместимыми контроллерами под управлением Linux (Faswell CPC) и DOC (Octagon 6040);")\n  ((:LI)\n   "приветствуются знания основ по прикладным направлениям (телевидение, робототехника, ультразвуковая дефектоскопия);")\n  ((:LI)\n   "возможность выезжать в командировки (от нескольких дней до 2-х недель);")\n  ((:LI)\n   "знания английского языка в объеме необходимом для чтения и понимания технической литературы по направлению деятельности.")\n  ((:LI) "английский язык технический."))\n ((:P) ((:B) "Условия:"))\n ((:UL) ((:LI) "оформление в соответствии с ТК РФ;")\n  ((:LI)\n   "график работы: 5/2 (с 9.00 до 18.00 или с 10.00 до 19.00), возможны командировки;")\n  ((:LI)\n   "полностью официальная заработная плата, выплачиваемая (без задержек) два раза в месяц на карту Сбербанка России;")\n  ((:LI)\n   "заработная плата на испытательный срок 50000 руб. и после испытательного срока 85000 руб.+ 30% ежемесячная премия (суммы указаны после вычета подоходного налога, т.е. \\"на руки\\")")\n  ((:LI) "ДМС после 3 лет работы в организации;")\n  ((:LI) "спортивные мероприятия (баскетбол, футбол, хоккей);")\n  ((:LI) "питание по льготной цене;")\n  ((:LI)\n   "предприятие находится в Калининском р-не СПб (ст.м. \\"Гражданский проспект\\"/\\"Проспект Просвещения\\");")\n  ((:LI) "работа связана с командировками (от нескольких дней до 2-х недель);")\n  ((:LI) "полный рабочий день.")))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:INTERESTING	\N
14	11807883	f	Senior PHP developer (внутренние ERP системы)	RUR	90000	90000	от 90 000 до 150 000 руб.	150000	90000	707239	 Embria	Санкт-Петербург	false	3–6 лет	2 февраля	((:P)\n ((:P) "Компания " ((:B) "YoulaMedia ") "занимается "\n  ((:B) "интернет-рекламой на мировом уровне")\n  ". Мы занимаемся практически всеми видами интернет-рекламы, в их числе: дисплэй, ричмедиа, видео, реклама на мобильных устройствах. Основную ставку мы делаем на развитие новых эффективных форматов показа рекламы и на достижение максимального результата от каждого показа. Мы уже создали уникальную технологию, позволяющую нам занимать лидирующую позицию на международном рынке в формате кликандер.")\n ((:P)\n  "Мы постоянно улучшаем качество показа рекламы, модернизируем систему подбора рекламы для каждого пользователя, используя самые современные подходы и технологии. Все это требует большой аналитики, умения быстро обрабатывать огромные массивы данных, собирать эти данные, автоматически обслуживать тысячи клиентов и создавать удобные для пользователей интерфейсы работы с нашим рекламным сервером. У нас очень много интересных и сложных задач.")\n ((:P)\n  "У нас молодой и дружный коллектив профессионалов в своем деле. С одной стороны это профессионалы, которые обладают глубокими знаниями в мире интернет рекламы, с другой — команда, которая в состоянии превращать эти знания в инструменты для постоянного роста.")\n ((:P)\n  "Мы очень быстро выросли. Еще два года назад нас было меньше 20. Сегодня нас уже почти 150. Мы начинали с 0, а на сегодня у нас 800 миллионов запросов на показ рекламы в сутки. К концу года мы хотим эти цифры удвоить. Надо понимать, что у нас хайлоад, без купюр.")\n ((:P)\n  "Мы ценим своих клиентов и стремимся создать самый удобный, качественный и успешный международный рекламный нетворк. Нам нужны сильные руки и умные головы, чтобы воплотить эту мечту в жизнь.")\n ((:P) ((:B) "Кого мы ищем?"))\n ((:P)\n  "Сообразительных, талантливых людей, которые готовы работать на качественный результат и укладываться в сроки. Нас в первую очередь интересует стремление делать хорошо и правильно, во вторую умение практически применять накопленные знания. Мы любим теоретиков, но понимаем что без практиков мы далеко не уедем.")\n ((:P)) ((:P) ((:B) "Знания и навыки,") " которые вам понадобятся:")\n ((:UL) ((:LI) "качественный код, code style")\n  ((:LI) "желание все систематизировать и автоматизировать")\n  ((:LI) "отсутствие страха перед финансами")\n  ((:LI) "глубокие знания PHP 5.3-5.5") ((:LI) "nginx + php-fpm")\n  ((:LI)\n   "Simfony2, или любой другой мейнстрим PHP фреймворк и желание перейти на симфони")\n  ((:LI) "postgresql") ((:LI) "redis")\n  ((:LI) "git со знанием стратегий его использования") ((:LI) "restfull api")\n  ((:LI) "тестирование кода, например phpunit")\n  ((:LI) "и да, у вас нет страха перед unix консолью")\n  ((:LI) "знание английского языка на уровне чтения технической документации")\n  ((:LI) "умение работать в команде"))\n ((:P) ((:B) "Бонусом")\n  " и для вас и для нас будет представление, а возможно и "\n  ((:B) "опыт практического использования,") " следующих технологий:")\n ((:UL) ((:LI) "участие в проектирование баз данных")\n  ((:LI) "участие в разработке CRM и ERP систем")\n  ((:LI) "участие в разработке billing систем")\n  ((:LI)\n   "системы для работы с очередями (например RabbitMQ, или опыт реализации своих очередей)")\n  ((:LI) "понимание принципов кеширования")\n  ((:LI) "понимание принципов шардирования")\n  ((:LI) "умение использовать паттерны программирования"))\n ((:P) ((:B) "Задачи, которыми предстоит заниматься:"))\n ((:UL) ((:LI) "развитие рекламной платформы") ((:LI) "развитие ERP системы")\n  ((:LI) "написание систем биллинга")\n  ((:LI)\n   "написание restfull api для взаимодействия с другими компонентами нашей системы"))\n ((:P) ((:B) "Что мы предлагаем:"))\n ((:UL)\n  ((:LI)\n   "развитие. Перед нами стоят сложные задачи и для их решения мы не боимся использовать новые технологии.")\n  ((:LI) "растущая команда.")\n  ((:LI)\n   "работа в уютном бизнес офисе класса А++ размером 1200 кв.м, м. Петроградская (10 минут пешком)")\n  ((:LI) "кофе машины, плюшки печеньки и т.п. в избытке")\n  ((:LI) "рабочий график с 11 до 20") ((:LI) "отпуск 28 календарных дней.")\n  ((:LI)\n   "уровень заработной платы обсуждается на интервью. Мы готовы платить за качественный результат выше рынка.")\n  ((:LI)\n   "у нас действует мотивационная система позволяющая зарабатывать хорошие ежеквартальные бонусы")\n  ((:LI) "занятия английским языком в офисе." ((:B)))))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:RESPONDED	\N
15	12539849	f	РНР разработчик/программист	RUR	90000	90000	до 90 000 руб.	90000	90000	750281	 Деньги Online	false	Спортивная	1–3 года	2 февраля	((:P)\n ((:P) "Компания " ((:B) ((:B) "«Деньги Online»"))\n  " — крупный агрегатор платежных систем, предоставляющий свои услуги по всему миру. В настоящее время «Деньги Online» — это более 100 способов оплаты (банковские карты, мобильные платежи, платежные терминалы, электронные кошельки и многое другое). К агрегатору платежных систем «Деньги Online» подключены более 2000 интернет-ресурсов, в том числе такие крупные игровые проекты, как игры Mail.ru.")\n ((:P) ((:B) "Что нужно делать:"))\n ((:UL) ((:LI) "Думать над задачей") ((:LI) "Проектировать варианты решения")\n  ((:LI) "Выбирать оптимальное решение совместно с коллегами")\n  ((:LI) "Писать код") ((:LI) "Тестировать код")\n  ((:LI) "Следить за работой своего сервиса")\n  ((:LI) "Поддерживать созданные решения и своевременно их модернизировать"))\n ((:P) ((:B) "Что мы ожидаем от кандидатов:"))\n ((:UL)\n  ((:LI)\n   "Желание учиться и обучаться. Более опытные коллеги всегда готовы поделиться своими знаниями, если этого будет недостаточно, возможно обучение за счет компании.")\n  ((:LI) "Ответственность, креативность, чувство юмора и меры.")\n  ((:LI) "Уверенное знание php5, ООП, паттернов проектирования")\n  ((:LI)\n   "Мы считаем что эффективнее всего тратить силы разработчиков на решение специфических бизнес-задач, поэтому активно используем фреймворки, соискателю на данную вакансию будет предложено работать с фреймворком Yii. Плюсом будет опыт работы с ним, или с другими фреймворками, использующими парадигму MVC.")\n  ((:LI)\n   "Практический опыт проектирования схем данных в реляционных БД. Здраво оценивать соотношение возможностей БД и требований к ней.")\n  ((:LI)\n   "Знание теории СУБД, опыт работы с MySQL (написание, анализ, оптимизация запросов). При необходимости использование noSQL решений.")\n  ((:LI)\n   "Понимание принципов построения безопасных веб-приложений и ответственность за написанный код.")\n  ((:LI)\n   "Базовое знание JavaScript необходимо, продвинутое — желательно. AJAX, jQuery.")\n  ((:LI)\n   "Умение адекватно оценивать трудозатраты на решение поставленных задач.")\n  ((:LI)\n   "Способность следовать принятым в компании стандартам разработки и принципам управления ИТ-проектами. Возможность изменять и улучшать их при возникновении такой потребности."))\n ((:P) ((:B) "Преимуществом будет (если не умеете, не критично, научим):"))\n ((:UL) ((:LI) "Опыт работы с распределёнными системами контроля версий")\n  ((:LI) "Опыт работы с front-end фреймворками, в т.ч. с Bootstrap")\n  ((:LI)\n   "Знание английского языка на достаточном для чтения документации уровне")\n  ((:LI)\n   "Понимание особенностей функционирования и опыт базовой настройки веб-сервера")\n  ((:LI)\n   "Если вы пришлете ссылку на github или bitbucket со своими примерами кода на PHP, это будет большим плюсом."))\n ((:P) ((:B) "Обязанности:"))\n ((:UL)\n  ((:LI) "Проектирование и разработка внутренних сервисов компании, CRM, CP")\n  ((:LI) "Работа с большим объёмом данных и разношёрстным стеком технологий."))\n ((:P) ((:B) "Мы предлагаем:"))\n ((:UL)\n  ((:LI)\n   "Интересные задачи и новый опыт: мы не делаем сайты и не пишем очередную CMS, только сервисы, уникальные и необычные")\n  ((:LI)\n   "Возможность карьерного роста: Компания растет, параллельно с развитием текущих стартуют новые проекты")\n  ((:LI) "Грамотное техническое руководство") ((:LI) "Премии, бонусы, плюшки")\n  ((:LI) "Корпоративный ДМС со стоматологией") ((:LI) "Компенсация питания")\n  ((:LI) "Семинары и тренинги") ((:LI) "Корпоративы")\n  ((:LI) "Современный офис в 7 минутах ходьбы от м. Спортивная")\n  ((:LI)\n   "Комната отдыха с кикером и видом на Биржевой мост и стрелку Васильевского острова)"))\n ((:P)\n  "У нас сложно, нервно, но интересно. Мы будем рады видеть вас частью нашей команды!")\n ((:P)\n  ((:B)\n   ((:B)\n    "Пожалуйста, при отклике на вакансию предоставьте нам ссылку на репозиторий с примерами кода."))))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:RESPONDED	\N
16	12611079	f	Вакансия Web-программист	RUR	20000	20000	от 20 000 до 100 000 руб.	100000	20000	1606253	ООО МЭЛМАРТ	Санкт-Петербург	false	1–3 года	2 февраля	((:P)\n ((:P)\n  "Нам нужны Web-разработчики, способные решать сложные задачи. Вам предстоит работать в активно развивающемся highload-проекте, в команде опытных специалистов. Основной язык - PHP в связке с MySQL. Везде Linux.")\n ("br" NIL) ((:P) ((:B) "Профессиональные требования:"))\n ((:UL)\n  ((:LI)\n   "По PHP требуются знания особенностей последних версий языка, опыт работы хотя бы с одним известным фреймворком (Zend, Symfony, Yii...)")\n  ((:LI)\n   "Нужны хорошие знания MySQL. Вы должны уметь составлять сложные запросы и понимать, где их можно оптимизировать")\n  ((:LI) "Пригодятся знания любой популярной NoSQL СУБД")\n  ((:LI)\n   "Нужно иметь представление о современной верстке, умение работать с Bootstrap и шаблонизаторами (Smarty, Twig)")\n  ((:LI)\n   "Хотелось бы видеть понимание основ JavaScript, хотя бы в виде jQuery")\n  ((:LI)\n   "Большим плюсом будет опыт работы в Highload проектах (в рекламных сетях, например)")\n  ((:LI)\n   "Также плюсом будет знание других языков программирования (Perl, Python, Go, JS(Node.js), C++), особенно Go")\n  ((:LI)\n   "Работа в команде, поэтому претендент на вакансию должен быть спокойным и неконфликтным")\n  ((:LI)\n   "Высшее образование и опыт работы в фирмах не требуется, нужен личный опыт и знания."))\n ("br" NIL) ((:P) ((:B) "Обязанности: "))\n ((:UL)\n  ((:LI) "Создание и развитие серверных модулей для работы со статистикой")\n  ((:LI) "Развитие ядра системы показа рекламы (highload)")\n  ((:LI) "Проведение интеграций с партнерскими системами"))\n ("br" NIL) ((:P) ((:B) "Условия:"))\n ((:UL) ((:LI) "Работа только в офисе")\n  ((:LI) "График: понедельник - пятница с 10:00 до 19:00 (1 час обед)")\n  ((:LI) "Офис класса А. Бесплатный автобус от метро пл. Ленина")\n  ((:LI)\n   "Рядом с БЦ 2 кафе (оплачиваемое питание после исп. срока), парковка авто (платная) и мото/вело (бесплатно)")\n  ((:LI) "В офисе чай, кофе, печеньки")\n  ((:LI) "Стабильная белая заработная плата") ((:LI) "Официальное оформление")\n  ((:LI) "Испытательный срок (2-3 мес.)")\n  ((:LI)\n   "Для успешных работников есть хорошие перспективы карьерного и зарплатного роста")\n  ((:LI) "Заработная плата от 20 до 100 на руки в зависимости от опыта")))	Скорректировать зп и отправить еще раз	Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:RESPONDED	\N
13	12615295	f	UX проектировщик	RUR	60000	60000	от 60 000 до 90 000 руб.	90000	60000	633069	ООО Селектел	false	Московские ворота	1–3 года	2 февраля	((:P)\n ((:P)\n  "Компания Селектел в связи с активным развитием приглашает UX-дизайнера, который сможет понять, как работают наши сервисы и сделает их удобными и понятными.")\n ("br" NIL) ((:P) ((:B) "Чем Вы будете заниматься на этой должности?"))\n ((:UL)\n  ((:LI)\n   "Разработкой механики интерфейса панели управления и сайтов компании;")\n  ((:LI)\n   "Выработкой концепции, проектированием форм взаимодействия, информационного наполнения, представления информации;")\n  ((:LI) "Экспертной оценкой и улучшением существующих интерфейсов;")\n  ((:LI) "Проработкой сценариев использования;")\n  ((:LI)\n   "Продумыванием и описанием взаимодействия пользователя с интерфейсами;")\n  ((:LI)\n   "Работой в тесной связке с разработчиками, созданием спецификаций для дизайнеров и программистов;")\n  ((:LI) "Контролем качества реализации интерфейсов разработчиками."))\n ("br" NIL)\n ((:P) ((:B) "Мы с радостью обсудим возможное сотрудничество, если:"))\n ((:UL) ((:LI) "Вы пришлете ссылку на портфолио, которым вы гордитесь;")\n  ((:LI)\n   "У Вас есть опыт проектирования интерфейсов (UI Design), создания дизайнов, скетчей, доведения их до совершенства;")\n  ((:LI)\n   "Вы знаете основы юзабилити, есть опыт проектирования удобных и качественных веб-интерфейсов;")\n  ((:LI) "Владеете инструментами UX-разработки и информационной архитектуры;")\n  ((:LI)\n   "Умеете быстро прототипировать и рисовать мокапы, умеете создавать интерактивные прототипы;")\n  ((:LI) "Знаете основы HTML, веб-технологий;")\n  ((:LI)\n   "Вам действительно интересно этим заниматься и есть желание создавать удобный продукт;")\n  ((:LI) "Вы быстро вникаете в детали, постоянно учитесь новому;")\n  ((:LI)\n   "Вы коммуникабельны, можете выстроить эффективные отношения с программистами и дизайнерами, можете аргументированно доносить и отстаивать свою точку зрения, ясно излагать мысли."))\n ("br" NIL) ((:P) ((:B) "Мы готовы Вам предложить:"))\n ((:UL)\n  ((:LI)\n   "Коллектив, в котором каждый получает удовольствие от того, чем он занимается (ожидаем, что и Вы будете таким же :));")\n  ((:LI) "Оформление по ТК РФ, полностью белую заработную плату;")\n  ((:LI) "Бесплатные обеды + чай, кофе, соки, конфеты, фрукты в офисе;")\n  ((:LI) "Полис ДМС (включая стоматологию);")\n  ((:LI) "Бесплатное обучение английскому языку;")\n  ((:LI) "50% оплаты занятий спортом;") ((:LI) "Надбавку за некурение;")\n  ((:LI)\n   "График работы гибкий: 5-дневная рабочая неделя, обязательные часы присутствия всех сотрудников в офисе с 12.00-17.00, остальные 4 часа в день на усмотрение каждого;")\n  ((:LI) "Место работы: м. Московские ворота; своя авто- и велопарковка.")))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:UNINTERESTING	\N
37	12619578	f	Ведущий инженер - программист	RUR	90000	90000	от 90 000 руб.	90000	90000	197216	ООО Росохрана Телеком	false	Чкаловская	3–6 лет	27 января	((:P)\n ((:P)\n  "В связи с развитием проектов в Компании, мы приглашаем в свою команду ведущего программиста.")\n ((:P) ((:B) "Что мы ждем от кандидата") ":")\n ((:UL) ((:LI) "Знание языков программирования C/C++/C#;")\n  ((:LI) "Глубокое понимание механизмов TCP/IP;")\n  ((:LI) "Умение разрабатывать техническую документацию;")\n  ((:LI)\n   "Опыт разработки высоко нагруженных сетевых приложений с большим количеством одновременных соединений;")\n  ((:LI) "Опыт разработки приложений для работы с СУБД (MSSQl и MySQL);")\n  ((:LI) "Опыт разработки ПО от 5 лет;")\n  ((:LI) "Умение читать техническую документацию на английском языке;"))\n ((:P)\n  "Большим преимуществом будет Ваше понимание принципов работы охранного оборудования и пультов централизованного наблюдения.")\n ((:P) ((:B) "Какие задачи необходимо решить:"))\n ((:UL)\n  ((:LI)\n   "Разработка программных адаптеров для подключения охранных устройств к пульту централизованного наблюдения;")\n  ((:LI)\n   "Разработка модулей преобразования протоколов для интеграции стороннего ПО с пультом централизованного наблюдения;")\n  ((:LI)\n   "Сбор требований, подготовка функциональной и технической спецификаций;")\n  ((:LI) "Разработка приложений под Windows на С/С++, С#;")\n  ((:LI) "Анализ и исправление ошибок;")\n  ((:LI) "Разработка юнит- и автотестеров, нагрузочное тестирование;")\n  ((:LI) "Внедрение и сопровождение разработанного ПО."))\n ((:P) ("br" NIL) ((:B) "Что мы предлагаем:"))\n ((:UL) ((:LI) "Интересных задачи и новые проекты.")\n  ((:LI) "Работу в стабильно развивающейся Компании.")\n  ((:LI)\n   "Достойную заработную плату: от 90 т.р. ( по результатам собеседования).")\n  ((:LI) "Удобный офис не далеко от ст.м. Чкаловская.")\n  ((:LI) "Своя уютная кухня, где всегда есть горячий чай и вкусный кофе.")\n  ((:LI) "ДМС после испытательного срока.")\n  ((:LI)\n   "График работы: с понедельника по четверг с 09.00 до 18.00, в пятницу с 09.00 до 17.00.")\n  ((:LI) "А также насыщенную корпоративную жизнь.")))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:UNINTERESTING	\N
66	12581085	f	Senior Backend Developer	USD	2500	2500	от 2 500 до 3 500 USD	3500	2500	850334	ООО ОнТаргет ЛАБС	Санкт-Петербург	false	3–6 лет	3 февраля	((:P)\n ((:P)\n  "OnTarget Labs, a leading outsourcing company in Russia, is looking for a Senior Backend Developer to join the company on a full-time position. We offer interesting projects for U.S. customers, work in a young friendly team and opportunities for professional growth for employees targeted on success!")\n ((:P) ((:B) "Project Description:"))\n ((:UL)\n  ((:LI)\n   "Our client is writing a new version of their web-based e-Learning system. This is a complex, ambitious project which includes a symbiosis of technologies such as: JavaScript, SQL, Grails, Groovy, HTML5, jQuery, CSS, Java SE/EE. First version of the product is commercially successful and is in production since 2010, setting new dimensions and concepts for e-Learning systems."))\n ((:P) ((:B) "Responsibilities:"))\n ((:UL) ((:LI) "New code development;")\n  ((:LI) "Planning and estimation of development efforts;")\n  ((:LI) "Legacy code analysis and optimization;")\n  ((:LI) "Providing technical consulting to other team members;")\n  ((:LI) "Participation to daily scrums within the distributed team."))\n ((:P) ((:B) "Requirements:"))\n ((:UL) ((:LI) "4+ years of programming experience;")\n  ((:LI) "Strong knowledge of Grails/Groovy, Java SE/EE;")\n  ((:LI) "Familiar with: JavaScript, jQuery, CSS, HTML5;")\n  ((:LI)\n   "Experience in creating architecture of the backend applications and server APIs;")\n  ((:LI) "Knowledge of the modern backend technologies;")\n  ((:LI) "Experience in building XML/JSON services would be a plus;")\n  ((:LI) "Good knowledge of SQL and MongoDB would be a plus;")\n  ((:LI)\n   "Good English (both oral and written skills), able to communicate clearly and effectively with customer directly;")\n  ((:LI) "Be a good team player in local/distributed team;")\n  ((:LI) "Basic understanding of Agile/Sprint cycle;"))\n ((:P) ((:B) "We offer:"))\n ((:UL)\n  ((:LI)\n   "Competitive salary ($3 000 - $3 600 to be defined upon the interview results);")\n  ((:LI) "Flexible working hours;") ((:LI) "Compliance with the Labor Code;")\n  ((:LI)\n   "Medical insurance (after successful completion of the trial period);")\n  ((:LI)\n   "Office located in the city center, close to metro station \\"Ligovskiy prospekt\\" and \\"Obvodniy kanal\\";")\n  ((:LI)\n   "Support with relocation from other regions and foreign countries (e.g Ukraine, Belorussia);")\n  ((:LI) "English language classes to further develop your spoken English;")\n  ((:LI) "Occasional business trips to US are possible.")))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:UNINTERESTING	
11	12537625	f	Windows Phone / Windows 8 Developer	RUR	80000	80000	от 80 000 до 110 000 руб.	110000	80000	955257	 SPB TV	false	Старая Деревня	более 6 лет	2 февраля	((:P)\n ((:P)\n  "SPB TV, лидер мирового уровня по разработке ТВ-решений, приглашает к сотрудничеству С# разработчиков. Мы занимаемся созданием решений в области OTT-ТВ, и у нашего собственного сервиса SPB TV уже более 25 миллионов пользователей по всему миру. Работая программистом в SPB TV, вы будете видеть результат своей работы на устройствах ваших друзей и родных.")\n ((:P) ((:B) "Обязанности: "))\n ((:UL)\n  ((:LI)\n   "Участие в проектах по разработке мобильных приложений под Windows Phone, Windows 8 на всех стадиях (от идеи до конечной реализации)."))\n ((:P) ((:B) "Требования:"))\n ((:UL)\n  ((:LI)\n   "Общее умение хорошо программировать нам важнее, чем знание конкретной технологии (конкретным технологиям мы научим, все равно они меняются каждые несколько лет). В разработчиках нам важно умение работать самостоятельно, желание самому понимать требования пользователей, навыки хорошей архитектуры кода и умение доводить дело до конца. Нас не интересует ваше образование и диплом — только способности и знания.")\n  ((:LI)\n   "Знания и опыт разработки на C#, XAML и использования платформы .NET;")\n  ((:LI) "Git или mercurial (мы используем git);")\n  ((:LI) "Знания и опыт разработки на Silverlight;")\n  ((:LI) "Знания и опыт разработки на Windows Phone;")\n  ((:LI)\n   "Без знания английского языка на уровне «умею писать» Вам будет проблематично общаться с коллегами и партнерами во всем мире."))\n ((:P) ((:B) "Преимуществами являются:"))\n ((:UL) ((:LI) "Навыки тестирования кода;")\n  ((:LI) "Знания и опыт разработки на других мобильных платформах;")\n  ((:LI) "Знания и опыт разработки HTML, CSS, JavaScript."))\n ((:P) ("br" NIL) ((:B) "Условия: "))\n ((:UL) ((:LI) "Комфортный офис в 2 минутах от метро Старая Деревня.")\n  ((:LI)\n   "Социальный пакет (ДМС со стоматологией, бесплатные фрукты, закуски, пицца, кофе в офисе, полная оплата при покупке книг на Amazon для работы, оплата 50% при покупке смартфонов, оплата 50% спорта).")\n  ((:LI)\n   "Полный рабочий день в офисе (40 часов в неделю, начало в 11:00 (можно приходить раньше :), оформление по трудовому договору, полностью «белая» зарплата).")\n  ((:LI) "Содействие в переезде для иногородних.")))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:INTERESTING	\N
21	12687839	f	Project Manager (в г.Пенза)	RUR	90000	90000	от 90 000 руб.	90000	90000	1212374	 iFunny	Санкт-Петербург	false	1–3 года	30 января	((:P)\n ((:P)\n  "Каждый день благодаря iFunny в мире становится на 30 000 000+ улыбок больше. За 3 года наш продукт превратился из крошечного app'а в одну из лидирующих соцмедиа в США.")\n ((:P)\n  "Вместе с масштабом наших успехов растет и масштаб проектов по развитию и продвижению iFunny. Мы приглашаем присоединиться к нам человека, который возьмет на себя часть операций в борьбе за мир.")\n ((:P)\n  "Вам предстоит превращать идеи в реальность, координируя работу наших dev- & design- & marketing- микрокоманд.")\n ("br" NIL) ((:P) ((:B) "Мы подойдем друг другу, если Вы") ":")\n ((:UL) ((:LI) "Имеете опыт работы в управлении;")\n  ((:LI) "Знакомы с гибкими методологиями разработки (Agile);")\n  ((:LI)\n   "Имеете технический background и умеете общаться с разработчиками на их языке;")\n  ((:LI)\n   "Ясно и грамотно излагаете свои мысли не только устно, но и письменно;")\n  ((:LI)\n   "Достигаете поставленных целей в оговоренные сроки, не прибегая к помощи дедлайнов")\n  ((:LI) "Готовы к переезду в Пензу"))\n ("br" NIL) ((:P) ((:B) "Возможно, вас заинтересует") ":")\n ((:UL) ((:LI) "Труд и развитие в опытной команде;")\n  ((:LI)\n   "Все основные \\"преимущества\\", которые обычно указываются в описании вакансии (комфортный офис в самом центре, оплата участия в зарубежных конференциях, заграничные party, комната отдыха, занятия английским в офисе, ТК и т.д.);")\n  ((:LI) "Оплата труда: от 90 000 руб.")))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:UNINTERESTING	\N
58	10655880	f	Программист php. WEB / разработчик Highload Project.	RUR	50000	50000	от 50 000 до 120 000 руб.	120000	50000	8916	ООО НИНСИС	false	Электросила	3–6 лет	29 декабря	((:P)\n ((:P)\n  ((:B) "Ищем в небольшой дружный коллектив хорошего WEB разработчика."\n   ("br" NIL) "Живые интересные проекты, профессиональный рост."))\n "   " ((:P) ((:B) "Требования:"))\n ((:UL) ((:LI) "Образование :   Высшее")\n  ((:LI) "Желание и умение создавать полезные проекты.")\n  ((:LI) "Опыт программирования реально работающих проектов от 3 лет.")\n  ((:LI) "Уверенное знание HTML, CSS, JavaScript, ActionScript, XML .")\n  ((:LI) "Опыт практического использования MySQL, хорошее знание языка SQL.")\n  ((:LI) "Опыт работы в команде разработчиков.")\n  ((:LI) "Опыт оптимизации кода и запросов по производительности.")\n  ((:LI) "Опыт работы с высоконагруженными проектами.")\n  ((:LI) "Умение разбираться и находить ошибки в чужом коде."))\n "   " ((:P) ((:B) "Приветствуется:"))\n ((:UL) ((:LI) "sphinx, memcached;")\n  ((:LI) "Понимание основ администрирования;")\n  ((:LI) "Опыт работы с системами контроля версий;")\n  ((:LI) "Опыт разработки структур баз данных;")\n  ((:LI) "Опыт работы с технологиями AJAX;") ((:LI) "Понимание Usability;")\n  ((:LI) "Участие в составлении технических заданий."))\n "   " ((:P) ((:B) "Должностные обязанности:"))\n ((:UL)\n  ((:LI)\n   "Работа в команде по развитию и поддержке высоконагруженного проекта;")\n  ((:LI) "120 тыс. посетителей и 3 млн. хитов в день;")\n  ((:LI) "Участие в разработке других интернет проектов;")\n  ((:LI) "Язык разработки – php;") ((:LI) "База данных - MySQL, Sphinx;")\n  ((:LI) "Клиентская  часть - JavaScript, AJAX;"))\n "   " ((:P) ((:B) "Условия:"))\n ((:UL) ((:LI) "Уровень дохода от 50 т.р. до 100 т.р. (дополнительно премии)")\n  ((:LI) "Работа в офисе, пятидневка с 10-18")\n  ((:LI) "Оформление согласно ТК РФ.") ((:LI) "Медицинская страховка")\n  ((:LI) "М. Электросила")))	Зарплата ниже, перед отправкой скорректировать резюме	Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:INTERESTING	\N
54	12375741	f	Программист-разработчик DSP	RUR	60000	60000	от 60 000 до 90 000 руб.	90000	60000	911016	ООО Мегаполис Консалт	Санкт-Петербург	false	1–3 года	14 января	((:P)\n "В научно-производственное предприятие, г.Санкт-Петербург требуется Программист-разработчик DSP"\n ("br" NIL) ("br" NIL) ((:B) "Обязанности:")\n ((:UL)\n  ((:LI)\n   "Работа с уникальными разработками в области телекоммуникаций, обработки радиосигнала( фильтрация, демодуляция, пространственная обработка)")\n  ((:LI) "Обработка сигналов на DSP")\n  ((:LI) "Разработка и сопровождение проектов по обработке сигналов,")\n  ((:LI)\n   "Участие в испытаниях техники, в сдаче работы заказчику, участие в показах"))\n ("br" NIL) ((:B) "Требования:")\n ((:UL) ((:LI) "Опыт разработки с использованием С/C++ не менее 3ех лет")\n  ((:LI) "Опыт разработки DSP не менее 3ех лет")\n  ((:LI) "Опыт программирования цифровых процессоров обработки сигналов")\n  ((:LI) "Опыт разработки в MATLAB, перенос алгоритмов на С/С++.")\n  ((:LI) "Хорошая математическая подготовка.")\n  ((:LI)\n   "Знание методов цифровой обработки сигналов (фильтрация, спектральный и временной анализ), теории оценивания (фильтр Калмана), теории случайных процессов.")\n  ((:LI) "Технический английский.")\n  ((:LI) "Знание основ информатики, алгоритмов и структур данных"))\n ("br" NIL) "Желательно: "\n ((:UL)\n  ((:LI)\n   "Плюсом будет опыт работы с сигнальными процессорами и понимание систем реального времени")\n  ((:LI) "Знание Board Support Package")\n  ((:LI) "Code Composer Studio (Texas Instruments)")\n  ((:LI) "BORLAND C++ BUILDER, С++ VISUAL STUDIO") ((:LI) "QT")\n  ((:LI) "Опыт разработки для TMS320C64, asm") ((:LI) "Linux"))\n ("br" NIL) ((:B) "Условия:")\n ((:UL) ((:LI) "Трудоустройство по ТК РФ,")\n  ((:LI)\n   "Белая Заработная плата, 60 000- 90 000 руб. (на руки), по результатам собеседования,")\n  ((:LI) "График работы: 5/2,")\n  ((:LI) "Премии и поощрения после успешных работ,")\n  ((:LI) "13-я Заработная плата по итогам года,") ((:LI) "ДМС.")))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:UNINTERESTING	\N
49	12580494	f	Руководитель проекта IT	RUR	100000	100000	от 100 000 руб.	100000	100000	1488079	 Деньги на дом	Санкт-Петербург	false	3–6 лет	16 января	((:P) ((:P) ((:B) "Обязанности") ":")\n ((:UL) ((:LI) "Контроль за работой команды")\n  ((:LI) "Сопровождение и администрирование проектов компании")\n  ((:LI) "Поддержание контента в актуальном виде.") ((:LI) "SEO") ((:LI) "SMM")\n  ((:LI) "Настройка и сопровождение контекстной рекламы.")\n  ((:LI) "Работа с отрицательными отзывами в интернете.")\n  ((:LI) "Сопровождение партнерских программ по лидогенерации.")\n  ((:LI) "Внедрение новых каналов продвижения в сети интернет")\n  ((:LI) "Работа с юзабилити сайта")\n  ((:LI) "Увеличение показателя конверсии сайта")\n  ((:LI) "В перспективе: участие в разработке новых интернет-проектов."))\n ((:P) ("br" NIL) ((:B) "Требования:"))\n ((:UL) ((:LI) "Успешный опыт продвижения сайтов в сети Интернет")\n  ((:LI) "Успешный опыт увеличения продаж")\n  ((:LI)\n   "Использование в работе широкого спектра инструментов по продвижению сайтов")\n  ((:LI)\n   "Приветствуются навыки работы в графических пакетах и навыки работы с HTML-кодом"))\n ("br" NIL) ((:P) ("br" NIL) ((:B) "Условия") ":")\n ((:UL)\n  ((:LI) "Пятидневная рабочая неделя в комфортабельном офисе в центре города")\n  ((:LI) "Оклад + KPI") ((:LI) "Компенсация мобильной связи")))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:RESPONDED	\N
27	12678863	f	Senior Software Developer (IntelliJ IDEA)	RUR	130000	130000	от 130 000 руб.	130000	130000	9281	 JetBrains	Санкт-Петербург	false	3–6 лет	29 января	((:P) ((:P) "Senior Software Developer (IntelliJ IDEA, core team)")\n ((:P)\n  "Основанная в 2000 году, компания JetBrains является мировым лидером в производстве профессиональных инструментов разработки.")\n ((:P)\n  "Наша цель – дать людям возможность работать c удовольствием и более продуктивно за счет использования «умных» программных решений, которые берут на себя рутинные задачи, позволяя сфокусироваться на творческой части работы.")\n ((:P)\n  "Для достижения этой цели нам очень нужны талантливые, творческие, инициативные люди.")\n ((:P)\n  "IntelliJ IDEA появилась на рынке программного обеспечения для Java программистов 10 лет назад. Это была первая среда разработки, реализовавшая автоматический рефакторинг. И по сей день IntelliJ IDEA является двигателем инноваций в сфере средств разработки и повышения продуктивности работы программистов. Это - фактически единственная коммерческая IDE, успешно конкурирующая с немалым количеством бесплатного программного обеспечения в своём сегменте. На данный момент IntelliJ IDEA также включает в себя средства разработки на других языках, таких как Ruby, Groovy, Scala, Python и PHP.")\n ((:P) ((:B) "Вам предстоит:"))\n ((:UL)\n  ((:LI)\n   "вместе с командой развивать поддержку уже известных IDEA языков программирования, а также реализовывать поддержку новых языков"))\n ((:P) ((:B) "Необходимые навыки:"))\n ((:UL)\n  ((:LI)\n   "опыт программирования на Java в коммерческих проектах не менее 3-х лет")\n  ((:LI) "глубокое понимание OOP")\n  ((:LI) "опыт многопоточного программирования")\n  ((:LI) "умение оптимизировать и рефакторить как свой, так и чужой код")\n  ((:LI) "ответственность, самостоятельность, организованность")\n  ((:LI) "умение работать в команде"))\n ((:P) ((:B) "Плюсами будут:"))\n ((:UL)\n  ((:LI)\n   "опыт разработки плагинов на базе платформ IDEA, Eclipse или Netbeans")\n  ((:LI)\n   "знание других языков и других парадигм (Groovy, Haskell, Objective C, Python, Scala, Ruby, etc.)")\n  ((:LI) "знакомство с технологиями создания компиляторов, анализа кода"))\n ("br" NIL) ((:P) ((:B) "Мы предлагаем:"))\n ((:UL) ((:LI) "увлекательную работу в дружном молодом коллективе")\n  ((:LI)\n   "участие в разработке продуктов, нацеленных на таких же, как мы, разработчиков")\n  ((:LI)\n   "высокую заработную плату (обсуждается индивидуально, заведомо выше средней для отрасли)")\n  ((:LI) "премии по итогам релизов") ((:LI) "гибкий график работы")\n  ((:LI) "оформление по Трудовому Кодексу")\n  ((:LI) "оплачиваемый отпуск (5 рабочих недель)")\n  ((:LI) "оплачиваемый больничный")\n  ((:LI) "ДМС (со стоматологией), ДМС для детей")\n  ((:LI) "просторный современный офис (открыт круглосуточно), парковка")\n  ((:LI) "эргономичные рабочие места и уютные зоны отдыха")\n  ((:LI) "горячие обеды, напитки, фрукты, снэки")\n  ((:LI) "нужные для работы книги и журналы, библиотека")\n  ((:LI) "обучение (уроки английского, немецкого языков)")\n  ((:LI) "спортзал в офисе (с душевыми), массажный кабинет, игровая зона")\n  ((:LI) "возможность участия в конференциях в США и Европе")\n  ((:LI) "помощь в переезде из другого региона."))\n ((:UL)))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:UNINTERESTING	\N
23	11884912	f	Руководитель группы SQL/BI	RUR	90000	90000	от 90 000 до 100 000 руб.	100000	90000	707807	 Клик Персонал	Санкт-Петербург	false	3–6 лет	30 января	((:P)\n ((:P) "В компании " ((:B) "ООО «Клик Персонал»")\n  " (предоставляет слуги по выполнению проектов в сфере ИТ) открыта позиция "\n  ((:B) "«Руководитель группы ") ((:B) "SQL") ((:B) "/") ((:B) "BI")\n  ((:B) "»"))\n ((:P)) ((:P) ((:B) "Проекты:"))\n ((:UL)\n  ((:LI)\n   "Развитие и поддержка распределенной системы управления хранилищем данных для телекоммуникационных компаний на базе MS SQL Server. Рабочие экземпляры (production) системы управляют хранением данных порядка 100TB, установлены в 7 странах")\n  ((:LI)\n   "Развитие и поддержка высоконагруженной системы управления фродом (выявление случаев мошенничества), реализация контролей на ее основе для одного из крупнейших операторов связи РФ. Для каждого контроля используется несколько источников данных объемом порядка 1-10TB")\n  ((:LI)\n   "Развитие и поддержка системы формирования витрин на базе MS SQL Server")\n  ((:LI)\n   "Разработка витрин и «тяжелых» ETL-процессов с применением MS SQL Sever (T-SQL, SSAS, SSIS, Informatica Power Centre SAP Business Object)"))\n ((:P)) ((:P) ((:B) "Основные задачи:"))\n ((:UL) ((:LI) "Управление проектами по разработке информационных систем")\n  ((:LI) "Формирование команды проекта, контроль, организация взаимодействия")\n  ((:LI)\n   "Развитие компетенций команды, вовлечение команды в производственную работу")\n  ((:LI)\n   "Управление проектами BI (инструменты: MS SQL Server, MS SharePoint, SAP Business Object, Informatica Power Center)")\n  ((:LI)\n   "Выявление потребностей заказчика, формулирование задач, согласование")\n  ((:LI)\n   "Контроль бюджета проекта, сроков, качества исполнения, оценка затрат"))\n ((:P)) ((:P) ((:B) "Требования:"))\n ((:UL) ((:LI) "Высшее техническое образование")\n  ((:LI)\n   "Опыт работы техническим менеджером проектов (желательно софтверная компания) от 2-х лет")\n  ((:LI) "Опыт разработки программного обеспечения")\n  ((:LI) "Опыт разработки под MS SQL или Oracle")\n  ((:LI) "Знание и опыт в применении современных методологий разработки")\n  ((:LI)\n   "Знание технологий и языка программирования: MS SQL Server или Oracle, .NET, C# или Java, любое известное средство ETL")\n  ((:LI)\n   "Желателен опыт разработки или управления проектами под: MS SharePoint, SAP Buisness Object, Informatica Power Center")\n  ((:LI) "Опыт управление проектами от 5-ти человек")\n  ((:LI) "Отличные управленческие навыки") ((:LI) "Клиентоориентированность")\n  ((:LI) "Умение брать на себя ответственность и умение принимать решения")\n  ((:LI)\n   "Умение работать большим объемом информации и управлять проектами изменений высоко нагруженных систем в режиме 24/7")\n  ((:LI)\n   "Умение подбирать, мотивировать сотрудников, выстраивать и реализовывать планы развития компетенций подразделения на длительном промежутке времени")\n  ((:LI) "Опыт удаленной работы"))\n ((:P)) ((:P) ((:B) "Условия:"))\n ((:UL) ((:LI) "Удаленная работа на полный день (с 09:00 до 18:00 по МСК)")\n  ((:LI) "График 5/2")\n  ((:LI) "Оплачиваемый отпуск, праздничные дни, компенсация больничных")\n  ((:LI)\n   "Зарплата: от 90 000 до 100 000 (по результатам собеседования), бонусы за проект")\n  ((:LI) "Профессиональный и материальный рост")\n  ((:LI) "Компания является партнером компании Microsoft")))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:UNINTERESTING	\N
24	11340699	f	Ведущий разработчик SQL	RUR	70000	70000	от 70 000 до 90 000 руб.	90000	70000	707807	 Клик Персонал	Санкт-Петербург	false	3–6 лет	30 января	((:P)\n ((:P) "В компании " ((:B) "ООО «Клик Персонал»")\n  " (предоставляет слуги по выполнению проектов в сфере ИТ) в связи с расширением открыта новая позиция "\n  ((:B) "«Ведущий разработчик БД ") ((:B) "MS") ((:B) "SQL") ((:B) "Server")\n  ((:B) ", ") ((:B) "T") ((:B) "-") ((:B) "SQL") ((:B) "»"))\n "   "\n ((:P)\n  "Нам нужен разработчик-эксперт, который сможет самостоятельно решать сложные задачи, наставлять других программистов")\n "   " ((:P) ((:B) "Проекты:"))\n ((:UL)\n  ((:LI)\n   "Развитие и поддержка распределенной системы управления хранилищем данных для телекоммуникационных компаний на базе MS SQL Server. Рабочие экземпляры (production) системы управляют хранением данных порядка 100TB, установлены в 7 странах")\n  ((:LI)\n   "Развитие и поддержка высоконагруженной системы управления фродом (выявление случаев мошенничества), реализация контролей на ее основе для одного из крупнейших операторов связи РФ. Для каждого контроля используется несколько источников данных объемом порядка 1-10TB")\n  ((:LI)\n   "Развитие и поддержка системы формирования витрин на базе MS SQL Server")\n  ((:LI) "Разработка витрин с применением MS SQL Sever (T-SQL, SSAS, SSIS)"))\n "   "\n ((:P)\n  "Мы используем высокопроизводительное оборудование (24-40 core / 240+GB RAM)")\n "   " ((:P) ((:B) "Основные задачи:"))\n ((:UL) ((:LI) "Разработка БД MS SQL Server и запросов с использованием T-SQL")\n  ((:LI)\n   "Документирование компонентов/модулей систем, подготовка спецификаций программных решений"))\n "   " ((:P) ((:B) "Требования:"))\n ((:UL)\n  ((:LI)\n   "Фундаментальное знание реляционной модели данных и реляционной алгебры")\n  ((:LI) "Опыт разработки БД MS SQL Server с использованием T-SQL от 5-ти лет")\n  ((:LI)\n   "Уверенный навык оптимизации общей производительности БД и отдельных ее частей, умение находить решения в случае возникновения блокировок")\n  ((:LI)\n   "Разработка простого и понятного другим исходного кода, использование комментариев")\n  ((:LI)\n   "Наличие быстрого и стабильного интернет-канала для общения по Skype, работы с удаленным сервером")\n  ((:LI) "Высшее техническое образование")\n  ((:LI) "Английский язык на уровне чтения технической документации"))\n "   " ((:P) ((:B) "Приветствуется:"))\n ((:UL) ((:LI) "Опыт работы с гетерогенными источниками данных")\n  ((:LI) "Опыт работы с объемом данных от 1TB")\n  ((:LI) "Опыт применения TDD и юнит-тестирования")\n  ((:LI) "Опыт работы с SSIS, SSAS, SSRS")\n  ((:LI) "Опыт разработки БД Oracle, знание PL/SQL")\n  ((:LI) "Сертификаты (Microsoft, Oracle, др.)"))\n "   " ((:P) ((:B) "Условия:"))\n ((:UL) ((:LI) "Удаленная работа на полный день (с 09:00 до 18:00 по МСК)")\n  ((:LI) "График 5/2")\n  ((:LI) "Оплачиваемый отпуск, праздничные дни, компенсация больничных")\n  ((:LI)\n   "Зарплата: от 70 000 до 90 000 (по результатам собеседования), проектные бонусы до 20% к окладу")\n  ((:LI) "Профессиональный и материальный рост")\n  ((:LI) "Компания является партнером компании Microsoft")))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:UNINTERESTING	\N
26	12679029	f	PHP Developer (г. Пенза)	RUR	90000	90000	от 90 000 руб.	90000	90000	1212374	 iFunny	Санкт-Петербург	false	1–3 года	29 января	((:P)\n ((:P)\n  "Ежедневно наши мобильные приложения генерируют более 300 миллионов запросов к API iFunny. Для обеспечения стабильной работы нашего сервиса под все возрастающими нагрузками мы используем популярный стек технологий, включающий в себя HaProxy, Nginx, PHP, MongoDB, Redis, работающий на нескольких десятках серверов.")\n ((:P)\n  "В процессе развития проекта мы постоянно пересматриваем архитектуру и рефакторим код. Нередки моменты, когда мы общаемся напрямую с разработчиками популярных OpenSource-продуктов и сообщаем о найденных под нагрузкой проблемах, получая взамен горячие решения, которые впоследствии входят в релизы этих продуктов.")\n ((:P)\n  "Мы приглашаем присоединиться к нам человека, разделяющего нашу любовь к HighLoad, со склонностью к перфекционизму и стремлением сделать сразу и хорошо. Готового следовать принципам, которых мы придерживаемся при разработке серверной части: простота, быстродействие, масштабируемость.")\n ((:P) ((:B) "Мы подойдем друг другу, если Вы") ":")\n ((:UL)\n  ((:LI)\n   "Трудитесь в сфере разработки ПО не менее пяти лет и так или иначе пользовались большинством популярных веб-технологий;")\n  ((:LI)\n   "Не являетесь принципиальным приверженцем какого-либо языка и при необходимости можете что-нибудь забабахать на Python или Ruby;")\n  ((:LI)\n   "Понимаете принципы построения высоконагруженных систем и всегда видите возможности для оптимизации;")\n  ((:LI)\n   "Готовы конструктивно отстаивать выдвигаемые архитектурные решения, руководствуясь здравым смыслом, а не модными тенденциями;")\n  ((:LI)\n   "Имеете профиль на GitHub, следите за обновлениями популярных библиотек и иногда контрибьютите в OpenSource-проекты;")\n  ((:LI)\n   "Не деплоите в пятницу... Но если всё-таки деплоите, то не возникает необходимости стирать штаны.")\n  ((:LI) "Готовы к переезду в Пензу"))\n ((:P) ((:B) "Возможно, вас заинтересует") ":")\n ((:UL) ((:LI) "Труд и развитие в опытной команде;")\n  ((:LI)\n   "Все основные \\"преимущества\\", которые обычно указываются в описании вакансии (комфортный офис в самом центре, оплата участия в зарубежных конференциях, заграничные party, комната отдыха, занятия английским в офисе, ТК и т.д.);")\n  ((:LI) "Оплата труда: от 90 000 руб.")))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:UNINTERESTING	\N
72	12608144	f	Software Engineer	USD	1800	1800	от 1 800 до 3 500 USD	3500	1800	1575916	ООО Рашэн Аутсорсинг	Санкт-Петербург	false	1–3 года	21 января	((:P) ((:P) ((:B) "Project Description:"))\n ((:UL)\n  ((:LI)\n   "Building site like Digital Store for Cisco’s training and certification videos, presentations, books and training materials. CISCO customers and partners will purchase training and CISCO certification courses and receive access to Website with CISCO’c content for self training. Customers will be able to pay for this content online and also to take CISCO certification tests online. Partners will be able to customize training materials and deliver customized training for CISCO products to their customers.")\n  ((:LI)\n   "Basically CISCO is creating Digital Store like Amazon and build applications on different platforms to view this content (documents, movies, etc.) – the platforms are Browsers, Windows applications, Android, iPad/iPhone, etc."))\n ("br" NIL) ("br" NIL) ((:P) ((:B) "Requirements:"))\n ((:UL)\n  ((:LI)\n   "Hence we're searching for 15 developers with software skills in different areas - Java, Android, ipad, and Windows native applications.")\n  ((:LI)\n   "Please fill free to send your CVs for our consideration and we'll contact you in closest time.")\n  ((:LI) "Spoken English is a must."))\n ("br" NIL) ((:P) "Please send your CV in ENGLISH."))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:UNINTERESTING	
67	12616870	f	Implementation engineer	USD	3000	3000	от 3 000 до 3 000 USD	3000	3000	79595	 Paladyne Systems	false	Чкаловская	3–6 лет	3 февраля	((:P)\n ((:P)\n  "Being the part of the Implementation team you would get the experience in implementing and customizing the software for the different types of financial organizations. This requires both very deep technical skills and business side understanding in one of the most complex areas. Implementation process usually implies the customization which can be the VB/C#/SQL/ XML/xpath/powershell scripts writing, SSRS reports, and also it’s the requirements specifications discussions to understand the business side part.")\n ((:P) ((:B) "Requirements:"))\n ((:UL)\n  ((:LI)\n   "1+ years experience with complex software products implementation or development (product companies preferably)")\n  ((:LI) "Fluent spoken and written English")\n  ((:LI)\n   "Strong technical background (C#, VB, XML,PS,SQL Server and Transact SQL skills)"))\n ((:P) ((:B) "The following knowledge and skills will be a plus:"))\n ((:UL) ((:LI) "Financial industry knowledge")\n  ((:LI) "Release management knowledge")\n  ((:LI)\n   "Other key attributes include to be self-motivated, an ability to take responsibility and be prepared to learn fast"))\n ((:P) ((:B) "Proposal:"))\n ((:UL)\n  ((:LI)\n   "Competitive salary, will be discussed with the successful candidates")\n  ((:LI) "End-of-year bonus program") ((:LI) "Medical insurance")\n  ((:LI) "English, technical and financial trainings")\n  ((:LI) "Official salary and employment contract")))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:UNINTERESTING	
30	12673969	f	Руководитель IT-направления в СМИ	RUR	120000	120000	от 120 000 руб.	120000	120000	43249	ООО АЛЕКСАНДР-Недвижимость	false	Площадь Ленина	3–6 лет	29 января	((:P) ((:P) ((:B) "Обязанности:"))\n ((:UL)\n  ((:LI)\n   "Определяет стратегию развития IT- направления проекта, цели, задачи и результат проекта как коммерческого продукта.")\n  ((:LI)\n   "Продумывает и составляет план развития и внедрения сервисов проекта, определяет контрольные точки.")\n  ((:LI) "Определяет структуру проекта и его сервисов.")\n  ((:LI)\n   "Определяет состав работ, необходимых для проработки и создания сервисов проекта.")\n  ((:LI)\n   "Выступает постановщиком задач IT-разработчикам, определяя сроки и приоритеты в порядке создания IT-сервисов путем планирования.")\n  ((:LI)\n   "Обеспечивает контроль выполнения поставленных задач в сроки предусмотренные планом разработки и внедрения.")\n  ((:LI)\n   "Определяет количество и оценивает стоимость ресурсов, требуемых для выполнения работ проекта")\n  ((:LI)\n   "Оценивает стоимость и определяет бюджет развития IT-направления проекта.")\n  ((:LI) "Выбирает команду проекта.")\n  ((:LI)\n   "Определяет профессиональные навыки, необходимые участникам команды проекта.")\n  ((:LI) "Прописывает цепочку взаимосвязей между участниками команды проекта.")\n  ((:LI) "Продумывает систему мотивации команды проекта.")\n  ((:LI) "Организует собрания команды проекта.")\n  ((:LI) "Принимает участие в разработке детального бизнес-плана.")\n  ((:LI)\n   "Контролирует подготовку необходимой документации для внедрения проекта.")\n  ((:LI)\n   "Обеспечивает своевременные сбор, накопление, распространение, хранение и последующее использование информации проекта.")\n  ((:LI)\n   "Координирует предоставление нужной информации в обусловленные сроки всем участникам проекта.")\n  ((:LI)\n   "Контролирует и отслеживает мероприятия по проработке и внедрению и при необходимости корректирует данные процессы.")\n  ((:LI) "Контролирует соблюдение сроков процессов проработки и внедрения.")\n  ((:LI) "Контролирует изменения бюджета проекта.")\n  ((:LI)\n   "Отслеживает отклонения от плана, вносит корректировки в план и согласует его со всеми участниками проекта.")\n  ((:LI)\n   "Анализирует возможное влияние отклонений в выполненных объемах работ на ход реализации проекта в целом."))\n ("br" NIL) ((:P) ((:B) "Требования:"))\n ((:UL) ((:LI) "Образование – высшее (в области IT-технологий).")\n  ((:LI)\n   "Личный опыт руководства по созданию сайтов, Интернет-приложений, баз данных (языки программирования ASP, PHP или аналогичные) не менее двух лет.")\n  ((:LI)\n   "Опыт руководства коллективами разработчиков (программистов) не менее трех лет.")\n  ((:LI)\n   "В послужном списке должно быть не менее 2-х успешно реализованных IT-проектов.")\n  ((:LI)\n   "Опыт анализа и описания бизнес-процессов различных предприятий, постановка задач по автоматизации данных бизнес-процессов, написание ТЗ и контроль его последующей реализации."))\n ((:P) ("br" NIL) ((:B) "Условия:"))\n ((:UL)\n  ((:LI)\n   "Работа в стабильной компании‚ в современном комфортном офисе‚ расположенном в 2 минутах от станции метро «Площадь Ленина-2»‚ ул. Боткинская.")))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:INTERESTING	\N
36	12653131	f	PHP-разработчик	RUR	35000	35000	от 35 000 до 100 000 руб.	100000	35000	1536449	ООО 4xxi	false	Площадь Мужества	1–3 года	27 января	((:P) ((:P) ((:B) " ")) ("br" NIL)\n ((:P)\n  "В компанию требуется PHP-разработчик для поддержки существующих проектов и разработки новых.")\n ("br" NIL) ((:P) ((:B) "Наши требования к кандидатам:"))\n ((:UL) ((:LI) "Хорошее знание PHP5.3+.")\n  ((:LI) "ООП на уровне хорошего понимания стандартных паттернов.")\n  ((:LI) "Опыт работы с Symfony2 будет являться " ((:B) "существенным")\n   " преимуществом.")\n  ((:LI) "Знание SQL (MySQL / PostgreSQL).")\n  ((:LI) "Использование систем контроля версий (GIT и подобное).")\n  ((:LI) "Базовые знания JS (jQuery), HTML, CSS.")\n  ((:LI) "Умение настраивать рабочую среду.")\n  ((:LI) "Английский на уровне чтения технической документации.")\n  ((:LI) "Гражданство России."))\n ("br" NIL) ((:P) ((:B) "Преимуществом будет:"))\n ((:UL)\n  ((:LI)\n   "Опыт работы с highload (кэширование в redis / memcached, оптимизация, репликация, шардинг).")\n  ((:LI) "Умение работать с нереляционными базами данных (mongodb).")\n  ((:LI) "Опыт работы с git-flow.")\n  ((:LI) "Опыт работы и проектирования RESTful протоколов.")\n  ((:LI)\n   "Умение автоматизировать рутинные процессы (capistrano, phing и др.).")\n  ((:LI)\n   "Знание и умение применять автоматическое тестирование (phpunit, behat + mink, phpspec)."))\n ("br" NIL) ((:P) ((:B) "Мы предлагаем:"))\n ((:UL)\n  ((:LI)\n   "Оплату в зависимости от вашей квалификации (от 35000 руб. до 100000 руб.). Мы готовы обучить и научить при сильной мотивации соискателя.")\n  ((:LI) "Работу только над интересными проектами.")\n  ((:LI) "Возможность проявить себя и быстро увидеть результат.")\n  ((:LI)\n   "Работа в офисе, полный рабочий день с 10:00 – 19:00 по Москве, возможен гибкий график работы. Удалённые сотрудники рассматриваются "\n   ((:B) "только при полном соответствии требованиям вакансии") ".")\n  ((:LI) "Карьерный и профессиональный рост.")\n  ((:LI)\n   "Постоянное повышение заработной платы при улучшении качества кода и увеличении самостоятельности, профессиональный рост."))\n ((:P) ((:B) "!!")) ((:P) ((:B) "Тестовое задание:"))\n ((:UL)\n  ((:LI) "Реализовать с использованием Symfony следующий функционал: "\n   ("ul" NIL\n    ("li" NIL\n     "Пользователь заходит на страницу. Видна кнопка входа через Facebook и форма для ввода логина-пароля.")\n    ("li" NIL "Пользователь логинится через Facebook / по логину-паролю.")\n    ("li" NIL\n     "На странице показывается список друзей и общий список комментариев (а-ля общий чат к сервису. Писать могут все залогиненные).")\n    ("li" NIL\n     "Имеются сверху кнопки: \\"Изменить профиль\\", \\"Написать комментарий\\" и \\"Выйти\\".")\n    ("li" NIL\n     "Перейдя по кнопке \\"Изменить профиль\\" пользователь может изменить фамилию и имя в приложении (на отдельной странице).")\n    ("li" NIL\n     "Нажав на кнопку \\"Написать комментарий\\" открывается форма для ввода комментария")\n    ("li" NIL\n     "Должна быть возможность отредактировать свой комментарий без перезагрузки страницы."))))\n ((:P) ((:B) "Комментарии к тестовому заданию:"))\n ((:UL) ((:LI) "Приложение должно быть аккуратно оформлено.")\n  ((:LI)\n   "Везде, где возможно, должны использоваться аннотации (кроме DI-компоненты и дополнительных бандлов).")\n  ((:LI) "Необходимо указать, сколько на какую часть ушло времени.")\n  ((:LI) "Результат: в виде ссылки на github.")\n  ((:LI)\n   "Если настройка / запуск проекта нестандартен, то в README необходимо указать дополнительные шаги, которые необходимо сделать для этого."))\n ("br" NIL)\n ((:P)\n  "Результат выполнения тестового задания, пожалуйста, прикрепите ссылкой на github;")\n ((:P) "Ссылку на профиль в github / bitbucket;")\n ((:P)\n  "Контакты людей, которые вас могут порекомендовать (e-mail, телефоны, скайп — что есть).")\n ((:P) ("br" NIL) ((:B) "Обратите внимание: ")\n  "запросы без выполненного тестового задания рассматриваться не будут."))	Требуется выполнить техзадание на симфони и скорректировать зп	Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:INTERESTING	\N
32	12666323	f	Support Engineer (ReSharper)	RUR	90000	90000	от 90 000 руб.	90000	90000	9281	 JetBrains	Санкт-Петербург	false	1–3 года	28 января	((:P)\n ((:P)\n  "Founded in 2000, JetBrains s.r.o. is a world-leading vendor of professional software development tools.")\n ((:P)\n  "At JetBrains, we have a passion for making people more productive through smart software solutions that help them focus more on what they really want to accomplish, and less on mundane, repetitive “computer-busy work.”We are looking for passionate, creative and open-minded people to join our development team.")\n ("br" NIL) ((:P) ((:B) "Responsibilities:"))\n ((:UL)\n  ((:LI) "Provide technical support for JetBrains .NET-oriented products")\n  ((:LI) "Help users with solving issues (email, forums, help desk)")\n  ((:LI) "Reproduce customer issues")\n  ((:LI) "Communicate with developers about bugs and non-working features"))\n ("br" NIL) ((:UL)) ("br" NIL) ((:B) "Requirements") ": "\n ((:UL) ((:LI) "Excellent spoken and written English")\n  ((:LI) "Good knowledge of .NET platform")\n  ((:LI) "Experience using bug-tracking systems")\n  ((:LI) "Familiarity with Visual Studio (2005 and higher)")\n  ((:LI) "Good communication skills") ((:LI) "Good teamwork skills")\n  ((:LI) "Be responsible and self-dependent")\n  ((:LI) "Basic knowledge of Object-Oriented Programming languages"))\n ("br" NIL) ((:P) ((:B) "Preferable:"))\n ((:UL) ((:LI) "Experience in software testing")\n  ((:LI)\n   "Knowledge of JetBrains .NET products (ReSharper, dotTrace, dotCover, dotPeek)")\n  ((:LI) "Ability to read and understand someone source code")\n  ((:LI) "Experience in Help Desk software (ZenDesk, UserVoice, etc.)")\n  ((:LI) "Familiarity with Visual Studio (2005 and higher), or other IDEs")\n  ((:LI) "Familiarity with .NET technologies")\n  ((:LI)\n   "Experience in a Virtual Environments (VMware, VirtualPC, Virtual Box)"))\n ("br" NIL) ((:P) ((:B) "We offer:"))\n ((:UL) ((:LI) "Fascinating work in a friendly, young team")\n  ((:LI)\n   "Employment package pursuant to the Labor Code of Russian Federation (compulsory health insurance, 5 weeks paid vacation)")\n  ((:LI)\n   "High salary: determined individually, but definitely above industry average")\n  ((:LI) "Full salary during sick leave")\n  ((:LI)\n   "Voluntary health insurance including dental insurance and voluntary health insurance for your children")\n  ((:LI) "Bonuses tied to product releases")\n  ((:LI) "Flexible working schedule")\n  ((:LI)\n   "Spacious, comfortable office (open 24/7) with hot shower and other amenities")\n  ((:LI)\n   "Hot meals, coffee, tea, sandwiches, juices and soft drinks free of charge")\n  ((:LI) "Office library with specialized work-related books and magazines")\n  ((:LI) "Comfortable, ergonomic workplaces")\n  ((:LI) "Training including on-the-job English language courses")\n  ((:LI)\n   "Opportunity to travel to professional conferences in Europe and the US")))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:INTERESTING	\N
31	12579806	f	Инженер-программист (устройства связи и системы технического обслуживания)	RUR	60000	60000	от 60 000 до 90 000 руб.	90000	60000	589007	 Арман	false	Фрунзенская	3–6 лет	29 января	((:P)\n ((:P) ((:B) "Группа компаний «Арман»") " сегодня это:" ("br" NIL)\n  ((:B) "ООО \\"Арман\\"")\n  " - системный интегратор оказывающий полный цикл услуг от предпроектного обследования до постгарантийного обслуживания в области Информационных и инженерных систем, среди которых Системы промышленной связи и безопасности, Системы промышленного освещения, а также Климатические системы для промышленности, Системы автоматизации и электрообеспечения;"\n  ("br" NIL) ((:B) "ООО \\"Армтел\\"")\n  " - разработчик и производитель современных систем промышленной связи, диспетчерской связи и оповещения для предприятий промышленного сектора, аэропортов, морских портов.")\n ((:P) ((:B) "Обязанности:"))\n ((:UL)\n  ((:LI)\n   "Участие в разработке программного обеспечения на всех стадиях проекта - от предпроектных изысканий до создания и сопровождения ПО, находящегося в эксплуатации")\n  ((:LI)\n   "Программирование и отладка в операционных системах Windows, Linux (в перспективе программирование под Android)")\n  ((:LI)\n   "Использование языков программирования C/C++, Java, Shell scripts, PHP")\n  ((:LI) "Работа в интегрированных средах разработки Eclipse, Visual Studio")\n  ((:LI) "Тестирование с использованием Wireshark, gdb")\n  ((:LI)\n   "Работа с системами контроля версий Subversion, Git и системами отслеживания ошибок Jira, RedMine")\n  ((:LI)\n   "Работа с Design Patterns, со стеком сетевых протоколов TCP/IP, с прикладными протоколами приложений VoIP: RTP, RTCP, с системами мониторинга и управления на базе протокола SNMP")\n  ((:LI) "Создание информационных баз MIB")\n  ((:LI)\n   "Низкоуровневое программирования Linux kernel и создание встраиваемых образов ОС Linux для устройств с различной микропроцессорной архитектурой (x86, ARM)")\n  ((:LI)\n   "Написание пользовательской и технической документации на разрабатываемое ПО"))\n ((:P) ((:B) "Требования:"))\n ((:UL)\n  ((:LI)\n   "Высшее техническое образование в области информационных технологий / телекоммуникаций")\n  ((:LI) "Опыт работы программистом от 3-х лет")\n  ((:LI)\n   "Понимание принципов работы телекоммуникационного оборудования с коммутацией каналов и коммутацией пакетов")\n  ((:LI)\n   "Знание и навыки работы с программными инструментами, используемыми в процессах разработки и отладки программного обеспечения ("\n   ((:B) "необходимые программные инструменты указаны в описании обязанностей")\n   ")")\n  ((:LI)\n   "Опыт разработки программного обеспечения для телекоммуникационного оборудования и устройств связи")\n  ((:LI) "Опыт создания Web-приложений")\n  ((:LI)\n   "Опыт разработки встраиваемого программного обеспечения для устройств промышленного назначения с различной микропроцессорной архитектурой")\n  ((:LI) "Знание английского языка (чтение технической документации)"))\n ((:P) ((:B) "Условия:"))\n ((:UL) ((:LI) "Работа в динамично развивающейся Компании")\n  ((:LI) "Условия для профессионального развития в интересном Вам направлении")\n  ((:LI)\n   "Поддержка профессионального роста и карьеры сотрудников, ориентация на долгосрочное сотрудничество")\n  ((:LI)\n   "Официальное трудоустройство, соблюдение компанией социальных гарантий (отпуск, больничный, праздничные дни в соответствии с ТК РФ)")\n  ((:LI)\n   "Пятидневная рабочая неделя Пн-Пт. с 9:00 до 18:00 (возможен гибкий график начала/окончания рабочего дня)")\n  ((:LI) "Офис недалеко от ст.м. \\"Фрунзенская\\"")))	Все подряд: C/C++, Java, Shell scripts, PHP. - Должно быть интересно	Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:INTERESTING	\N
44	12616545	f	Web программист	RUR	150000	150000	от 150 000 до 150 000 руб.	150000	150000	1068709	 Агентство Научные кадры	Санкт-Петербург	false	1–3 года	21 января	((:P) ((:P) "Web программист со знанием химии и физики") ("br" NIL)\n ((:P) ((:B) "Обязанности:"))\n ((:UL)\n  ((:LI)\n   "Онлайновая коллекция всех химических опытов, редактируемая пользователями наподобие Википедии (прототип тут chemistry.melscience.com)")\n  ((:LI)\n   "Виртуальная химическая лаборатория с визуализацией процесса (можно проделать любую химическую реакцию онлайн)")\n  ((:LI)\n   "Интерактивность в химическом наборе: сайт с заданиями, рейтинги, возможность поделиться видео с друзьями, комментарии, и т.д.")\n  ((:LI)\n   "Отдельной строкой стоит задача локализации всего, что мы делаем, на много стран и много языков")\n  ((:LI)\n   "Сайт “новый опыт каждую неделю”: сайт с информацией, интеграция оплаты, логистики, личного кабинета"))\n ((:B) "Требования:")\n ((:UL)\n  ((:LI) "Никаких совмещений, это должна быть основная и единственная работа")\n  ((:LI)\n   "Наши рынки – за пределами России. Поэтому вам нужно уметь говорить по-английски уже сейчас")\n  ((:LI)\n   "Знание Python и JavaScript обязательно, знание других технологий будет преимуществом")\n  ((:LI)\n   "Знание физики и химии на хорошем уровне (80% сотрудников компании – победители предметных олимпиад)"))\n ((:B) "Условия:")\n ((:UL)\n  ((:LI)\n   "Зарплата 150 000 рублей в месяц (до уплаты подоходного налога), зарплата полностью белая, на карту любого банка")\n  ((:LI)\n   "Работа в офисе, на юго-западе города (БЦ Империал, 4 минуты пешком от м.Кировский Завод)")\n  ((:LI) "Отпуск - 1 месяц в году")\n  ((:LI)\n   "Мы не поощряем переработки. Вы работаете 40 часов в неделю. Доступ в офис открыт 24/7")\n  ((:LI) "Поездки за границу на выставки или конференции – не реже раза в год")\n  ((:LI)\n   "Научная библиотека в офисе. Встречи с научными экспертами для расширения кругозора. Оплата профессиональной литературы")))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:BEENVIEWED	\N
34	10458439	f	Senior Software Developer	RUR	130000	130000	от 130 000 руб.	130000	130000	9281	 JetBrains	Санкт-Петербург	false	3–6 лет	28 января	((:P)\n ((:P)\n  "Основанная в 2000 году, компания JetBrains является мировым лидером в производстве профессиональных инструментов разработки.")\n ((:P)\n  "Наша цель – дать людям возможность работать c удовольствием и более продуктивно за счет использования «умных» программных решений, которые берут на себя рутинные задачи, позволяя сфокусироваться на творческой части работы. В настоящий момент среди продуктов компании IDE для Java, HTML, PHP, Objective C, Ruby, Python и других, инструменты для поддержки командной работы, профайлер и другие. Также ведется работа над еще не анонсированными продуктами.")\n ((:P)\n  "Для помощи в создании самых умных инструментов для программиста нам очень нужны талантливые, творческие, инициативные люди. В одном из наших проектов открыта вакансия Senior Software Developer.")\n ("br" NIL) ((:P) ((:B) "Вам предстоит:"))\n ((:UL)\n  ((:LI) "участвовать в разработке " ((:B) "новой технологии")\n   ". Она позволяет создавать десктоп- или веб-приложения для совместного редактирования данных."))\n ("br" NIL) ((:P) ((:B) "Требования:"))\n ((:UL)\n  ((:LI) "необходимые навыки: "\n   ("ul" NIL\n    ("li" NIL\n     "опыт программирования на Java не менее 3-х лет в коммерческих проектах")\n    ("li" NIL "глубокое понимание OOP")\n    ("li" NIL\n     "знания основных алгоритмов и структур данных, общая математическая эрудиция")\n    ("li" NIL "опыт многопоточного программирования")\n    ("li" NIL "умение оптимизировать и рефакторить как свой, так и чужой код")\n    ("li" NIL "ответственность, самостоятельность, организованность")\n    ("li" NIL "умение работать в команде")))\n  ((:LI) "плюсами будут: "\n   ("ul" NIL\n    ("li" NIL\n     "опыт написания компонентов операционных систем или распределенных приложений")\n    ("li" NIL "знание JDBC, MySQL, GWT")\n    ("li" NIL\n     "интерес к функциональным языкам и другим парадигмам программирования (Haskell, F#, Scala, etc.)"))))\n ("br" NIL) ((:P) ((:B) "Мы предлагаем:"))\n ((:UL) ((:LI) "увлекательную интересную работу в дружном молодом коллективе")\n  ((:LI)\n   "участие в разработке продуктов, нацеленных на таких же, как мы, разработчиков")\n  ((:LI)\n   "оформление по Трудовому Кодексу (ОМС, оплачиваемый отпуск 5 рабочих недель)")\n  ((:LI) "компенсация больничного листа до полной зарплаты")\n  ((:LI)\n   "ДМС, включая стоматологию, а также оплачиваемое компанией ДМС для детей сотрудников")\n  ((:LI) "премии по итогам релизов") ((:LI) "гибкий график работы")\n  ((:LI) "комфортный большой офис (открыт круглосуточно) с душем")\n  ((:LI)\n   "бесплатные горячие обеды, а также кофе, чай, бутерброды, питьевая вода")\n  ((:LI) "нужные для работы книги и журналы, библиотека в офисе")\n  ((:LI) "обучение (уроки английского языка в офисе)")\n  ((:LI) "возможность участия в конференциях в США и Европе")\n  ((:LI) "помощь в переезде из другого региона.")))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:UNINTERESTING	\N
29	12677296	f	Архитектор баз данных / Principal Software Engineer for Database (г. Казань)	RUR	100000	100000	от 100 000 руб.	100000	100000	3504	 Универсальный Сервис	Санкт-Петербург	false	более 6 лет	29 января	((:P)\n ((:P)\n  ((:B)\n   "В крупной международной компании, предоставляющей системы по обработке платежей для банков, промышленности и розничной торговли по всему миру, открыта вакансия \\"")\n  ((:B) "Арxитектор баз данных / Principal Software Engineer for Database\\""))\n ((:P) ((:B) "Обязанности:"))\n ((:UL)\n  ((:LI)\n   ((:P)\n    "Самостоятельное проектирование, разработка, обслуживание приложений и интеграций с использованием платформы Microsoft SQL Server; включая отчеты, задачи по хранению данных и другие задачи, связанные с базой данных."))\n  ((:LI) ((:P) "Обеспечение технологическим ноу-хау по проектам"))\n  ((:LI)\n   ((:P)\n    "Наставничество младших по должности разработчиков, включая веб-разработчиков, по лучшим практикам SQL."))\n  ((:LI)\n   ((:P)\n    "Разработка и испытание новых архитектур для поддержки требований приложений, используя компоненты многократного использования."))\n  ((:LI)\n   ((:P)\n    "Ревизия новых приложений на соответствие существующим архитектурам. Понимание и передача технологических целей и стратегий."))\n  ((:LI)\n   ((:P)\n    "Эта позиция требует безупречной коммуникации, технической квалификации и навыков командной работы.")))\n ((:P) ((:B) "Требования:")) ((:P) "Обязательные навыки")\n ((:UL) ((:LI) ((:P) "Опыт работы не менее 12 лет"))\n  ((:LI)\n   ((:P)\n    "Экспертные рабочие знания функционала и возможностей MS SQL Server 2008 R2 - (T-SQL, SSIS, SSMS)."))\n  ((:LI) ((:P) "Опыт программирования SQL не менее 5 лет."))\n  ((:LI)\n   ((:P)\n    "Опыт работы с крупными он-лайн базами данных с большим объемом транзакций."))\n  ((:LI)\n   ((:P)\n    "Возможность диагностировать проблемы с производительностью баз данных и реализации решений в рамках существующего фреймворка."))\n  ((:LI)\n   ((:P)\n    "Отличный письменные, устные и презентационные коммуникативные навыки"))\n  ((:LI)\n   ((:P)\n    "Английский язык - уровень, необходимый для общения с международной командой проекта (возможно письменный)")))\n ((:P) "Желательные навыки:")\n ((:UL) ((:LI) ((:P) "Опыт администрирования баз данных"))\n  ((:LI) ((:P) "Опыт работы в отрасли платежей"))\n  ((:LI)\n   ((:P)\n    "Опыт ведения полного жизненного цикла программного обеспечения, включая проектирование, тестирование, развертывание, документирование и техническую поддержку")))\n ((:P) ((:B) "Условия:"))\n ((:UL)\n  ((:LI)\n   ((:P)\n    "Офис - г.Казань, рядом с м.«Площадь Габдуллы Тукая» или «Суконная Cлобода»"))\n  ((:LI) ((:P) "5-дневная рабочая неделя с 10:00 до 19:00, работа в офисе"))\n  ((:LI) ((:P) "Оформление по бессрочному ТД, испытательный срок - 3 месяца"))\n  ((:LI) ((:P) "Обучение английскому языку (за счет компании)"))))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:UNINTERESTING	\N
33	12666258	f	Senior Test Engineer (ReSharper)	RUR	90000	90000	от 90 000 руб.	90000	90000	9281	 JetBrains	Санкт-Петербург	false	3–6 лет	28 января	((:P)\n ((:P)\n  "Основанная в 2000 году, компания JetBrains является мировым лидером в производстве профессиональных инструментов разработки."\n  ("br" NIL) ("br" NIL)\n  "Наша цель – дать людям возможность работать c удовольствием и более продуктивно за счет использования «умных» программных решений, которые берут на себя рутинные задачи, позволяя сфокусироваться на творческой части работы."\n  ("br" NIL) ("br" NIL)\n  "Для достижения этой цели нам очень нужны талантливые, творческие, инициативные люди.")\n ("br" NIL) ((:P) ((:B) "Вам предстоит:"))\n ((:UL)\n  ((:LI)\n   "в проект ReSharper требуется специалист по тестированию для проверки качества работы продукта и поддержки пользователей")\n  ((:LI)\n   "работа включает тесное взаимодействие с командой разработчиков, участие в разработке новой функциональности и повседневной жизни проекта")\n  ((:LI)\n   "нам бы хотелось привлечь в команду инициативного и коммуникабельного специалиста с техническим образованием, опытом работы по тестированию программного обеспечения"))\n ("br" NIL) ((:P) ((:B) "Необходимые навыки: "))\n ((:UL)\n  ((:LI) "опыт тестирования в больших коммерческих проектах не менее 3-х лет")\n  ((:LI) "отличное понимание процесса тестирования")\n  ((:LI) "опыт тестирования без функциональной спецификации")\n  ((:LI)\n   "умения самостоятельно ставить себе задачу и оценивать время на ее решение")\n  ((:LI) "умение коротко и ясно описывать проблемные места")\n  ((:LI) "способность и желание работать в команде")\n  ((:LI) "хороший письменный английский язык")\n  ((:LI) "опыт работы в тестировании совместимости нескольких продуктов")\n  ((:LI)\n   "опыт работы с инструментами для автоматического тестирования графического интерфейса")\n  ((:LI) "знание принципов объектно-ориентированного программирования"))\n ("br" NIL) ((:B) "Желательно:")\n ((:UL)\n  ((:LI)\n   "знание .NET технологий в объеме достаточном для написания простых приложений")\n  ((:LI) "опыт работы с пользователями / в технической поддержке")\n  ((:LI) "плюсом будет опыт тестирования IDE (plugins / addins)"))\n ("br" NIL) ((:P) ((:B) "Мы ценим:"))\n ((:UL)\n  ((:LI)\n   "трудолюбие, внимательность к деталям и желание пополнять багаж знаний")\n  ((:LI)\n   "в нашей команде каждый программист принимает участие в определении облика продукта, принимает решения по деталям реализации и функциональности систем, которыми он занимается")\n  ((:LI)\n   "у нас принято думать самостоятельно и прислушиваться к коллегам, а также к сообществу пользователей (которое зачастую получает доступ к свежей функциональности уже на следующий день после интеграции изменений в проект)")\n  ((:LI)\n   "от вас потребуется умение анализировать отзывы, конструктивно подходить к возможной критике и развивать функциональность так, чтобы она была максимально полезна"))\n ("br" NIL) ((:P) ((:B) "Мы предлагаем:"))\n ((:UL) ((:LI) "увлекательную работу в дружном молодом коллективе")\n  ((:LI)\n   "участие в разработке продуктов, нацеленных на таких же, как мы, разработчиков")\n  ((:LI)\n   "высокую заработную плату (обсуждается индивидуально, заведомо выше средней для отрасли)")\n  ((:LI) "премии по итогам релизов") ((:LI) "гибкий график работы")\n  ((:LI) "оформление по Трудовому Кодексу")\n  ((:LI) "оплачиваемый отпуск (5 рабочих недель)")\n  ((:LI) "оплачиваемый больничный")\n  ((:LI) "ДМС со стоматологией для сотрудников и их детей")\n  ((:LI) "просторный современный офис (открыт круглосуточно), парковка")\n  ((:LI) "эргономичные рабочие места и уютные зоны отдыха")\n  ((:LI) "горячие обеды, напитки, фрукты, снэки")\n  ((:LI) "нужные для работы книги и журналы, библиотека")\n  ((:LI) "обучение (уроки английского, немецкого языков)")\n  ((:LI) "спортзал в офисе (с душевыми), массажный кабинет, игровая зона")\n  ((:LI) "возможность участия в конференциях в США и Европе")\n  ((:LI) "помощь в переезде из другого региона."))\n ((:UL)))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:UNINTERESTING	\N
70	12616470	f	Senior Build and Release Engineer	USD	3500	3500	от 3 500 до 3 800 USD	3800	3500	1729022	ООО Nitro Software, Inc.	false	Ладожская	3–6 лет	2 февраля	((:P)\n ((:P)\n  ((:B) "Senior Build and Release Engineer" ("br" NIL)\n   ((:B) "Engineering | St. Petersburg, Russia")))\n ("br" NIL)\n ((:P)\n  "We’re looking for a talented Senior Build and Release Engineer to join our Saint-Petersburg team."\n  ("br" NIL)\n  "As a Build and Release Engineer, you will provide support for developing build scripts and tools that will improve the efficiency of the development and its build process."\n  ("br" NIL)\n  "We are looking for an experienced, self-motivated, detail oriented engineer who has demonstrated ability to work in a fast-pace and complex software build environment."\n  ("br" NIL)\n  "You’ll report to our VP of Infrastructure & Security and be working closely with our development and operation teams."\n  ("br" NIL)\n  "You’ll be working on a small team of senior contributors responsible for running the systems that are servicing millions of users every month."\n  ("br" NIL) ("br" NIL) ((:B) "What you'll be doing:"))\n ((:UL)\n  ((:LI)\n   "Execute deployments to various environments and produce deploy notes where necessary.")\n  ((:LI)\n   "Establish and scale build and release best practices during a period of incredible growth for the company.")\n  ((:LI) "Work with the team to set up continuous integration environments.")\n  ((:LI)\n   "Understanding the integration between automated software test and the build process.")\n  ((:LI)\n   "Collaborate with developers and architects to refine build, test, and release practices across the organization.")\n  ((:LI)\n   "Help developers and QA with their implementation of build and test scripts according to best practices.")\n  ((:LI)\n   "Assist in setting up new servers for new projects both in development and production")\n  ((:LI) "Troubleshoot issues in testing environments.")\n  ((:LI)\n   "Define and document our integration and deployment best practices and processes.")\n  ((:LI) "Troubleshoot issues in testing environments."))\n ((:P) ("br" NIL) ((:B) "What we're looking for:"))\n ((:UL)\n  ((:LI)\n   "3+ years of configuration management and engineering for large-scale systems, ideally supporting an Agile development process.")\n  ((:LI)\n   "Deep understanding of version control systems (Perforce, svn, Git, etc.), including branching and merging strategies.")\n  ((:LI)\n   "Experience with software build tools (MSBuild, Maven) and continuous integration tools (Jenkins).")\n  ((:LI)\n   "Experience with Window and Linux environments and scripting languages")\n  ((:LI)\n   "Experience working with cloud platforms (EC2, Rackspace Open Cloud, etc.) and cloud automation tools (Chef, Puppet)."))\n ((:P) ("br" NIL)\n  ((:B) "Traits that will distinguish the ultimate candidate:"))\n ((:UL)\n  ((:LI) "B.S. in Computer Science, Mathematics or Electrical Engineering.")\n  ((:LI) "Experience with Buildbot, Bamboo, etc.")\n  ((:LI) "Experience with multiple clouds (AWS, Rackspace, Azure, etc).")\n  ((:LI)\n   "Comfortable working late evening hours, which is when most releases and patches occur.")\n  ((:LI)\n   "You are extremely proactive at identifying ways to improve things and to make them more reliable.")\n  ((:LI) "High attention to detail and excellent problem solving skills.")\n  ((:LI) "You’re fun to be around!"))\n ((:P) ("br" NIL) ((:B) "We offer:"))\n ((:UL) ((:LI) "Work in no-bullshit Nitro team")\n  ((:LI) "Flexible working hours") ((:LI) "Competitive salary")\n  ((:LI) "Official employment")\n  ((:LI)\n   "Comfortable office, 3 minutes walking from Ladozhskaya metro station"))\n ((:P) ("br" NIL) ((:B) "Who we are:") ("br" NIL)\n  "At Nitro, we’re changing the way the world works with documents. From the desktop to the cloud, we make it easy to create, edit, share, sign and collaborate – online or offline."\n  ("br" NIL)\n  "More than 450,000 businesses run Nitro, including over 50% of the Fortune 500. We’re the PDF software partner of choice for Lenovo, and our award-winning products, including Nitro Pro and Nitro Cloud, are used by millions of people around the world every month."\n  ("br" NIL)\n  "Australian-founded, we’re headquartered in downtown San Francisco with offices in Melbourne, Australia; Dublin, Ireland; Nitra, Slovakia; and St. Petersburg, Russia."\n  ("br" NIL)\n  "One of the fastest-growing private companies in the world, Nitro is also a multiple Inc. 500/5000, BRW Fast 100, Deloitte Technology Fast 50 and Software 500 award winner."))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:UNINTERESTING	
40	12641235	f	Менеджер проектов разработки/ Team Lead	RUR	60000	60000	от 60 000 до 120 000 руб.	120000	60000	1422511	ООО DDelivery	Санкт-Петербург	false	1–3 года	26 января	((:P) ((:B) "Обязанности: ")\n ((:UL) ((:LI) "Взаимодействие с разработчиками и отделом тестирования.")\n  ((:LI) "Постановка задач и написание ТЗ;")\n  ((:LI) "Контроль за сроками выполнения работ;")\n  ((:LI)\n   "Взаимодействие с транспортными компаниями для решения интеграционных задач;"))\n ((:P) ("br" NIL) ((:B) "Требования:"))\n ((:UL)\n  ((:LI)\n   "Умение доступно излагать мысли ( Я могу объяснить ребенку, что такое газотурбинный генератор );")\n  ((:LI) "Я умею видеть детали и правильно оценивать их значимость;")\n  ((:LI) "Опыт работы с фрилансерами от 2 лет;")\n  ((:LI)\n   "Базовые знания программирования (желательно более продвинутый уровень);")\n  ((:LI) "Знание теоретических основ БД;")\n  ((:LI) "Продвинутый пользователь ПК (весь офисный пакет, photoshop, corel);")\n  ((:LI) "Умение решать много задач в \\"фоне\\";")\n  ((:LI) "Нелинейность мышления. Умение находить красивые решения задач;")\n  ((:LI)\n   "Хорошие коммуникативные навыки (общаться нужно долго и много с разными участниками проекта);")\n  ((:LI) "Работа на результат."))\n ((:P) ("br" NIL) ((:B) "Условия:"))\n ((:UL) ((:LI) "Офис в центре Петербурга, 10 мин. от метро Восстания;")\n  ((:LI) "Дружный молодой коллектив;")\n  ((:LI)\n   "Возможность воплотить свои мечты в реальность (каждый участник нашей команды вносит свои идеи);")\n  ((:LI)\n   "Уникальный опыт по созданию первого логистического интегратора страны!")\n  ((:LI) "Чай, кофе, печеньки.")))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:INTERESTING	\N
38	12613120	f	Главный специалист отдела информационных технологий	RUR	86500	86500	от 86 500 до 108 000 руб.	108000	86500	2748	 Ростелеком, Макрорегиональный филиал "Северо-Запад"	Санкт-Петербург	false	1–3 года	27 января	((:P) ((:P) ((:B) "Обязанности") ":")\n ((:UL)\n  ((:LI)\n   "Обеспечение эксплуатации и развития IP/MPLS сети филиала и ее сервисов;")\n  ((:LI)\n   "Обеспечение эксплуатации и развития сетей доступа (Docsis и Ethernet) филиала;")\n  ((:LI)\n   "Обеспечение организации, эксплуатации, развития системы мониторинга сети,сетевых сервисов, каналов связи;")\n  ((:LI) "Обеспечение эксплуатации и развития IP телефонии филиала;")\n  ((:LI)\n   "Обеспечение бесперебойного функционирования систем оперативно - розыскных мероприятий (COPM) для IP (каналы связи,система дублирования трафика);")\n  ((:LI)\n   "Участие в проектах по модернизации ,расширению сети (на всех уровнях), подготавливает технические задания, технические условия и обоснования в зоне ответственности отдела;")\n  ((:LI)\n   "Ведение договоров на каналы связи, сервисное обслуживание оборудования, эксплуатируемого отделом;")\n  ((:LI) "Согласование договоров для закупки оборудования;")\n  ((:LI)\n   "Подготовка предложения по бюджету отдела, контроль исполнения бюджета;")\n  ((:LI)\n   "Контроль за оплатой счетов за услуги и работы в зоне ответственности отдела (организация или аренда каналов связи, услуги присоединения сетей, размещения оборудования ПД и ТФ, сервисное обслуживание оборудования передачи данных и телефонии и т.п.);")\n  ((:LI)\n   "Формирование отчетности о статистике по каналам связи, трафику и т.д;")\n  ((:LI) "Анализ узких мест в сети филиала, причин аварий и неисправностей;")\n  ((:LI) "Исполнение обязанностей начальника отдела в случае его отсутствия."))\n ((:P) ((:B) "Требования") ":")\n ((:UL) ((:LI) "Высшее техническое образование, желательно IT специальностей;")\n  ((:LI) "Предыдущие занимаемые позиции: "\n   ("ul" NIL ("li" NIL "Старший (главный) специалист;")\n    ("li" NIL\n     "Заместитель или руководитель подразделения с числом подчиненных от 5 человек.")))\n  ((:LI) "Навыки: "\n   ("ul" NIL\n    ("li" NIL\n     "Опытный пользователь ПК, желательно знание perl ,shell, работа с базами данных PostgreSQL."))))\n ((:P) ((:B) "Условия") ":")\n ((:UL) ((:LI) "Нормированный рабочий день.")\n  ((:LI)\n   "График: 2/2. С 8:30 до 17:30. Пятница - короткий день с 8:30 до 16:15. Обеденный перерыв с 12:00 до 12:45.")\n  ((:LI) "Оклад + премии.") ((:LI) "Официальное оформление согласно ТК РФ.")))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:UNINTERESTING	\N
39	12642642	f	Front-End разработчик	RUR	70000	70000	от 70 000 до 90 000 руб.	90000	70000	121888	 Short	false	Маяковская	1–3 года	26 января	((:P) ((:P) ((:B) "Обязанности"))\n ((:UL) ((:LI) "Разработка клиентской части web-приложений")) ("br" NIL)\n ((:P) ((:B) "Требования"))\n ((:UL) ((:LI) "Опыт работы на современных JS/CSS фреймворках")\n  ((:LI) "Уверенные знания JavaScript, CSS3 и HTML5")\n  ((:LI)\n   "Понимание принципов usability, архитектуры корпоративных web-приложений")\n  ((:LI) "Опыт работы с системами контроля версий кода (Git)")\n  ((:LI) "Знание основ построения корпоративных web-приложений")\n  ((:LI) ((:B) "Приветствуется")\n   ("ul" NIL ("li" NIL "Опыт использования AngularJS / AngularUI")\n    ("li" NIL "Опыт написания JS юнит тестов (например Jasmine)")\n    ("li" NIL "Опыт использования jQuery Plugins")\n    ("li" NIL "Знание стилей и компонентов Twitter Bootstrap 3")\n    ("li" NIL "Знание Java, REST WS"))))\n ("br" NIL) ((:P) ((:B) "Мы предлагаем"))\n ((:UL) ((:LI) "Офис в центре города, 3 минуты от ст. м. Маяковская")\n  ((:LI) "Оформление по трудовому кодексу РФ с официальной заработной платой")\n  ((:LI) "Полис добровольного медицинского страхования")\n  ((:LI)\n   "Оплата курсов повышения квалификации, спортивных занятий по выбору, проездного билета.")))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:UNINTERESTING	\N
46	12606761	f	Senior Software Developer (ReSharper)	RUR	130000	130000	от 130 000 руб.	130000	130000	9281	 JetBrains	Санкт-Петербург	false	3–6 лет	20 января	((:P)\n ((:P) "Основанная в 2000 году, компания " ((:B) "JetBrains")\n  " является мировым лидером в производстве профессиональных инструментов разработки.")\n ((:P) "В команду " ((:B) "ReSharper ") "мы ищем" ((:B))\n  "талантливых, уникальных людей, тех, кто готов поделиться своим искусством с сотнями тысяч разработчиков. Тех, кто хочет и может влиять на индустрию создания программных продуктов.")\n ((:P)\n  "Наша цель – дать людям возможность работать c удовольствием и более продуктивно с помощью интеллектуальных продуктов, которые берут на себя рутину, позволяя программисту сфокусироваться на творческой части работы.")\n ((:P)\n  "Мы верим, что при решении каждой задачи может быть учтено бессчетное число важных мелочей, а в каждом элементе функциональности можно изобретать все более удобные способы взаимодействия с пользователем.")\n ((:P)\n  "Структура компании такова, что владельцы компании и CEO участвовали и продолжают участвовать в создании продуктов. Программирование для нас не только средство, это наше призвание.")\n ((:P) ((:B) "Смело присылайте резюме нам, если..."))\n ((:UL)\n  ((:LI)\n   "для Вас программирование - это средство самовыражения, это искусство, которым Вы мастерски владеете. Ваши знания и опыт - это энергия, стремящаяся воплотиться в продукте;")\n  ((:LI)\n   "Вы круты в алгоритмах, дизайне, архитектуре, технологиях. Где угодно, но по-настоящему круты;")\n  ((:LI) "Вы верите, что в программировании может отсутствовать рутина;")\n  ((:LI) "Вы никогда не останавливаетесь в развитии;")\n  ((:LI)\n   "Вас интересует содержание. Для Вас компилятор - это объект исследования, SOLID - способ объяснить красоту архитектуры."))\n ((:P) ((:B) "Мы заметили, что успешные кандидаты обычно:"))\n ((:UL)\n  ((:LI)\n   "имеют опыт разработки на С#/Java, а также опыт технического руководства;")\n  ((:LI)\n   "участвуют в open-source проектах, либо имеют опыт ведения собственных проектов;")\n  ((:LI)\n   "интересуются альтернативными технологиями, парадигмами программирования, функциональным языками, небезразличны к вопросам архитектуры и в курсе последних новостей и трендов в индустрии."))\n ((:P)\n  ((:B)\n   "Собеседование пройти не просто. Но это стоит того, потому что в JetBrains Вы найдете:"))\n ((:UL)\n  ((:LI) "команду творческих личностей" ((:B) ". ")\n   "Мечтателей, перфекционистов, мыслителей и энтузиастов;")\n  ((:LI)\n   "открытый для Ваших идей процесс создания продукта. С первых дней работы Вы не просто пишете код, Вы создаете продукт. Вы общаетесь с пользователями, придумываете новые фичи, работаете над архитектурой, думаете про UX, интегрируетесь в сообщество и распространяете знания;")\n  ((:LI)\n   "креативное окружение, где Ваш вклад может действительно что-то изменить. Мы верим что уникальные продукты создаются уникальными людьми;")\n  ((:LI) "красоту продуктов," ((:B)) "которая" ((:B))\n   "у нас сочетается с красотой исходного кода. Мы ценим красоту;")\n  ((:LI) "самую интересную предметную область."))\n ((:P) ((:B) "А также:"))\n ((:UL) ((:LI) "увлекательную работу в дружном молодом коллективе")\n  ((:LI)\n   "высокую заработную плату (обсуждается индивидуально, заведомо выше средней для отрасли)")\n  ((:LI) "оформление по Трудовому Кодексу")\n  ((:LI) "оплачиваемый отпуск (5 рабочих недель)")\n  ((:LI) "оплачиваемый больничный")\n  ((:LI) "ДМС (со стоматологией), ДМС для детей сотрудников")\n  ((:LI) "премии по итогам релизов") ((:LI) "гибкий график работы")\n  ((:LI) "комфортный большой офис (открыт круглосуточно)")\n  ((:LI) "горячие обеды, а также кофе, чай, бутерброды")\n  ((:LI) "нужные для работы книги и журналы, библиотека в офисе")\n  ((:LI) "удобные, эргономичные рабочие места")\n  ((:LI) "обучение (уроки английского и немецкого языка)")\n  ((:LI) "возможность участия в конференциях в США и Европе")\n  ((:LI) "помощь в переезде из другого региона.")))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:UNINTERESTING	\N
50	12191607	f	Senior Software Developer (PyCharm)	RUR	130000	130000	от 130 000 руб.	130000	130000	9281	 JetBrains	Санкт-Петербург	false	3–6 лет	15 января	((:P)\n ((:P)\n  "Founded in 2000, JetBrains s.r.o. is a world-leading vendor of professional software development tools. At JetBrains, we have a passion for making people more productive through smart software solutions that help them focus more on what they really want to accomplish, and less on mundane, repetitive “computer-busy work.”We are looking for passionate, creative and open-minded people to join our development team.")\n ((:P)\n  "As part of our team, you will provide developers all over the world the best programming environment for Python ecosystem - "\n  ((:B) "PyCharm IDE") ".")\n ((:P) ((:B) "Responsibilities:"))\n ((:UL) ((:LI) "Conceive and implement new features")\n  ((:LI) "Redesign and optimize existing features")\n  ((:LI) "Enhance performance of IDE subsystems")\n  ((:LI) "Interact with users in public issue tracker"))\n ((:P) ((:B) "Requirements:"))\n ((:UL) ((:LI) "4 years(or more) experience with Java")\n  ((:LI) "Knowledge of essential algorithms and data structures")\n  ((:LI) "Experience with multithreaded code")\n  ((:LI) "Responsibility, discipline, self-motivation")\n  ((:LI) "Ability to implement ideas into high-quality product features")\n  ((:LI) "Good teamwork skills"))\n ((:P) ((:B) "As a plus would be ") "(but not required):")\n ((:UL) ((:LI) "Python knowledge")\n  ((:LI) "Experience with other JVM based languages")\n  ((:LI) "Participation in open-source projects"))\n ((:P) ((:B) "We offer:"))\n ((:UL) ((:LI) "Fascinating work in a friendly, young team")\n  ((:LI) "Developing products for software developers much like ourselves")\n  ((:LI)\n   "Employment package (compulsory health insurance, 5 weeks paid vacation)")\n  ((:LI)\n   "High salary: determined individually, but definitely above industry average")\n  ((:LI) "Full salary during sick leave")\n  ((:LI)\n   "Voluntary health insurance including dental insurance and voluntary health insurance for your children")\n  ((:LI) "Bonuses tied to product releases")\n  ((:LI) "Flexible working schedule")\n  ((:LI)\n   "Spacious, comfortable office (open 24/7) with hot shower and other amenities")\n  ((:LI)\n   "Hot meals, coffee, tea, sandwiches, juices and soft drinks free of charge")\n  ((:LI) "Office library with specialized work-related books and magazines")\n  ((:LI) "Comfortable, ergonomic workplaces")\n  ((:LI) "Training including on-the-job English language courses")\n  ((:LI)\n   "Opportunity to travel to professional conferences in Europe and the US")\n  ((:LI) "Help in relocating from another region.")))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:UNINTERESTING	\N
71	12686808	f	Программист node.js, javascript (удаленно)	USD	2000	2000	от 2 000 USD	2000	2000	804043	 RC Design	Санкт-Петербург	false	более 6 лет	2 февраля	((:P) ((:P) "Программист node.js, javascript (удаленно).")\n ((:P) "Для опенсорсных проектов Nodeca и Fontello требуются разработчики.")\n ((:P) ((:B) "В основном дело касается:"))\n ((:UL) ((:LI) "node.js") ((:LI) "mongodb") ((:LI) "redis") ((:LI) "jquery")\n  ((:LI) "html5 + немного bootstrap и БЕМ") ((:LI) "github"))\n ((:P) ((:B) "Пожелание к кандидатам:"))\n ((:UL) ((:LI) "минимум 5 лет программирования") ((:LI) "linux")\n  ((:LI) "желательно быть в курсе современных веяний веб разработки")\n  ((:LI) "нужно знать еще какой-то язык, помимо JS, причем не php.")\n  ((:LI)\n   "нужно не бояться верстки на уровне переклеивания кусков из twitter bootstrap")\n  ((:LI) "технический английский на уровне грамотного комментирования кода")\n  ((:LI) "если есть аккаунт на гитхабе - обязательно указывайте в резюме")))	Довольно интересно	Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:INTERESTING	
48	12251537	f	Системный администратор (Devops)	RUR	90000	90000	от 90 000 руб.	90000	90000	633069	ООО Селектел	false	Московские ворота	1–3 года	20 января	((:P)\n ((:P) ((:B) "Компания Селектел приглашает на работу ")\n  ((:B) "Системного администратора в отдел Devops."))\n ((:P) ((:B) "Наши ожидания от кандидатов:"))\n ((:UL) ((:LI) "большой опыт администрирования Linux-систем;")\n  ((:LI) "работа с CI, опыт написания тестов;")\n  ((:LI) "опыт настройки аппаратных и программных RAID-массивов;")\n  ((:LI) "знание основных системы виртуализации;")\n  ((:LI)\n   "понимание принципов работы компьютерных сетей, знание основных сетевых сервисов (DNS, DHCP, VLAN, NAT, VPN), знание стека протоколов TCP/IP, опыт работы с сетевыми утилитами, снифферами, понимание принципов работы iptables;")\n  ((:LI)\n   "умение конфигурировать широко используемые системы мониторинга: Zabbix, Munin, Cacti, Nagios;")\n  ((:LI)\n   "опыт работы с PostgreSQL, MySQL (так же MariaDB, Percona Server). Уметь выполнять оптимизацию, настраивать репликацию и резервное копирование;")\n  ((:LI) "умение пользоваться утилитами трассировки (strace, ktrace);")\n  ((:LI) "знание основ написания скриптов на bash, python;")\n  ((:LI) "навыки работы с git;")\n  ((:LI) "опыт работы с Chef, Puppet, Ansible, SaltStack;")\n  ((:LI) "тонкая настройка (NGinx), почтовых серверов (postfix), SFTP."))\n ((:P) ((:B) "На этой позиции Вы будете заниматься:"))\n ((:UL) ((:LI) "внедрением внутренних продуктов;")\n  ((:LI) "поддержкой и обновлением."))\n ((:P) ((:B) "Мы готовы Вам предложить:"))\n ((:UL) ((:LI) "оформление по ТК РФ, полностью белую заработную плату;")\n  ((:LI) "бесплатные обеды + чай, кофе, соки, конфеты в офисе;")\n  ((:LI) "полис ДМС (включая стоматологию);")\n  ((:LI) "бесплатное обучение английскому языку;")\n  ((:LI) "50 % оплаты занятий спортом;") ((:LI) "надбавка за некурение;")\n  ((:LI)\n   "график работы гибкий: 5-дневная рабочая неделя, обязательные часы присутствия всех сотрудников в офисе с 12.00-17.00, остальные 4 часа в день на усмотрение каждого")\n  ((:LI) "своя авто- и велопарковка;") ((:LI) "карьерный рост;")\n  ((:LI) "молодой, дружный коллектив."))\n ((:P)\n  ((:B)\n   "Если вакансия показалась Вам интересной, сопроводите, пожалуйста, Ваш отклик следующей информацией")\n  ":")\n ((:UL) ((:LI) "описание проектов в общих чертах, Ваша роль в них;")\n  ((:LI)\n   "конкретные технологии, которые использовали именно Вы в работе над проектами")))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:UNINTERESTING	\N
43	12619713	f	Инженер (отдел клиентской поддержки)	RUR	60000	60000	от 60 000 до 90 000 руб.	90000	60000	4156	 OpenWay Group	Санкт-Петербург	false	1–3 года	22 января	((:P)\n ((:P)\n  "Группа компаний OpenWay – мировой лидер в области разработки и внедрения программных решений для финансовых процессингов - в связи с расширением объявляет конкурс на позицию инженера отдела клиентской поддержки.")\n ((:P) ((:B) "Обязанности:"))\n ((:UL)\n  ((:LI)\n   "Консультирование клиентов (руководители IT отделов и процессинговых центров, DBA и т.п.) по техническим и предметным вопросам использования и настройки продуктов Компании;")\n  ((:LI)\n   "Дежурства на линии поддержки; первичная оценка и анализ клиентских запросов, разрешение проблемных ситуаций клиентов;")\n  ((:LI)\n   "Участие в обучении клиентов и консалтинге (при достижении экспертного уровня знаний)."))\n ((:P) ("br" NIL) ((:B) "Требования:"))\n ((:UL)\n  ((:LI)\n   "Образование: высшее техническое (IT, математика, физика), дополнительное специальное финансовое или экономическое образование будет плюсом.")\n  ((:LI)\n   "Опыт работы в сфере информационных технологий – от 2-х лет, в том числе опыт хотя бы в одной из следующих областей: "\n   ("ul" NIL ("li" NIL "«большие» БД (разработка и/или администрирование);")\n    ("li" NIL\n     "участие в разработке, тестировании, внедрении или поддержке больших распределенных прикладных систем;")))\n  ((:LI)\n   "Опыт консультирования технических специалистов по вопросам настройки и работы сложного прикладного ПО будет плюсом.")\n  ((:LI) "Знания и навыки: "\n   ("ul" NIL\n    ("li" NIL\n     "понимание теоретических основ и общая эрудиция в области IT и CS, знание жизненного цикла ПО, основ проектирования, разработки и обеспечения качества ПО;")\n    ("li" NIL\n     "навыки разработки ПО желательны (Java, PL/SQL или другие технологии);")\n    ("li" NIL\n     "понимание теории и практики СУБД (разработки и/или администрирования);")\n    ("li" NIL "знание теории компьютерных сетей и сетевых технологий;")\n    ("li" NIL\n     "хорошие навыки ведения деловой переписки и вербального общения;")\n    ("li" NIL "«рабочий» уровень английского языка.")))\n  ((:LI)\n   "А также: желание и умение решать проблемы, готовность детально разбираться в сути проблем; многозадачность; системность мышления, аналитические способности; позитивная профессиональная мотивация и конструктивность; ответственность и активная жизненная позиция; хорошие коммуникативные навыки; желание и умение учиться."))\n ((:P) ("br" NIL) ((:B) "Условия:"))\n ((:UL) ((:LI) "Интересные и сложные задачи;")\n  ((:LI) "Работа в профессиональном коллективе интересных людей,")\n  ((:LI) "Комфортные условия работы, обучение;")\n  ((:LI) "Конкурентоспособная заработная плата и соц. пакет.")))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:UNINTERESTING	\N
47	12606572	f	Technical manager	RUR	60000	60000	от 60 000 до 100 000 руб.	100000	60000	178925	 Екассир	false	Чёрная речка	3–6 лет	20 января	((:P)\n ((:P)\n  "Екассир, продуктовая компания в области программных решений для ДБО, платежных, билетных и рекламных систем, приглашает грамотного специалиста на должность Technical Manager.")\n ("br" NIL) ((:P) ((:B) "Обязанности:"))\n ((:UL)\n  ((:LI)\n   "Комплексное ведение проектов внедрения продуктов eKassir у клиентов компании (банки, платежные системы, крупные сети терминалов самообслуживания и точек с кассиром, расчетные центры в России, ближнем и дальнем зарубежье), включая разработку дополнительных программных модулей, реализующих уникальный функционал различной степени сложности."\n   ((:B))))\n ("br" NIL) ((:P) ((:B) "Эта работа включает в себя: "))\n ((:UL) ((:LI) "Участие в предпродажной подготовке;")\n  ((:LI) "Разработка требований;")\n  ((:LI) "Определение трудоемкости и участие в ценообразовании;")\n  ((:LI) "Согласование с клиентом целей, задач и этапов проекта;")\n  ((:LI) "Планирование, постановка и контроль выполнения задач по проекту;")\n  ((:LI) "Консультации клиента;")\n  ((:LI)\n   "Принятие решений о способах интеграции с программными системами клиента."))\n ("br" NIL) ((:P) ((:B) "Требования:"))\n ((:UL)\n  ((:LI)\n   "Опыт работы с несколькими из перечисленных технологий (MSSQL, Oracle, .Net, HTML, Криптография);")\n  ((:LI)\n   "Знание одной из предметных областей (платежные системы, электронные деньги, биллинг, бухгалтерия банка, денежные переводы);")\n  ((:LI) "Опыт управления людьми, знание методик управления проектами в IT;")\n  ((:LI)\n   "Опыт практической работы в разработке или тестировании ПО - обязателен, приветствуются кандидаты, которые хотят перейти из разработки или тестирования в сферу управления проектами;")\n  ((:LI)\n   "Опыт административного и технического руководства проектами по разработке, кастомизации и внедрению сложных программных решений - желателен;")\n  ((:LI)\n   "Грамотный устный и письменный русский язык, умение вести деловую переписку;")\n  ((:LI)\n   "Разговорный и письменный английский не ниже Upper Intermediate, приветствуются дополнительные языки."))\n ("br" NIL) ((:P) ((:B) "Личные качества:"))\n ((:UL)\n  ((:LI)\n   "Аналитический склад ума, нацеленность на результат, высокая степень ответственности, доброжелательность, способность требовать выполнения задач от смежников."))\n ("br" NIL) ((:P) ((:B) "Условия:"))\n ((:UL)\n  ((:LI)\n   "Работа в перспективной развивающейся компании на острие технологий, в дружной молодой команде профессионалов. Возможен карьерный рост.")\n  ((:LI) "Профессиональный рост и интересные задачи - гарантируем.")\n  ((:LI) "Удобный офис в 10 минутах от м. Черная Речка.")\n  ((:LI) "Оформление по ТК, пятидневка 9-18.")\n  ((:LI)\n   "По оплате: в компании действует система мотивации, в рамках которой вознаграждение Technical Manager'а зависит от объема и сложности решаемых задач.")))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:INTERESTING	\N
35	12663567	f	Сhief technical officer /CTO в Старт-ап (Германия)	RUR	60000	60000	от 60 000 до 100 000 руб.	100000	60000	1082435	ОАО Intuition IT Solutions Ltd	Санкт-Петербург	false	более 6 лет	28 января	((:P) ((:P) ((:B) "Требуется опытный CTO в Старт-ап команду."))\n ((:P) ("br" NIL) ((:B) "Требования") ":")\n ((:UL)\n  ((:LI)\n   "Знание одного или нескольких языков программирования из серии: PHP, Python, Perl, Java, JavaScript, C, C++, C#, Ruby, SQL")\n  ((:LI)\n   "Знание и опыт работы с одним или несколькими популярными фреймворками: Symfony, Laravel, Yii, Zend, Django, Spring, Hibernate, Ruby-on-Rails.")\n  ((:LI) "Опыт мобильной разработки под платформы: Android и iOS")\n  ((:LI)\n   "Знание принципов ООП, а также паттернов объектно-ориентированного проектирования")\n  ((:LI)\n   "Знание основных алгоритмов и структур данных, понимание сложности алгоритмов")\n  ((:LI)\n   "Интерес к новым языкам программирования, фреймворкам, алгоритмам и технологиям в целом")\n  ((:LI) "Опыт работы программистом не менее пяти лет")\n  ((:LI) "Опыт работы тимлидом не менее одного года")\n  ((:LI) "Высокий уровень коммуникативных навыков")\n  ((:LI) "Знание Английского или Немецкого языка"))\n ("br" NIL) ((:P) ((:B) "Условия") ":")\n ((:UL) ((:LI) "Работа в перспективной европейской компании")\n  ((:LI) "Организация релокации в Германию")\n  ((:LI) "Подготовка документов для релокации")\n  ((:LI) "Высокая заработная плата") ((:LI) "Долгосрочный контракт")))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:INTERESTING	\N
74	12734997	f	Back-end разработчик, php	RUR	60000	60000	от 60 000 до 100 000 руб.	100000	60000	1519234	ООО Вайт Код	false	Петроградская	1–3 года	6 февраля	((:P)\n ((:P)\n  "Для реализации новых проектов в команду «.White Code» требуются талантливые и ответственные люди, способные самоконтролю, готовые выполнять свои обязанности достойно хорошей оплате. Работа в сплоченном коллективе в легкодоступном месте Санкт-Петербурга, 2 минуты от ст. метро Петроградская, по адресу: улица Льва Толстого МФЦ «Толстой Сквер». Бизнес центр находится в насыщенной исторической части Санкт-Петербурга и имеет развитую инфраструктуру: магазин, видовой ресторан, кофейня, парикмахерская, химчистка, туристическое агентство, банк, винный магазин, магазин цветов и театр.")\n ((:P)) ((:P) ((:B) "Обязанности:"))\n ((:UL) ((:LI) "Разработка парсеров") ((:LI) "Разработка мини-скриптов")\n  ((:LI) "Разработка и внедрение систем статистики"))\n ((:P)) ((:P) ((:B) "Наши требования:"))\n ((:UL) ((:LI) "Хорошие знания php") ((:LI) "Базовые знания html, css")\n  ((:LI) "Базовые знания js") ((:LI) "Базовые знания linux(ssh, scp, ftp)")\n  ((:LI) "Знание баз данных(mysql, postgresql, redis, memcached)")\n  ((:LI) "Опыт работы c Git"))\n ((:P)) ((:P) ((:B) "Дополнительным плюсом будет:"))\n ((:UL) ((:LI) "Опыт написание shell-скриптов (awk, sed, bash, zsh, cut, tr)")\n  ((:LI) "Опыт работы c ElasticSearch, sphinx")\n  ((:LI) "Опыт работы с node.js (io.js)") ((:LI) "Базовые знания python"))\n ((:P)) ((:P) ((:B) "Мы предлагаем:"))\n ((:UL)\n  ((:LI)\n   "Просторный современный офис, оснащённый кондиционерами, отдельной приточной вентиляцией, высокую оплату труда и бонусную программу. Возможность быстрого карьерного роста в свежем молодом коллективе.")\n  ((:LI) ((:B) "А также:")\n   ("ul" NIL\n    ("li" NIL\n     "отдельно оборудованную кухню (посуда, посудомойка, холодильник, микроволновка)")\n    ("li" NIL "чай, кофе «Nespresso» для поднятия настроения")\n    ("li" NIL "минеральную питьевую воду «Архыз»")\n    ("li" NIL\n     "комфортное рабочее место (большое личное пространство, удобное кресло, новая мебель)")\n    ("li" NIL\n     "возможность выбора оборудования для работы (в данный момент, выбор большинства iMac 27”)")\n    ("li" NIL "официальное трудоустройство согласно ТК РФ")\n    ("li" NIL\n     "лояльный график работы с 11 до 20, обед продолжительностью 1 час, в удобное время")\n    ("li" NIL\n     "ДМС высокой категории в СК «РЕСО-Гарантия» (более 150 клиник, включая стоматологию, амбулаторное лечение, вызов скорой помощи, стационар)")\n    ("li" NIL "оплачиваемые обеды") ("li" NIL "3 собственных санузла")))))	Поправить зп и отправлять	Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:UNSORT	
19	12556692	f	Веб-дизайнер / Арт директор	RUR	70000	70000	от 70 000 до 120 000 руб.	120000	70000	885763	ООО Цитрус	false	Выборгская	3–6 лет	1 февраля	((:P) ((:P) ((:B) "Обязанности:"))\n ((:UL) ((:LI) "Разработка визуальных концепций")\n  ((:LI) "Разработка макетов по готовым прототипам")\n  ((:LI)\n   "Проектирование интерфейсов для веб-сервисов и под мобильные платформы iOS и Android")\n  ((:LI) "Взаимодействие с разработчиками")\n  ((:LI) "Работа над несколькими проектами параллельно"))\n ((:P) ((:B) "Требования:"))\n ((:UL) ((:LI) "Опыт работы в аналогичной роли от 3 лет")\n  ((:LI) "Знание и понимание особенностей интерфейсов каждой из платформ")\n  ((:LI) "Способность объяснить то или иное решение задачи")\n  ((:LI) "Понимание процесса разработки")\n  ((:LI) "Владение пакетом Adobe (Ps, Ai) и аккуратное ведение проекта в нем")\n  ((:LI) "Кропотливость и педантичность") ((:LI) "Портфолио")\n  ((:LI) "Отсутствие параллельной работы или учёбы")\n  ((:LI) "Желательно: "\n   ("ul" NIL ("li" NIL "живое прототипирование") ("li" NIL "HTML/CSS")\n    ("li" NIL "организованность") ("li" NIL "системное мышление")\n    ("li" NIL "опыт эффективного планирования")\n    ("li" NIL "опыт руководства командой из 2-3 дизайнеров"))))\n ((:P) ((:B) "Мы предлагаем:"))\n ((:UL) ((:LI) "Конкурентоспособную зарплату 70 000 - 120 000 руб.")\n  ((:LI) "Хорошо оборудованное рабочее место;")\n  ((:LI) "Офис рядом с метро Выборгская;") ((:LI) "Гибкий график работы."))\n ((:P) "По запросу предоставим более детальную информацию." ("br" NIL)\n  "Это работа мечты! Светлый большой офис, интересные проекты, крупные клиенты, исключительные профессионалы в коллективе."))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:UNINTERESTING	\N
75	12737168	f	Фронтенд разработчик, PHP	RUR	50000	50000	от 50 000 до 110 000 руб.	110000	50000	1692070	ООО Деловая практика	Санкт-Петербург	false	3–6 лет	8 февраля	((:P) ((:B) "Обязанности:")\n ((:UL)\n  ((:LI)\n   "разработка фронтенда в соответствии с проектной документацией, поддержка и развитие системы")\n  ((:LI) "активная самостоятельная работа, совместная работа с разработчиками")\n  ((:LI) "подчинение техническому директору"))\n ("br" NIL) ((:B) "Требования:")\n ((:UL)\n  ((:LI) "понимание принципов разработки и опыт разработки AJAX интерфейсов")\n  ((:LI) "хорошее знание PHP") ((:LI) "опыт работы с PostgreSQL DB")\n  ((:LI) "хорошие знания Linux и интерфейса командной строки"))\n ((:P) ((:B) "Будет плюсом:"))\n ((:UL) ((:LI) "опыт работы в Highload-проектах")\n  ((:LI) "опыт проектирования и разработки интерфейсов мобильных приложений")\n  ((:LI) "опыт работы в проектах, связанных с аггрегацией заказа билетов"))\n ("br" NIL) ((:B) "Условия")\n ((:UL)\n  ((:LI)\n   "Redmine + GIT, часть недели можно работать удаленно (Skype meetings)")\n  ((:LI)\n   "оформление по контракту, после прохождения испытательного срока зарплата индексируется по курсу евро")\n  ((:LI) "испытательный срок")\n  ((:LI) "возможность профессионального и карьерного роста"))\n ((:P)\n  ((:B)\n   "При отправке резюме, напишите пару слов о том, в каких проектах участвовали. Резюме без описания опыта работы с конкретными технологиями рассматриваться не будут.")))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:UNSORT	
12	12644276	f	PHP-разработчик / Technical Lead	RUR	120000	120000	от 120 000 руб.	120000	120000	862257	ООО БИАРУМ	false	Чёрная речка	3–6 лет	2 февраля	((:P)\n ((:P)\n  "Компания \\"БИАРУМ\\" занимается как разработкой на заказ (аутсорсинг), так и собственной разработкой в нескольких областях: медицинский софт, анализ текстовых документов (Natural Language Processing), приложения для iOS, системы управления дорожным движением и др.")\n ((:P)\n  "В команду, занимающуюся разработкой систем медицинской тематики, требуется PHP разработчик. Система представляет собой веб-сайт написанный с использованием фреймворка CodeIgniter с довольно сложной внутренней логикой (связанной с медициной).")\n ((:P) "Предполагается работа в команде из 3-4 человек.")\n ((:P) ((:B) "Требования:"))\n ((:UL) ((:LI) ((:P) "уверенное владение PHP;"))\n  ((:LI) ((:P) "знание Javascript;"))\n  ((:LI) ((:P) "знание HTML5, CSS3, кроссбраузерность;"))\n  ((:LI)\n   ((:P)\n    "знание английского языка как минимум на уровне общения в таск-трекере и почте;")))\n ((:P) ((:B) "Будет плюсом:"))\n ((:UL) ((:LI) ((:P) "умение работать с базами данных (MySQL, Sql Server);"))\n  ((:LI) "знание CodeIgniter фреймворка") ((:LI) "знание Unix-Shell;"))\n ((:P) ((:B) "Условия:"))\n ((:UL)\n  ((:LI) ((:P) "работа в офисе, гибкий график (40-часовая рабочая неделя);"))\n  ((:LI)\n   ((:P)\n    "уровень заработной платы обсуждается индивидуально и зависит от вашей квалификации;"))\n  ((:LI) ((:P) "кофе, чай, печенье, Xbox;"))\n  ((:LI) ((:P) "корпоративные мероприятия два раза в год;"))\n  ((:LI)\n   ((:P)\n    "50% компенсация обучения английскому в офисе (для уровней pre-intermediate и выше);"))\n  ((:LI) ((:P) "ДМС"))))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:BEENVIEWED	\N
64	12614528	f	Старший WEB-разработчик	RUR	85000	85000	от 85 000 до 150 000 руб.	150000	85000	278499	ООО Alloy Software Inc.	Санкт-Петербург	false	3–6 лет	2 февраля	((:P) ((:P) ((:B) "Требования:"))\n ((:UL) ((:LI) "Опыт работы C# Asp.Net (classic) / Asp.Net MVC")\n  ((:LI) "Знание html/css на уровне средней верстки")\n  ((:LI)\n   "Навыки дизайна Web приложений‚ разработки интерфейса и элементов управления")\n  ((:LI) "Умение работать с базами данных‚ T-SQL")\n  ((:LI)\n   "Знание и опыт работы с javascript библиотеками типа jQuery‚ extJS и т.п.")\n  ((:LI) "Опыт работы со связкой ajax/json")\n  ((:LI) "Умение разбираться и вносить изменения в существующий код")\n  ((:LI) "Владение ООП и паттернами проектирования")\n  ((:LI) "Знание технического английского языка (чтение)")\n  ((:LI) "Знание CVS или других систем контроля версий")\n  ((:LI)\n   "Плюсом будет опыт разработки веб-приложений для мобильных устройств"))\n ((:P) ((:B) "Обязанности:"))\n ((:UL) ((:LI) "Анализ требований к продукту, участие в их обсуждении")\n  ((:LI)\n   "Помощь другим разработчикам, контроль за общим качеством кода продукта")\n  ((:LI)\n   "Поддержка принятых в компании процедур разработки, отчеты о результатах")\n  ((:LI) "Взаимодействие с группами тестирования, группой Windows приложений")\n  ((:LI) "Самому писать много хорошего кода"))\n ((:P) ((:B) "Условия:"))\n ((:UL) ((:LI) "Интересные‚ перспективные проекты")\n  ((:LI) "Возможность профессионального роста")\n  ((:LI) "Работа в современном офисе")\n  ((:LI) "Оформление в соответствии с ТК РФ")\n  ((:LI)\n   "Гибкий график работы (возможность выбора начала и окончания рабочего дня)")\n  ((:LI)\n   "Корпоративные мероприятия и активный досуг (картинг‚ боулинг‚ загородный отдых)")\n  ((:LI) "Компенсация расходов на обеды и фитнес")))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:UNINTERESTING	
56	9025434	f	Senior Software Developer (TeamCity)	RUR	130000	130000	от 130 000 руб.	130000	130000	9281	 JetBrains	Санкт-Петербург	false	3–6 лет	30 декабря	((:P)\n ((:P) "Основанная в 2000 году, компания " ((:B) "JetBrains")\n  " является мировым лидером в производстве профессиональных инструментов разработки."\n  ("br" NIL) ("br" NIL)\n  "Наша цель – дать людям возможность работать c удовольствием и более продуктивно за счет использования «умных» программных решений, которые берут на себя рутинные задачи, позволяя сфокусироваться на творческой части работы."\n  ("br" NIL) ("br" NIL)\n  "Для достижения этой цели нам очень нужны талантливые, творческие, инициативные люди.")\n ((:P) ((:B) "TeamCity")\n  " – это инструмент для организации процесса непрерывной интеграции (Continuous Integration), используемый тысячами компаний во всём мире.")\n ((:P)\n  "Это серверное приложение, построенное на базе технологии J2EE, и обеспечивающее непрерывную сборку проектов, автоматическое тестирование, анализ качества кода, а также мониторинг и раннее оповещение о проблемах, возникших в процессе интеграции.")\n ((:P) ((:B) "Вам предстоит:"))\n ((:UL)\n  ((:LI) "развивать поддержку" ((:B) " .NET") " технологий в "\n   ((:B) "TeamCity")\n   ", делая продукт еще более удобным и мощным для .NET разработчиков."))\n ((:P) ((:B) "Мы ищем:"))\n ((:UL)\n  ((:LI) "эксперта в платформе " ((:B) ".NET")\n   ", который внимательно следит за изменениями, происходящими в мире .NET технологий и способен выявить тенденции развития экосистемы в целом.")\n  ((:LI)\n   "опытного профессионала, способного полностью взять на себя ответственность за развитие компоненты / подсистемы сложного серверного продукта.")\n  ((:LI) "разработчика, знающего " ((:B) "Java")\n   " в достаточной степени, чтобы понимать и развивать сопутcтвующий код на этом языке, поскольку существенная часть кода интеграции TeamCity с .NET технологиями написана на Java."))\n ((:P) ((:B) "Необходимые навыки:"))\n ((:UL)\n  ((:LI) "опыт разработки сложных систем c использованием " ((:B) ".NET") ".")\n  ((:LI) "опыт реализации проектов на " ((:B) "Java"))\n  ((:LI)\n   "знание и опыт использования средств разработки под .NET (NuGet, TFS, MSBuild, unit testing frameworks, coverage tools) понимание принципов OOP понимание принципов клиент-серверных приложений умение разбираться и рефакторить как свой, так и чужой код самостоятельность, организованность, ответственность умение и желание работать без непосредственного контроля умение работать в распределенной команде (Санкт-Петербург - Мюнхен - Прага) уверенное владение английским языком"))\n ((:P) ((:B) "Плюсами будут:"))\n ((:UL)\n  ((:LI)\n   "опыт разработки своих собственных или open source проектов (ссылки в CV приветствуются)")\n  ((:LI)\n   "опыт использования TeamCity или других систем непрерывной интеграции"))\n ((:P) ((:B) "Мы предлагаем:"))\n ((:UL) ((:LI) "увлекательную работу в дружном молодом коллективе")\n  ((:LI)\n   "участие в разработке продуктов, нацеленных на таких же, как мы, разработчиков")\n  ((:LI)\n   "высокую заработную плату (обсуждается индивидуально, заведомо выше средней для отрасли)")\n  ((:LI) "премии по итогам релизов") ((:LI) "гибкий график работы")\n  ((:LI) "оформление по Трудовому Кодексу")\n  ((:LI) "оплачиваемый отпуск (5 рабочих недель)")\n  ((:LI) "оплачиваемый больничный")\n  ((:LI) "ДМС (со стоматологией), ДМС для детей")\n  ((:LI) "просторный современный офис (открыт круглосуточно), парковка")\n  ((:LI) "эргономичные рабочие места и уютные зоны отдыха")\n  ((:LI) "горячие обеды, напитки, фрукты, снэки")\n  ((:LI) "нужные для работы книги и журналы, библиотека")\n  ((:LI) "обучение (уроки английского, немецкого языков)")\n  ((:LI) "спортзал в офисе (с душевыми), массажный кабинет, игровая зона")\n  ((:LI) "возможность участия в конференциях в США и Европе")\n  ((:LI) "помощь в переезде из другого региона.")))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:UNINTERESTING	\N
57	11927260	f	Senior Software Developer (MPS)	RUR	130000	130000	от 130 000 руб.	130000	130000	9281	 JetBrains	Санкт-Петербург	false	3–6 лет	30 декабря	((:P)\n ((:P)\n  "Основанная в 2000 году, компания JetBrains является мировым лидером в производстве профессиональных инструментов разработки.")\n ((:P)\n  "Наша цель – дать людям возможность работать c удовольствием и более продуктивно за счет использования «умных» программных решений, которые берут на себя рутинные задачи, позволяя сфокусироваться на творческой части работы. В настоящий момент среди продуктов компании IDE для Java, HTML, PHP, Objective C, Ruby, Python и других, инструменты для поддержки командной работы, профайлер и другие. Также ведется работа над еще не анонсированными продуктами.")\n ((:P)\n  "Для помощи в создании самых умных инструментов для программиста нам очень нужны талантливые, творческие, инициативные люди.")\n ((:P) "Одним из продуктов, разрабатываемых компанией JetBrains является "\n  ((:B) "система мета-программирования MPS"))\n ((:P) ((:B) "Вам предстоит: "))\n ((:UL) ((:LI) "участвовать в разработке ядра продукта MPS"))\n ((:P) ((:B) "Необходимые навыки:"))\n ((:UL)\n  ((:LI)\n   "опыт программирования на Java в коммерческих проектах не менее 5-ти лет")\n  ((:LI) "глубокое понимание OOP")\n  ((:LI) "знания основных алгоритмов и структур данных")\n  ((:LI) "общая математическая эрудиция") ((:LI) "опыт программирования UI")\n  ((:LI) "опыт многопоточного программирования")\n  ((:LI) "умение оптимизировать и рефакторить как свой, так и чужой код")\n  ((:LI)\n   "ответственность, самостоятельность, организованность умение работать в команде"))\n ((:P) ((:B) "Плюсами будут:"))\n ((:UL) ((:LI) "опыт разработки IDE")\n  ((:LI)\n   "использование или создание DSL в предыдущих проектах опыт работы с системами генерации кода знание других языков и других парадигм (Kotlin, Groovy, Haskell, Objective C, Python, Scala, Ruby, etc.)"))\n ((:P) ((:B) "Мы предлагаем:"))\n ((:UL) ((:LI) "увлекательную интересную работу в дружном молодом коллективе")\n  ((:LI)\n   "участие в разработке продуктов, нацеленных на таких же, как мы, разработчиков")\n  ((:LI)\n   "оформление по Трудовому Кодексу (ОМС, оплачиваемый отпуск 5 рабочих недель)")\n  ((:LI)\n   "компенсация больничного листа до полной зарплаты ДМС, включая стоматологию, а также оплачиваемое компанией ДМС для детей сотрудников премии по итогам релизов")\n  ((:LI) "гибкий график работы")\n  ((:LI) "комфортный большой офис (открыт круглосуточно) с душем")\n  ((:LI)\n   "бесплатные горячие обеды, а также кофе, чай, бутерброды, питьевая вода")\n  ((:LI)\n   "нужные для работы книги и журналы, библиотека в офисе обучение (уроки английского языка в офисе)")\n  ((:LI) "возможность участия в конференциях в США и Европе")\n  ((:LI) "помощь в переезде из другого региона")))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:UNINTERESTING	\N
22	12283151	f	Системный архитектор	RUR	100000	100000	от 100 000 руб.	100000	100000	728292	 СПбИАЦ	false	Лиговский проспект	3–6 лет	30 января	((:P) ((:P) ((:B) "Обязанности:"))\n ((:UL) ((:LI) "Разработка и развитие архитектуры решений;")\n  ((:LI)\n   "Постановка задач как внешним вендорам, так и внутренней команде разработки;")\n  ((:LI) "Управление архитектурой проекта;") ((:LI) "Архитектурный надзор"))\n ((:P) ((:B) "Требования:"))\n ((:UL) ((:LI) "Опыт работы в области IT от 5 лет;")\n  ((:LI) "Опыт работы архитектором / проектировщиком от 2 лет;")\n  ((:LI) "Опыт проектирования и внедрения высоконагруженных систем;")\n  ((:LI) "Хорошее понимание принципов SOA, ООП;")\n  ((:LI) "Опыт проектирования систем с использованием J2EE;")\n  ((:LI) "Опыт разработки архитектуры Enterprise систем будет преимуществом;")\n  ((:LI) "Знание и опыт применения паттернов проектирования;")\n  ((:LI) "Знание UML на уровне опытного проектировщика;")\n  ((:LI) "Знание методологий разработки будет вашим преимуществом."))\n ((:P) ((:B) "Профессиональные знания и умения: "))\n ((:UL) ((:LI) "Аккуратность и ответственность,") ((:LI) "Знание uml,")\n  ((:LI) "Опыт работы с git,") ((:LI) "Знание шаблонов проектирования,")\n  ((:LI) "Знание структур данных и алгоритмов,")\n  ((:LI) "Ведение технической документации;")\n  ((:LI) "Проведение code review и рефакторинга;")\n  ((:LI) "Понимание теории (и практики) построения баз данных."))\n ((:P) ((:B) "Дополнительные требования к кандидату:"))\n ((:UL)\n  ((:LI)\n   "Опыт проектирования и разработки приложений с клиент-серверной архитектурой, сервис-ориентированной архитектурой."))\n ((:P) ("br" NIL) ((:B) "Условия:"))\n ((:UL) ((:LI) "Трудоустройство в соответствии с ТК РФ")\n  ((:LI) "Достойная заработная плата ( обсуждается с успешным кандидатом)")\n  ((:LI) "Система премирования") ((:LI) "Соц. пакет + ДМС")\n  ((:LI) "Обучение, карьерный рост")))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:RESPONDED	\N
41	12479362	f	Веб-программист	RUR	100000	100000	до 100 000 руб.	100000	100000	29413	 Деловые Линии	false	Московская	1–3 года	26 января	((:P)\n ((:P)\n  "Служба интернет-коммуникаций компании \\"Деловые линии\\", лидера в сфере междугородных грузоперевозок, приглашает на работу Веб-программиста")\n ("br" NIL) ((:P) ((:B) "Обязанности:"))\n ((:UL)\n  ((:LI) "Разработка и сопровождение интернет- и интранет-проектов компании;"))\n ((:P) ((:B) "Требования:"))\n ((:UL)\n  ((:LI)\n   "Опыт работы в проектировании и программировании веб-сайтов от 3 лет;")\n  ((:LI) "Умение в одиночку спроектировать и написать сайт любой сложности;")\n  ((:LI)\n   "Опыт проектирования БД, архитектуры кода, интеграционных схем, интерфейсов;")\n  ((:LI) "Навыки работы с XML, XSLT;")\n  ((:LI) "Образование высшее или среднее специальное;")\n  ((:LI)\n   "Знание HTML/XHTML/CSS, jQuery, MySQL и любого из перечисленных языков: Parser3, Python, Ruby."))\n ((:P) ((:B) "Условия:"))\n ((:UL)\n  ((:LI)\n   "Участие в разносторонних масштабных проектах с применением современных технологий;")\n  ((:LI) "Инфраструктурная обеспеченность;")\n  ((:LI) "Рабочее место, оснащённое современным оборудованием;")\n  ((:LI) "Работа в комфортном офисе класса А.")))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:RESPONDED	\N
76	12733670	f	Системный аналитик	RUR	70000	70000	от 70 000 до 90 000 руб.	90000	70000	178925	 Екассир	false	Чёрная речка	3–6 лет	6 февраля	((:P)\n ((:P)\n  "Екассир, продуктовая компания в области программных решений для ДБО, платежных, билетных и рекламных систем, приглашает грамотного специалиста на должность Системного аналитика.")\n ((:P) ((:B) "Обязанности:"))\n ((:UL)\n  ((:LI)\n   "Участие в разработке продуктов компании (высоконагруженные системы обработки транзакций, системы дистанционного банковского обслуживания, рекламные и билетные системы) с повышенными требованиями к надежности и безопасности;")\n  ((:LI)\n   "Разработка и согласование спецификаций и протоколов ПО на новый функционал продуктов компании, как с использованием общепринятых стандартов и нотаций, так и без них;")\n  ((:LI)\n   "Постановка задачи на кастомизацию продуктов и разработку интеграционных модулей для внедрения и стыковки с информационными системами клиента (АБС) и третьих лиц (биллинговые системы получателей платежей, агрегаторы, системы денежных переводов) при внедрениях в России и за рубежом;")\n  ((:LI)\n   "Взаимодействие с клиентом по вопросам выявления требований и спецификаций, взаимодействие с коллективом разработчиков;")\n  ((:LI) "Разработка технологических решений, оценка трудоемкости;")\n  ((:LI)\n   "Разработка технической проектной документации (техническое описание и спецификация внедряемых решений)."))\n ((:P)) ((:P) ((:B) "Требования:"))\n ((:UL) ((:LI) "Образование: высшее в области ИТ, программирования;")\n  ((:LI)\n   "Опыт участия в разработке ПО платежных систем или в банковской сфере, понимание принципов банковского учета;")\n  ((:LI)\n   "Понимание принципов построения распределенных архитектур клиент-серверных приложений;")\n  ((:LI)\n   "Знание основ бухгалтерского учета, принципов функционирования платежных систем;")\n  ((:LI) "Знание основ реляционных баз данных, навыки написания SQL запросов;")\n  ((:LI)\n   "Знания в области администрирования ОС Windows (2003 Server, XP), сетевых технологий;")\n  ((:LI)\n   "Знание принципов обеспечения безопасности информации, шифрования, ЭЦП;")\n  ((:LI) "Навыки составления технической документации;")\n  ((:LI) "Приветствуется опыт программирования.")\n  ((:LI) "Преимущество кандидатам, владеющим разговорным английским."))\n ((:P) "Личные качества:")\n ((:UL)\n  ((:LI)\n   "Высокая обучаемость, коммуникативные навыки, умение решать нестандартные задачи."))\n ((:P) ((:B) "Условия:"))\n ((:UL)\n  ((:LI)\n   "Заработная плата в зависимости от квалификации кандидата и уровня задач, которые он способен решить, указаны ориентировочные рамки.")\n  ((:LI)\n   "Оформление по ТК РФ, полный рабочий день, пятидневка, возможен индивидуальный гибкий график.")\n  ((:LI) "Работа в стабильной компании, дружная профессиональная команда.")\n  ((:LI) "Мы гарантируем интересные задачи и профессиональный рост.")\n  ((:LI)\n   "Удобный офис с кондиционером в 10 минутах ходьбы от м. Черная Речка.")))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:UNSORT	
18	12689535	f	PHP developer	RUR	100000	100000	от 100 000 до 150 000 руб.	150000	100000	1022120	 MBT	false	Новочеркасская	3–6 лет	1 февраля	((:P)\n ((:P)\n  "Крупная, международная компания, в связи с активным развитием проекта, в поисках "\n  ((:B) "PHP developer'ов ") "на следующие участки:")\n ((:UL) ((:LI) "API;") ((:LI) "Отчеты, статистика;") ((:LI) "Ядро;")\n  ((:LI) "Парнерская программа (маркетинг);")\n  ((:LI) "Continuous Integration."))\n ((:P)\n  "Мы ищем опытного специалиста, который готов включиться в разработку сложного, но безумно интересного проекта.")\n ((:P) ((:B) "Мы очень хотим с вами познакомиться если вы знаете:"))\n ((:UL) ((:LI) "PHP (5.*) ООП;") ((:LI) "PostgreSQL, опыт проектирования БД;")\n  ((:LI) "Систему контроля версий;") ((:LI) "PHPUnit (либо аналоги);")\n  ((:LI) "Технический английский."))\n ((:P) ((:B) "Вы готовы к решению следующих задач:"))\n ((:UL) ((:LI) "Сode review;") ((:LI) "Проектирование разработки;")\n  ((:LI) "Изучение новых технологий и повышение уровня собственных знаний."))\n ((:P) ((:B) "Вашим конкурентным преимуществом будет:"))\n ((:UL) ((:LI) "Опыт работы с Linux;")\n  ((:LI) "Опыт работы с Redis, Nginx, NodeJS;")\n  ((:LI) "Опыт работы с HighLoad проектами;")\n  ((:LI) "Опыт разработки по методологии Kanban."))\n ((:P) ((:B) "Нашему будущему мы готовы предложить:"))\n ((:UL) ((:LI) "Трудоустройство согласно ТК РФ;")\n  ((:LI)\n   "Работа в уютном офисе, в десяти минутах ходьбы от с.м. Новочеркасска;")\n  ((:LI) "Компенсация обедов, занятий в спорт зале;")\n  ((:LI) "Участие в профильных мероприятиях (семинарах, конференциях);")\n  ((:LI) "Unlimited чай, печеньки, фрукты и турниры по киккеру.")))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:BEENVIEWED	\N
6	12496861	f	Фронтенд разработчик, PHP	RUR	35000	35000	от 35 000 до 100 000 руб.	100000	35000	1692070	ООО Деловая практика	Санкт-Петербург	false	3–6 лет	3 февраля	((:P) ((:B) "Обязанности:")\n ((:UL)\n  ((:LI)\n   "разработка фронтенда в соответствии с проектной документацией, поддержка и развитие системы")\n  ((:LI) "активная самостоятельная работа, совместная работа с разработчиками")\n  ((:LI) "подчинение техническому директору"))\n ("br" NIL) ((:B) "Требования:")\n ((:UL)\n  ((:LI) "понимание принципов разработки и опыт разработки AJAX интерфейсов")\n  ((:LI) "хорошее знание PHP") ((:LI) "опыт работы с PostgreSQL DB")\n  ((:LI) "хорошие знания Linux и интерфейса командной строки"))\n ((:P) ((:B) "Будет плюсом:"))\n ((:UL) ((:LI) "опыт работы в Highload-проектах")\n  ((:LI) "опыт проектирования и разработки интерфейсов мобильных приложений")\n  ((:LI) "опыт работы в проектах, связанных с аггрегацией заказа билетов"))\n ("br" NIL) ((:B) "Условия")\n ((:UL)\n  ((:LI)\n   "Redmine + GIT, часть недели можно работать удаленно (Skype meetings)")\n  ((:LI)\n   "оформление по контракту, после прохождения испытательного срока зарплата индексируется по курсу евро")\n  ((:LI) "испытательный срок")\n  ((:LI) "возможность профессионального и карьерного роста"))\n ((:P)\n  ((:B)\n   "При отправке резюме, напишите пару слов о том, в каких проектах участвовали. Резюме без описания опыта работы с конкретными технологиями рассматриваться не будут.")))	Попробовать отправить еще одно резюме с меньшей зп	Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:RESPONDED	\N
52	12561742	f	Разработчик конфигураций (Build Engeneer)	RUR	60000	60000	от 60 000 до 130 000 руб.	130000	60000	703437	 Betria inc	false	Лиговский проспект	3–6 лет	14 января	((:P) ((:P) ((:B) "Требования:"))\n ((:UL) ((:LI) "С++") ((:LI) "Знание скриптовых языков (bash, python)")\n  ((:LI) "Написание скриптов для работы QMake.")\n  ((:LI) "Опыт создания и поддержки DEB, RPM пакетов")\n  ((:LI)\n   "Особенности работы с компиляцией кода под множество платформ (Linux, Android, IOS).")\n  ((:LI)\n   "Английский язык - разговорный и письменный (общение с носителями обязательно)"))\n ((:P) ((:B) "Желательно") ":")\n ((:UL) ((:LI) "Знание процесса тестирования и особенностей разработки ПО")\n  ((:LI) "Знания по настройке и администрированию: Linux")\n  ((:LI) "Опыт создания автоматизированного Deployment"))\n ((:P) ((:B) "Условия:"))\n ((:UL)\n  ((:LI)\n   "Заработная плата по итогам собеседования, в зависимости от знаний и навыков"))\n ((:P) "Адрес")\n ((:UL) ((:LI) "Санкт-Петербург, м. пл. Восстания проспект, Лиговский")))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:UNINTERESTING	\N
77	12733398	f	Руководитель/Team Lead группы разработки	RUR	70000	70000	от 70 000 до 120 000 руб.	120000	70000	7851	 RealWeb, Интернет-агентство	false	Крестовский остров	1–3 года	6 февраля	((:P)\n ((:P)\n  "Быстро развивающееся SEO-направление ищет в свою команду разработки увлеченного специалиста, который знает, что работа над проектом станет успешной и эффективной только усилиями сплоченной команды, работающей на общую цель!")\n ((:P)\n  "Наш будущий сотрудник — увлеченный человек. Несмотря на всю техничность мышления, он способен параллельно генерить идеи по усовершенствованию и развитию. Он способен четко и понятно ставить задачи, спланировать и замотивировать. Может объяснить клиенту, чем наш продукт будет полезен его бизнесу, а программисту - суть технической задачи.")\n ((:P)\n  ((:B)\n   "Мы постарались лаконично и структурировано изложить, какого человека мы ждем:"))\n ((:UL)\n  ((:LI) "успешный опыт руководства группой специалистов "\n   ((:B) "не менее двух лет") ";")\n  ((:LI) "опыт разработки крупных нестандартных web-проектов "\n   ((:B) "не менее 3х лет") ";")\n  ((:LI)\n   "умение найти общий язык и выстроить конструктивный диалог в любой ситуации;")\n  ((:LI) "желание расти и развиваться вместе с командой;")\n  ((:LI)\n   "способность и готовность структурировать и совершенствовать бизнес-процессы, в которых крутится работа;")\n  ((:LI) "высшее образование (техническое)."))\n ((:P)\n  ((:B)\n   "Профессиональные знания, которые мы ищем в нашем успешном кандидате:"))\n ((:UL)\n  ((:LI)\n   "навыки работы как с популярными CMS (Joomla, Bitrix, WordPress, UMI), так и самописными всякими разными;")\n  ((:LI) "умение разбираться в созданном коде;")\n  ((:LI) "есть четкое представление, что такое SEO;")\n  ((:LI) "уверенные знания в ООП;")\n  ((:LI) "опыт создания/кастомизации компонентов/модулей;")\n  ((:LI) "базовые знания серверного администрирования."))\n ((:P) ((:B) "Личные качества:"))\n ((:UL) ((:LI) "высокая самоорганизованность и самодисциплина;")\n  ((:LI) "ответственность и внимание к деталям;")\n  ((:LI) "требовательность и справедливость к коллегам;")\n  ((:LI) "увлеченность, интерес к новинкам в области веб-разработок;")\n  ((:LI) "природная потребность в соблюдении анонсированных сроков;")\n  ((:LI) "умение четко и понятно ставить задачи, объяснять, мотивировать."))\n ((:P) ((:B) "Объем задач:"))\n ((:UL)\n  ((:LI)\n   "руководство командой специалистов (и команда будет расти и развиваться под Вашим чутким руководством);")\n  ((:LI) "организация и построение бизнес-процессов;")\n  ((:LI) "оценка и планирование поступающих задач (объемы, сроки);")\n  ((:LI) "участие в разработке на особо хитрых/редких/vip проектах;")\n  ((:LI)\n   "координирование рабочих процессов внутри команды, взаимодействие со смежными подразделениями;")\n  ((:LI) "встречи с клиентами, составление КП, допродажи;")\n  ((:LI) "развитие линейки услуг для клиентов;")\n  ((:LI) "ведение отчетности по проекту;")\n  ((:LI) "освоение и внедрение новых технологий."))\n ((:P) ((:B) "Мы предлагаем:"))\n ((:UL)\n  ((:LI)\n   "действительно крупные и интересные проекты (\\"Петрович\\", \\"Zarina\\", \\"Стройтрест\\" и многие другие известные бренды);")\n  ((:LI)\n   "достойный уровень дохода (оклад + %) – обсуждается индивидуально (готовы обсудить Ваше предложение);")\n  ((:LI)\n   "работа в комфортном офисе на Крестовском острове (рядом с метро/без проблем с парковкой);")\n  ((:LI) "дружный коллектив, позитивная рабочая атмосфера;")\n  ((:LI) "возможность карьерного роста и обучения за счет компании.")))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:UNSORT	
10	12661208	f	Руководитель проектов	RUR	120000	120000	от 120 000 руб.	120000	120000	1497729	ООО STORVERK	Санкт-Петербург	false	3–6 лет	3 февраля	((:P)\n ((:P)\n  "Компания StorVerk внедряет эффективные решения для комплексной автоматизации бизнеса. Мы приводим процессы компании к соответствию российским и международным стандартам менеджмента (ISO 9000, ISO 14000, ISO 22000/HACCP). StorVerk поможет наглядно представить Ваши существующие бизнес-процессы, оптимизировать их и управлять ими.")\n ((:P) "StorVerk:CRM — ведущий продукт нашей компании.")\n ((:P)\n  "При его разработке мы использовали многолетний опыт реальных торгово-производственных компаний, соединив современные IT инструменты и знания об особенностях функционирования сектора b2b.")\n ((:P) ((:B) "Вам предстоит:"))\n ((:UL)\n  ((:LI)\n   "Ведение проектов, сложных и интересных, по автоматизации предприятий на базе платформы 1С 8.0 с командой программистов")\n  ((:LI)\n   "Составление технических заданий для программистов, доработка прикладных решений по техническим заданиям")\n  ((:LI)\n   "Оценка трудоемкости задач и сроков их исполнения, осуществление контроля и проверки заданий у программистов")\n  ((:LI) "Поиск и исправление ошибок в коде")\n  ((:LI) "Ведение проектной документации."))\n ((:P) ((:B) "Нам важно:"))\n ((:UL) ((:LI) "Профильное образование")\n  ((:LI)\n   "Опыт программирования в среде 1С (7.7, 8.0, 8.1,8.2), знание механизмов платформы 1С, умение качественно писать код, желателен опыт изменения типовых конфигураций")\n  ((:LI)\n   "Активная жизненная позиция, умение влиять на людей, объединять их для решения общих задач")\n  ((:LI) "Знание других языков программирования")\n  ((:LI) "Наличие сертификатов специалиста по 1С будет Вашим преимуществом"))\n ((:P) ((:B) "Мы предлагаем:"))\n ((:UL)\n  ((:LI) "Интересные проекты, творческую реализацию и профессиональный рост")\n  ((:LI)\n   "Работу в динамичной IT-компании, входящей в состав крупного холдинга")\n  ((:LI) "Соблюдение норм ТК, расширенный соц. пакет")\n  ((:LI)\n   "Комфортные условия труда, офис в шаговой доступности от ст. м . \\"пл. Ленина\\"")\n  ((:LI)\n   ((:B) ((:B) "Мы будем рады рассмотреть Ваше резюме и встретиться лично")))))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:UNINTERESTING	\N
78	12752999	f	Начальник отдела перспективных разработок	RUR	90000	90000	от 90 000 руб.	90000	90000	184152	ЗАО Технические Системы и Технологии	false	Спортивная	3–6 лет	10 февраля	((:P) ((:P) ((:B) "Обязанности:"))\n ((:UL)\n  ((:LI)\n   "Руководство проектами по созданию аппаратных средств и программного обеспечения от разработки и согласования ТЗ до испытаний опытного образца;")\n  ((:LI)\n   "Определение перспективных направлений разработки и ключевых технических решений;")\n  ((:LI) "Руководство отделом."))\n ((:P)) ((:P) ((:B) "Требования:"))\n ((:UL)\n  ((:LI)\n   "Высшее техническое образование (электроника, радиотехника, информатика и вычислительная техника);")\n  ((:LI) "Опыт аналогичной работы не менее 5-ти лет;")\n  ((:LI) "Знание цифровой и аналоговой схемотехники;")\n  ((:LI) "Опыт разработки ПО под Windows, Linux, QNX;")\n  ((:LI) "Знание требований нормативных документов ЕСКД, ЕСПД."))\n ((:P)) ((:P) ((:B) "Будет плюсом:"))\n ((:UL)\n  ((:LI)\n   "Практический опыт применения элементной базы: ПЛИС (Altera), микроконтроллеры (AVR, ARM7, ARM9), цифровые сигнальные процессоры (SHARC, MC-12, MC-24);")\n  ((:LI)\n   "Знание и опыт применения языков программирования (C, VHDL) под МК и ПЛИС соответственно;")\n  ((:LI) "Владение MATLAB и опыт применения для расчетов и моделирования;")\n  ((:LI)\n   "Знание высокоуровневого языка программирования (C++, C#), QNX, Windows, Linux."))\n ((:P)) ((:P) ((:B) "Условия:"))\n ((:UL) ((:LI) "Полная занятость;") ((:LI) "Пятидневная рабочая неделя;")\n  ((:LI) "Оформление в соответствии с трудовым кодексом РФ.")))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:UNSORT	
53	12561155	f	Программист трехмерной среды для бизнес-коммуникаций	RUR	100000	100000	от 100 000 до 100 000 руб.	100000	100000	444428	 Elverils.LLC	Санкт-Петербург	false	1–3 года	14 января	((:P) ((:P) ((:B) "Обязанности:"))\n ((:UL)\n  ((:LI)\n   "Разработка клиентского 3D приложения Win32 для многопользовательской игровой бизнес системы")\n  ((:LI) "Документирование полученных результатов"))\n ("br" NIL) ((:P) ((:B) "Требования (Unreal):"))\n ((:UL) ((:LI) "Фундаментальные знания C++")\n  ((:LI) "Хорошие знания платформы Unreal")\n  ((:LI) "Начальные знания технологии UnrealScript")\n  ((:LI)\n   "Хорошее знание и понимание протоколов TCP/IP группы и знание BSD Socket's API")\n  ((:LI)\n   "Хорошее знание устройства Win32/64 платформ включая примитивы ядра, многопоточность, асинхронные вызовы")\n  ((:LI) "Английский язык (как минимум уверенное письмо)"))\n ("br" NIL) ((:P) ((:B) "Дополнительно:"))\n ((:UL) ((:LI) "Начальные знание iOS/OS X") ((:LI) "Начальные знания Unix")))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:UNINTERESTING	\N
79	12752078	f	Разработчик мобильных приложений	RUR	40000	40000	от 40 000 до 100 000 руб.	100000	40000	751767	 Playvision	false	Площадь Ленина	1–3 года	10 февраля	((:P) ((:P) "Требуется универсальный разработчик мобильных приложений") ((:P))\n ((:P) ((:B) "Задачи:"))\n ((:UL)\n  ((:LI) "Разработка и поддержка собственного SDK для мобильных приложений")\n  ((:LI) "Разработка мобильных приложений"))\n ((:P)) ((:P) ((:B) "Требования:"))\n ((:UL) ((:LI) "Опыт разработки под iOS и Android")\n  ((:LI) "Уверенные знания Objective C и Java")\n  ((:LI) "Знание iOS SDK, общее понимание архитектуры iOS")\n  ((:LI) "Знание Android SDK и основ архитектуры Android")\n  ((:LI) "Понимание особенностей разных версий iOS и Android")\n  ((:LI) "Знание HTML, Javascript") ((:LI) "Уверенное использование Git"))\n ((:P)) ((:P) ((:B) "Условия:"))\n ((:UL) ((:LI) "Работа только в офисе")\n  ((:LI) "График: понедельник - пятница с 10:00 до 19:00 (1 час обед)")\n  ((:LI) "Офис класса А. Бесплатная развозка от метро пл. Ленина")\n  ((:LI)\n   "Рядом с БЦ 2 кафе (оплачиваемое питание после исп. срока), парковка авто (платная) и мото/вело (бесплатно)")\n  ((:LI) "В офисе чай, кофе, печеньки")\n  ((:LI) "Стабильная белая заработная плата") ((:LI) "Официальное оформление")\n  ((:LI) "Испытательный срок (2-3 мес.)")))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:UNSORT	
80	12740504	f	Инженер по внедрению	RUR	60000	60000	от 60 000 до 90 000 руб.	90000	60000	4156	 OpenWay Group	Санкт-Петербург	false	3–6 лет	9 февраля	((:P)\n ((:P)\n  "Группа компаний OpenWay – мировой лидер в области разработки и внедрения программных решений для финансовых процессингов - в связи с расширением объявляет конкурс на позицию инженера по внедрению.")\n ((:P) ((:B) "Обязанности:"))\n ((:UL)\n  ((:LI)\n   "Участие в проектах (в том числе международных) по внедрению модулей карточных систем в банках и процессинговых центрах: "\n   ("ul" NIL ("li" NIL "сбор и анализ требований клиента;")\n    ("li" NIL "участие в разработке спецификаций и проектировании решения;")\n    ("li" NIL "оценка трудоемкости реализации требований;")\n    ("li" NIL "настройка и кастомизация модулей системы;")\n    ("li" NIL "организация установки и запуска системы на сайте клиента;")\n    ("li" NIL\n     "управление проектами малого и среднего размера (при достижении экспертного уровня знаний)."))))\n ((:P) ((:B) "Требования:"))\n ((:UL)\n  ((:LI) ((:B) "Образование:")\n   ("ul" NIL ("li" NIL "высшее техническое (IT, математика, физика)")))\n  ((:LI) ((:B) "Опыт работы")\n   " в сфере информационных технологий – от 3-х лет, в том числе опыт хотя бы в одной из следующих областей: "\n   ("ul" NIL ("li" NIL "«большие» БД (разработка и/или администрирование);")\n    ("li" NIL "участие в разработке больших распределенных прикладных систем;")\n    ("li" NIL\n     "тестирование больших распределенных прикладных программных систем;")\n    ("li" NIL "внедрение / поддержка таких систем")))\n  ((:LI) ((:B) "Знания и навыки:")\n   ("ul" NIL\n    ("li" NIL\n     "понимание теоретических основ и общая эрудиция в области IT , знание жизненного цикла ПО, основ проектирования, разработки и обеспечения качества ПО;")\n    ("li" NIL "навыки разработки ПО (C/C++, Java, PL/SQL) будут плюсом;")\n    ("li" NIL\n     "понимание теории и практики СУБД (разработки и/или администрирования);")\n    ("li" NIL "навыки работы с ОС семейства *nix будут плюсом;")\n    ("li" NIL "«рабочий» уровень английского языка;")\n    ("li" NIL\n     "навыки ведения деловой переписки и составления проектной документации будут плюсом.")))\n  ((:LI) ((:B) "А также:")\n   ("ul" NIL ("li" NIL "системность мышления, аналитические способности;")\n    ("li" NIL "позитивная профессиональная мотивация и конструктивность;")\n    ("li" NIL "ответственность и аккуратность;")\n    ("li" NIL "активная жизненная позиция;")\n    ("li" NIL "хорошие коммуникативные навыки;")\n    ("li" NIL "желание и умение учиться."))))\n ((:P) ((:B) "Условия:"))\n ((:UL) ((:LI) "Интересные и сложные задачи, командировки;")\n  ((:LI)\n   "Работа в профессиональном коллективе интересных людей, комфортные условия работы;")\n  ((:LI) "Обучение;")\n  ((:LI) "Конкурентоспособная заработная плата и соцпакет.")))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:UNSORT	
45	12615410	f	Менеджер проектов	RUR	60000	60000	от 60 000 до 1 000 000 руб.	1000000	60000	63585	 WEBDOM, группа компаний	false	Гражданский проспект	1–3 года	21 января	((:P)\n ((:P)\n  "Группа компаний \\"Вебдом\\" (webdom.net) ищет менеджера по ведению проектов в отдел разработки мобильных приложений и информационных систем.")\n ((:P)\n  ((:B)\n   "Работа только с иностранными заказчиками! Обязательно отличное знание разговорного английского языка! "))\n ((:P) ((:B) "Должностные обязанности: "))\n ((:UL)\n  ((:LI)\n   "первичный сбор и формализация требований, написание технического задания и согласование его с заказчиком;")\n  ((:LI) "разработка проектной документации;")\n  ((:LI) "планирование и контроль работ по проекту;")\n  ((:LI) "сдача работ заказчику."))\n ((:P) ((:B) "Требования: "))\n ((:UL) ((:LI) "высшее техническое образование в IT области;")\n  ((:LI) "опыт управления проектами, руководства отделом, группой;")\n  ((:LI) "навыки оценки и формализации бизнес-процессов;")\n  ((:LI) "навыки планирования, управления и контроля;")\n  ((:LI)\n   "опыт работы: не менее 1 года на управляющей должности в сфере информационных технологий;")\n  ((:LI) "знание современных Интернет-технологий и бизнес-процессов;")\n  ((:LI) "системное мышление, коммуникабельность;")\n  ((:LI) ((:B) "отличное знание разговорного английского языка") "!"))\n ((:P) ((:B) "Условия:"))\n ((:UL) ((:LI) "работа ТОЛЬКО офисе;")\n  ((:LI) "оплата по результатам собеседования от 60000 руб, + премии;")\n  ((:LI)\n   "испытательный срок 2 месяца, заработная плата на испытательный срок по результатам собеседования;")\n  ((:LI) "оформление в соответствии с трудовым законодательством РФ;")\n  ((:LI) "соц.пакет, мед.страховка, премии.")))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:UNINTERESTING	\N
60	12091953	f	Senior PHP developer (высоконагруженный рекламный сервер)	RUR	100000	100000	от 100 000 до 170 000 руб.	170000	100000	707239	 Embria	false	Петроградская	3–6 лет	3 февраля	((:P)\n ((:P)\n  "Компания YoulaMedia занимается интернет-рекламой на мировом уровне. В связи с расширением, мы ищем по-настоящему сильных PHP-разработчиков, которым сможем доверить самые сложные и важные задачи, связанные с развитием основы всей нашей рекламной сети — "\n  ((:B) "высоконагруженного рекламного сервера") " (adserver).")\n ((:P) ((:B) "Наши требования просты:"))\n ((:UL) ((:LI) "Глубокие практические знания PHP;")\n  ((:LI) "Серьезный опыт работы с MySQL и Redis;")\n  ((:LI) "Реальный опыт разработки высоконагруженных приложений;")\n  ((:LI) "Умение работать в командной строке Linux."))\n ((:P) ((:B) "Дополнительным плюсом будут:"))\n ((:UL) ((:LI) "Знание Go;") ((:LI) "Опыт работы с Cassandra;")\n  ((:LI) "Знание Docker."))\n ((:P) ((:B) "Задачи (всегда сложные и интересные):"))\n ((:UL)\n  ((:LI)\n   "Развитие adserver-а (разработка новых решений и оптимизация существующих)."))\n ((:P) ((:B) "Наш adserver, это:"))\n ((:UL)\n  ((:LI)\n   "Система, по функциональности опережающая конкурирующие на мировом рынке аналоги;")\n  ((:LI)\n   "Настоящий highload — 800M запросов на показ рекламы (ad request) в сутки, 100+ серверов, 15K записей в базу в секунду, 1000M записей в базу в сутки, 120 стран охват по Geo, в 20 раз — рост нагрузки за последний год, в 10 раз — прогноз роста нагрузки на ближайший год);")\n  ((:LI)\n   "Самые прогрессивные на текущий момент технологии, которые мало кто использует в России."))\n ((:P) ((:B) "Условия:"))\n ((:UL)\n  ((:LI)\n   "Комфортные условия работы: новый бизнес центр класса A+ недалеко от м. \\"Петроградская\\"; выделенные зоны отдыха (чай, кофе, орешки, йогурты, печенье и прочие «вкусности»); корпоративные праздники, выезды.")\n  ((:LI) "Официальное оформление по ТК РФ.")\n  ((:LI) "Рабочий график с 11 до 20") ((:LI) "Отпуск 28 календарных дней.")\n  ((:LI)\n   "Уровень заработной платы обсуждается на интервью. Мы готовы платить за качественный результат выше рынка.")\n  ((:LI) "Испытательный срок 2 месяца.")))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:RESPONDED	/applicant/negotiations/item?topicId=483458139
20	12688645	f	UX Дизайнер	RUR	40000	40000	от 40 000 до 90 000 руб.	90000	40000	1388471	 Супрематика	false	Петроградская	1–3 года	31 января	((:P)\n ((:P)\n  "Требуется креативный, нацеленный на результат специалист в области User eXperience.")\n ((:P)\n  "Мы ищем командного игрока для участия в активно развивающемся проекте, связанном с облачными технологиями.")\n ((:P)\n  "Если Вы предпочитаете работу от звонка до звонка - эта вакансия не для Вас.")\n ((:P)\n  "Если Вам интересно решать нестандартные задачи, добиваться результата любыми средствами, и у Вас \\"понедельник начинается в субботу\\" - ждем Ваше резюме и портфолио,")\n ((:P)\n  "Амбициозность, подкрепленная высокими профессиональными качествами, приветствуется.")\n ((:P)\n  "Участие в успешном и зрелом инновационном стартапе, получившем инвестиции - возможность реализовать себя на 100%.")\n ((:P) ((:B) "Обязанности:"))\n ((:UL)\n  ((:LI)\n   "Разработка пользовательского интерфейса для веб-приложений, мобильных приложений")\n  ((:LI) "Веб-дизайн, брендинг, фирменный стиль")\n  ((:LI) "Предметный 3D дизайн, промышленный дизайн"))\n ((:P) ((:B) "Требования:"))\n ((:UL) ((:LI) "Опыт в области разработки GUI не менее 2 лет")\n  ((:LI) "Отличное владение средствами 2D графики (Adobe Creative Suite etc.)")\n  ((:LI) "Владение средствами веб-верстки - HTML, JavaScript, CSS")\n  ((:LI)\n   "Желательно умение программировать - что-то из области Python, Perl, PHP etc.")\n  ((:LI)\n   "Опыт разработки 3D предметного дизайна, владение необходимыми инструментами")\n  ((:LI)\n   "Владение инструментами проектирования вещей (Autocad etc.) будет значительным преимуществом")\n  ((:LI)\n   "Владение английским языком, как минимум, на уровне свободного чтения технических текстов"))\n ((:P) ((:B) "Условия:"))\n ((:UL) ((:LI) "Официальное трудоустройство по ТК РФ")\n  ((:LI) "Работа в благоустроенном офисе, центр города, недалеко от метро")\n  ((:LI) "Ненормированный рабочий день")\n  ((:LI)\n   "Конкурентная зарплата или (достойное вознаграждение + опцион на долю в бизнесе) - Ваш выбор")\n  ((:LI) "Coffee unlimited =)")))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:UNINTERESTING	\N
68	12547219	f	Software Engineer Acoustic Signal Processing	USD	2500	2500	от 2 500 до 5 000 USD	5000	2500	250	 COMTEK Inc.	false	Василеостровская	3–6 лет	3 февраля	((:P)\n ((:P)\n  ((:B)\n   "A leading USA provider of mobile messaging service (with more than 200 million registered members) is opening its office in St. Petersburg, Russia. We are looking for developers for this office. Multiple vacancies are open."))\n ((:P)\n  ((:B)\n   "You will start from 3-6 month internship in Silicon Valley, California."))\n ("br" NIL)\n ((:P)\n  "We are looking for a results oriented A+ engineer to help develop the next generation of our product.")\n ("br" NIL) ((:P) ((:B) "Responsibilities:"))\n ((:UL)\n  ((:LI)\n   "Research, development and maintenance of acoustic signal processing modules")\n  ((:LI) "Help optimize audio performance on various hardware platforms")\n  ((:LI) "Work with QA team to profile and evaluate the developed algorithms"))\n ((:P) ((:B) "Requirements:"))\n ((:UL)\n  ((:LI) "Experience with acoustic echo cancellation, must have written code")\n  ((:LI) "Expert C or C++ development experience")\n  ((:LI)\n   "Ability to analyze, debug and redesign audio streaming components on embedded platforms with emphasis on Android and iOS")\n  ((:LI) "Consistent execution") ((:LI) "Excellent communication skill")\n  ((:LI) "English language - at least Intermediate level"))\n ((:P) ((:B) "Big Plus") ":")\n ((:UL)\n  ((:LI)\n   "Experience with voice activity detection, noise reduction, speech coding, voice signal enhancements")\n  ((:LI)\n   "Assembly language optimization experience with knowledge of ARM CPU architecture")\n  ((:LI) "Experience with the fast-paced, flexible environment of a start-up")\n  ((:LI) "Understand research papers and implement algorithms accordingly")\n  ((:LI) "Creative problem solving skill and solid maths background"))\n ((:P) ((:B) "What We Offer:"))\n ((:UL) ((:LI) "Competitive salary") ((:LI) "Medical ensurance")\n  ((:LI) "Tea, coffee and cookies")\n  ((:LI) "The company is ready to sponsor relocation to USA and Green Card")))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:UNINTERESTING	
51	12568541	f	Инженер-схемотехник	RUR	60000	60000	от 60 000 до 100 000 руб.	100000	60000	1099824	ООО БалтИнфоКом	Санкт-Петербург	false	1–3 года	15 января	((:P) ((:P) ((:B) "Обязанности:"))\n ((:UL)\n  ((:LI)\n   "разработка принципиальных электрических схем высокочастотных оптоэлектронных и электронных устройств;")\n  ((:LI) "проектирование печатных плат;")\n  ((:LI)\n   "макетирование, а также наладка экспериментальных и опытных образцов разработанных устройств;")\n  ((:LI)\n   "сопровождение серийного выпуска у контрактного производителя, в том числе за рубежом;"))\n ((:P) ((:B) "Требования к соискателю:"))\n ((:UL)\n  ((:LI)\n   "разработка электрических принципиальных схем для 10/40/100G Ethernet на базе FPGA Altera (Stratix V)")\n  ((:LI) "базовые знания по программированию FPGA Altera")\n  ((:LI)\n   "уверенные знания современной элементной базы и поиск электронных компонентов")\n  ((:LI)\n   "проектирование многослойных печатных плат (P-CAD, Altium Designer) для высокоскоростных цепей")\n  ((:LI)\n   "расчет импеданса проводников, выбор стека и подготовка к производству печатной платы")\n  ((:LI)\n   "практические навыки монтажа/демонтажа SMD компонентов (от 0402), м/с (от 0,5 мм), тестирование и ремонт разработанных устройств")\n  ((:LI) "проектирование корпусов изделий в AutoCad и Solid-Works")\n  ((:LI) "оформление КД (Э3, ПЭ3, Э4, ПЭ4, ВП, СП, ТУ) по ГОСТ")\n  ((:LI) "сопровождение производства разрабатываемых устройств"))\n ((:P) ((:B) "Условия:"))\n ((:UL) ((:LI) "оформление по ТК")\n  ((:LI) "премия в конце года по итогам работы")\n  ((:LI) "испытательный срок максимум на три месяца")))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:UNINTERESTING	\N
81	12699207	f	Senior User Interface Developer/Разработчик графических интерфейсов GUI/UI/UX	RUR	90000	90000	от 90 000 руб.	90000	90000	574211	 Netwrix Corporation	false	Старая Деревня	3–6 лет	2 февраля	((:P)\n ((:P)\n  "Netwrix Corporation - международная компания, специализирующаяся на разработке программного обеспечения для аудита корпоративной IT-инфраструктуры.")\n ((:P)\n  "Компания Netwrix Corporation создает инновационные технологии, не требующие больших временных затрат на внедрение и настройку. Продукция компании регулярно отмечается наградами на престижных международных конкурсах и IT-выставках.")\n ((:P)\n  "Основанная в 2006 году, компания Netwrix Corporation зарекомендовала себя как №1 в аудите изменений, подтверждением чему являются тысячи довольных пользователей по всему миру.")\n ((:P)\n  "Головной офис компании находится в Irvine, California (USA), региональные офисы представлены в New Jersey, Ohio и в United Kingdom. Центр разработки расположен в Санкт-Петербурге (Россия).")\n ((:P)\n  "Офис компании «Netwrix Corporation» в Санкт-Петербурге продолжает развиваться и открывает вакансию "\n  ((:B) "Senior User Interface Developer."))\n ((:P) ((:B) "Эта вакансия для Вас, если Вы:"))\n ((:UL)\n  ((:LI) "Любите проектировать и программировать пользовательский интерфейс")\n  ((:LI)\n   "Понимаете, что такое UI/UX, элегантный и интуитивно понятный интерфейс")\n  ((:LI) "Уверенно владеете " ((:B) "C") ((:B) "++"))\n  ((:LI) "Занимаетесь разработкой под Windows")\n  ((:LI) "Загораетесь интересными задачами и доводите начатое дело до конца")\n  ((:LI) "Умеете работать как самостоятельно, так и в команде")\n  ((:LI)\n   "Внимательны к мелочам в своей работе и ориентированы на качественный результат")\n  ((:LI) "Свободно читаете техническую документацию на английском языке."))\n ((:P) ((:B) "Мы предлагаем:"))\n ((:UL)\n  ((:LI)\n   "Работу в современном бизнес-центре класса \\"А\\" напротив м. \\"Старая Деревня\\"")\n  ((:LI) "Оформление по ТК РФ, \\"белую\\" заработную плату")\n  ((:LI) "ДМС со стоматологией")\n  ((:LI)\n   "Участие во всероссийских и международных конференциях по разработке ПО")\n  ((:LI) "Еженедельные оплачиваемые занятия спортом (футбол/волейбол)")\n  ((:LI) "Приобретение необходимой для работы литературы за счет компании")\n  ((:LI) "Комфортные рабочие места и современное компьютерное оборудование")\n  ((:LI) "Гибкий график работы и комфортную рабочую атмосферу")\n  ((:LI) "Никакой бюрократии!")\n  ((:LI) "Кофе, чай и вкусности к чаю за счет компании :)")))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:UNSORT	
69	12547212	f	Senior Mobile Video Engineer	USD	2000	2000	от 2 000 до 5 000 USD	5000	2000	250	 COMTEK Inc.	false	Василеостровская	3–6 лет	3 февраля	((:P)\n ((:P)\n  ((:B)\n   "A leading USA provider of mobile messaging service (with more than 200 million registered members) is opening its office in St. Petersburg, Russia. We are looking for developers for this office. Multiple vacancies are open."))\n ((:P)\n  ((:B)\n   "You will start from 3-6 month internship in Silicon Valley, California."))\n ("br" NIL)\n ((:P)\n  ((:B)\n   "We are looking for a results oriented A+ engineer to help develop the next generation of our product."))\n ("br" NIL) ((:P) ((:B) "Responsibilities:"))\n ((:UL) ((:LI) "Advance Company's video quality")\n  ((:LI) "Tune Company's video capabilities on new mobile hardware platforms"))\n ((:P) ((:B) "Requirements:"))\n ((:UL) ((:LI) "Expert C/C++ development experience")\n  ((:LI) "Hands on experience with OpenMAX on Android")\n  ((:LI) "Strong Java development experience with Java Native Interface")\n  ((:LI) "Android Native application development with Android NDK")\n  ((:LI)\n   "Ability to analyze, debug and redesign audio/video streaming components on embedded platforms with emphasis on Android")\n  ((:LI)\n   "Detailed working knowledge of the H.264/MPEG-4 AVC video compression standard")\n  ((:LI)\n   "Detailed working knowledge of embedded platform audio/video capture and rendering interfaces"))\n ((:P) ((:B) "Pluses") ":")\n ((:UL)\n  ((:LI) "iOS (iPhone OS) application development experience with Objective-C")\n  ((:LI)\n   "Experience with Qualcomm 8×60,8×55, Samsung Hummingbird, NVidia Tegra series")\n  ((:LI) "Experience with the fast-paced, flexible environment of a start-up"))\n ((:P) ((:B) "What We Offer") ":")\n ((:UL) ((:LI) "Competitive salary") ((:LI) "Medical ensurance")\n  ((:LI) "Tea, coffee and cookies")\n  ((:LI) "The company is ready to sponsor relocation to USA and Green Card")))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:UNINTERESTING	
61	12719164	f	Web Developer (backend/frontend python)	RUR	80000	80000	от 80 000 до 100 000 руб.	100000	80000	970879	 Цезурити/Cezurity	Санкт-Петербург	false	1–3 года	4 февраля	((:P)\n ((:P)\n  "Российская IT-компания Cezurity (работает с 2006 года, история на сайте), специализирующаяся на разработке технологий и продуктов в области защиты информации (изолированная среда, антивирус, выявление APT) приглашает в свою команду.")\n ((:P) "Город: Санкт-Петербург." ("br" NIL)\n  "Занятость: полная; работа в офисе (ст. м. Пионерская).")\n ((:P) ("br" NIL) "Вакансия: "\n  ((:B) "Python Web Developer (backend/frontend python") ((:B) ")"))\n ((:P) ((:B) "Задачи:"))\n ((:UL)\n  ((:LI)\n   "Разработка внутренних web-интерфейсов, участие в разработке витрин данных, поисковых индексов и фильтров, которые используют аналитики для разбора вредоносного ПО.")\n  ((:LI)\n   "Работа с постоянно растущими объемами данных, сейчас это более 100М сложных объектов для анализа.")\n  ((:LI)\n   "Участие в разработке web-интерфейсов к продуктам компании для корпоративных клиентов.")\n  ((:LI)\n   "Участие в интеграции решений с партнерами компании (Яндекс, ВКонтакте).")\n  ((:LI)\n   "Интеграция решений в существующую инфраструктуру (Linux, RabbitMQ, HBase, Postgresql).")\n  ((:LI)\n   "Стремление к самостоятельному решению задач от этапа постановки до ввода в эксплуатацию.")\n  ((:LI) "Использование SVN/Mercurial, JIRA, Confluence, Teamcity."))\n ((:P) ((:B) "Требования:"))\n ((:UL)\n  ((:LI)\n   "Ответственность, тщательность, аккуратность и внимательность к деталям.")\n  ((:LI)\n   "Знание Python, web-фреймворков (например, webpy), DBAPI (например, psycopg2).")\n  ((:LI) "Знание SQL.") ((:LI) "Знание html, css, javascript.")\n  ((:LI) "Уверенная работа в командной строке Linux."))\n ((:P) ((:B) "Условия:"))\n ((:UL) ((:LI) "Официальное трудоустройство (\\"белая\\" зарплата, по ТК);")\n  ((:LI) "Возможность участвовать в разработке продукта мирового уровня;")\n  ((:LI) "Огромные возможности по самореализации и профессиональному росту;")\n  ((:LI) "Уникальная команда и возможность работать с интересными людьми;")\n  ((:LI) "Комфортный офис (удаленное сотрудничество невозможно);")\n  ((:LI)\n   "Заработная плата от 80 000 рублей. Определяется результатом собеседования;")\n  ((:LI) "Помощь при переезде в Санкт-Петербург и аренде жилья."))\n ((:P) ((:B) "Тэги:"))\n ((:P)\n  "разработчик, разработчик python, разработчик программного обеспечения, разработчик по, python, js, javascript, css, html, postgresql, web."))	Смущает питон в остальном ок	Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:INTERESTING	
55	12544277	f	Технолог ИБСО (IBSO)	RUR	90000	90000	от 90 000 руб.	90000	90000	16430	ОАО Петербургский социальный коммерческий банк	Санкт-Петербург	false	3–6 лет	13 января	((:P) ((:P) ((:B) "Обязанности:"))\n ((:UL)\n  ((:LI)\n   "Разработка и сопровождение программы в соответствии с Техническим заданием в части функционирования АБС и ее интеграции с другими программными комплексами.")\n  ((:LI)\n   "Модернизация функционирующих программ в соответствии с Техническим заданием в части функционирования АБС и ее интеграции с другими программными комплексами.")\n  ((:LI)\n   "Взаимодействие с разработчиками АБС в процессе внедрения и эксплуатации программного обеспечения.")\n  ((:LI)\n   "Взаимодействие с другими подразделениями Банка, консультирование сотрудников смежных подразделений по вопросам сопровождения АБС."))\n ("br" NIL) ((:P) ((:B) "Требования:"))\n ((:UL) ((:LI) "Опыт внедрения или сопровождения АБС «ЦФТ-Банк».")\n  ((:LI)\n   "Знание основного продукта системы - Учетное ядро и какого либо дополнительного:РКО, Кредиты, Депозиты, Расчетный центр, Ценные бумаги, Векселя, Налоговый учет.")\n  ((:LI) "Знание PL/PLUS."))\n ("br" NIL) ((:P) ((:B) "Условия:"))\n ((:UL) ((:LI) "Оформление‚ льготы и компенсации в соответствии с ТК РФ.")\n  ((:LI) "Стабильная заработная плата 2 раза в месяц.")\n  ((:LI)\n   "Заработная плата в зависимости от опыта и результатов собеседования.")\n  ((:LI) "Офис ст. м. Электросила")))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:UNINTERESTING	\N
28	12677830	f	Специалист по тестированию ПО / Senior Quality Assurance (г.Казань)	RUR	90000	90000	от 90 000 руб.	90000	90000	3504	 Универсальный Сервис	Санкт-Петербург	false	более 6 лет	29 января	((:P)\n ((:P)\n  ((:B)\n   "В крупной международной компании, предоставляющей системы по обработке платежей для банков, промышленности и розничной торговли по всему миру, открыта вакансия \\"")\n  ((:B) "Специалист по тестированию ПО / Senior Quality Assurance")\n  ((:B) "\\""))\n ("br" NIL) ((:P) ((:B) "Обязанности:"))\n ((:UL)\n  ((:LI)\n   "Анализ бизнес-требований для оценки временных затрат на тестирование")\n  ((:LI) "Составление тест-плана и тестовых спецификаций")\n  ((:LI) "Создание автоматизированных тестов")\n  ((:LI) "Отслеживание тестового покрытия требований")\n  ((:LI) "Составление отчетов тестирования")\n  ((:LI) "Оценка соответствия ПО критериям качества на каждом этапе проекта")\n  ((:LI)\n   "Уточнение требований к продукту, проверка степени соответствия продукта установленным требованиям")\n  ((:LI) "Выявление и контроль рисков в процессе тестирования")\n  ((:LI) "Взаимодействие с другими членами команды"))\n ((:P) ((:B) "Требования:"))\n ((:UL) ((:LI) "Английский язык - свободный")\n  ((:LI) "Опыт тестирования ПО не менее 5 лет")\n  ((:LI) "Опыт автоматизации тестирования ПО")\n  ((:LI) "Навыки составления тест-планов и тестовых спецификаций")\n  ((:LI) "Умение работать с системами баг-трекинга и тест-менеджмента")\n  ((:LI)\n   "Высокоразвитые аналитические навыки (для понимания и анализа требований к ПО и его архитектуре)"))\n ((:P) "Дополнительные требования:")\n ((:UL) ((:LI) "Опыт работы с Selenium WebDriver / Selenium WebGrid")\n  ((:LI) "Понимание и знание ООП (Java / .NET)")\n  ((:LI) "Опыт работы на проектах по Agile методологии.")\n  ((:LI) "Базовые навыки администрирования ОС Windows Server")\n  ((:LI) "Знание SQL, HTML, CSS"))\n ((:P) ((:B) "Условия:"))\n ((:UL)\n  ((:LI)\n   "Офис - г.Казань, рядом с м.«Площадь Габдуллы Тукая» или «Суконная Cлобода»")\n  ((:LI) "5-дневная рабочая неделя с 10:00 до 19:00, работа в офисе")\n  ((:LI) "Оформление по бессрочному ТД, испытательный срок - 3 месяца")\n  ((:LI) "Обучение английскому языку (за счет компании)")))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:UNINTERESTING	\N
62	12719160	f	Senior Web Developer (backend/frontend python)	RUR	100000	100000	от 100 000 руб.	100000	100000	970879	 Цезурити/Cezurity	Санкт-Петербург	false	1–3 года	4 февраля	((:P)\n ((:P) "Российская IT-компания " ((:B) "Cezurity")\n  ", специализирующаяся на информационной безопасности, приглашает в свою команду талантливого Web разработчика.")\n ((:P) "Город: Санкт-Петербург.")\n ((:P) "Занятость: полная; работа в офисе (ст. м. Пионерская).")\n ((:P) ((:B) "Вакансия: Senior Web Developer (backend/frontend python") ", "\n  ((:B) "html") ", " ((:B) "css, js)"))\n ((:P)\n  "Мы ищем самостоятельного, ответственного и внимательного разработчика для создания интерфейса управления систем анализа данных (огромная панель управления анализа данных).")\n ((:P)) ((:P) ((:B) "Задачи, которые необходимо решать:"))\n ((:UL)\n  ((:LI)\n   "Разработка внутренних веб-интерфейсов, которые используют аналитики для разбора вредоносного ПО. Обязательно знание HTML, CSS, Javascript, Ajax. Не обязательно быть крутым верстальщиком, но с административными интерфейсами необходимо справляться легко и быстро. Тут мы ценим внимательность и аккуратность.")\n  ((:LI)\n   "Разработка внутреннего и внешнего REST API, которое используют подсистемы компании и покупатели наших технологий."))\n ((:P)) ((:P) ((:B) "Требования к кандидатам:"))\n ((:UL)\n  ((:LI) "Умение работать " ((:B) "самостоятельно") ", " ((:B) "быстро") " и "\n   ((:B) "эффективно") ";")\n  ((:LI) ((:B) "Внимательность") " к деталям при верстке форм управления;")\n  ((:LI) "Ответственность и коммуникабельность;")\n  ((:LI) "Опыт веб-разработки не менее года;")\n  ((:LI) "Уверенное знание основных алгоритмов и структур данных;")\n  ((:LI) "Хорошее знание python и популярных фреймворков;")\n  ((:LI)\n   "Опыт работы с реляционными БД БЕЗ фреймворков и ORM. ACID транзакции. Желательно Postgres;")\n  ((:LI) "Опыт разработки клиентского интерфейса (html, css, javascript);"))\n ((:UL)\n  ((:LI)\n   "Опыт использования JS библиотек для разработки интерфейсов (jquery, prototype и другие);"))\n ((:UL) ((:LI) "Уверенная работа с unix shell.")) ((:P))\n ((:P) ((:B) "Преимуществом будут:"))\n ((:UL) ((:LI) "Опыт написания хранимых процедур;.")\n  ((:LI)\n   "Опыт работы с нереляционными БД, интеграция приложений, работа с серверами очередей;")\n  ((:LI) "Умение правильно применять принципы и шаблоны ООП."))\n ((:P)) ((:UL)) ((:P) ((:B) "Условия:"))\n ((:UL) ((:LI) "Официальное трудоустройство;")\n  ((:LI) "Возможность участвовать в разработке продукта мирового уровня;")\n  ((:LI) "Огромные возможности по самореализации и профессиональному росту;")\n  ((:LI) "Уникальная команда и возможность работать с интересными людьми;")\n  ((:LI) "Комфортный офис (удаленное сотрудничество невозможно);")\n  ((:LI)\n   "Заработная плата от 100 000 рублей. Определяется результатом собеседования;")\n  ((:LI) "Помощь при переезде в Санкт-Петербург и аренде жилья."))\n ((:P)) ((:P) ((:B) "Тэги:"))\n ((:P)\n  "разработчик, разработчик python, разработчик программного обеспечения, разработчик по, python, js, javascript, css, html, postgresql."))	Тоже питон	Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:INTERESTING	
9	12348157	f	Технический руководитель проекта	RUR	90000	90000	от 90 000 руб.	90000	90000	172	 1C-Рарус	Санкт-Петербург	false	1–3 года	3 февраля	((:P) ((:P) ((:B) "Обязанности:"))\n ((:UL)\n  ((:LI)\n   "Планирование, постановка задач и координация использования человеческих ресурсов со стороны Исполнителя;")\n  ((:LI) "Принятие решений по архитектуре внедряемой системы;")\n  ((:LI)\n   "Принятие решений о способах интеграции внедряемой системы с системами Заказчика;")\n  ((:LI) "Качественное выполнение работ в соответствии с планом проекта;")\n  ((:LI)\n   "Контроль количества и сроков выполняемых работ заложенных в план проекта"))\n ((:P) ("br" NIL) ((:B) "Требования:"))\n ((:UL) ((:LI) "Высшее техническое/экономическое образование")\n  ((:LI) "Опыт руководства проектами (1С)")\n  ((:LI) "Уверенное знание продукта \\"1С: УПП\\"")\n  ((:LI) "Знание 1С: Документооборот - желательно")\n  ((:LI) "Наличие управленческих навыков и организаторских способностей")\n  ((:LI) "Наличие сертификатов 1С приветствуется")\n  ((:LI) "Опыт работы руководителем проекта/архитектором от 2-х лет")\n  ((:LI)\n   "Опыт внедрения решений на базе 1С в проектно-производственных организациях")\n  ((:LI)\n   "Опыт описания бизнес-процессов и реализации информационных систем в базе процессного подхода"))\n ((:P) ("br" NIL) ((:B) "Условия:"))\n ((:UL)\n  ((:LI)\n   "Высокая заработная плата оклад +выработка на проекте (в среднем 90 000 - 120 000)")\n  ((:LI) "Офис в центре Петербурга")\n  ((:LI) "Участие в крупных и интересных проектах в крупных компаниях")\n  ((:LI) "Перспективы карьерного роста и профессионального развития")\n  ((:LI) "Дружный коллектив, комфортный психологический климат")\n  ((:LI) ((:B) "Социальный пакет:")\n   ("ul" NIL\n    ("li" NIL "своевременные выплаты заработной платы (2 раза в месяц)")\n    ("li" NIL\n     "официальное оформление с первого дня, отпуска, больничные, полисы обязательного медицинского страхования, ДМС")\n    ("li" NIL "корпоративная связь.")\n    ("li" NIL "компенсация затрат на проезд, оплата командировок")\n    ("li" NIL "оплата обучения и сертификации в 1С")\n    ("li" NIL "корпоративные мероприятия")\n    ("li" NIL "в бизнес-центре недорогая столовая с вкусными обедами"))))\n ((:P)) ((:P)))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:UNINTERESTING	\N
63	12629667	f	Разработчик Web-приложений	RUR	60000	60000	от 60 000 до 90 000 руб.	90000	60000	781323	ООО Вега	false	Выборгская	3–6 лет	4 февраля	((:P) ((:P) ((:B) "Должностные обязанности:"))\n ((:P) "– программирование на языке Java и JavaScript")\n ((:P) "– взаимодействие с реляционными БД PostgreSQL через Hibernate JPA")\n ((:P) "– создание тестов, автоматизация")\n ((:P) "– следование стандартам кодирования")\n ((:P)\n  "– верстка HTML5 CSS для поддерживаемых браузеров (ie9+,opera, ff, chrome, safari)")\n ((:P)) ((:P) ((:B) "Требуется:"))\n ((:P) "– владение платформой Java или .NET, а также JavaScript")\n ((:P) "– знание основ функционального программирования")\n ((:P) "– знание PostgreSQL, Hibernate JPA") ((:P) "– опыт работы в команде")\n ((:P) ((:B) "Преимуществом является:"))\n ((:P) "– знание какой-либо из библиотек Angular/Backbone и т.п.")\n ((:P)\n  "– знание Spring MVC, Spring Data, Gradle, Guava - будет большим плюсом")\n ((:P)) ((:P) ((:B) "Мы предлагаем:"))\n ((:P) "– постоянную работу в крупном российском интернет-проекте" ("br" NIL)\n  "– возможность использования самых последних технологий разработки"\n  ("br" NIL)\n  "– развитие и полную самореализацию, возможность осуществлять самые \\"дерзкие идеи\\""\n  ("br" NIL)\n  "– работу в коллективе увлеченных единомышленников, захваченных идеей \\"покорения мира\\" нашим продуктом")\n ((:P) "– комфортные условия в атмосфере дружелюбия и поддержки" ("br" NIL)\n  "– выплату зарплаты без задержек" ("br" NIL)\n  "– расширенный социальный пакет (ДМС, стоматология и т.д.) после 6 мес. работы в проекте")\n ((:P)))	JAVA + WEB	Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:UNINTERESTING	
59	12486997	f	Программист-методист (проект)	RUR	150000	150000	от 150 000 руб.	150000	150000	28845	ООО Макаръ и Ко	false	Волковская	3–6 лет	25 декабря	((:P) ((:P) "Требуется программист-методист на проект.")\n ((:P)\n  "Создание управленческого учета на базе программ 1С Управление торговли и 1С БИТ Финанс.")\n ((:P)\n  "Логистическая компания, занимающаяся услугами ответственного хранения, ищет фрилансера/компанию на проект по созданию управленческого учета на базе программ 1С Управление торговли и 1С БИТ Финанс.")\n "   " ((:P) ((:B) "Требования") ":")\n ((:UL)\n  ((:LI)\n   "Нужен специалист знающий предметную область управленческого учета, объединение программ: "\n   ("ul" NIL ("li" NIL "1С Бухгалтерия") ("li" NIL "1С торговля")\n    ("li" NIL "1С Бит Финанс")))\n  ((:LI) "ОПЫТ РАБОТЫ!"))\n ("br" NIL) ((:P) ((:B) "Мы предлагаем:"))\n ((:UL) ((:LI) "Оплата по договору с необходимым авансированием")\n  ((:LI) "Заработная плата по итогам собеседования!")\n  ((:LI) "Временная работа / freelance")))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:UNINTERESTING	\N
25	12679320	f	System Administrator	RUR	70000	70000	от 70 000 до 100 000 руб.	100000	70000	1020844	 SeeControl	Санкт-Петербург	false	3–6 лет	30 января	((:P) ((:P) ((:B) "Что у нас есть:"))\n ((:UL) ((:LI) "Уникальный инновационный Machine-to-Machine продукт.")\n  ((:LI)\n   "Более 100 клиентов по всему миру, среди которых Оracle, HP и Alcatel."))\n ("br" NIL) ((:P) ((:B) "Как понять, что вы нам подходите:"))\n ((:UL) ((:LI) "Вы ответственны, аккуратны и дисциплинированны.")\n  ((:LI)\n   "У Вас есть опыт в настройке и поддержании работы серверной инфраструктуры в режиме 24/7.")\n  ((:LI)\n   "Отличное знание Linux систем - установка, настройка, автоматизация сценариев.")\n  ((:LI) "Базовые навыки программирования.")\n  ((:LI)\n   "Опыт работы с Oracle DB – развертывание, конфигурирование, поддержка, оптимизация.")\n  ((:LI) "Знание стэка TCP/IP технологий."))\n ("br" NIL) ((:P) ((:B) "Плюсом будет:"))\n ((:UL) ((:LI) "Опыт поддержки кластера базы данных Oracle или другой.")\n  ((:LI) "Знания стэка Java-Web технологий.")\n  ((:LI) "Опыт работы с системами мониторинга."))\n ("br" NIL) ((:P) ((:B) "Какие задачи предстоит решать:"))\n ((:UL) ((:LI) "Системное администрирование серверной инфраструктуры SaaS.")\n  ((:LI) "Установка и поддержка систем управления базами данных.")\n  ((:LI) "Управление и создание тестовых энвароментов.")\n  ((:LI)\n   "Участие во внедрении и поддержке систем информационной безопасности компании.")\n  ((:LI) "Техническая поддержка работников компании."))\n ("br" NIL) ((:P) ((:B) "Что мы предлагаем:"))\n ((:UL) ((:LI) "Гибкий график.")\n  ((:LI) "Оформление по трудовому законодательству.")\n  ((:LI)\n   "Использование передовых технологий, интересные и сложные задачи, широкие возможности для самореализации, профессионального и карьерного роста.")\n  ((:LI) "Молодой, дружный коллектив.") ((:LI) "Курсы английского языка.")\n  ((:LI)\n   "Комфортабельный офис класса \\"А\\" на ст. м. «Пл. Ленина», бесплатный автобус от метро.")))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:UNINTERESTING	\N
42	12625266	f	Ведущий разработчик	RUR	100000	100000	от 100 000 до 150 000 руб.	150000	100000	1524165	 LBNV	false	Приморская	более 6 лет	22 января	((:P)\n ((:P)\n  "В компанию приглашается ведущий разработчик для разработки высоконагруженных систем.")\n ((:P) ((:B) "Требования:"))\n ((:UL) ((:LI) "Языки: PHP, Ruby (RoR), JS (Client, NodeJS)")\n  ((:LI) "БД: MySql, PostgreSQL, MongoDB")\n  ((:LI) "Знание и понимание паттернов программирования") ((:LI) "TDD/BDD")\n  ((:LI) "ОС Linux (Administrator level)")\n  ((:LI)\n   "Понимание принципов построения масштабируемых систем, основные проблемы, пути решения"))\n ("br" NIL) ((:P) ((:B) "Условия:"))\n ((:UL) ((:LI) "Полный рабочий день с 10:00 до 19:00")\n  ((:LI) "Офис на Васильевском острове у гостиницы Приморская")\n  ((:LI) "Уровень заработной платы обсуждается на собеседовании")\n  ((:LI) "Работа с интересными и инновационными проектами в дружной команде")))	Был на собеседовании. По видимому для этого нужен отдельный статус	Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:RESPONDED	\N
73	12728297	f	Senior Telco Engineer in Service Engineering	RUR	100000	100000	от 100 000 руб.	100000	100000	168307	 DINO Systems	Санкт-Петербург	false	более 6 лет	5 февраля	((:P) ((:P) ((:B) "Responsibilities:"))\n ((:UL)\n  ((:LI)\n   "Investigate, troubleshoot, resolve service issues related to VoIP and FoIP telephony platforms and applications.")\n  ((:LI)\n   "Work with Operations, Engineering and Development teams on solutions for production issues.")\n  ((:LI)\n   "Document bug reports and enhancement requests containing complete information for the development as well as solution proposals.")\n  ((:LI)\n   "Participate in the development of telecommunication services architecture.")\n  ((:LI)\n   "Provide consulting and assistance in solving problems for the customer support Tier 3 team.")\n  ((:LI)\n   "Collaborate with Service Engineering team members in the United States."))\n ((:P) ((:B) "Required skills:"))\n ((:UL)\n  ((:LI)\n   "Minimum five years of professional experience in Telecom and Software development field on a senior engineering position.")\n  ((:LI) "Excellent problem solving and strong analytical skills.")\n  ((:LI)\n   "Strong knowledge of SIP, RTP, RTCP and related telephony protocols/standards.")\n  ((:LI)\n   "Troubleshooting experience of VoIP platforms and applications, ability to analyze SIP/RTP to isolate and resolve issues.")\n  ((:LI)\n   "Knowledge of C++ language and the concepts of OOP, experience in using MS Visual C++ and Windows Development Environment.")\n  ((:LI) "Strong knowledge of TCP/IP fundamentals."))\n ((:P) ((:B) "Desirable skills:"))\n ((:UL)\n  ((:LI) "Knowledge of the structure and principles of NGN and IMS networks.")\n  ((:LI)\n   "Experience with Kamailio (OpenSer), Asterisk, ACME/Sonus, Media Gateways.")\n  ((:LI)\n   "Experience with Polycom, Cisco and other VoIP handsets and soft phones.")\n  ((:LI) "Understanding of VoIP QoS concepts, Jitter, Delay, etc.")\n  ((:LI)\n   "Experience using source control, bug tracking, and ticketing systems in a team environment like WiKi, Jira, Salesforce.")\n  ((:LI) "Strong knowledge of Windows/Linux operating systems.")\n  ((:LI) "Programming experience in Java SE/EE.")\n  ((:LI) "Scripting languages (Bash, Perl, Python)."))\n ((:P) ((:B) "Education and Personal:"))\n ((:UL)\n  ((:LI) "Customer service mentality – calm, customer-oriented communication.")\n  ((:LI) "Strong interpersonal and communication skills.")\n  ((:LI)\n   "Intermediate (or higher) verbal and written English communication skills."))\n ((:P) ((:B) "Conditions:"))\n ((:UL) ((:LI) "Well coordinated professional team.")\n  ((:LI)\n   "Cutting edge technologies, interesting and challenging tasks, dynamic project, great opportunities for self-realization, professional and career growth.")\n  ((:LI) "Corporate training programs, English language courses.")\n  ((:LI)\n   "Business trips and further work in foreign branch offices (including H1-B U.S., Philippines, China).")\n  ((:LI)\n   "Job placement and payment of salary take place according to the labor code.")\n  ((:LI) "Individual and team bonuses.") ((:LI) "Sick leaves 100% paid.")\n  ((:LI) "28 day vacation 100% paid in accordance with the current salary.")\n  ((:LI)\n   "Medical assistance (voluntary health insurance, dental insurance, office doctor).")\n  ((:LI)\n   "Great working conditions, modern business center, cycle parking, equipped kitchens, tea, coffee, soft drinks and sweets.")\n  ((:LI) "Corporate events, trips, sports.")\n  ((:LI) "Office in 10-minute walk from the subway.")\n  ((:LI)\n   "Nonresident applicants granted Relocation Bonus and help in finding accommodation in St. Petersburg.")))		Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:UNINTERESTING	
4	12312580	f	Начальник отдела перспективных разработок	RUR	90000	90000	от 90 000 руб.	90000	90000	184152	ЗАО Технические Системы и Технологии	Санкт-Петербург	false	3–6 лет	3 февраля	((:P) ((:P) ((:B) "Обязанности:"))\n ((:UL)\n  ((:LI)\n   "Руководство проектами по созданию аппаратных средств и программного обеспечения от разработки и согласования ТЗ до испытаний опытного образца;")\n  ((:LI)\n   "Определение перспективных направлений разработки и ключевых технических решений;")\n  ((:LI) "Руководство отделом."))\n ((:P)) ((:P) ((:B) "Требования:"))\n ((:UL)\n  ((:LI)\n   "Высшее техническое образование (электроника, радиотехника, информатика и вычислительная техника);")\n  ((:LI) "Опыт аналогичной работы не менее 5-ти лет;")\n  ((:LI) "Знание цифровой и аналоговой схемотехники;")\n  ((:LI) "Опыт разработки ПО под Windows, Linux, QNX;")\n  ((:LI) "Знание требований нормативных документов ЕСКД, ЕСПД."))\n ((:P) ((:B) "Будет плюсом:")) ((:P))\n ((:UL)\n  ((:LI)\n   "Практический опыт применения элементной базы: ПЛИС (Altera), микроконтроллеры (AVR, ARM7, ARM9), цифровые сигнальные процессоры (SHARC, MC-12, MC-24);")\n  ((:LI)\n   "Знание и опыт применения языков программирования (C, VHDL) под МК и ПЛИС соответственно;")\n  ((:LI) "Владение MATLAB и опыт применения для расчетов и моделирования;")\n  ((:LI)\n   "Знание высокоуровневого языка программирования (C++, C#), QNX, Windows, Linux."))\n ((:P)) ((:P) ((:B) "Условия:"))\n ((:UL) ((:LI) "Полная занятость;") ((:LI) "Пятидневная рабочая неделя;")\n  ((:LI) "Оформление в соответствии с трудовым кодексом РФ.")))	Интересно, но электроника	Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90	:INTERESTING	\N
\.


--
-- Name: vacancy_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ylg
--

SELECT pg_catalog.setval('vacancy_id_seq', 81, true);


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
-- Name: cmps_pkey; Type: CONSTRAINT; Schema: public; Owner: ylg; Tablespace: 
--

ALTER TABLE ONLY cmps
    ADD CONSTRAINT cmps_pkey PRIMARY KEY (id);


--
-- Name: color_pkey; Type: CONSTRAINT; Schema: public; Owner: ylg; Tablespace: 
--

ALTER TABLE ONLY color
    ADD CONSTRAINT color_pkey PRIMARY KEY (id);


--
-- Name: event_pkey; Type: CONSTRAINT; Schema: public; Owner: ylg; Tablespace: 
--

ALTER TABLE ONLY event
    ADD CONSTRAINT event_pkey PRIMARY KEY (id);


--
-- Name: group_pkey; Type: CONSTRAINT; Schema: public; Owner: ylg; Tablespace: 
--

ALTER TABLE ONLY "group"
    ADD CONSTRAINT group_pkey PRIMARY KEY (id);


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
-- Name: uniq_name; Type: CONSTRAINT; Schema: public; Owner: ylg; Tablespace: 
--

ALTER TABLE ONLY "user"
    ADD CONSTRAINT uniq_name UNIQUE (name);


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
-- Name: vacancy_pkey; Type: CONSTRAINT; Schema: public; Owner: ylg; Tablespace: 
--

ALTER TABLE ONLY vacancy
    ADD CONSTRAINT vacancy_pkey PRIMARY KEY (id);


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

