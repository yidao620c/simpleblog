--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
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
-- Name: auth_group; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE auth_group (
    id integer NOT NULL,
    name character varying(80) NOT NULL
);


ALTER TABLE public.auth_group OWNER TO postgres;

--
-- Name: auth_group_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE auth_group_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_group_id_seq OWNER TO postgres;

--
-- Name: auth_group_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE auth_group_id_seq OWNED BY auth_group.id;


--
-- Name: auth_group_permissions; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE auth_group_permissions (
    id integer NOT NULL,
    group_id integer NOT NULL,
    permission_id integer NOT NULL
);


ALTER TABLE public.auth_group_permissions OWNER TO postgres;

--
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE auth_group_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_group_permissions_id_seq OWNER TO postgres;

--
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE auth_group_permissions_id_seq OWNED BY auth_group_permissions.id;


--
-- Name: auth_permission; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE auth_permission (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    content_type_id integer NOT NULL,
    codename character varying(100) NOT NULL
);


ALTER TABLE public.auth_permission OWNER TO postgres;

--
-- Name: auth_permission_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE auth_permission_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_permission_id_seq OWNER TO postgres;

--
-- Name: auth_permission_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE auth_permission_id_seq OWNED BY auth_permission.id;


--
-- Name: auth_user; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE auth_user (
    id integer NOT NULL,
    password character varying(128) NOT NULL,
    last_login timestamp with time zone NOT NULL,
    is_superuser boolean NOT NULL,
    username character varying(30) NOT NULL,
    first_name character varying(30) NOT NULL,
    last_name character varying(30) NOT NULL,
    email character varying(75) NOT NULL,
    is_staff boolean NOT NULL,
    is_active boolean NOT NULL,
    date_joined timestamp with time zone NOT NULL
);


ALTER TABLE public.auth_user OWNER TO postgres;

--
-- Name: auth_user_groups; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE auth_user_groups (
    id integer NOT NULL,
    user_id integer NOT NULL,
    group_id integer NOT NULL
);


ALTER TABLE public.auth_user_groups OWNER TO postgres;

--
-- Name: auth_user_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE auth_user_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_user_groups_id_seq OWNER TO postgres;

--
-- Name: auth_user_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE auth_user_groups_id_seq OWNED BY auth_user_groups.id;


--
-- Name: auth_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE auth_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_user_id_seq OWNER TO postgres;

--
-- Name: auth_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE auth_user_id_seq OWNED BY auth_user.id;


--
-- Name: auth_user_user_permissions; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE auth_user_user_permissions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    permission_id integer NOT NULL
);


ALTER TABLE public.auth_user_user_permissions OWNER TO postgres;

--
-- Name: auth_user_user_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE auth_user_user_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_user_user_permissions_id_seq OWNER TO postgres;

--
-- Name: auth_user_user_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE auth_user_user_permissions_id_seq OWNED BY auth_user_user_permissions.id;


--
-- Name: blog_category; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE blog_category (
    id integer NOT NULL,
    name character varying(40) NOT NULL
);


ALTER TABLE public.blog_category OWNER TO postgres;

--
-- Name: blog_category_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE blog_category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.blog_category_id_seq OWNER TO postgres;

--
-- Name: blog_category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE blog_category_id_seq OWNED BY blog_category.id;


--
-- Name: blog_comment; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE blog_comment (
    id integer NOT NULL,
    author character varying(20) NOT NULL,
    email character varying(75) NOT NULL,
    text text NOT NULL,
    created_date timestamp with time zone NOT NULL,
    post_id integer NOT NULL
);


ALTER TABLE public.blog_comment OWNER TO postgres;

--
-- Name: blog_comment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE blog_comment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.blog_comment_id_seq OWNER TO postgres;

--
-- Name: blog_comment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE blog_comment_id_seq OWNED BY blog_comment.id;


--
-- Name: blog_evaluate; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE blog_evaluate (
    id integer NOT NULL,
    ip character varying(40) NOT NULL,
    evaluate integer NOT NULL,
    post_id integer NOT NULL
);


ALTER TABLE public.blog_evaluate OWNER TO postgres;

--
-- Name: blog_evaluate_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE blog_evaluate_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.blog_evaluate_id_seq OWNER TO postgres;

--
-- Name: blog_evaluate_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE blog_evaluate_id_seq OWNED BY blog_evaluate.id;


--
-- Name: blog_page; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE blog_page (
    id integer NOT NULL,
    author_id integer NOT NULL,
    title character varying(200) NOT NULL,
    text text NOT NULL,
    porder integer NOT NULL,
    created_date timestamp with time zone NOT NULL,
    published_date timestamp with time zone
);


ALTER TABLE public.blog_page OWNER TO postgres;

--
-- Name: blog_page_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE blog_page_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.blog_page_id_seq OWNER TO postgres;

--
-- Name: blog_page_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE blog_page_id_seq OWNED BY blog_page.id;


--
-- Name: blog_post; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE blog_post (
    id integer NOT NULL,
    title character varying(200) NOT NULL,
    text text NOT NULL,
    created_date timestamp with time zone NOT NULL,
    published_date timestamp with time zone,
    author_id integer NOT NULL,
    category_id integer NOT NULL,
    click integer NOT NULL
);


ALTER TABLE public.blog_post OWNER TO postgres;

--
-- Name: blog_post_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE blog_post_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.blog_post_id_seq OWNER TO postgres;

--
-- Name: blog_post_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE blog_post_id_seq OWNED BY blog_post.id;


--
-- Name: blog_post_tags; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE blog_post_tags (
    id integer NOT NULL,
    post_id integer NOT NULL,
    tag_id integer NOT NULL
);


ALTER TABLE public.blog_post_tags OWNER TO postgres;

--
-- Name: blog_post_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE blog_post_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.blog_post_tags_id_seq OWNER TO postgres;

--
-- Name: blog_post_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE blog_post_tags_id_seq OWNED BY blog_post_tags.id;


--
-- Name: blog_tag; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE blog_tag (
    id integer NOT NULL,
    name character varying(40) NOT NULL
);


ALTER TABLE public.blog_tag OWNER TO postgres;

--
-- Name: blog_tag_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE blog_tag_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.blog_tag_id_seq OWNER TO postgres;

--
-- Name: blog_tag_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE blog_tag_id_seq OWNED BY blog_tag.id;


--
-- Name: django_admin_log; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE django_admin_log (
    id integer NOT NULL,
    action_time timestamp with time zone NOT NULL,
    object_id text,
    object_repr character varying(200) NOT NULL,
    action_flag smallint NOT NULL,
    change_message text NOT NULL,
    content_type_id integer,
    user_id integer NOT NULL,
    CONSTRAINT django_admin_log_action_flag_check CHECK ((action_flag >= 0))
);


ALTER TABLE public.django_admin_log OWNER TO postgres;

--
-- Name: django_admin_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE django_admin_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_admin_log_id_seq OWNER TO postgres;

--
-- Name: django_admin_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE django_admin_log_id_seq OWNED BY django_admin_log.id;


--
-- Name: django_content_type; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE django_content_type (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    app_label character varying(100) NOT NULL,
    model character varying(100) NOT NULL
);


ALTER TABLE public.django_content_type OWNER TO postgres;

--
-- Name: django_content_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE django_content_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_content_type_id_seq OWNER TO postgres;

--
-- Name: django_content_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE django_content_type_id_seq OWNED BY django_content_type.id;


--
-- Name: django_migrations; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE django_migrations (
    id integer NOT NULL,
    app character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    applied timestamp with time zone NOT NULL
);


ALTER TABLE public.django_migrations OWNER TO postgres;

--
-- Name: django_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE django_migrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_migrations_id_seq OWNER TO postgres;

--
-- Name: django_migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE django_migrations_id_seq OWNED BY django_migrations.id;


--
-- Name: django_session; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE django_session (
    session_key character varying(40) NOT NULL,
    session_data text NOT NULL,
    expire_date timestamp with time zone NOT NULL
);


ALTER TABLE public.django_session OWNER TO postgres;

--
-- Name: reversion_revision; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE reversion_revision (
    id integer NOT NULL,
    manager_slug character varying(200) NOT NULL,
    date_created timestamp with time zone NOT NULL,
    comment text NOT NULL,
    user_id integer
);


ALTER TABLE public.reversion_revision OWNER TO postgres;

--
-- Name: reversion_revision_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE reversion_revision_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.reversion_revision_id_seq OWNER TO postgres;

--
-- Name: reversion_revision_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE reversion_revision_id_seq OWNED BY reversion_revision.id;


--
-- Name: reversion_version; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE reversion_version (
    id integer NOT NULL,
    object_id text NOT NULL,
    object_id_int integer,
    format character varying(255) NOT NULL,
    serialized_data text NOT NULL,
    object_repr text NOT NULL,
    content_type_id integer NOT NULL,
    revision_id integer NOT NULL
);


ALTER TABLE public.reversion_version OWNER TO postgres;

--
-- Name: reversion_version_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE reversion_version_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.reversion_version_id_seq OWNER TO postgres;

--
-- Name: reversion_version_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE reversion_version_id_seq OWNED BY reversion_version.id;


--
-- Name: xadmin_bookmark; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE xadmin_bookmark (
    id integer NOT NULL,
    title character varying(128) NOT NULL,
    user_id integer,
    url_name character varying(64) NOT NULL,
    content_type_id integer NOT NULL,
    query character varying(1000) NOT NULL,
    is_share boolean NOT NULL
);


ALTER TABLE public.xadmin_bookmark OWNER TO postgres;

--
-- Name: xadmin_bookmark_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE xadmin_bookmark_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.xadmin_bookmark_id_seq OWNER TO postgres;

--
-- Name: xadmin_bookmark_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE xadmin_bookmark_id_seq OWNED BY xadmin_bookmark.id;


--
-- Name: xadmin_usersettings; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE xadmin_usersettings (
    id integer NOT NULL,
    user_id integer NOT NULL,
    key character varying(256) NOT NULL,
    value text NOT NULL
);


ALTER TABLE public.xadmin_usersettings OWNER TO postgres;

--
-- Name: xadmin_usersettings_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE xadmin_usersettings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.xadmin_usersettings_id_seq OWNER TO postgres;

--
-- Name: xadmin_usersettings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE xadmin_usersettings_id_seq OWNED BY xadmin_usersettings.id;


--
-- Name: xadmin_userwidget; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE xadmin_userwidget (
    id integer NOT NULL,
    user_id integer NOT NULL,
    page_id character varying(256) NOT NULL,
    widget_type character varying(50) NOT NULL,
    value text NOT NULL
);


ALTER TABLE public.xadmin_userwidget OWNER TO postgres;

--
-- Name: xadmin_userwidget_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE xadmin_userwidget_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.xadmin_userwidget_id_seq OWNER TO postgres;

--
-- Name: xadmin_userwidget_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE xadmin_userwidget_id_seq OWNED BY xadmin_userwidget.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY auth_group ALTER COLUMN id SET DEFAULT nextval('auth_group_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY auth_group_permissions ALTER COLUMN id SET DEFAULT nextval('auth_group_permissions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY auth_permission ALTER COLUMN id SET DEFAULT nextval('auth_permission_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY auth_user ALTER COLUMN id SET DEFAULT nextval('auth_user_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY auth_user_groups ALTER COLUMN id SET DEFAULT nextval('auth_user_groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY auth_user_user_permissions ALTER COLUMN id SET DEFAULT nextval('auth_user_user_permissions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY blog_category ALTER COLUMN id SET DEFAULT nextval('blog_category_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY blog_comment ALTER COLUMN id SET DEFAULT nextval('blog_comment_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY blog_evaluate ALTER COLUMN id SET DEFAULT nextval('blog_evaluate_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY blog_page ALTER COLUMN id SET DEFAULT nextval('blog_page_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY blog_post ALTER COLUMN id SET DEFAULT nextval('blog_post_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY blog_post_tags ALTER COLUMN id SET DEFAULT nextval('blog_post_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY blog_tag ALTER COLUMN id SET DEFAULT nextval('blog_tag_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY django_admin_log ALTER COLUMN id SET DEFAULT nextval('django_admin_log_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY django_content_type ALTER COLUMN id SET DEFAULT nextval('django_content_type_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY django_migrations ALTER COLUMN id SET DEFAULT nextval('django_migrations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY reversion_revision ALTER COLUMN id SET DEFAULT nextval('reversion_revision_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY reversion_version ALTER COLUMN id SET DEFAULT nextval('reversion_version_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY xadmin_bookmark ALTER COLUMN id SET DEFAULT nextval('xadmin_bookmark_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY xadmin_usersettings ALTER COLUMN id SET DEFAULT nextval('xadmin_usersettings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY xadmin_userwidget ALTER COLUMN id SET DEFAULT nextval('xadmin_userwidget_id_seq'::regclass);


--
-- Data for Name: auth_group; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY auth_group (id, name) FROM stdin;
\.


--
-- Name: auth_group_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('auth_group_id_seq', 1, false);


--
-- Data for Name: auth_group_permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY auth_group_permissions (id, group_id, permission_id) FROM stdin;
\.


--
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('auth_group_permissions_id_seq', 1, false);


--
-- Data for Name: auth_permission; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY auth_permission (id, name, content_type_id, codename) FROM stdin;
1	Can add log entry	1	add_logentry
2	Can change log entry	1	change_logentry
3	Can delete log entry	1	delete_logentry
4	Can add permission	2	add_permission
5	Can change permission	2	change_permission
6	Can delete permission	2	delete_permission
7	Can add group	3	add_group
8	Can change group	3	change_group
9	Can delete group	3	delete_group
10	Can add user	4	add_user
11	Can change user	4	change_user
12	Can delete user	4	delete_user
13	Can add content type	5	add_contenttype
14	Can change content type	5	change_contenttype
15	Can delete content type	5	delete_contenttype
16	Can add session	6	add_session
17	Can change session	6	change_session
18	Can delete session	6	delete_session
19	Can add post	7	add_post
20	Can change post	7	change_post
21	Can delete post	7	delete_post
22	Can add tag	8	add_tag
23	Can change tag	8	change_tag
24	Can delete tag	8	delete_tag
25	Can add category	9	add_category
26	Can change category	9	change_category
27	Can delete category	9	delete_category
28	Can add comment	10	add_comment
29	Can change comment	10	change_comment
30	Can delete comment	10	delete_comment
31	Can add evaluate	11	add_evaluate
32	Can change evaluate	11	change_evaluate
33	Can delete evaluate	11	delete_evaluate
34	Can view category	9	view_category
35	Can view comment	10	view_comment
36	Can view content type	5	view_contenttype
37	Can view evaluate	11	view_evaluate
38	Can view group	3	view_group
39	Can view log entry	1	view_logentry
40	Can view permission	2	view_permission
41	Can view post	7	view_post
42	Can view session	6	view_session
43	Can view tag	8	view_tag
44	Can view user	4	view_user
45	Can add Bookmark	12	add_bookmark
46	Can change Bookmark	12	change_bookmark
47	Can delete Bookmark	12	delete_bookmark
48	Can add User Setting	13	add_usersettings
49	Can change User Setting	13	change_usersettings
50	Can delete User Setting	13	delete_usersettings
51	Can add User Widget	14	add_userwidget
52	Can change User Widget	14	change_userwidget
53	Can delete User Widget	14	delete_userwidget
54	Can view Bookmark	12	view_bookmark
55	Can view User Setting	13	view_usersettings
56	Can view User Widget	14	view_userwidget
57	Can add revision	15	add_revision
58	Can change revision	15	change_revision
59	Can delete revision	15	delete_revision
60	Can add version	16	add_version
61	Can change version	16	change_version
62	Can delete version	16	delete_version
63	Can view revision	15	view_revision
64	Can view version	16	view_version
65	Can add page	17	add_page
66	Can change page	17	change_page
67	Can delete page	17	delete_page
68	Can view page	17	view_page
\.


--
-- Name: auth_permission_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('auth_permission_id_seq', 68, true);


--
-- Data for Name: auth_user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY auth_user (id, password, last_login, is_superuser, username, first_name, last_name, email, is_staff, is_active, date_joined) FROM stdin;
1		2014-11-04 16:23:06.327568+08	f	ola				f	t	2014-11-04 16:23:06.32763+08
2	pbkdf2_sha256$12000$oGE3PB4y9G4a$laHEPvLrn22wIhZjbpQAkS5hFpo0KBnbiYBUYqS3SAc=	2014-12-08 15:23:23.314+08	t	admin			admin@gmail.com	t	t	2014-11-04 16:25:55.974333+08
\.


--
-- Data for Name: auth_user_groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY auth_user_groups (id, user_id, group_id) FROM stdin;
\.


--
-- Name: auth_user_groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('auth_user_groups_id_seq', 1, false);


--
-- Name: auth_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('auth_user_id_seq', 2, true);


--
-- Data for Name: auth_user_user_permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY auth_user_user_permissions (id, user_id, permission_id) FROM stdin;
\.


--
-- Name: auth_user_user_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('auth_user_user_permissions_id_seq', 1, false);


--
-- Data for Name: blog_category; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY blog_category (id, name) FROM stdin;
1	Java
2	Linux
3	算法
4	朝花夕拾
\.


--
-- Name: blog_category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('blog_category_id_seq', 4, true);


--
-- Data for Name: blog_comment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY blog_comment (id, author, email, text, created_date, post_id) FROM stdin;
2	一路向北	sunwukong@gmail.com	总是在父母保护下成长，在手足关系中定位自己，在恋人呵护中找到真爱，在朋友关心中得到温暖。你知道这些人经过了你的生命，也丰富了你的一生。你谢谢他们带给你的一切，却又总是说不出口。	2014-11-19 17:54:48.718569+08	3
4	小小	xiaoxiao@163.com	在可以追逐的未来。我双眼保持着眺望，我双耳仔细地聆听，唯恐疏忽错过。\r\n后来才发现，那些握过手	2014-11-19 18:48:38.976329+08	3
\.


--
-- Name: blog_comment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('blog_comment_id_seq', 4, true);


--
-- Data for Name: blog_evaluate; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY blog_evaluate (id, ip, evaluate, post_id) FROM stdin;
1	127.0.0.1	1	3
2	127.0.0.1	0	6
3	127.0.0.1	1	5
4	127.0.0.1	1	14
5	127.0.0.1	1	7
6	127.0.0.1	0	10
8	127.0.0.1	0	15
9	127.0.0.1	0	12
\.


--
-- Name: blog_evaluate_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('blog_evaluate_id_seq', 9, true);


--
-- Data for Name: blog_page; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY blog_page (id, author_id, title, text, porder, created_date, published_date) FROM stdin;
1	2	开心一刻	乌龟生病了，他的朋友蜗牛帮他去买药，走了三天没回来。乌龟生气的说：“这个小蜗牛也太慢啦！” 话音刚落，蜗牛开门说：“你要是再说我，我可不去了啊。”\r\n\r\n我女朋友哪都好，就是路痴，这都多少年了还没找到我。\r\n\r\n一程序员向一暗恋好久的MM表白，MM拒绝了，程序员含着泪问MM：“那你把我当什么？” MM：“真人版Windows优化大师！”\r\n\r\n十年前，男：我就抱抱不干什么。女：不行！ 十年后，男：我就抱抱不干什么。女：不行！\r\n\r\n北体大运动会一哥们跑1500。最后一名。突然他女神跑上主席台。大喊XXX你要是能跑第一我当你女朋友。之后除了他以外的所有运动员都停下了。只有他一个人在跑。每当他超过一个人。那个被超过的人就会说：“兄弟哥们只能帮你这些了”。之后他俩就在一起了。我喜欢这个故事，这就是体育！\r\n\r\n一老汉赶驴车进城，遇到一个妇女搭车，路上妇女说：大哥你看天真热，让驴吃点草，咱俩去小树林凉快一会，一路凉快了十来次！眼看快到城了，妇女说：大哥今天遇见你也是缘份，不知道何时在见，让驴在啃会草，咱俩在凉快一次吧？老汉口吐白沫的说：妹子你看这样行不行，我去啃会草，你跟驴凉快凉快行不？\r\n\r\n在一个烟雨蒙蒙的清晨，你站在窗前，心里十分惆怅，感慨万千。曾经失望过，曾经失落过，但一切的曾经都代替不了现在的行走，活在当下，曾经终究不是未来。水一滴滴从屋檐自由落下，你的思绪也随之荡漾开。你突然发现它通过屋檐下高为1.4m的窗户时用时0.2s，空气阻力不计。求窗户离屋檐的距离。	0	2014-12-08 16:21:06+08	2014-12-08 16:21:30+08
3	2	关于本站	之前的blog地址 —— http://yidao620c.iteye.com/，最近上面到处都是广告，讨论区的人也越来越少，有质量的东西越来越少，所以我都懒得上了。\r\n\r\n决定自己弄个独立的域名，省时省力，而且自由度高，也不难。\r\n\r\n本站为什么叫“野猪林”，因为电视剧水浒传里面有一集押送豹子头林冲就叫野猪林，本人非常喜欢这一集，纯粹个人爱好。^_^\r\n\r\n除非文章内特别说明，你可以转载野猪林的文章，但请加入文章作者和出处。谢谢。\r\n\r\n我希望通过共享知识能够和更多的人交流，大多数时候，主要是分享下知识，技术，心得，趣闻等等，文章内容，质量，风格基本上没有什么要求，主要是在一种轻松的氛围下享受编程的乐趣就可以了。	2	2014-12-08 16:22:23+08	2014-12-08 16:22:30+08
4	2	关于作者	我叫熊能，一个很普通的程序员，毕业到现在已经有些年头了，记忆力很差，所以基本靠支烂笔头在记东西，我喜欢用evernote做笔记，喜欢写博客。这样感觉挺好的，在写东西的过程中会有更深刻的体会，不仅能帮自己记忆还能分享给别人，有时还能收到别人的感谢，这种感觉很爽。所以后来就越发喜欢上了写博客，之前的博客放在iteye上，现在已经停止更新了，感觉这个社区大不如从前了。最后决定自己弄了独立博客，发现还挺不错的，很自由，想写啥都行。\r\n\r\n我现在在广州一搞云计算公司做开发，自己主要对python，java，linux和算法感兴趣。我是个很随和的人，乐于和大家成为朋友，大家能一起相互进步那是最好不过的了！\r\n\r\n个人资料：\r\nEmail： yidao620@gmail.com\r\nGitHub： https://github.com/yidao620c\r\n公司： 广州云宏信息科技股份有限公司	0	2014-12-08 16:22:46+08	2014-12-08 16:23:00+08
\.


--
-- Name: blog_page_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('blog_page_id_seq', 4, true);


--
-- Data for Name: blog_post; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY blog_post (id, title, text, created_date, published_date, author_id, category_id, click) FROM stdin;
5	Team团队协作平台正式开放	Team 正式开放给大家，可自由开通使用，无需 @小编辑 干预，@小编辑 你辛苦了，跪安吧。\r\n\r\n或许你会举出几个类似应用，但 Team 绝对是独一无二的专为程序员打造的团队协作平台。我们并不想改变你的工作方式，而是让原有的工作条理变得更清晰，更透明，更有效率。善用 Team，可以让项目有条不紊推进。\r\n\r\nTeam 值得注意的特性：\r\n\r\n直接绑定 Github 项目，项目动态直接呈现在 Team\r\n绑定多个项目（Github+Git@OSC），项目状态一目了然，无需单独切换不同项目界面\r\n强大的任务管理机制和统计功能\r\n自动生成工作周报（我早就不想写工作周报了）\r\n便签记录个人琐碎\r\nTeam 主界面截图：	2014-11-18 16:30:30.567275+08	2014-03-18 17:07:26+08	2	4	16
4	打个草稿	Android5.0的美感\r\n\r\nAndroid5.0对用户来说，完全是一场视觉盛宴，这是一次脱离Android皮，回归Google心的全新系统，在使用Android5.0系统的时候，你再也感觉不到丝毫以前Android系统的冰冷感。动画、分层、简单却明快的调色板，所有这一切都在此体现得淋淋尽致；一些元素在设计时就瞄准了更小的屏幕，比如说具有透明效果的下拉式通知界面，与它们在屏幕更大的Nexus 9上面的表现一样突出。无论是在屏幕更小的Nexus 5上面，还是在大屏Nexus 6上面，Android 5.0对谷歌乃至整个移动设计而言都是巨大的成就。\r\n\r\n在过去几个月里，已经有几款谷歌应用采用了风格一致的新颖设计，因为谷歌正在从沿用了三年的“Holo”设计语言转向“Material Design”。这种新风格在Android 5.0 Lollipop体现得淋漓尽致，并且很快就会向整个谷歌生态系统——包括电脑、汽车、电视和可穿戴设备延伸。\r\n\r\n我们应该看到一些变化，Google正在从一个工程师做产品的方向，慢慢到了“一个产品应有的样子”。工程师们将变得更具有审美，也更感性，而不是觉得有没有交互都一样，只要结果一样就OK。搞机哥认为，Google这次所做的改变，会影响到非常深远的未来，并潜移默化。\r\n\r\nAndroid5.0对中国的影响\r\n\r\n由于Android历史遗留的一些问题，大多数国内Android用户所获得的都并不是原生的Android体验，他们大都数都是使用手机厂商定制的第三方ROM，比如HTC的Sense、小米的MIUI、魅族的Flyme等等。但这不免让人觉得遗憾，因为Android5.0是一个非常精致的系统版本，其原生的UI设计，无论是美观度、还是用户体验上，搞机哥都觉得完爆手机厂商自己定制的ROM。\r\n\r\n让用户获得一致性的用户体验是非常重要的，自从Android诞生以来，Android似乎是第一次在用户界面和用户体验上面拥有了真正清晰的想法。更为重要的是，Lollipop的体验还延伸到了平板、手机、电视和可穿戴领域。无论是Android Wear中的卡片的图层和纹理，还是Android TV中的用色和总体设计语言，这一切看上去终于像是属于同一个产品系列。\r\n\r\n从Android5.0开始，Google对Android系统的不作为，变成引导手机厂商如何设计Android系统，这就好比一个老师在教堂教学生如何设计出具有独立美感的作品。但是学生是否听话，会遵从老师的教导又是另外一回事，由于每位设计师在审美品位上的差异性，不见得Google认为的"美感"会被手机厂商所接受，像MIUI、Sense、Flyme这些随着Android系统成长起来的第三方ROM，早就逐渐衍生了自己的独特设计的视觉风格，用户也习惯接受他们的审美品位，他们可能会采纳Android5.0的视觉素材，但并不一定会照搬。	2014-11-18 14:59:38.399428+08	\N	2	2	2
7	啊啊啊啊啊	前面是这个<br />\r\n<pre class="brush:py;auto-links:false;toolbar:false" contenteditable="false">def add_comment(request, pk):\r\n    """添加评论"""\r\n    form = CommentForm(request.POST)\r\n    if form.is_valid():\r\n        comment = form.save(commit=False)\r\n        comment.post_id = pk\r\n        comment.save()\r\n        return redirect('blog.views.post_detail', pk=pk)</pre>\r\n后面是这个<br /><br />	2014-11-21 11:26:50.372518+08	2014-11-24 17:36:13.113699+08	2	4	5
2	vim正则表达式	Vim中的正则表达式功能很强大，如果能自由运用，则可以完成很多难以想象的操作。\r\n\r\n一、使用正则表达式的命令\r\n使用正则表达式的命令最常见的就是 / （搜索）命令。其格式如下：\r\n/正则表达式\r\n另一个很有用的命令就是 :s（替换）命令，将第一个//之间的正则表达式替换成第二个//之间的字符串。\r\n:s/正则表达式/替换字符串/选项\r\n在学习正则表达式时可以利用 / 命令来练习。\r\n\r\n二、元字符\r\n元字符是具有特殊意义的字符。使用元字符可以表达任意字符、行首、行 尾、某几个字符等意义。\r\n元字符一览\r\n元字符 说明\r\n. 匹配任意一个字符\r\n[abc] 匹配方括号中的任意一个字符。可以使用-表示字符范围，\r\n如[a-z0-9]匹 配小写字母和阿拉伯数字。\r\n[^abc] 在方括号内开头使用^符号，表示匹配除方括号中字符之外的任意字符。\r\n\\d 匹配阿拉伯数字，等同于[0-9]。\r\n\\D 匹配阿拉伯数字之外的任意字符，等同于[^0-9]。\r\n\\x 匹配十六进制数字，等同于[0-9A-Fa-f]。\r\n\\X 匹配十六进制数字之外的任意字符，等同于[^0-9A-Fa-f]。\r\n\\w 匹配单词字母，等同于[0-9A-Za-z_]。\r\n\\W 匹配单词字母之外的任意字符，等同于[^0-9A-Za-z_]。\r\n\\t 匹配字符。\r\n\\s 匹配空白字符，等同于[ \\t]。\r\n\\S 匹配非空白字符，等同于[^ \\t]。\r\n另外，如果要查找字符 *、.、/等，则需要在前面用 \\ 符号，表示这不是元字符，而只是普通字符而已。\r\n元字符 说明\r\n\\* 匹配 * 字符。\r\n\\. 匹配 . 字符。\r\n\\/ 匹配 / 字符。\r\n\\\\ 匹配 \\ 字符。\r\n\\[ 匹配 [ 字符。\r\n表示数量的元字符\r\n元字符 说明\r\n* 匹配0-任意个\r\n\\+ 匹配1-任意个\r\n\\? 匹配0-1个\r\n\\{n,m} 匹配n-m个\r\n\\{n} 匹配n个\r\n\\{n,} 匹配n-任意个\r\n\\{,m} 匹配0-m个\r\n表示位置的符号\r\n元字符 说明\r\n$ 匹配行尾\r\n^ 匹配行首\r\n\\< 匹配单词词首\r\n\\> 匹配单词词尾\r\n使用例子：\r\n/char\\s\\+[A-Za-z_]\\w*;” 查找所有以char开头，之后是一个以上的空白，” 最后是一个标识符和分号/\\d\\d:\\d\\d:\\d\\d”\r\n查找如 17:37:01 格式的时间字符串:g/^\\s*$/d”\r\n删除只有空白的行:s/\\/4/g”\r\n将所有的four替换成4，但是fourteen中的four不替换	2014-11-18 14:49:00.992971+08	2013-11-18 14:49:05+08	2	2	6
6	我的Python程序	请看下面这段程序：<br /><!--more-->\r\n<pre class="brush:py;auto-links:false;toolbar:false" contenteditable="false">def add_comment(request, pk):\r\n    """添加评论"""\r\n    form = CommentForm(request.POST)\r\n    if form.is_valid():\r\n        comment = form.save(commit=False)\r\n        comment.post_id = pk\r\n        comment.save()\r\n        return redirect('blog.views.post_detail', pk=pk)</pre>\r\n请看下是不是有效果了。<br /><br />	2014-11-21 10:51:06+08	2014-11-21 11:21:11+08	2	3	17
3	珍惜世上的五个人	1、世界上有一个人， 和你在一起的时候，总是千万次嘱咐要多穿件衣服，要注意安全，你觉得很烦人，却也觉得很温暖。 没钱的时候，他总会说些赚钱不易之类的话来训你，边教训，边塞钱给你。 这个人，叫做父母。<br /> 2、世界上有一个人， 和你在一起时候，偶尔会和你打架，偶尔会和你斗嘴。他坏道总是抢你点心，总是向父母打小报告，但也总是爱护你比谁都多，你们有最亲密，最亲密的关系。这个人，叫手足。 <br />3、世界上有一个人， 不见面的时候会一直惦记着他，见面时却又脸红心跳，什么话都说不出口。他总是轻易地把你心揪住，让你无法忘怀，也能让你胡思乱想睡不好觉，但你仍然甘之如饴，因为你爱他。他是你最甜蜜，最甜蜜的负荷。 这个人，叫做恋人。 <br />4、世界上有一个人， 知道你一些不为人知的小秘密，犯错的时候，他帮着你找理由；暗恋一个人的时候，他帮你传话； 和恋人吵架时候，你一定会哭着跑去找他。你很抱歉，你总是麻烦来到时才想到他，但你很庆幸生命中出现了这么好的一个人。也许你们在一起的日子，走得比恋人还要长久。 这个人，叫做朋友。 <br />5、世界上有一个人， 总是在父母保护下成长，在手足关系中定位自己，在恋人呵护中找到真爱，在朋友关心中得到温暖。你知道这些人经过了你的生命，也丰富了你的一生。你谢谢他们带给你的一切，却又总是说不出口。 这个人，就是自己。 <br /><br />一直以为幸福在远方，在可以追逐的未来。我双眼保持着眺望，我双耳仔细地聆听，唯恐疏忽错过。 后来才发现，那些握过手，唱过歌，流过泪，爱过的人。所谓曾经，就是幸福．．．．．． 这就是人一生中要珍惜的五个人。	2014-11-18 14:50:32.805222+08	2014-11-18 14:50:37.011463+08	2	4	101
14	测试插入more标签	这是一个测试的例子。[!--more--]<br />我们都是好孩子<br />哈哈哈。你不服啊~~~	2014-11-25 16:50:15.734952+08	2014-11-25 16:52:02.52506+08	2	2	17
9	AAA	AAAAA	2014-11-24 17:35:17.819536+08	2014-11-24 17:36:09.094469+08	2	2	1
10	BBB	BBB	2014-11-24 17:35:27.465088+08	2014-11-24 17:36:04.889229+08	2	2	3
11	EEE	EEQQQ	2014-11-24 17:35:36.280592+08	2014-11-24 17:35:57.3898+08	2	3	1
12	FFFFF	QASFASFASF	2014-11-24 17:35:44.261049+08	2014-11-24 17:35:51.037436+08	2	4	1
15	这是一个新文章	<p>开源中国继续招聘 Java 工程师，我们对学历没要求，而且不要求你会 Spring、Struts 和 Hibernate 等这些框架。如果你热爱 OSChina，热爱编码，Java 基本功扎实，希望参与 OSChina 的开发，为国内的程序员提供一流的开发服务，那么请果断将你的简历发送到 ld@oschina.net 。</p>\r\n<p>如果你在深圳周边，可以直接上门面试，不管面试是否通过我们都将送出开源内裤一条。外地的应聘者我们将通过电话跟你联系。</p>\r\n<p>此外，我们即将在本月底最迟下个月初搬到位于深圳南山科兴科技园的全新办公室（离地铁口很近哦）。</p>	2014-12-04 16:59:31.878+08	2014-12-04 16:59:41.386+08	2	3	2
1	Java8中的lambda表达式	<p>2014年3月18日，Oracle终于发布Java8正式版。在新的版本里面加入了很多特性，总共增加了55个新特性，其中最最吸引人的就是Lambdas表达式和Stream函数式编程，本文详细讲解这两个特性。</p>\r\n<p>其他特性比如日期API，泛型，反射，注解，集合框架，并发，Nashorn引擎等等这里暂时就不详细介绍了。具体可以参考：<a href="http://openjdk.java.net/projects/jdk8/features">http://openjdk.java.net/projects/jdk8/features</a></p>\r\n<p>昨天参加了Oracle的Java8宣讲活动，有幸目睹了Simon Ritter的风采，写个总结来分享下。<span id="more-118"></span></p>\r\n<p>Java并发编程演变：</p>\r\n<table class="bbcode">\r\n<tbody>\r\n<tr>\r\n<td>版本</td>\r\n<td>发布年份</td>\r\n<td>并发技术</td>\r\n</tr>\r\n<tr>\r\n<td>1.4</td>\r\n<td>2002</td>\r\n<td>java.lang.Thread</td>\r\n</tr>\r\n<tr>\r\n<td>5</td>\r\n<td>2004</td>\r\n<td>java.util.concurrent(jsr166)</td>\r\n</tr>\r\n<tr>\r\n<td>6</td>\r\n<td>2006</td>\r\n<td>Phasers, etc(jsr166)</td>\r\n</tr>\r\n<tr>\r\n<td>7</td>\r\n<td>2011</td>\r\n<td>Fork/Join Framework(jsr166y)</td>\r\n</tr>\r\n<tr>\r\n<td>8</td>\r\n<td>2014</td>\r\n<td>Project Lambda</td>\r\n</tr>\r\n</tbody>\r\n</table>\r\n--more--\r\n<p>先来一个小例子见识下Java8的威力！</p>\r\n<pre class="brush:java;auto-links:false;toolbar:false" contenteditable="false">List&lt;Student&gt; students = ...\r\ndouble highestScore = 0.0;\r\nfor (Student s : students) {\r\n    if (s.gradYear == 2011) {\r\n        if (s.score &gt; highestScore) {\r\n            highestScore = s.score;\r\n        }\r\n    }\r\n}</pre>\r\n<p>传统的外部迭代主要问题：<br />&bull; 程序员自己控制迭代，容易出问题！<br />&bull; 顺序执行：迭代从开始到结束一个一个的顺序迭代元素<br />&bull; 线程不安全，由于业务逻辑依靠可修改变量，容易产生竞态问题<br /><br /><br /></p>	2014-11-18 14:48:03.738696+08	2014-11-18 14:48:17.176465+08	2	1	20
\.


--
-- Name: blog_post_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('blog_post_id_seq', 15, true);


--
-- Data for Name: blog_post_tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY blog_post_tags (id, post_id, tag_id) FROM stdin;
4	2	4
5	2	5
14	5	2
15	5	6
18	7	8
19	3	3
24	1	6
25	1	7
29	14	11
30	15	12
31	6	6
32	6	7
\.


--
-- Name: blog_post_tags_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('blog_post_tags_id_seq', 32, true);


--
-- Data for Name: blog_tag; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY blog_tag (id, name) FROM stdin;
2	github
3	珍惜
4	vim
5	linux
6	java
7	lambda
8	python
9	算法
11	迭代
12	吼吼
\.


--
-- Name: blog_tag_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('blog_tag_id_seq', 12, true);


--
-- Data for Name: django_admin_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY django_admin_log (id, action_time, object_id, object_repr, action_flag, change_message, content_type_id, user_id) FROM stdin;
1	2014-11-04 16:26:14.156174+08	2	我的奋斗史	2	已修改 published_date 。	7	2
2	2014-11-04 16:26:31.311109+08	3	那些人儿	2	已修改 published_date 。	7	2
\.


--
-- Name: django_admin_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('django_admin_log_id_seq', 2, true);


--
-- Data for Name: django_content_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY django_content_type (id, name, app_label, model) FROM stdin;
1	log entry	admin	logentry
2	permission	auth	permission
3	group	auth	group
4	user	auth	user
5	content type	contenttypes	contenttype
6	session	sessions	session
7	post	blog	post
8	tag	blog	tag
9	category	blog	category
10	comment	blog	comment
11	evaluate	blog	evaluate
12	Bookmark	xadmin	bookmark
13	User Setting	xadmin	usersettings
14	User Widget	xadmin	userwidget
15	revision	reversion	revision
16	version	reversion	version
17	page	blog	page
\.


--
-- Name: django_content_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('django_content_type_id_seq', 17, true);


--
-- Data for Name: django_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY django_migrations (id, app, name, applied) FROM stdin;
6	contenttypes	0001_initial	2014-11-18 14:41:37.666614+08
7	auth	0001_initial	2014-11-18 14:41:37.725617+08
8	admin	0001_initial	2014-11-18 14:41:55.822652+08
9	blog	0001_initial	2014-11-18 14:44:58.628108+08
10	blog	0002_auto_20141118_1444	2014-11-18 14:44:58.816119+08
11	sessions	0001_initial	2014-11-18 14:44:58.83912+08
12	blog	0002_auto_20141118_1456	2014-11-18 14:56:53.657006+08
13	reversion	0001_initial	2014-12-05 15:43:58.392+08
\.


--
-- Name: django_migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('django_migrations_id_seq', 13, true);


--
-- Data for Name: django_session; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY django_session (session_key, session_data, expire_date) FROM stdin;
e9mhdndicesd4lpq6htj87xn075liu4n	N2RkNzVmZmUzYWFlMmM2NTgxM2VkY2YwNTFjNzE2MTBjOWQyN2U2ZTp7Il9hdXRoX3VzZXJfaGFzaCI6IjkwYmUwZjkxMGRjZWFiYWZjYTI3M2E0YzEzNDA1ZTU3MmM3Nzk1NzIiLCJfYXV0aF91c2VyX2lkIjoyLCJfYXV0aF91c2VyX2JhY2tlbmQiOiJkamFuZ28uY29udHJpYi5hdXRoLmJhY2tlbmRzLk1vZGVsQmFja2VuZCJ9	2014-11-21 17:48:37.935009+08
sb2dqrfuh4on448o2x7paeo5b4ktpmso	MWNmM2IzMWZkOTQ3OTNjYWRiNzkxNmQ2N2EyZGZlYWQ2MGIyYjg5NTp7Il9hdXRoX3VzZXJfaWQiOjIsIl9hdXRoX3VzZXJfYmFja2VuZCI6ImRqYW5nby5jb250cmliLmF1dGguYmFja2VuZHMuTW9kZWxCYWNrZW5kIiwiX2F1dGhfdXNlcl9oYXNoIjoiOTBiZTBmOTEwZGNlYWJhZmNhMjczYTRjMTM0MDVlNTcyYzc3OTU3MiJ9	2014-12-02 14:59:03.822451+08
\.


--
-- Data for Name: reversion_revision; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY reversion_revision (id, manager_slug, date_created, comment, user_id) FROM stdin;
\.


--
-- Name: reversion_revision_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('reversion_revision_id_seq', 1, false);


--
-- Data for Name: reversion_version; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY reversion_version (id, object_id, object_id_int, format, serialized_data, object_repr, content_type_id, revision_id) FROM stdin;
\.


--
-- Name: reversion_version_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('reversion_version_id_seq', 1, false);


--
-- Data for Name: xadmin_bookmark; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY xadmin_bookmark (id, title, user_id, url_name, content_type_id, query, is_share) FROM stdin;
\.


--
-- Name: xadmin_bookmark_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('xadmin_bookmark_id_seq', 1, false);


--
-- Data for Name: xadmin_usersettings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY xadmin_usersettings (id, user_id, key, value) FROM stdin;
2	2	site-theme	/static/xadmin/css/themes/bootstrap-xadmin.css
1	2	dashboard:home:pos	2
\.


--
-- Name: xadmin_usersettings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('xadmin_usersettings_id_seq', 2, true);


--
-- Data for Name: xadmin_userwidget; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY xadmin_userwidget (id, user_id, page_id, widget_type, value) FROM stdin;
2	2	home	list	{"model": "blog.page", "title": "欢迎页"}
\.


--
-- Name: xadmin_userwidget_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('xadmin_userwidget_id_seq', 2, true);


--
-- Name: auth_group_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY auth_group
    ADD CONSTRAINT auth_group_name_key UNIQUE (name);


--
-- Name: auth_group_permissions_group_id_permission_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_group_id_permission_id_key UNIQUE (group_id, permission_id);


--
-- Name: auth_group_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_pkey PRIMARY KEY (id);


--
-- Name: auth_group_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY auth_group
    ADD CONSTRAINT auth_group_pkey PRIMARY KEY (id);


--
-- Name: auth_permission_content_type_id_codename_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY auth_permission
    ADD CONSTRAINT auth_permission_content_type_id_codename_key UNIQUE (content_type_id, codename);


--
-- Name: auth_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY auth_permission
    ADD CONSTRAINT auth_permission_pkey PRIMARY KEY (id);


--
-- Name: auth_user_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY auth_user_groups
    ADD CONSTRAINT auth_user_groups_pkey PRIMARY KEY (id);


--
-- Name: auth_user_groups_user_id_group_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY auth_user_groups
    ADD CONSTRAINT auth_user_groups_user_id_group_id_key UNIQUE (user_id, group_id);


--
-- Name: auth_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY auth_user
    ADD CONSTRAINT auth_user_pkey PRIMARY KEY (id);


--
-- Name: auth_user_user_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_pkey PRIMARY KEY (id);


--
-- Name: auth_user_user_permissions_user_id_permission_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_user_id_permission_id_key UNIQUE (user_id, permission_id);


--
-- Name: auth_user_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY auth_user
    ADD CONSTRAINT auth_user_username_key UNIQUE (username);


--
-- Name: blog_category_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY blog_category
    ADD CONSTRAINT blog_category_pkey PRIMARY KEY (id);


--
-- Name: blog_comment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY blog_comment
    ADD CONSTRAINT blog_comment_pkey PRIMARY KEY (id);


--
-- Name: blog_evaluate_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY blog_evaluate
    ADD CONSTRAINT blog_evaluate_pkey PRIMARY KEY (id);


--
-- Name: blog_page_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY blog_page
    ADD CONSTRAINT blog_page_pkey PRIMARY KEY (id);


--
-- Name: blog_post_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY blog_post
    ADD CONSTRAINT blog_post_pkey PRIMARY KEY (id);


--
-- Name: blog_post_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY blog_post_tags
    ADD CONSTRAINT blog_post_tags_pkey PRIMARY KEY (id);


--
-- Name: blog_post_tags_post_id_tag_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY blog_post_tags
    ADD CONSTRAINT blog_post_tags_post_id_tag_id_key UNIQUE (post_id, tag_id);


--
-- Name: blog_tag_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY blog_tag
    ADD CONSTRAINT blog_tag_pkey PRIMARY KEY (id);


--
-- Name: django_admin_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY django_admin_log
    ADD CONSTRAINT django_admin_log_pkey PRIMARY KEY (id);


--
-- Name: django_content_type_app_label_7bfa06168d673c4_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY django_content_type
    ADD CONSTRAINT django_content_type_app_label_7bfa06168d673c4_uniq UNIQUE (app_label, model);


--
-- Name: django_content_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY django_content_type
    ADD CONSTRAINT django_content_type_pkey PRIMARY KEY (id);


--
-- Name: django_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY django_migrations
    ADD CONSTRAINT django_migrations_pkey PRIMARY KEY (id);


--
-- Name: django_session_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY django_session
    ADD CONSTRAINT django_session_pkey PRIMARY KEY (session_key);


--
-- Name: reversion_revision_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY reversion_revision
    ADD CONSTRAINT reversion_revision_pkey PRIMARY KEY (id);


--
-- Name: reversion_version_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY reversion_version
    ADD CONSTRAINT reversion_version_pkey PRIMARY KEY (id);


--
-- Name: xadmin_bookmark_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY xadmin_bookmark
    ADD CONSTRAINT xadmin_bookmark_pkey PRIMARY KEY (id);


--
-- Name: xadmin_usersettings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY xadmin_usersettings
    ADD CONSTRAINT xadmin_usersettings_pkey PRIMARY KEY (id);


--
-- Name: xadmin_userwidget_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY xadmin_userwidget
    ADD CONSTRAINT xadmin_userwidget_pkey PRIMARY KEY (id);


--
-- Name: auth_group_permissions_0e939a4f; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX auth_group_permissions_0e939a4f ON auth_group_permissions USING btree (group_id);


--
-- Name: auth_group_permissions_8373b171; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX auth_group_permissions_8373b171 ON auth_group_permissions USING btree (permission_id);


--
-- Name: auth_permission_417f1b1c; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX auth_permission_417f1b1c ON auth_permission USING btree (content_type_id);


--
-- Name: auth_user_groups_0e939a4f; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX auth_user_groups_0e939a4f ON auth_user_groups USING btree (group_id);


--
-- Name: auth_user_groups_e8701ad4; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX auth_user_groups_e8701ad4 ON auth_user_groups USING btree (user_id);


--
-- Name: auth_user_user_permissions_8373b171; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX auth_user_user_permissions_8373b171 ON auth_user_user_permissions USING btree (permission_id);


--
-- Name: auth_user_user_permissions_e8701ad4; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX auth_user_user_permissions_e8701ad4 ON auth_user_user_permissions USING btree (user_id);


--
-- Name: blog_comment_f3aa1999; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX blog_comment_f3aa1999 ON blog_comment USING btree (post_id);


--
-- Name: blog_evaluate_post_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX blog_evaluate_post_id ON blog_evaluate USING btree (post_id);


--
-- Name: blog_page_author_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX blog_page_author_id ON blog_page USING btree (author_id);


--
-- Name: blog_post_4f331e2f; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX blog_post_4f331e2f ON blog_post USING btree (author_id);


--
-- Name: blog_post_b583a629; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX blog_post_b583a629 ON blog_post USING btree (category_id);


--
-- Name: blog_post_tags_76f094bc; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX blog_post_tags_76f094bc ON blog_post_tags USING btree (tag_id);


--
-- Name: blog_post_tags_f3aa1999; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX blog_post_tags_f3aa1999 ON blog_post_tags USING btree (post_id);


--
-- Name: django_admin_log_417f1b1c; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX django_admin_log_417f1b1c ON django_admin_log USING btree (content_type_id);


--
-- Name: django_admin_log_e8701ad4; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX django_admin_log_e8701ad4 ON django_admin_log USING btree (user_id);


--
-- Name: django_session_de54fa62; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX django_session_de54fa62 ON django_session USING btree (expire_date);


--
-- Name: reversion_revision_b16b0f06; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX reversion_revision_b16b0f06 ON reversion_revision USING btree (manager_slug);


--
-- Name: reversion_revision_c69e55a4; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX reversion_revision_c69e55a4 ON reversion_revision USING btree (date_created);


--
-- Name: reversion_revision_e8701ad4; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX reversion_revision_e8701ad4 ON reversion_revision USING btree (user_id);


--
-- Name: reversion_version_0c9ba3a3; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX reversion_version_0c9ba3a3 ON reversion_version USING btree (object_id_int);


--
-- Name: reversion_version_417f1b1c; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX reversion_version_417f1b1c ON reversion_version USING btree (content_type_id);


--
-- Name: reversion_version_5de09a8d; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX reversion_version_5de09a8d ON reversion_version USING btree (revision_id);


--
-- Name: xadmin_bookmark_content_type_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX xadmin_bookmark_content_type_id ON xadmin_bookmark USING btree (content_type_id);


--
-- Name: xadmin_bookmark_user_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX xadmin_bookmark_user_id ON xadmin_bookmark USING btree (user_id);


--
-- Name: xadmin_usersettings_user_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX xadmin_usersettings_user_id ON xadmin_usersettings USING btree (user_id);


--
-- Name: xadmin_userwidget_user_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX xadmin_userwidget_user_id ON xadmin_userwidget USING btree (user_id);


--
-- Name: auth_content_type_id_1b5c9f375622ff55_fk_django_content_type_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY auth_permission
    ADD CONSTRAINT auth_content_type_id_1b5c9f375622ff55_fk_django_content_type_id FOREIGN KEY (content_type_id) REFERENCES django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_group_permissio_group_id_7ce5f4453924996a_fk_auth_group_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY auth_group_permissions
    ADD CONSTRAINT auth_group_permissio_group_id_7ce5f4453924996a_fk_auth_group_id FOREIGN KEY (group_id) REFERENCES auth_group(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_group_permission_id_73e9203e39934916_fk_auth_permission_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY auth_group_permissions
    ADD CONSTRAINT auth_group_permission_id_73e9203e39934916_fk_auth_permission_id FOREIGN KEY (permission_id) REFERENCES auth_permission(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_user__permission_id_6313a7ef89891174_fk_auth_permission_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY auth_user_user_permissions
    ADD CONSTRAINT auth_user__permission_id_6313a7ef89891174_fk_auth_permission_id FOREIGN KEY (permission_id) REFERENCES auth_permission(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_user_groups_group_id_232004bf0d03854d_fk_auth_group_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY auth_user_groups
    ADD CONSTRAINT auth_user_groups_group_id_232004bf0d03854d_fk_auth_group_id FOREIGN KEY (group_id) REFERENCES auth_group(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_user_groups_user_id_26ceb18b7d5d9c65_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY auth_user_groups
    ADD CONSTRAINT auth_user_groups_user_id_26ceb18b7d5d9c65_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_user_user_permiss_user_id_492afc5aea568f46_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permiss_user_id_492afc5aea568f46_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: blog_comment_post_id_79c10f30cc809cc3_fk_blog_post_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY blog_comment
    ADD CONSTRAINT blog_comment_post_id_79c10f30cc809cc3_fk_blog_post_id FOREIGN KEY (post_id) REFERENCES blog_post(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: blog_evaluate_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY blog_evaluate
    ADD CONSTRAINT blog_evaluate_post_id_fkey FOREIGN KEY (post_id) REFERENCES blog_post(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: blog_page_author_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY blog_page
    ADD CONSTRAINT blog_page_author_id_fkey FOREIGN KEY (author_id) REFERENCES auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: blog_post_author_id_238f7cb2e3329193_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY blog_post
    ADD CONSTRAINT blog_post_author_id_238f7cb2e3329193_fk_auth_user_id FOREIGN KEY (author_id) REFERENCES auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: blog_post_category_id_5cfe6a2f0c770898_fk_blog_category_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY blog_post
    ADD CONSTRAINT blog_post_category_id_5cfe6a2f0c770898_fk_blog_category_id FOREIGN KEY (category_id) REFERENCES blog_category(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: blog_post_tags_post_id_51c32415c95b5d3_fk_blog_post_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY blog_post_tags
    ADD CONSTRAINT blog_post_tags_post_id_51c32415c95b5d3_fk_blog_post_id FOREIGN KEY (post_id) REFERENCES blog_post(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: blog_post_tags_tag_id_5cd1d65588c0fe1c_fk_blog_tag_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY blog_post_tags
    ADD CONSTRAINT blog_post_tags_tag_id_5cd1d65588c0fe1c_fk_blog_tag_id FOREIGN KEY (tag_id) REFERENCES blog_tag(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: djan_content_type_id_3efd3064f98e2079_fk_django_content_type_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY django_admin_log
    ADD CONSTRAINT djan_content_type_id_3efd3064f98e2079_fk_django_content_type_id FOREIGN KEY (content_type_id) REFERENCES django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: django_admin_log_user_id_3c59e95c01725ee5_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY django_admin_log
    ADD CONSTRAINT django_admin_log_user_id_3c59e95c01725ee5_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: reversion_revision_user_id_5b2ec55e_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY reversion_revision
    ADD CONSTRAINT reversion_revision_user_id_5b2ec55e_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: reversion_ve_content_type_id_26d4c4a9_fk_django_content_type_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY reversion_version
    ADD CONSTRAINT reversion_ve_content_type_id_26d4c4a9_fk_django_content_type_id FOREIGN KEY (content_type_id) REFERENCES django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: reversion_version_revision_id_4916a950_fk_reversion_revision_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY reversion_version
    ADD CONSTRAINT reversion_version_revision_id_4916a950_fk_reversion_revision_id FOREIGN KEY (revision_id) REFERENCES reversion_revision(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: xadmin_bookmark_content_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY xadmin_bookmark
    ADD CONSTRAINT xadmin_bookmark_content_type_id_fkey FOREIGN KEY (content_type_id) REFERENCES django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: xadmin_bookmark_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY xadmin_bookmark
    ADD CONSTRAINT xadmin_bookmark_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: xadmin_usersettings_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY xadmin_usersettings
    ADD CONSTRAINT xadmin_usersettings_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: xadmin_userwidget_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY xadmin_userwidget
    ADD CONSTRAINT xadmin_userwidget_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth_user(id) DEFERRABLE INITIALLY DEFERRED;


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

