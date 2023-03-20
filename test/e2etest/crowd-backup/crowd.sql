--
-- PostgreSQL database dump
--

-- Dumped from database version 14.7 (Debian 14.7-1.pgdg110+1)
-- Dumped by pg_dump version 14.7 (Debian 14.7-1.pgdg110+1)

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: cwd_app_dir_default_groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cwd_app_dir_default_groups (
                                                   id bigint NOT NULL,
                                                   application_mapping_id bigint NOT NULL,
                                                   group_name character varying(255) NOT NULL
);


ALTER TABLE public.cwd_app_dir_default_groups OWNER TO postgres;

--
-- Name: cwd_app_dir_group_mapping; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cwd_app_dir_group_mapping (
                                                  id bigint NOT NULL,
                                                  app_dir_mapping_id bigint NOT NULL,
                                                  application_id bigint NOT NULL,
                                                  directory_id bigint NOT NULL,
                                                  group_name character varying(255) NOT NULL
);


ALTER TABLE public.cwd_app_dir_group_mapping OWNER TO postgres;

--
-- Name: cwd_app_dir_mapping; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cwd_app_dir_mapping (
                                            id bigint NOT NULL,
                                            application_id bigint NOT NULL,
                                            directory_id bigint NOT NULL,
                                            allow_all character(1) NOT NULL,
                                            list_index integer
);


ALTER TABLE public.cwd_app_dir_mapping OWNER TO postgres;

--
-- Name: cwd_app_dir_operation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cwd_app_dir_operation (
                                              app_dir_mapping_id bigint NOT NULL,
                                              operation_type character varying(32) NOT NULL
);


ALTER TABLE public.cwd_app_dir_operation OWNER TO postgres;

--
-- Name: cwd_app_emails_scan; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cwd_app_emails_scan (
                                            application_id bigint NOT NULL,
                                            scan_date timestamp without time zone NOT NULL,
                                            invalid_emails_count bigint NOT NULL,
                                            duplicated_emails_count bigint NOT NULL
);


ALTER TABLE public.cwd_app_emails_scan OWNER TO postgres;

--
-- Name: cwd_app_licensed_user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cwd_app_licensed_user (
                                              id bigint NOT NULL,
                                              username character varying(255) NOT NULL,
                                              full_name character varying(255),
                                              email character varying(255),
                                              last_active timestamp without time zone,
                                              directory_id bigint NOT NULL,
                                              lower_username character varying(255) NOT NULL,
                                              lower_full_name character varying(255),
                                              lower_email character varying(255)
);


ALTER TABLE public.cwd_app_licensed_user OWNER TO postgres;

--
-- Name: cwd_app_licensing; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cwd_app_licensing (
                                          id bigint NOT NULL,
                                          generated_on timestamp without time zone NOT NULL,
                                          version bigint NOT NULL,
                                          application_id bigint NOT NULL,
                                          application_subtype character varying(32) NOT NULL,
                                          total_users integer NOT NULL,
                                          max_user_limit integer NOT NULL,
                                          total_crowd_users integer NOT NULL,
                                          active character(1) NOT NULL
);


ALTER TABLE public.cwd_app_licensing OWNER TO postgres;

--
-- Name: cwd_app_licensing_dir_info; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cwd_app_licensing_dir_info (
                                                   id bigint NOT NULL,
                                                   name character varying(255) NOT NULL,
                                                   directory_id bigint,
                                                   licensing_summary_id bigint NOT NULL
);


ALTER TABLE public.cwd_app_licensing_dir_info OWNER TO postgres;

--
-- Name: cwd_application; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cwd_application (
                                        id bigint NOT NULL,
                                        application_name character varying(255) NOT NULL,
                                        lower_application_name character varying(255) NOT NULL,
                                        created_date timestamp without time zone NOT NULL,
                                        updated_date timestamp without time zone NOT NULL,
                                        active character(1) NOT NULL,
                                        description character varying(255),
                                        application_type character varying(32) NOT NULL,
                                        credential character varying(255) NOT NULL
);


ALTER TABLE public.cwd_application OWNER TO postgres;

--
-- Name: cwd_application_address; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cwd_application_address (
                                                application_id bigint NOT NULL,
                                                remote_address character varying(255) NOT NULL
);


ALTER TABLE public.cwd_application_address OWNER TO postgres;

--
-- Name: cwd_application_alias; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cwd_application_alias (
                                              id bigint NOT NULL,
                                              application_id bigint NOT NULL,
                                              user_name character varying(255) NOT NULL,
                                              lower_user_name character varying(255) NOT NULL,
                                              alias_name character varying(255) NOT NULL,
                                              lower_alias_name character varying(255) NOT NULL
);


ALTER TABLE public.cwd_application_alias OWNER TO postgres;

--
-- Name: cwd_application_attribute; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cwd_application_attribute (
                                                  application_id bigint NOT NULL,
                                                  attribute_name character varying(255) NOT NULL,
                                                  attribute_value text
);


ALTER TABLE public.cwd_application_attribute OWNER TO postgres;

--
-- Name: cwd_application_saml_config; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cwd_application_saml_config (
                                                    application_id bigint NOT NULL,
                                                    assertion_consumer_service character varying(255) NOT NULL,
                                                    audience character varying(255) NOT NULL,
                                                    enabled character(1) NOT NULL,
                                                    name_id_format character varying(64) NOT NULL,
                                                    add_user_attributes_enabled character(1) NOT NULL
);


ALTER TABLE public.cwd_application_saml_config OWNER TO postgres;

--
-- Name: cwd_audit_log_changeset; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cwd_audit_log_changeset (
                                                id bigint NOT NULL,
                                                audit_timestamp bigint NOT NULL,
                                                author_type character varying(255) NOT NULL,
                                                author_id bigint,
                                                author_name character varying(255),
                                                event_type character varying(255) NOT NULL,
                                                ip_address character varying(45),
                                                event_message character varying(255),
                                                event_source character varying(255) NOT NULL
);


ALTER TABLE public.cwd_audit_log_changeset OWNER TO postgres;

--
-- Name: cwd_audit_log_entity; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cwd_audit_log_entity (
                                             id bigint NOT NULL,
                                             entity_type character varying(255) NOT NULL,
                                             entity_id bigint,
                                             entity_name character varying(255),
                                             is_primary character(1) NOT NULL,
                                             changeset_id bigint NOT NULL
);


ALTER TABLE public.cwd_audit_log_entity OWNER TO postgres;

--
-- Name: cwd_audit_log_entry; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cwd_audit_log_entry (
                                            id bigint NOT NULL,
                                            property_name character varying(255) NOT NULL,
                                            changeset_id bigint NOT NULL,
                                            old_value text,
                                            new_value text
);


ALTER TABLE public.cwd_audit_log_entry OWNER TO postgres;

--
-- Name: cwd_cluster_heartbeat; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cwd_cluster_heartbeat (
                                              node_id character varying(36) NOT NULL,
                                              node_name character varying(255),
                                              hearbeat_timestamp bigint NOT NULL
);


ALTER TABLE public.cwd_cluster_heartbeat OWNER TO postgres;

--
-- Name: cwd_cluster_info; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cwd_cluster_info (
                                         node_id character varying(255) NOT NULL,
                                         ip_address character varying(255),
                                         hostname character varying(255),
                                         current_heap bigint,
                                         max_heap bigint,
                                         load_average double precision,
                                         uptime bigint,
                                         info_timestamp bigint NOT NULL
);


ALTER TABLE public.cwd_cluster_info OWNER TO postgres;

--
-- Name: cwd_cluster_job; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cwd_cluster_job (
                                        id character varying(255) NOT NULL,
                                        runner_key character varying(255) NOT NULL,
                                        job_interval bigint,
                                        cron_expression character varying(120),
                                        time_zone character varying(80),
                                        next_run_timestamp bigint,
                                        version bigint NOT NULL,
                                        job_parameters bytea,
                                        claim_node_id character varying(36),
                                        claim_timestamp bigint
);


ALTER TABLE public.cwd_cluster_job OWNER TO postgres;

--
-- Name: cwd_cluster_lock; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cwd_cluster_lock (
                                         lock_name character varying(255) NOT NULL,
                                         lock_timestamp bigint,
                                         node_id character varying(36)
);


ALTER TABLE public.cwd_cluster_lock OWNER TO postgres;

--
-- Name: cwd_cluster_message; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cwd_cluster_message (
                                            id bigint NOT NULL,
                                            channel character varying(64),
                                            msg_text character varying(1024),
                                            msg_timestamp bigint,
                                            sender_node_id character varying(36)
);


ALTER TABLE public.cwd_cluster_message OWNER TO postgres;

--
-- Name: cwd_cluster_message_id; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cwd_cluster_message_id (
    next_val bigint
);


ALTER TABLE public.cwd_cluster_message_id OWNER TO postgres;

--
-- Name: cwd_cluster_safety; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cwd_cluster_safety (
                                           entry_key character varying(255) NOT NULL,
                                           entry_value character varying(255),
                                           node_id character varying(255),
                                           ip_address character varying(255),
                                           "timestamp" bigint NOT NULL
);


ALTER TABLE public.cwd_cluster_safety OWNER TO postgres;

--
-- Name: cwd_databasechangelog; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cwd_databasechangelog (
                                              id character varying(255) NOT NULL,
                                              author character varying(255) NOT NULL,
                                              filename character varying(255) NOT NULL,
                                              dateexecuted timestamp without time zone NOT NULL,
                                              orderexecuted integer NOT NULL,
                                              exectype character varying(10) NOT NULL,
                                              md5sum character varying(35),
                                              description character varying(255),
                                              comments character varying(255),
                                              tag character varying(255),
                                              liquibase character varying(20),
                                              contexts character varying(255),
                                              labels character varying(255),
                                              deployment_id character varying(10)
);


ALTER TABLE public.cwd_databasechangelog OWNER TO postgres;

--
-- Name: cwd_databasechangeloglock; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cwd_databasechangeloglock (
                                                  id integer NOT NULL,
                                                  locked boolean NOT NULL,
                                                  lockgranted timestamp without time zone,
                                                  lockedby character varying(255)
);


ALTER TABLE public.cwd_databasechangeloglock OWNER TO postgres;

--
-- Name: cwd_directory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cwd_directory (
                                      id bigint NOT NULL,
                                      directory_name character varying(255) NOT NULL,
                                      lower_directory_name character varying(255) NOT NULL,
                                      created_date timestamp without time zone NOT NULL,
                                      updated_date timestamp without time zone NOT NULL,
                                      active character(1) NOT NULL,
                                      description character varying(255),
                                      impl_class character varying(255) NOT NULL,
                                      lower_impl_class character varying(255) NOT NULL,
                                      directory_type character varying(32) NOT NULL
);


ALTER TABLE public.cwd_directory OWNER TO postgres;

--
-- Name: cwd_directory_attribute; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cwd_directory_attribute (
                                                directory_id bigint NOT NULL,
                                                attribute_name character varying(255) NOT NULL,
                                                attribute_value text
);


ALTER TABLE public.cwd_directory_attribute OWNER TO postgres;

--
-- Name: cwd_directory_operation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cwd_directory_operation (
                                                directory_id bigint NOT NULL,
                                                operation_type character varying(32) NOT NULL
);


ALTER TABLE public.cwd_directory_operation OWNER TO postgres;

--
-- Name: cwd_expirable_user_token; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cwd_expirable_user_token (
                                                 id bigint NOT NULL,
                                                 token character varying(255) NOT NULL,
                                                 user_name character varying(255),
                                                 email_address character varying(255),
                                                 expiry_date bigint NOT NULL,
                                                 directory_id bigint NOT NULL,
                                                 token_type character varying(64) NOT NULL
);


ALTER TABLE public.cwd_expirable_user_token OWNER TO postgres;

--
-- Name: cwd_granted_perm; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cwd_granted_perm (
                                         id bigint NOT NULL,
                                         created_date timestamp without time zone NOT NULL,
                                         permission_id integer NOT NULL,
                                         app_dir_mapping_id bigint NOT NULL,
                                         group_name character varying(255) NOT NULL
);


ALTER TABLE public.cwd_granted_perm OWNER TO postgres;

--
-- Name: cwd_group; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cwd_group (
                                  id bigint NOT NULL,
                                  group_name character varying(255) NOT NULL,
                                  lower_group_name character varying(255) NOT NULL,
                                  active character(1) NOT NULL,
                                  created_date timestamp without time zone NOT NULL,
                                  updated_date timestamp without time zone NOT NULL,
                                  description character varying(255),
                                  group_type character varying(32) NOT NULL,
                                  directory_id bigint NOT NULL,
                                  is_local character(1) NOT NULL,
                                  external_id character varying(255)
);


ALTER TABLE public.cwd_group OWNER TO postgres;

--
-- Name: cwd_group_admin_group; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cwd_group_admin_group (
                                              id bigint NOT NULL,
                                              group_id bigint NOT NULL,
                                              target_group_id bigint NOT NULL
);


ALTER TABLE public.cwd_group_admin_group OWNER TO postgres;

--
-- Name: cwd_group_admin_user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cwd_group_admin_user (
                                             id bigint NOT NULL,
                                             user_id bigint NOT NULL,
                                             target_group_id bigint NOT NULL
);


ALTER TABLE public.cwd_group_admin_user OWNER TO postgres;

--
-- Name: cwd_group_attribute; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cwd_group_attribute (
                                            id bigint NOT NULL,
                                            group_id bigint NOT NULL,
                                            directory_id bigint NOT NULL,
                                            attribute_name character varying(255) NOT NULL,
                                            attribute_value character varying(255),
                                            attribute_lower_value character varying(255)
);


ALTER TABLE public.cwd_group_attribute OWNER TO postgres;

--
-- Name: cwd_membership; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cwd_membership (
                                       id bigint NOT NULL,
                                       parent_id bigint,
                                       child_id bigint,
                                       membership_type character varying(32),
                                       group_type character varying(32) NOT NULL,
                                       parent_name character varying(255) NOT NULL,
                                       lower_parent_name character varying(255) NOT NULL,
                                       child_name character varying(255) NOT NULL,
                                       lower_child_name character varying(255) NOT NULL,
                                       directory_id bigint NOT NULL,
                                       created_date timestamp without time zone
);


ALTER TABLE public.cwd_membership OWNER TO postgres;

--
-- Name: cwd_property; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cwd_property (
                                     property_key character varying(255) NOT NULL,
                                     property_name character varying(255) NOT NULL,
                                     property_value text
);


ALTER TABLE public.cwd_property OWNER TO postgres;

--
-- Name: cwd_remember_me_token; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cwd_remember_me_token (
                                              id bigint NOT NULL,
                                              username character varying(255) NOT NULL,
                                              remote_address character varying(255),
                                              token character varying(64) NOT NULL,
                                              series character varying(64) NOT NULL,
                                              created_date timestamp(6) without time zone NOT NULL,
                                              used_date timestamp(6) without time zone,
                                              directory_id bigint NOT NULL
);


ALTER TABLE public.cwd_remember_me_token OWNER TO postgres;

--
-- Name: cwd_saml_trust_entity_idp; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cwd_saml_trust_entity_idp (
                                                  id bigint NOT NULL,
                                                  certificate character varying(4000) NOT NULL,
                                                  created_date timestamp without time zone NOT NULL,
                                                  expiration_date timestamp without time zone NOT NULL,
                                                  private_key character varying(4000) NOT NULL
);


ALTER TABLE public.cwd_saml_trust_entity_idp OWNER TO postgres;

--
-- Name: cwd_synchronisation_status; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cwd_synchronisation_status (
                                                   id integer NOT NULL,
                                                   directory_id bigint NOT NULL,
                                                   node_id character varying(36),
                                                   sync_start bigint NOT NULL,
                                                   sync_end bigint,
                                                   sync_status character varying(255),
                                                   status_parameters text,
                                                   incremental_sync_error text,
                                                   full_sync_error text,
                                                   node_name character varying(255)
);


ALTER TABLE public.cwd_synchronisation_status OWNER TO postgres;

--
-- Name: cwd_synchronisation_token; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cwd_synchronisation_token (
                                                  directory_id bigint NOT NULL,
                                                  sync_status_token text
);


ALTER TABLE public.cwd_synchronisation_token OWNER TO postgres;

--
-- Name: cwd_token; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cwd_token (
                                  id bigint NOT NULL,
                                  directory_id bigint NOT NULL,
                                  entity_name character varying(255) NOT NULL,
                                  random_number bigint NOT NULL,
                                  identifier_hash character varying(255) NOT NULL,
                                  random_hash character varying(255) NOT NULL,
                                  created_date timestamp without time zone NOT NULL,
                                  last_accessed_date timestamp without time zone NOT NULL,
                                  last_accessed_time bigint DEFAULT 0 NOT NULL,
                                  duration bigint
);


ALTER TABLE public.cwd_token OWNER TO postgres;

--
-- Name: cwd_tombstone; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cwd_tombstone (
                                      id bigint NOT NULL,
                                      tombstone_type character varying(255) NOT NULL,
                                      tombstone_timestamp bigint NOT NULL,
                                      entity_name character varying(255),
                                      directory_id bigint,
                                      parent character varying(255),
                                      application_id bigint
);


ALTER TABLE public.cwd_tombstone OWNER TO postgres;

--
-- Name: cwd_user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cwd_user (
                                 id bigint NOT NULL,
                                 user_name character varying(255) NOT NULL,
                                 lower_user_name character varying(255) NOT NULL,
                                 active character(1) NOT NULL,
                                 created_date timestamp without time zone NOT NULL,
                                 updated_date timestamp without time zone NOT NULL,
                                 first_name character varying(255),
                                 lower_first_name character varying(255),
                                 last_name character varying(255),
                                 lower_last_name character varying(255),
                                 display_name character varying(255),
                                 lower_display_name character varying(255),
                                 email_address character varying(255),
                                 lower_email_address character varying(255),
                                 directory_id bigint NOT NULL,
                                 credential character varying(255),
                                 external_id character varying(255)
);


ALTER TABLE public.cwd_user OWNER TO postgres;

--
-- Name: cwd_user_attribute; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cwd_user_attribute (
                                           id bigint NOT NULL,
                                           user_id bigint NOT NULL,
                                           directory_id bigint NOT NULL,
                                           attribute_name character varying(255) NOT NULL,
                                           attribute_value character varying(255),
                                           attribute_lower_value character varying(255),
                                           attribute_numeric_value bigint
);


ALTER TABLE public.cwd_user_attribute OWNER TO postgres;

--
-- Name: cwd_user_credential_record; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cwd_user_credential_record (
                                                   id bigint NOT NULL,
                                                   user_id bigint NOT NULL,
                                                   password_hash character varying(255) NOT NULL,
                                                   list_index integer
);


ALTER TABLE public.cwd_user_credential_record OWNER TO postgres;

--
-- Name: cwd_webhook; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cwd_webhook (
                                    id bigint NOT NULL,
                                    endpoint_url character varying(255) NOT NULL,
                                    application_id bigint NOT NULL,
                                    token character varying(255),
                                    oldest_failure_date timestamp without time zone,
                                    failures_since_last_success bigint NOT NULL
);


ALTER TABLE public.cwd_webhook OWNER TO postgres;

--
-- Name: hibernate_unique_key; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.hibernate_unique_key (
    next_hi bigint
);


ALTER TABLE public.hibernate_unique_key OWNER TO postgres;

--
-- Data for Name: cwd_app_dir_default_groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cwd_app_dir_default_groups (id, application_mapping_id, group_name) FROM stdin;
\.


--
-- Data for Name: cwd_app_dir_group_mapping; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cwd_app_dir_group_mapping (id, app_dir_mapping_id, application_id, directory_id, group_name) FROM stdin;
360449	327681	2	131073	crowd-administrators
\.


--
-- Data for Name: cwd_app_dir_mapping; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cwd_app_dir_mapping (id, application_id, directory_id, allow_all, list_index) FROM stdin;
327681	2	131073	F	0
327682	3	131073	T	0
\.


--
-- Data for Name: cwd_app_dir_operation; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cwd_app_dir_operation (app_dir_mapping_id, operation_type) FROM stdin;
327681	CREATE_GROUP
327681	CREATE_ROLE
327681	UPDATE_USER_ATTRIBUTE
327681	UPDATE_ROLE_ATTRIBUTE
327681	DELETE_GROUP
327681	CREATE_USER
327681	DELETE_USER
327681	DELETE_ROLE
327681	UPDATE_GROUP_ATTRIBUTE
327681	UPDATE_ROLE
327681	UPDATE_USER
327681	UPDATE_GROUP
327682	CREATE_GROUP
327682	CREATE_ROLE
327682	UPDATE_USER_ATTRIBUTE
327682	UPDATE_ROLE_ATTRIBUTE
327682	DELETE_GROUP
327682	CREATE_USER
327682	DELETE_USER
327682	DELETE_ROLE
327682	UPDATE_GROUP_ATTRIBUTE
327682	UPDATE_ROLE
327682	UPDATE_USER
327682	UPDATE_GROUP
\.


--
-- Data for Name: cwd_app_emails_scan; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cwd_app_emails_scan (application_id, scan_date, invalid_emails_count, duplicated_emails_count) FROM stdin;
\.


--
-- Data for Name: cwd_app_licensed_user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cwd_app_licensed_user (id, username, full_name, email, last_active, directory_id, lower_username, lower_full_name, lower_email) FROM stdin;
\.


--
-- Data for Name: cwd_app_licensing; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cwd_app_licensing (id, generated_on, version, application_id, application_subtype, total_users, max_user_limit, total_crowd_users, active) FROM stdin;
\.


--
-- Data for Name: cwd_app_licensing_dir_info; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cwd_app_licensing_dir_info (id, name, directory_id, licensing_summary_id) FROM stdin;
\.


--
-- Data for Name: cwd_application; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cwd_application (id, application_name, lower_application_name, created_date, updated_date, active, description, application_type, credential) FROM stdin;
1	google-apps	google-apps	2023-03-14 20:11:31.313	2023-03-14 20:13:56.157	T	Google Applications Connector	PLUGIN	{PKCS5S2}xSBOYzGaC+WQAOxhOVT7e5E5FgtAg0IMy9RCuvj2xYEajA5ZOIlSc8fZXEVYfBfT
2	crowd	crowd	2023-03-14 20:13:51.411	2023-03-14 20:13:56.465	T	Crowd console	CROWD	cmOatowwuu5cNPne0wyw6F
3	crowd-openid-server	crowd-openid-server	2023-03-14 20:13:55.816	2023-03-14 22:22:23.451	T	CrowdID OpenID server	GENERIC_APPLICATION	{PKCS5S2}2qgn/BJDNmtWSIsZwTA79M0UVF6rLraUHA1fJY3xxL70si/r4Yd+rt0goXg2VYEx
\.


--
-- Data for Name: cwd_application_address; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cwd_application_address (application_id, remote_address) FROM stdin;
3	localhost
3	0.0.0.0/0
3	172.17.0.3
3	127.0.0.1
\.


--
-- Data for Name: cwd_application_alias; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cwd_application_alias (id, application_id, user_name, lower_user_name, alias_name, lower_alias_name) FROM stdin;
\.


--
-- Data for Name: cwd_application_attribute; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cwd_application_attribute (application_id, attribute_name, attribute_value) FROM stdin;
1	atlassian_sha1_applied	true
2	accessDenied	true
2	atlassian_sha1_applied	true
2	filterGroupsWithAccess	false
2	aggregateMemberships	false
2	lowerCaseOutput	false
2	aliasingEnabled	false
2	filterUsersWithAccess	false
2	optimizeCachedDirectoriesAuthenticationAuthenticationOrder	false
3	atlassian_sha1_applied	true
3	filterGroupsWithAccess	false
3	aggregateMemberships	false
3	lowerCaseOutput	false
3	aliasingEnabled	false
3	filterUsersWithAccess	false
3	authenticationByEmailEnabled	false
3	optimizeCachedDirectoriesAuthenticationAuthenticationOrder	false
1	filterGroupsWithAccess	false
1	aggregateMemberships	false
1	lowerCaseOutput	false
1	aliasingEnabled	false
1	filterUsersWithAccess	false
1	authenticationByEmailEnabled	false
1	optimizeCachedDirectoriesAuthenticationAuthenticationOrder	false
2	authenticationByEmailEnabled	true
\.


--
-- Data for Name: cwd_application_saml_config; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cwd_application_saml_config (application_id, assertion_consumer_service, audience, enabled, name_id_format, add_user_attributes_enabled) FROM stdin;
\.


--
-- Data for Name: cwd_audit_log_changeset; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cwd_audit_log_changeset (id, audit_timestamp, author_type, author_id, author_name, event_type, ip_address, event_message, event_source) FROM stdin;
32769	1678824694283	OTHER	\N		APPLICATION_CREATED	172.17.0.1		MANUAL
32770	1678824720090	OTHER	\N		CONFIGURATION_MODIFIED	172.17.0.1		MANUAL
32771	1678824720101	OTHER	\N		CONFIGURATION_MODIFIED	172.17.0.1		MANUAL
32772	1678824720103	OTHER	\N		CONFIGURATION_MODIFIED	172.17.0.1		MANUAL
32773	1678824720107	OTHER	\N		CONFIGURATION_MODIFIED	172.17.0.1		MANUAL
32774	1678824720110	OTHER	\N		CONFIGURATION_MODIFIED	172.17.0.1		MANUAL
32775	1678824720112	OTHER	\N		CONFIGURATION_MODIFIED	172.17.0.1		MANUAL
32776	1678824720114	OTHER	\N		CONFIGURATION_MODIFIED	172.17.0.1		MANUAL
32777	1678824720117	OTHER	\N		CONFIGURATION_MODIFIED	172.17.0.1		MANUAL
32778	1678824720120	OTHER	\N		CONFIGURATION_MODIFIED	172.17.0.1		MANUAL
32779	1678824725940	OTHER	\N		DIRECTORY_CREATED	172.17.0.1		MANUAL
32780	1678824831299	OTHER	\N		USER_CREATED	172.17.0.1		MANUAL
32781	1678824831380	OTHER	\N		GROUP_CREATED	172.17.0.1		MANUAL
32782	1678824831401	OTHER	\N		ADDED_TO_GROUP	172.17.0.1		MANUAL
32783	1678824831460	OTHER	\N		APPLICATION_CREATED	172.17.0.1		MANUAL
32784	1678824831495	OTHER	\N		APPLICATION_UPDATED	172.17.0.1		MANUAL
32785	1678824835849	OTHER	\N		APPLICATION_CREATED	172.17.0.1		MANUAL
32786	1678824835879	OTHER	\N		APPLICATION_UPDATED	172.17.0.1		MANUAL
32787	1678824836066	OTHER	\N		APPLICATION_UPDATED	172.17.0.1		MANUAL
32788	1678824836096	OTHER	\N		CONFIGURATION_MODIFIED	172.17.0.1		MANUAL
32789	1678824836104	OTHER	\N		CONFIGURATION_MODIFIED	172.17.0.1		MANUAL
32790	1678824836106	OTHER	\N		CONFIGURATION_MODIFIED	172.17.0.1		MANUAL
32791	1678824836107	OTHER	\N		CONFIGURATION_MODIFIED	172.17.0.1		MANUAL
32792	1678824836109	OTHER	\N		CONFIGURATION_MODIFIED	172.17.0.1		MANUAL
32793	1678824836112	OTHER	\N		CONFIGURATION_MODIFIED	172.17.0.1		MANUAL
32794	1678824836176	OTHER	\N		APPLICATION_UPDATED	172.17.0.1		MANUAL
32795	1678824836234	OTHER	\N		CONFIGURATION_MODIFIED	172.17.0.1		MANUAL
458753	1678824836355	OTHER	\N		CONFIGURATION_MODIFIED	172.17.0.1		MANUAL
458754	1678824836442	OTHER	\N		CONFIGURATION_MODIFIED	172.17.0.1		MANUAL
458755	1678824836444	OTHER	\N		CONFIGURATION_MODIFIED	172.17.0.1		MANUAL
458756	1678824836451	OTHER	\N		CONFIGURATION_MODIFIED	172.17.0.1		MANUAL
458757	1678824836452	OTHER	\N		CONFIGURATION_MODIFIED	172.17.0.1		MANUAL
458758	1678824836477	OTHER	\N		APPLICATION_UPDATED	172.17.0.1		MANUAL
458759	1678824836501	OTHER	\N		CONFIGURATION_MODIFIED	172.17.0.1		MANUAL
458760	1678825363929	USER	163841	admin	APPLICATION_UPDATED	172.17.0.1		MANUAL
458761	1678832543472	USER	163841	admin	APPLICATION_UPDATED	172.17.0.1		MANUAL
\.


--
-- Data for Name: cwd_audit_log_entity; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cwd_audit_log_entity (id, entity_type, entity_id, entity_name, is_primary, changeset_id) FROM stdin;
98305	APPLICATION	1	google-apps	T	32769
98306	DIRECTORY	131073	Crowd Server	T	32779
98307	DIRECTORY	131073	Crowd Server	F	32780
98308	USER	163841	admin	T	32780
98309	DIRECTORY	131073	Crowd Server	F	32781
98310	GROUP	262145	crowd-administrators	T	32781
98311	USER	163841	admin	F	32782
98312	DIRECTORY	131073	Crowd Server	F	32782
98313	GROUP	262145	crowd-administrators	T	32782
98314	APPLICATION	2	crowd	T	32783
98315	APPLICATION	2	crowd	T	32784
98316	APPLICATION	3	crowd-openid-server	T	32785
98317	APPLICATION	3	crowd-openid-server	T	32786
98318	APPLICATION	3	crowd-openid-server	T	32787
98319	APPLICATION	1	google-apps	T	32794
557057	APPLICATION	2	crowd	T	458758
557058	APPLICATION	3	crowd-openid-server	T	458760
557059	APPLICATION	3	crowd-openid-server	T	458761
\.


--
-- Data for Name: cwd_audit_log_entry; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cwd_audit_log_entry (id, property_name, changeset_id, old_value, new_value) FROM stdin;
65537	Created Date	32769		2023-03-14T20:11:31.313+0000
65538	Type	32769		PLUGIN
65539	Name	32769		google-apps
65540	Description	32769		Google Applications Connector
65541	Attribute: atlassian_sha1_applied	32769		true
65542	Is permanent	32769		true
65543	Active	32769		true
65544	Password	32769		*****
65545	deployment.title	32770		Crowd Server
65546	des.encryption.key	32771		*****
65547	session.time	32772		1800000
65548	cache.enabled	32773	false	true
65549	base.url	32774		http://localhost:8095/crowd
65550	mailserver.message.template	32775		Hello $firstname $lastname,\n\nYou (or someone else) have requested to reset your password for $deploymenttitle on $date.\n\nIf you follow the link below you will be able to personally reset your password.\n$resetlink\n\nThis password reset request is valid for the next 24 hours.\n\nHere are the details of your account:\n\nUsername: $username\nFull name: $firstname $lastname\nYour account is currently: $active\n\n$deploymenttitle administrator
65551	email.template.forgotten.username	32776		Hello $firstname $lastname,\n\nYou have requested the username for your email address: $email.\n\nYour username(s) are: $username\n\nIf you think this email was sent incorrectly, please contact one of the administrators at: $admincontact\n\n$deploymenttitle administrator
65552	mailserver.prefix	32777		[Crowd Server - Atlassian Crowd]
65553	email.template.password.expiration.reminder	32778		Hello $username,\n\nyour password will expire in $daysToPasswordExpiration day(s). Use the following link to change your password to avoid losing access to Crowd and connected applications.\n\n$changePasswordlink\n\n$deploymenttitle administrator
65554	Name	32779		Crowd Server
65555	Encryption type	32779		atlassian-security
65556	Created date	32779		2023-03-14T20:12:05.910+0000
65557	Allowed operations	32779	[]	[CREATE_GROUP, CREATE_USER, DELETE_GROUP, DELETE_USER, UPDATE_GROUP, UPDATE_GROUP_ATTRIBUTE, UPDATE_USER, UPDATE_USER_ATTRIBUTE]
65558	Attribute: password_max_change_time	32779		0
65559	Directory type	32779		INTERNAL
65560	Attribute: password_max_attempts	32779		0
65561	Attribute: user_encryption_method	32779		atlassian-security
65562	Attribute: password_history_count	32779		0
65563	Active	32779		true
65564	Implementation class	32779		com.atlassian.crowd.directory.InternalDirectory
65565	Email	32780		admin@admin.com
65566	Username	32780		admin
65567	First name	32780		Admin
65568	External id	32780		0a5cc43e-1a04-4280-90bd-b1a1c3860466
65569	Last name	32780		Crowd
65570	Display name	32780		Admin Crowd
65571	Active	32780		true
65572	Password	32780		*****
65573	Name	32781		crowd-administrators
65574	Local	32781		false
65575	Active	32781		true
65576	Type	32783		CROWD
65577	Name	32783		crowd
65578	Attribute: accessDenied	32783		true
65579	Description	32783		Crowd console
65580	Attribute: atlassian_sha1_applied	32783		true
65581	Is permanent	32783		true
65582	Active	32783		true
65583	Created Date	32783		2023-03-14T20:13:51.411+0000
65584	Password	32783		*****
65585	Attribute: authenticationByEmailEnabled	32784		false
65586	Attribute: aggregateMemberships	32784		false
65587	Attribute: filterUsersWithAccess	32784		false
65588	Attribute: filterGroupsWithAccess	32784		false
65589	Attribute: optimizeCachedDirectoriesAuthenticationAuthenticationOrder	32784		false
65590	Attribute: aliasingEnabled	32784		false
65591	Attribute: lowerCaseOutput	32784		false
65592	Created Date	32785		2023-03-14T20:13:55.816+0000
65593	Name	32785		crowd-openid-server
65594	Remote addresses	32785	[]	[127.0.0.1, 172.17.0.3, localhost]
65595	Is permanent	32785		false
65596	Description	32785		CrowdID OpenID server
65597	Attribute: atlassian_sha1_applied	32785		true
65598	Type	32785		GENERIC_APPLICATION
65599	Active	32785		true
65600	Password	32785		*****
65601	Directory mappings.131073.Allowed operations	32786		[CREATE_GROUP, CREATE_ROLE, UPDATE_USER_ATTRIBUTE, UPDATE_ROLE_ATTRIBUTE, DELETE_GROUP, CREATE_USER, DELETE_USER, DELETE_ROLE, UPDATE_GROUP_ATTRIBUTE, UPDATE_ROLE, UPDATE_USER, UPDATE_GROUP]
65602	Directory mappings	32786	[]	[131073]
65603	Directory mappings.131073.Allow all to authenticate	32786		true
65604	Attribute: authenticationByEmailEnabled	32787		false
65605	Attribute: aggregateMemberships	32787		false
65606	Attribute: filterUsersWithAccess	32787		false
65607	Attribute: filterGroupsWithAccess	32787		false
65608	Attribute: optimizeCachedDirectoriesAuthenticationAuthenticationOrder	32787		false
65609	Attribute: aliasingEnabled	32787		false
65610	Attribute: lowerCaseOutput	32787		false
65611	com.sun.jndi.ldap.connect.pool.initsize	32788		1
65612	com.sun.jndi.ldap.connect.pool.prefsize	32789		0
65613	com.sun.jndi.ldap.connect.pool.maxsize	32790		0
65614	com.sun.jndi.ldap.connect.pool.timeout	32791		300000
65615	com.sun.jndi.ldap.connect.pool.protocol	32792		plain ssl
65616	com.sun.jndi.ldap.connect.pool.authentication	32793		simple
65617	Attribute: authenticationByEmailEnabled	32794		false
65618	Attribute: aggregateMemberships	32794		false
65619	Attribute: filterUsersWithAccess	32794		false
65620	Attribute: filterGroupsWithAccess	32794		false
65621	Attribute: optimizeCachedDirectoriesAuthenticationAuthenticationOrder	32794		false
65622	Attribute: aliasingEnabled	32794		false
65623	Attribute: lowerCaseOutput	32794		false
491521	notification.email	458753		[""]
491523	crowd.encryption.encryptor.default	458755		AES_CBC_PKCS5Padding
491525	email.template.email.change.info	458757		Hello $firstname $lastname,\n\nWe've noticed you've changed the email assigned to your account. To confirm the change, please check $newemail to confirm the new address and complete updating your account.\n\nIf you didn't request this change, please contact one of the administrators at: $admincontact
65624	mailserver.timeout	32795		60
491522	crowd.encryption.encryptor.AES.keyPath	458754		KEY_DIR/javax.crypto.spec.SecretKeySpec_1678824836410
491524	email.template.email.change.validation	458756		Hello $firstname $lastname,\n\nClick the link below to confirm that this is your email address.\n\n$validationlink
491526	Attribute: authenticationByEmailEnabled	458758	false	true
491527	build.number	458759		1891
491528	Remote addresses	458760	[127.0.0.1, 172.17.0.3, localhost]	[0.0.0.0/0, 127.0.0.1, 172.17.0.3, localhost]
491529	Password	458761	*****	*****
\.


--
-- Data for Name: cwd_cluster_heartbeat; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cwd_cluster_heartbeat (node_id, node_name, hearbeat_timestamp) FROM stdin;
7d347b97-9c62-4dc5-b3cd-5b4d00402652		1678832734940
\.


--
-- Data for Name: cwd_cluster_info; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cwd_cluster_info (node_id, ip_address, hostname, current_heap, max_heap, load_average, uptime, info_timestamp) FROM stdin;
7d347b97-9c62-4dc5-b3cd-5b4d00402652	172.17.0.3	6be20636ab88	316	512	0.537109375	8243939	1678832758003
\.


--
-- Data for Name: cwd_cluster_job; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cwd_cluster_job (id, runner_key, job_interval, cron_expression, time_zone, next_run_timestamp, version, job_parameters, claim_node_id, claim_timestamp) FROM stdin;
heartbeat-cleanup	com.atlassian.crowd.manager.cluster.heartbeat.CrowdClusterNodeHeartbeatService	\N	0 0 0/4 * * ?	\N	1678838400000	1	\N	\N	\N
delegatedDirCleanupJob	com.atlassian.labs.crowd.directory.pruning.jobs.DelegatedDirectoryPruningJob	\N	0 0 3 * * ?	\N	1678849200000	1	\N	\N	\N
PluginRequestCheckJob-job	PluginRequestCheckJob-runner	3600000	\N	\N	1678835636558	4	\N	7d347b97-9c62-4dc5-b3cd-5b4d00402652	1678832036565
LocalPluginLicenseNotificationJob-job	LocalPluginLicenseNotificationJob-runner	86400000	\N	\N	1678911236550	2	\N	7d347b97-9c62-4dc5-b3cd-5b4d00402652	1678824836551
PluginUpdateCheckJob-job	PluginUpdateCheckJob-runner	86400000	\N	\N	1678844413574	1	\N	\N	\N
InstanceTopologyJob-job	InstanceTopologyJob-runner	86400000	\N	\N	1678846376417	1	\N	\N	\N
Service Provider Session Remover	com.atlassian.oauth.serviceprovider.internal.ExpiredSessionRemover	28800000	\N	\N	1678853636579	1	\N	\N	\N
applink-status-analytics-job	com.atlassian.applinks.analytics.ApplinkStatusJob	86400000	\N	\N	1678911237232	2	\N	7d347b97-9c62-4dc5-b3cd-5b4d00402652	1678824837233
applicationSyncMonitor	ApplicationStatusSyncRefresherJobRunner	\N	0 */10 * * * ?	\N	1678833000000	14	\N	7d347b97-9c62-4dc5-b3cd-5b4d00402652	1678832400017
licenseResourceTrigger	LicenseResourceJob	\N	0 0 */6 * * ?	\N	1678838400000	1	\N	\N	\N
stalledSynchronisationsHandlerJob	stalledSynchronisationsHandlerJob	\N	0 */5 * * * ?	\N	1678833000000	28	\N	7d347b97-9c62-4dc5-b3cd-5b4d00402652	1678832700031
clusterMessageReaperTrigger	clusterMessageReaperJob	\N	0 0 */6 * * ?	\N	1678838400000	1	\N	\N	\N
tombstoneReaperTrigger	TombstoneReaperJob	\N	0 0 */6 * * ?	\N	1678838400000	1	\N	\N	\N
com.atlassian.crowd.manager.directory.monitor.DirectoryMonitorRefresherStarter-job	com.atlassian.crowd.manager.directory.monitor.DirectoryMonitorRefresherJob-runner	120000	\N	\N	1678832877910	68	\N	7d347b97-9c62-4dc5-b3cd-5b4d00402652	1678832757929
auditLogPrunerJob	auditLogPrunerJob	\N	0 0 0 */1 * ?	\N	1678838400000	1	\N	\N	\N
clusterNodeInformationPrunerJob	clusterNodeInformationPrunerJob	\N	0 0 3 */1 * ?	\N	1678849200000	1	\N	\N	\N
AutomatedBackup	AutomatedBackup	\N	0 0 2 * * ?	\N	1678845600000	1	\N	\N	\N
com.atlassian.crowd.analytics.statistics.scheduler.ClusterWideStatisticsCollectionScheduler-job	com.atlassian.crowd.analytics.statistics.scheduler.ClusterWideStatisticsCollectionScheduler	\N	0 0 23 * * ?	\N	1678834800000	1	\N	\N	\N
sessionTokenReaperTrigger	SessionTokenReaperJob	\N	0 0 * * * ?	\N	1678834800000	3	\N	7d347b97-9c62-4dc5-b3cd-5b4d00402652	1678831200045
passwordExpirationMailNotificationJob	passwordExpirationMailNotificationJob	\N	0 0 */1 * * ?	\N	1678834800000	3	\N	7d347b97-9c62-4dc5-b3cd-5b4d00402652	1678831200035
rememberMeTokenReaperTrigger	RememberMeTokenReaperJob	\N	0 0 * * * ?	\N	1678834800000	3	\N	7d347b97-9c62-4dc5-b3cd-5b4d00402652	1678831200038
userTokenReaperTrigger	UserTokenReaperJob	\N	0 0 * * * ?	\N	1678834800000	3	\N	7d347b97-9c62-4dc5-b3cd-5b4d00402652	1678831200067
\.


--
-- Data for Name: cwd_cluster_lock; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cwd_cluster_lock (lock_name, lock_timestamp, node_id) FROM stdin;
com.atlassian.upm.request.PluginSettingsPluginRequestStore	1678832036585	\N
com.atlassian.upm.notification.PluginSettingsNotificationCache	1678832036598	\N
CROWD_ENCRYPTION	1678824836440	\N
com.atlassian.crowd.manager.upgrade.UpgradeManagerImpl	1678824836494	\N
com.atlassian.upm.impl.PluginManagerPluginAsynchronousTaskStatusStoreImpl	1678824836532	\N
sal.upgrade.com.atlassian.labs.crowd.directory-pruning-plugin	1678824836598	\N
com.atlassian.crowd.licensing.ApplicationDataSyncMonitorJobRunner-lock	1678832400089	\N
com.atlassian.crowd.manager.directory.monitor.DirectoryMonitorRefresherJob-lock	1678832757952	\N
sal.upgrade.com.atlassian.upm.atlassian-universal-plugin-manager-plugin	1678824837212	\N
sal.upgrade.crowd-saml-plugin	1678824837225	\N
\.


--
-- Data for Name: cwd_cluster_message; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cwd_cluster_message (id, channel, msg_text, msg_timestamp, sender_node_id) FROM stdin;
1	ClusterAwareUserAuthorisationCache	clear	1678824831473	7d347b97-9c62-4dc5-b3cd-5b4d00402652
2	ClusterAwareUserAuthorisationCache	clear	1678824835875	7d347b97-9c62-4dc5-b3cd-5b4d00402652
3	ClusterAwareUserAuthorisationCache	clear	1678824835960	7d347b97-9c62-4dc5-b3cd-5b4d00402652
4	ClusterAwareUserAuthorisationCache	clear	1678824835983	7d347b97-9c62-4dc5-b3cd-5b4d00402652
5	ClusterAwareUserAuthorisationCache	clear	1678824836014	7d347b97-9c62-4dc5-b3cd-5b4d00402652
6	ClusterAwareUserAuthorisationCache	clear	1678824836055	7d347b97-9c62-4dc5-b3cd-5b4d00402652
7	ClusterAwareUserAuthorisationCache	clear	1678824836062	7d347b97-9c62-4dc5-b3cd-5b4d00402652
8	ClusterAwareUserAuthorisationCache	clear	1678824836159	7d347b97-9c62-4dc5-b3cd-5b4d00402652
9	ClusterAwareUserAuthorisationCache	clear	1678824836164	7d347b97-9c62-4dc5-b3cd-5b4d00402652
10	ClusterAwareUserAuthorisationCache	clear	1678824836170	7d347b97-9c62-4dc5-b3cd-5b4d00402652
11	ClusterAwareUserAuthorisationCache	clear	1678824836467	7d347b97-9c62-4dc5-b3cd-5b4d00402652
12	plugin-change	PLUGIN_DISABLED-com.atlassian.ams.shipit.tomcat-filter	1678824836512	7d347b97-9c62-4dc5-b3cd-5b4d00402652
13	ANALYTICS_CACHE	EXPIRE_CACHE	1678824837294	7d347b97-9c62-4dc5-b3cd-5b4d00402652
14	ANALYTICS_CACHE	EXPIRE_CACHE	1678824837682	7d347b97-9c62-4dc5-b3cd-5b4d00402652
15	ClusterAwareInetAddressCache	clear	1678825363910	7d347b97-9c62-4dc5-b3cd-5b4d00402652
16	ClusterAwareUserAuthorisationCache	clear	1678825363919	7d347b97-9c62-4dc5-b3cd-5b4d00402652
17	ClusterAwareUserAuthorisationCache	clear	1678832543453	7d347b97-9c62-4dc5-b3cd-5b4d00402652
18	ClusterAwareUserAuthorisationCache	clear	1678832543465	7d347b97-9c62-4dc5-b3cd-5b4d00402652
\.


--
-- Data for Name: cwd_cluster_message_id; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cwd_cluster_message_id (next_val) FROM stdin;
19
\.


--
-- Data for Name: cwd_cluster_safety; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cwd_cluster_safety (entry_key, entry_value, node_id, ip_address, "timestamp") FROM stdin;
\.


--
-- Data for Name: cwd_databasechangelog; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cwd_databasechangelog (id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, comments, tag, liquibase, contexts, labels, deployment_id) FROM stdin;
Clean liquibase changelog	crowd	liquibase/drop.xml	2023-03-14 20:11:03.187605	46	EXECUTED	8:6e4c634ee804919232d6137894a5547f	delete tableName=CWD_DATABASECHANGELOG		\N	4.16.1	\N	\N	8824662908
KRAK-707: cwd_token	crowd	liquibase/bootstrap/02_cwd_token.xml	2023-03-14 20:11:03.892135	47	EXECUTED	8:85fb391fb975acc4cecadbcf61629310	createTable tableName=cwd_token; addUniqueConstraint constraintName=uk_token_id_hash, tableName=cwd_token; createIndex indexName=idx_token_dir_id, tableName=cwd_token; createIndex indexName=idx_token_key, tableName=cwd_token; createIndex indexName...	Creates the cwd_token table	\N	4.16.1	\N	\N	8824663734
CWD-3028-1	crowd	liquibase/bootstrap/02_cwd_token.xml	2023-03-14 20:11:03.903773	48	EXECUTED	8:785801b68e32bdf075d1401bdba84c2a	addColumn tableName=cwd_token	Create cwd_token.last_accessed_time column	\N	4.16.1	\N	\N	8824663734
CWD-3028-2	crowd	liquibase/bootstrap/02_cwd_token.xml	2023-03-14 20:11:03.907055	49	EXECUTED	8:f096812c3b94dee689aea0f3abbba987	addColumn tableName=cwd_token	Create cwd_token.duration column	\N	4.16.1	\N	\N	8824663734
KRAK-707: cwd_directory	crowd	liquibase/bootstrap/03_cwd_directory.xml	2023-03-14 20:11:03.937544	50	EXECUTED	8:06aa91c1b36f7b366957ab2a6ca4ead7	createTable tableName=cwd_directory; addUniqueConstraint constraintName=uk_dir_l_name, tableName=cwd_directory; createIndex indexName=idx_dir_active, tableName=cwd_directory; createIndex indexName=idx_dir_l_impl_class, tableName=cwd_directory; cre...	Creates the cwd_directory table	\N	4.16.1	\N	\N	8824663734
KRAK-707: cwd_directory_attribute	crowd	liquibase/bootstrap/03_cwd_directory.xml	2023-03-14 20:11:03.974804	51	EXECUTED	8:24892959d245b366f7bc5c3e77a99359	createTable tableName=cwd_directory_attribute; addPrimaryKey tableName=cwd_directory_attribute; addForeignKeyConstraint baseTableName=cwd_directory_attribute, constraintName=fk_directory_attribute, referencedTableName=cwd_directory	Creates the cwd_directory_attribute table	\N	4.16.1	\N	\N	8824663734
KRAK-707: cwd_directory_operation	crowd	liquibase/bootstrap/03_cwd_directory.xml	2023-03-14 20:11:03.99286	52	EXECUTED	8:256d63966f38debb7e66aea054af5d70	createTable tableName=cwd_directory_operation; addPrimaryKey tableName=cwd_directory_operation; addForeignKeyConstraint baseTableName=cwd_directory_operation, constraintName=fk_directory_operation, referencedTableName=cwd_directory	Creates the cwd_directory_operation table	\N	4.16.1	\N	\N	8824663734
KRAK-707: cwd_application	crowd	liquibase/bootstrap/04_cwd_application.xml	2023-03-14 20:11:04.022577	53	EXECUTED	8:3ebeff2f41015332712d00547c045428	createTable tableName=cwd_application; addUniqueConstraint constraintName=uk_app_l_name, tableName=cwd_application; createIndex indexName=idx_app_active, tableName=cwd_application; createIndex indexName=idx_app_type, tableName=cwd_application		\N	4.16.1	\N	\N	8824663734
CWD-3017-1	crowd	liquibase/bootstrap/04_cwd_application.xml	2023-03-14 20:11:04.025227	54	MARK_RAN	8:11e0f5037d5702da6b11753470a6de2d	dropPrimaryKey tableName=cwd_application_address; dropColumn columnName=remote_address_binary, tableName=cwd_application_address; addPrimaryKey tableName=cwd_application_address	Drops cwd_application.remote_address_binary	\N	4.16.1	\N	\N	8824663734
CWD-3017-2	crowd	liquibase/bootstrap/04_cwd_application.xml	2023-03-14 20:11:04.027828	55	MARK_RAN	8:ab296d3e2d9e5f08ddc36914fb6fca40	dropColumn columnName=remote_address_mask, tableName=cwd_application_address	Drops cwd_application.remote_address_mask	\N	4.16.1	\N	\N	8824663734
KRAK-707: cwd_app_dir_mapping	crowd	liquibase/bootstrap/04_cwd_application.xml	2023-03-14 20:11:04.052266	56	EXECUTED	8:fb67a936d18515c07bd6c4415d0232dd	createTable tableName=cwd_app_dir_mapping; addUniqueConstraint constraintName=uk_app_dir, tableName=cwd_app_dir_mapping; addForeignKeyConstraint baseTableName=cwd_app_dir_mapping, constraintName=fk_app_dir_app, referencedTableName=cwd_application;...		\N	4.16.1	\N	\N	8824663734
KRAK-707: cwd_app_dir_operation	crowd	liquibase/bootstrap/04_cwd_application.xml	2023-03-14 20:11:04.066983	57	EXECUTED	8:274e23eaf0c3f348dbb52a4d98ea09c7	createTable tableName=cwd_app_dir_operation; addPrimaryKey tableName=cwd_app_dir_operation; addForeignKeyConstraint baseTableName=cwd_app_dir_operation, constraintName=fk_app_dir_mapping, referencedTableName=cwd_app_dir_mapping		\N	4.16.1	\N	\N	8824663734
KRAK-707: cwd_app_dir_group_mapping	crowd	liquibase/bootstrap/04_cwd_application.xml	2023-03-14 20:11:04.098238	58	EXECUTED	8:6bb2fe72bb5aa41e07229752f08d8748	createTable tableName=cwd_app_dir_group_mapping; addUniqueConstraint constraintName=uk_app_dir_group, tableName=cwd_app_dir_group_mapping; createIndex indexName=idx_app_dir_group_group_dir, tableName=cwd_app_dir_group_mapping; addForeignKeyConstra...		\N	4.16.1	\N	\N	8824663734
KRAK-707: cwd_application_address	crowd	liquibase/bootstrap/04_cwd_application.xml	2023-03-14 20:11:04.11501	59	EXECUTED	8:bdb68a7f049ce975be6dee9d60806e9b	createTable tableName=cwd_application_address; addPrimaryKey tableName=cwd_application_address; addForeignKeyConstraint baseTableName=cwd_application_address, constraintName=fk_application_address, referencedTableName=cwd_application		\N	4.16.1	\N	\N	8824663734
KRAK-707: cwd_application_alias	crowd	liquibase/bootstrap/04_cwd_application.xml	2023-03-14 20:11:04.144995	60	EXECUTED	8:ca57c21350aa80a148594126d3e2e445	createTable tableName=cwd_application_alias; addUniqueConstraint constraintName=uk_alias_app_l_alias, tableName=cwd_application_alias; addUniqueConstraint constraintName=uk_alias_app_l_username, tableName=cwd_application_alias; addForeignKeyConstr...		\N	4.16.1	\N	\N	8824663734
KRAK-707: cwd_application_attribute	crowd	liquibase/bootstrap/04_cwd_application.xml	2023-03-14 20:11:04.168977	61	EXECUTED	8:4e28db392eb5d6817e8e95c0d72e6721	createTable tableName=cwd_application_attribute; addPrimaryKey tableName=cwd_application_attribute; addForeignKeyConstraint baseTableName=cwd_application_attribute, constraintName=fk_application_attribute, referencedTableName=cwd_application		\N	4.16.1	\N	\N	8824663734
KRAK-845: cwd_app_dir_default_groups	crowd	liquibase/bootstrap/04_cwd_application.xml	2023-03-14 20:11:04.189954	62	EXECUTED	8:6c08594d5c1c0e57adc1d208dcae4506	createTable tableName=cwd_app_dir_default_groups; addUniqueConstraint constraintName=uk_appmapping_groupname, tableName=cwd_app_dir_default_groups; addForeignKeyConstraint baseTableName=cwd_app_dir_default_groups, constraintName=fk_app_mapping, re...		\N	4.16.1	\N	\N	8824663734
KRAK-707: cwd_granted_perm	crowd	liquibase/bootstrap/05_cwd_granted_perm.xml	2023-03-14 20:11:04.208444	63	EXECUTED	8:03a045631315ad1442ea8de742a4770e	createTable tableName=cwd_granted_perm; addForeignKeyConstraint baseTableName=cwd_granted_perm, constraintName=fk_permission_group, referencedTableName=cwd_app_dir_group_mapping		\N	4.16.1	\N	\N	8824663734
KRAK-707: cwd_user	crowd	liquibase/bootstrap/06_cwd_user.xml	2023-03-14 20:11:04.243705	64	EXECUTED	8:fe6e7fd7c5706513735f178788e36052	createTable tableName=cwd_user; addUniqueConstraint constraintName=uk_user_name_dir_id, tableName=cwd_user; createIndex indexName=idx_user_active, tableName=cwd_user; createIndex indexName=idx_user_name_dir_id, tableName=cwd_user; addForeignKeyCon...		\N	4.16.1	\N	\N	8824663734
CWD-1843: drop cwd_user.icon_location	crowd	liquibase/bootstrap/06_cwd_user.xml	2023-03-14 20:11:04.245937	65	MARK_RAN	8:02a6e02d97801f4218c20747df2ff518	dropColumn columnName=icon_location, tableName=cwd_user		\N	4.16.1	\N	\N	8824663734
EMBCWD-300: drop idx_user_lower_display_name before mutating constraints	crowd	liquibase/bootstrap/06_cwd_user.xml	2023-03-14 20:11:04.257411	66	MARK_RAN	8:005e4749798f23cef7cfba293a6a76e5	dropIndex indexName=idx_user_lower_display_name, tableName=cwd_user		\N	4.16.1	\N	\N	8824663734
EMBCWD-300: drop idx_user_lower_email_address before mutating constraints	crowd	liquibase/bootstrap/06_cwd_user.xml	2023-03-14 20:11:04.260422	67	MARK_RAN	8:c51559119c402469b7f576062dac98ad	dropIndex indexName=idx_user_lower_email_address, tableName=cwd_user		\N	4.16.1	\N	\N	8824663734
EMBCWD-300: drop idx_user_lower_first_name before mutating constraints	crowd	liquibase/bootstrap/06_cwd_user.xml	2023-03-14 20:11:04.263622	68	MARK_RAN	8:2baf71b998a9017f7e97f61c2bd6c4d2	dropIndex indexName=idx_user_lower_first_name, tableName=cwd_user		\N	4.16.1	\N	\N	8824663734
EMBCWD-300: drop idx_user_lower_last_name before mutating constraints	crowd	liquibase/bootstrap/06_cwd_user.xml	2023-03-14 20:11:04.268279	69	MARK_RAN	8:7dcdd5059a38b5dd07b5f229baf45ab3	dropIndex indexName=idx_user_lower_last_name, tableName=cwd_user		\N	4.16.1	\N	\N	8824663734
EMBCWD-300: remove not-null constraints on cwd_user.first_name	crowd	liquibase/bootstrap/06_cwd_user.xml	2023-03-14 20:11:04.271651	70	EXECUTED	8:ace7dc2e26315c4a2890244101ac3ef4	dropNotNullConstraint columnName=first_name, tableName=cwd_user		\N	4.16.1	\N	\N	8824663734
EMBCWD-300: remove not-null constraints on cwd_user.lower_first_name	crowd	liquibase/bootstrap/06_cwd_user.xml	2023-03-14 20:11:04.273764	71	EXECUTED	8:3eabccf0e511a23c7d818b62c342674f	dropNotNullConstraint columnName=lower_first_name, tableName=cwd_user		\N	4.16.1	\N	\N	8824663734
EMBCWD-300: remove not-null constraints on cwd_user.last_name	crowd	liquibase/bootstrap/06_cwd_user.xml	2023-03-14 20:11:04.275883	72	EXECUTED	8:0ea392fac0a4ce8d56e5483d071efce5	dropNotNullConstraint columnName=last_name, tableName=cwd_user		\N	4.16.1	\N	\N	8824663734
EMBCWD-300: remove not-null constraints on cwd_user.lower_last_name	crowd	liquibase/bootstrap/06_cwd_user.xml	2023-03-14 20:11:04.278592	73	EXECUTED	8:8e69cb6979565b9460fd2fa0222080d9	dropNotNullConstraint columnName=lower_last_name, tableName=cwd_user		\N	4.16.1	\N	\N	8824663734
EMBCWD-300: remove not-null constraints on cwd_user.display_name	crowd	liquibase/bootstrap/06_cwd_user.xml	2023-03-14 20:11:04.281172	74	EXECUTED	8:e9138365d48f87c7b1a0ad5047eeacff	dropNotNullConstraint columnName=display_name, tableName=cwd_user		\N	4.16.1	\N	\N	8824663734
EMBCWD-300: remove not-null constraints on cwd_user.lower_display_name	crowd	liquibase/bootstrap/06_cwd_user.xml	2023-03-14 20:11:04.28412	75	EXECUTED	8:0fba178a6781d3387212fae680941805	dropNotNullConstraint columnName=lower_display_name, tableName=cwd_user		\N	4.16.1	\N	\N	8824663734
EMBCWD-300: remove not-null constraints on cwd_user.email_address	crowd	liquibase/bootstrap/06_cwd_user.xml	2023-03-14 20:11:04.286536	76	EXECUTED	8:f2cb0070fec7b1816d20651c84d3cd93	dropNotNullConstraint columnName=email_address, tableName=cwd_user		\N	4.16.1	\N	\N	8824663734
EMBCWD-300: remove not-null constraints on cwd_user.lower_email_address	crowd	liquibase/bootstrap/06_cwd_user.xml	2023-03-14 20:11:04.2896	77	EXECUTED	8:2cdae077cc4695a5835222d128c9127b	dropNotNullConstraint columnName=lower_email_address, tableName=cwd_user		\N	4.16.1	\N	\N	8824663734
EMBCWD-300: recreate cwd_user indexes	crowd	liquibase/bootstrap/06_cwd_user.xml	2023-03-14 20:11:04.308697	78	EXECUTED	8:13046f9d2010004f8afbdc7247b99ec2	createIndex indexName=idx_user_lower_display_name, tableName=cwd_user; createIndex indexName=idx_user_lower_email_address, tableName=cwd_user; createIndex indexName=idx_user_lower_first_name, tableName=cwd_user; createIndex indexName=idx_user_lowe...		\N	4.16.1	\N	\N	8824663734
CWD-3340: add external_id	crowd	liquibase/bootstrap/06_cwd_user.xml	2023-03-14 20:11:04.316132	79	EXECUTED	8:5304cf1c4ec608cd6567e80abd439ed1	addColumn tableName=cwd_user; createIndex indexName=idx_external_id, tableName=cwd_user		\N	4.16.1	\N	\N	8824663734
KRAK-707: cwd_user_attribute	crowd	liquibase/bootstrap/07_cwd_user_attribute.xml	2023-03-14 20:11:04.356226	80	EXECUTED	8:bdfb651e70be34d5771cb1ae9c76f7d7	createTable tableName=cwd_user_attribute; addUniqueConstraint constraintName=uk_user_attr_name_lval, tableName=cwd_user_attribute; createIndex indexName=idx_user_attr_dir_name_lval, tableName=cwd_user_attribute; createIndex indexName=idx_user_attr...		\N	4.16.1	\N	\N	8824663734
KRAK-707: cwd_user_credential_record	crowd	liquibase/bootstrap/08_cwd_user_credential_record.xml	2023-03-14 20:11:04.382593	81	EXECUTED	8:3791fefa8f9794d0c74e19c628193fbb	createTable tableName=cwd_user_credential_record; addForeignKeyConstraint baseTableName=cwd_user_credential_record, constraintName=fk_user_cred_user, referencedTableName=cwd_user		\N	4.16.1	\N	\N	8824663734
KRAK-707: cwd_group	crowd	liquibase/bootstrap/09_cwd_group.xml	2023-03-14 20:11:04.419952	82	EXECUTED	8:984c4a935b8c9838e1006f485ccdfd5e	createTable tableName=cwd_group; addUniqueConstraint constraintName=uk_group_name_dir_id, tableName=cwd_group; createIndex indexName=idx_group_active, tableName=cwd_group; createIndex indexName=idx_group_dir_id, tableName=cwd_group; addForeignKeyC...		\N	4.16.1	\N	\N	8824663734
EMBCWD-300: Add column cwd_group.is_local	crowd	liquibase/bootstrap/09_cwd_group.xml	2023-03-14 20:11:04.425203	83	EXECUTED	8:a046e53aa369eddb9b2a8abd5b2a7950	addColumn tableName=cwd_group		\N	4.16.1	\N	\N	8824663734
KRAK-328: Add column cwd_group.external_id	crowd	liquibase/bootstrap/09_cwd_group.xml	2023-03-14 20:11:04.431799	84	EXECUTED	8:76aaa396c778d9826396fb48d1fb28a2	addColumn tableName=cwd_group; createIndex indexName=idx_group_external_id, tableName=cwd_group		\N	4.16.1	\N	\N	8824663734
KRAK-707: cwd_group_attribute	crowd	liquibase/bootstrap/09_cwd_group.xml	2023-03-14 20:11:04.466889	85	EXECUTED	8:0e4dfd834a7adf1b2f1cc81cad6779c3	createTable tableName=cwd_group_attribute; addUniqueConstraint constraintName=uk_group_name_attr_lval, tableName=cwd_group_attribute; createIndex indexName=idx_group_attr_dir_name_lval, tableName=cwd_group_attribute; createIndex indexName=idx_grou...		\N	4.16.1	\N	\N	8824663734
KRAK-707: cwd_membership	crowd	liquibase/bootstrap/10_cwd_membership.xml	2023-03-14 20:11:04.505538	86	EXECUTED	8:0e4046db47145400eb08465762ab636f	createTable tableName=cwd_membership; addUniqueConstraint constraintName=uk_mem_parent_child_type, tableName=cwd_membership; createIndex indexName=idx_mem_dir_child, tableName=cwd_membership; createIndex indexName=idx_mem_dir_parent, tableName=cwd...		\N	4.16.1	\N	\N	8824663734
KRAK-326: Add column cwd_membership.created_date	crowd	liquibase/bootstrap/10_cwd_membership.xml	2023-03-14 20:11:04.510268	87	EXECUTED	8:c082cbb8fca645c5ffec757156bfec6d	addColumn tableName=cwd_membership		\N	4.16.1	\N	\N	8824663734
KRAK-707: cwd_audit_log_changeset	crowd	liquibase/bootstrap/11_cwd_audit_log.xml	2023-03-14 20:11:04.551506	88	EXECUTED	8:6165610535994e520d2e0bb9dd824cc4	createTable tableName=cwd_audit_log_changeset; createIndex indexName=idx_audit_authid, tableName=cwd_audit_log_changeset; createIndex indexName=idx_audit_authname, tableName=cwd_audit_log_changeset; createIndex indexName=idx_audit_authtype, tableN...		\N	4.16.1	\N	\N	8824663734
KRAK-707: cwd_audit_log_entry	crowd	liquibase/bootstrap/11_cwd_audit_log.xml	2023-03-14 20:11:04.5692	89	EXECUTED	8:097dea655aed7ae69e1ae51dc344903d	createTable tableName=cwd_audit_log_entry; createIndex indexName=idx_audit_propname, tableName=cwd_audit_log_entry		\N	4.16.1	\N	\N	8824663734
KRAK-707: cwd_audit_log_entry - name foreign key	crowd	liquibase/bootstrap/11_cwd_audit_log.xml	2023-03-14 20:11:05.071201	90	EXECUTED	8:2f3e8a2c473300c99781f5139364938f	dropAllForeignKeyConstraints baseTableName=cwd_audit_log_entry; addForeignKeyConstraint baseTableName=cwd_audit_log_entry, constraintName=fk_audit_entry_changeset, referencedTableName=cwd_audit_log_changeset		\N	4.16.1	\N	\N	8824663734
KRAK-707: cwd_expirable_user_token	crowd	liquibase/bootstrap/12_cwd_expirable_user_token.xml	2023-03-14 20:11:05.092179	91	EXECUTED	8:03700c56bb81ac16ab65a3f8bdde9eed	createTable tableName=cwd_expirable_user_token; addUniqueConstraint constraintName=uk_expirable_user_token, tableName=cwd_expirable_user_token		\N	4.16.1	\N	\N	8824663734
KRAK-707: drop superflous idx_expirable_user_token_key	crowd	liquibase/bootstrap/12_cwd_expirable_user_token.xml	2023-03-14 20:11:05.093511	92	EXECUTED	8:d41d8cd98f00b204e9800998ecf8427e	empty		\N	4.16.1	\N	\N	8824663734
KRAK-707: cwd_cluster_heartbeat	crowd	liquibase/bootstrap/13_cwd_cluster_heartbeat.xml	2023-03-14 20:11:05.107457	93	EXECUTED	8:25cd85ab36bd0ee616ec10f085fe6dd5	createTable tableName=cwd_cluster_heartbeat; createIndex indexName=idx_hb_timestamp, tableName=cwd_cluster_heartbeat		\N	4.16.1	\N	\N	8824663734
KRAK-707: cwd_cluster_info	crowd	liquibase/bootstrap/14_cwd_cluster_info.xml	2023-03-14 20:11:05.124199	94	EXECUTED	8:ba864d9b25f66e1fb88497e7506f5186	createTable tableName=cwd_cluster_info		\N	4.16.1	\N	\N	8824663734
KRAK-707: cwd_cluster_job	crowd	liquibase/bootstrap/15_cwd_cluster_job.xml	2023-03-14 20:11:05.147502	95	EXECUTED	8:161aa37a6ef02ead357c3566ec3bab46	createTable tableName=cwd_cluster_job; createIndex indexName=nextRunTime_idx, tableName=cwd_cluster_job; createIndex indexName=runnerKey_idx, tableName=cwd_cluster_job		\N	4.16.1	\N	\N	8824663734
KRAK-707: cwd_cluster_message	crowd	liquibase/bootstrap/16_cwd_cluster_message.xml	2023-03-14 20:11:05.171141	96	EXECUTED	8:7210ea414060cb638e9ebc0bda42967f	createTable tableName=cwd_cluster_message; createIndex indexName=sender_node_id_idx, tableName=cwd_cluster_message; createIndex indexName=timestamp_idx, tableName=cwd_cluster_message		\N	4.16.1	\N	\N	8824663734
KRAK-707: cwd_cluster_message_id	crowd	liquibase/bootstrap/16_cwd_cluster_message.xml	2023-03-14 20:11:05.178664	97	EXECUTED	8:bd8eb884d51e45f97d499d2661be7cc4	createTable tableName=cwd_cluster_message_id		\N	4.16.1	\N	\N	8824663734
KRAK-707: Populate cwd_cluster_message_id	crowd	liquibase/bootstrap/16_cwd_cluster_message.xml	2023-03-14 20:11:05.18739	98	EXECUTED	8:59e244437b2898958ce9d8774ddfef95	insert tableName=cwd_cluster_message_id		\N	4.16.1	\N	\N	8824663734
KRAK-707: cwd_cluster_lock	crowd	liquibase/bootstrap/17_cwd_cluster_lock.xml	2023-03-14 20:11:05.200725	99	EXECUTED	8:f51938d1a2bc7030baa89f5a57577767	createTable tableName=cwd_cluster_lock		\N	4.16.1	\N	\N	8824663734
KRAK-707: Drop cwd_cluster_safety	crowd	liquibase/bootstrap/18_cwd_cluster_safety.xml	2023-03-14 20:11:05.204812	100	MARK_RAN	8:cdc1d1f1ffea136a5ee118df9c2f3c04	dropTable tableName=cwd_cluster_safety		\N	4.16.1	\N	\N	8824663734
KRAK-707: Recreate cwd_cluster_safety	crowd	liquibase/bootstrap/18_cwd_cluster_safety.xml	2023-03-14 20:11:05.21894	101	EXECUTED	8:437f08556ac4621b0b0ab7d5bbd05253	createTable tableName=cwd_cluster_safety		\N	4.16.1	\N	\N	8824663734
KRAK-707: cwd_property	crowd	liquibase/bootstrap/19_cwd_property.xml	2023-03-14 20:11:05.2358	102	EXECUTED	8:69a551167a22147f6f7aa5a91dd9225c	createTable tableName=cwd_property; addPrimaryKey tableName=cwd_property		\N	4.16.1	\N	\N	8824663734
KRAK-707: cwd_tombstone	crowd	liquibase/bootstrap/20_cwd_tombstone.xml	2023-03-14 20:11:05.254713	103	EXECUTED	8:7a46baf32e84931329eac3d64e3f93c3	createTable tableName=cwd_tombstone; createIndex indexName=idx_tombstone_type_timestamp, tableName=cwd_tombstone		\N	4.16.1	\N	\N	8824663734
KRAK-707: cwd_webhook	crowd	liquibase/bootstrap/21_cwd_webhook.xml	2023-03-14 20:11:05.281975	104	EXECUTED	8:569777c20cc429ad48a512081dee5fd3	createTable tableName=cwd_webhook; addUniqueConstraint constraintName=uk_webhook_url_app, tableName=cwd_webhook; addForeignKeyConstraint baseTableName=cwd_webhook, constraintName=fk_webhook_app, referencedTableName=cwd_application		\N	4.16.1	\N	\N	8824663734
KRAK-707: cwd_synchronisation_status	crowd	liquibase/bootstrap/22_cwd_synchronisation_status.xml	2023-03-14 20:11:05.308926	105	EXECUTED	8:43f2089496e1759b4c8c3f3b7efbd628	createTable tableName=cwd_synchronisation_status; createIndex indexName=idx_directory_id, tableName=cwd_synchronisation_status; createIndex indexName=idx_sync_end, tableName=cwd_synchronisation_status; createIndex indexName=idx_sync_status_node_id...		\N	4.16.1	\N	\N	8824663734
KRAK-707: cwd_synchronisation_status - name foreign key	crowd	liquibase/bootstrap/22_cwd_synchronisation_status.xml	2023-03-14 20:11:05.785811	106	EXECUTED	8:45ba079f09385019ab5db66664cc35ca	dropAllForeignKeyConstraints baseTableName=cwd_synchronisation_status; addForeignKeyConstraint baseTableName=cwd_synchronisation_status, constraintName=fk_sync_status_dir, referencedTableName=cwd_directory		\N	4.16.1	\N	\N	8824663734
KRAK-707: cwd_synchronisation_token	crowd	liquibase/bootstrap/23_cwd_synchronisation_token.xml	2023-03-14 20:11:05.803968	107	EXECUTED	8:6b2084416be337cd32b63c8f61c8109f	createTable tableName=cwd_synchronisation_token		\N	4.16.1	\N	\N	8824663734
KRAK-707: cwd_synchronisation_token - name foreign key	crowd	liquibase/bootstrap/23_cwd_synchronisation_token.xml	2023-03-14 20:11:06.265722	108	EXECUTED	8:b697b2e3ae356c0eaf988ce8229c516a	dropAllForeignKeyConstraints baseTableName=cwd_synchronisation_token; addForeignKeyConstraint baseTableName=cwd_synchronisation_token, constraintName=fk_sync_token_dir, referencedTableName=cwd_directory		\N	4.16.1	\N	\N	8824663734
CWD-4119	crowd	liquibase/crowd_3_1_0/01_setup_hibernate_unique_key.xml	2023-03-14 20:11:06.276149	109	EXECUTED	8:6fb6cc493cb465a0c5337258d977658e	createTable tableName=hibernate_unique_key; insert tableName=hibernate_unique_key	Creates and seeds the hibernate_unique_key table used by Hibernate id generators.	\N	4.16.1	\N	\N	8824663734
CWD-5004	crowd	liquibase/crowd_3_1_0/02_denormalize_granted_permissions.xml	2023-03-14 20:11:06.293194	110	EXECUTED	8:c15c0255ec12b4e186b8ab58877e4992	addColumn tableName=cwd_granted_perm; addNotNullConstraint columnName=group_name, tableName=cwd_granted_perm; addNotNullConstraint columnName=app_dir_mapping_id, tableName=cwd_granted_perm; addForeignKeyConstraint baseTableName=cwd_granted_perm, c...	Replaces cwd_granted_perm with group_name and app_dir_mapping_id in cwd_granted_perm	\N	4.16.1	\N	\N	8824663734
KRAK-1087	crowd	liquibase/crowd_3_1_3/01_audit_entry_cascade.xml	2023-03-14 20:11:06.795357	111	EXECUTED	8:e5d744dd803ac93f01aa36b3b5c95730	dropAllForeignKeyConstraints baseTableName=cwd_audit_log_entry; addForeignKeyConstraint baseTableName=cwd_audit_log_entry, constraintName=fk_entry_changeset, referencedTableName=cwd_audit_log_changeset	Replaces the current foreign key mapping between the changeset and the entry with one that has an ondelete cascade	\N	4.16.1	\N	\N	8824663734
KRAK-1074	crowd	liquibase/crowd_3_2_0/01_create_audit_log_entity_table.xml	2023-03-14 20:11:06.835057	112	EXECUTED	8:c9e077805d5d85de3134144aae266e14	createTable tableName=cwd_audit_log_entity; dropIndex indexName=idx_audit_enttype, tableName=cwd_audit_log_changeset; dropIndex indexName=idx_audit_entid, tableName=cwd_audit_log_changeset; dropIndex indexName=idx_audit_entname, tableName=cwd_audi...	Adds the audit log entity table	\N	4.16.1	\N	\N	8824663734
KRAK-1073	crowd	liquibase/crowd_3_2_0/02_audit_log_migration.xml	2023-03-14 20:11:06.844715	113	EXECUTED	8:785f8ef69fb64aa4472b7af0efcd3cd5	sql; sql; dropColumn columnName=entity_id, tableName=cwd_audit_log_changeset; dropColumn columnName=entity_name, tableName=cwd_audit_log_changeset; dropColumn columnName=entity_type, tableName=cwd_audit_log_changeset	Migrates the data from the audit log changeset table to the new entity table, drops the entity columns from the changeset	\N	4.16.1	\N	\N	8824663734
KRAK-1170	crowd	liquibase/crowd_3_2_0/03_audit_log_event_source.xml	2023-03-14 20:11:06.854144	114	EXECUTED	8:b1e8e3a8730fa6a89de703107a2974a4	addColumn tableName=cwd_audit_log_changeset; addNotNullConstraint columnName=event_source, tableName=cwd_audit_log_changeset; createIndex indexName=idx_audit_source, tableName=cwd_audit_log_changeset	Creates the source column for the cwd_audit_log_changeset table	\N	4.16.1	\N	\N	8824663734
KRAK-1146_1	crowd	liquibase/crowd_3_2_0/04_audit_log_fk_indexes.xml	2023-03-14 20:11:06.860356	115	EXECUTED	8:13bd12969890a8e350ec52233b7e5fb5	createIndex indexName=idx_entry_changeset, tableName=cwd_audit_log_entry	Creates an index on cwd_audit_log_entry.changeset_id	\N	4.16.1	\N	\N	8824663734
KRAK-1146_2	crowd	liquibase/crowd_3_2_0/04_audit_log_fk_indexes.xml	2023-03-14 20:11:06.867358	116	EXECUTED	8:cf5dba677252389f26ee2832841b15eb	createIndex indexName=idx_changeset_entity, tableName=cwd_audit_log_entity	Creates an index on cwd_audit_log_entity.changeset_id	\N	4.16.1	\N	\N	8824663734
KRAK-1187	crowd	liquibase/crowd_3_3_0/01_user_numeric_attribute.xml	2023-03-14 20:11:06.874676	117	EXECUTED	8:92de3436b48e4a69b15a19d13cbcc33a	addColumn tableName=cwd_user_attribute; createIndex indexName=idx_user_attr_nval, tableName=cwd_user_attribute	Creates new column with numeric value of attributes.	\N	4.16.1	\N	\N	8824663734
KRAK-1031	crowd	liquibase/crowd_3_3_0/02_synchronisation_status_parameters_type_migration.xml	2023-03-14 20:11:06.87574	118	MARK_RAN	8:2e02d935a6fad0bcac9c2f866b60b816	modifyDataType columnName=status_parameters, tableName=cwd_synchronisation_status	Changes status_parameters type from long to clob in database of oracle type	\N	4.16.1	\N	\N	8824663734
KRAK-1031	crowd	liquibase/crowd_3_3_0/03_synchronisation_status_token_type_migration.xml	2023-03-14 20:11:06.877225	119	MARK_RAN	8:2e55f5fff94ee7090f97e7681e1018a1	modifyDataType columnName=sync_status_token, tableName=cwd_synchronisation_token	Changes sync_status_token type from long to clob in database of oracle type	\N	4.16.1	\N	\N	8824663734
KRAK-1031	crowd	liquibase/crowd_3_3_0/04_directory_attribute_value_type_migration.xml	2023-03-14 20:11:06.88376	120	EXECUTED	8:5c55ea02fb4fc9542b86d0b9ff445596	delete tableName=cwd_directory_attribute; addColumn tableName=cwd_directory_attribute; update tableName=cwd_directory_attribute; dropColumn columnName=attribute_value, tableName=cwd_directory_attribute; renameColumn newColumnName=attribute_value, ...	Changes attribute value type from varchar to clob	\N	4.16.1	\N	\N	8824663734
KRAK-1031	crowd	liquibase/crowd_3_3_0/05_audit_log_entry_types_migration.xml	2023-03-14 20:11:06.89441	121	EXECUTED	8:b307256fcac0c59e7b3710f42ce29dc6	addColumn tableName=cwd_audit_log_entry; update tableName=cwd_audit_log_entry; dropColumn columnName=old_value, tableName=cwd_audit_log_entry; renameColumn newColumnName=old_value, oldColumnName=old_value_clob, tableName=cwd_audit_log_entry; addCo...	Changes attribute value type from varchar to clob	\N	4.16.1	\N	\N	8824663734
KRAK-1385	crowd	liquibase/crowd_3_3_0/06_cwd_group_admin_group_table.xml	2023-03-14 20:11:06.923117	122	EXECUTED	8:faeca069fb614fc4ddab64de480b6f1b	createTable tableName=cwd_group_admin_group; addForeignKeyConstraint baseTableName=cwd_group_admin_group, constraintName=fk_admin_group, referencedTableName=cwd_group; addForeignKeyConstraint baseTableName=cwd_group_admin_group, constraintName=fk_...	Create cwd_group_admin_group table	\N	4.16.1	\N	\N	8824663734
KRAK-1385	crowd	liquibase/crowd_3_3_0/07_cwd_group_admin_user_table.xml	2023-03-14 20:11:06.952031	123	EXECUTED	8:8633e1fd3f5c3101911ad8adb89812e7	createTable tableName=cwd_group_admin_user; addForeignKeyConstraint baseTableName=cwd_group_admin_user, constraintName=fk_admin_user, referencedTableName=cwd_user; addForeignKeyConstraint baseTableName=cwd_group_admin_user, constraintName=fk_user_...	Create cwd_group_admin_user table	\N	4.16.1	\N	\N	8824663734
KRAK-707: hibernate_unique_key - make sure next_hi is a bigint	crowd	liquibase/crowd_3_3_0/08_fixup_hibernate_unique_key.xml	2023-03-14 20:11:06.956437	124	EXECUTED	8:29d2957d362ee1c52273a85a8f0980cd	renameColumn newColumnName=next_hi_old, oldColumnName=next_hi, tableName=hibernate_unique_key; addColumn tableName=hibernate_unique_key; dropColumn columnName=next_hi_old, tableName=hibernate_unique_key		\N	4.16.1	\N	\N	8824663734
CWD-4242: drop cwd_webhook.idx_webhook_url_app	crowd	liquibase/crowd_3_3_0/09_drop_superflous_cwd_webhook_index.xml	2023-03-14 20:11:06.957575	125	EXECUTED	8:d41d8cd98f00b204e9800998ecf8427e	empty		\N	4.16.1	\N	\N	8824663734
CWD-5004: cwd_granted_perm.group_name fix	crowd	liquibase/crowd_3_3_0/10_fix_granted_perm_group_name_type.xml	2023-03-14 20:11:06.966009	126	EXECUTED	8:b76bac7e89115ab9528fd7dd490628f6	delete tableName=cwd_granted_perm; renameColumn newColumnName=group_name_old, oldColumnName=group_name, tableName=cwd_granted_perm; addColumn tableName=cwd_granted_perm; addNotNullConstraint columnName=group_name, tableName=cwd_granted_perm; dropC...		\N	4.16.1	\N	\N	8824663734
KRAK-1031: make sure cwd_cluster_job.job_parameters has the expected type	crowd	liquibase/crowd_3_3_0/11_cwd_cluster_job_job_parameters_blob_migration.xml	2023-03-14 20:11:06.967166	127	MARK_RAN	8:869b6a6489292d2bf2809899cd9e0eaa	delete tableName=cwd_cluster_job; dropColumn columnName=job_parameters, tableName=cwd_cluster_job; addColumn tableName=cwd_cluster_job		\N	4.16.1	\N	\N	8824663734
KRAK-1712	crowd	liquibase/crowd_3_4_0/01_application_saml_configuration.xml	2023-03-14 20:11:06.984062	128	EXECUTED	8:c59aadad7518eeb636e35e818fe75cab	createTable tableName=cwd_application_saml_config; addForeignKeyConstraint baseTableName=cwd_application_saml_config, constraintName=fk_app_sso_config, referencedTableName=cwd_application	Create cwd_application_saml_config table	\N	4.16.1	\N	\N	8824663734
KRAK-1711	crowd	liquibase/crowd_3_4_0/02_saml_trust_entity_idp_table.xml	2023-03-14 20:11:06.999738	129	EXECUTED	8:9e7db4f4e524f7462d3863ed8dd0c6ce	createTable tableName=cwd_saml_trust_entity_idp	Create cwd_saml_trust_entity_idp table	\N	4.16.1	\N	\N	8824663734
KRAK-1574	crowd	liquibase/crowd_3_4_0/03_crowd_remember_me_token.xml	2023-03-14 20:11:07.027106	130	EXECUTED	8:0348699b21eb8c359a0913260a43a0ad	createTable tableName=cwd_remember_me_token; createIndex indexName=idx_rmt_username, tableName=cwd_remember_me_token; createIndex indexName=idx_rmt_created_date, tableName=cwd_remember_me_token; addUniqueConstraint constraintName=uk_rmt_token, tab...	Create cwd_remember_me_token table	\N	4.16.1	\N	\N	8824663734
KRAK-1791_1	crowd	liquibase/crowd_3_4_0/03_crowd_remember_me_token.xml	2023-03-14 20:11:07.042638	131	EXECUTED	8:8c720fa12679ae152d1da3fa0677e720	dropTable tableName=cwd_remember_me_token	Dropping cwd_remember_me_token table	\N	4.16.1	\N	\N	8824663734
KRAK-1791_2	crowd	liquibase/crowd_3_4_0/03_crowd_remember_me_token.xml	2023-03-14 20:11:07.08119	132	EXECUTED	8:cb5795fae2a4ac74c06b5da17a333b24	createTable tableName=cwd_remember_me_token; createIndex indexName=idx_rmt_username, tableName=cwd_remember_me_token; createIndex indexName=idx_rmt_directory_id, tableName=cwd_remember_me_token; createIndex indexName=idx_rmt_created_date, tableNam...	Re-create cwd_remember_me_token table	\N	4.16.1	\N	\N	8824663734
CWD-5213	crowd	liquibase/crowd_3_4_0/04_update_azure_ad_timeouts.xml	2023-03-14 20:11:07.08553	133	EXECUTED	8:1dd8e2e2568a929ecd8063d9749f589b	sql; sql	Set default timeouts for Azure AD directories	\N	4.16.1	\N	\N	8824663734
KRAK-2030	crowd	liquibase/crowd_3_5_0/01_cwd_app_licensing.xml	2023-03-14 20:11:07.109674	134	EXECUTED	8:9a04a55c7d566405b04b2df1c040ac10	createTable tableName=cwd_app_licensing; createIndex indexName=idx_app_id, tableName=cwd_app_licensing; createIndex indexName=idx_app_id_subtype_version, tableName=cwd_app_licensing; addForeignKeyConstraint baseTableName=cwd_app_licensing, constra...	Create cwd_app_licensing table	\N	4.16.1	\N	\N	8824663734
KRAK-2030	crowd	liquibase/crowd_3_5_0/02_cwd_app_licensing_dir_info.xml	2023-03-14 20:11:07.136833	135	EXECUTED	8:ba02753e6c343d2c04d92e051c9e8405	createTable tableName=cwd_app_licensing_dir_info; createIndex indexName=idx_dir_id, tableName=cwd_app_licensing_dir_info; createIndex indexName=idx_summary_id, tableName=cwd_app_licensing_dir_info; addForeignKeyConstraint baseTableName=cwd_app_lic...	Create cwd_app_licensing_dir_info table	\N	4.16.1	\N	\N	8824663734
KRAK-2030	crowd	liquibase/crowd_3_5_0/03_cwd_app_licensed_user.xml	2023-03-14 20:11:07.156517	136	EXECUTED	8:af47b1f3d79a4111f56ca63432302596	createTable tableName=cwd_app_licensed_user; addForeignKeyConstraint baseTableName=cwd_app_licensed_user, constraintName=fk_licensed_user_dir_id, referencedTableName=cwd_app_licensing_dir_info	Create cwd_application_saml_config table	\N	4.16.1	\N	\N	8824663734
KRAK-2030-drop-constraints	crowd	liquibase/crowd_3_5_0/04_cwd_app_licensed_user_updates.xml	2023-03-14 20:11:07.158819	137	EXECUTED	8:9524a2f7850baae952ac0019176a6509	dropNotNullConstraint columnName=full_name, tableName=cwd_app_licensed_user; dropNotNullConstraint columnName=email, tableName=cwd_app_licensed_user		\N	4.16.1	\N	\N	8824663734
KRAK-2030-delete-before-add-lowercased-columns	crowd	liquibase/crowd_3_5_0/05_before_cwd_app_licensed_user_lowercase.xml	2023-03-14 20:11:07.16299	138	EXECUTED	8:3d8500fe43c5ef45ba914e05bfc8b65c	delete tableName=cwd_app_licensed_user; delete tableName=cwd_app_licensing_dir_info; delete tableName=cwd_app_licensing		\N	4.16.1	\N	\N	8824663734
KRAK-2030-add-lowercased-columns	crowd	liquibase/crowd_3_5_0/05_cwd_app_licensed_user_lowercase.xml	2023-03-14 20:11:07.16864	139	EXECUTED	8:cd1dff69be9df94b13b05d439af67bad	addColumn tableName=cwd_app_licensed_user; addColumn tableName=cwd_app_licensed_user; addColumn tableName=cwd_app_licensed_user		\N	4.16.1	\N	\N	8824663734
KRAK-844	crowd	liquibase/crowd_3_7_0/01_cwd_property_value_type_change.xml	2023-03-14 20:11:07.173292	140	EXECUTED	8:0678e718ea42ea2b39293230cc8cddfb	addColumn tableName=cwd_property; update tableName=cwd_property; dropColumn columnName=property_value, tableName=cwd_property; renameColumn newColumnName=property_value, oldColumnName=property_value_clob, tableName=cwd_property		\N	4.16.1	\N	\N	8824663734
KRAK-677	crowd	liquibase/crowd_3_7_0/02_cwd_application_attribute_value_type_change.xml	2023-03-14 20:11:07.178228	141	EXECUTED	8:3f140e86edbb6fc5e765f88f2323f9c1	addColumn tableName=cwd_application_attribute; update tableName=cwd_application_attribute; dropColumn columnName=attribute_value, tableName=cwd_application_attribute; renameColumn newColumnName=attribute_value, oldColumnName=attribute_value_clob, ...		\N	4.16.1	\N	\N	8824663734
KRAK-2897: Make cwd_cluster_message_id compatible with hibernate 5.4.0	crowd	liquibase/crowd_4_0_0/01_cwd_cluster_message_id.xml	2023-03-14 20:11:07.180797	142	EXECUTED	8:1f048ec74cecb187f672f588ba62bc89	update tableName=cwd_cluster_message_id		\N	4.16.1	\N	\N	8824663734
KRAK-2935: cwd_membership_indexes	crowd	liquibase/crowd_4_0_3/01_cwd_membership_indexes.xml	2023-03-14 20:11:07.198228	143	EXECUTED	8:1becfac63fe9dfd650dd567fa1b18614	dropIndex indexName=idx_mem_dir_child, tableName=cwd_membership; createIndex indexName=idx_mem_dir_child, tableName=cwd_membership; dropIndex indexName=idx_mem_dir_parent, tableName=cwd_membership; createIndex indexName=idx_mem_dir_parent, tableNa...		\N	4.16.1	\N	\N	8824663734
KRAK-3496: Add the incremental_sync_error and full_sync_error columns to cwd_synchronisation_status	crowd	liquibase/crowd_4_2_0/01_cwd_synchronisation_status_inc_and_full_sync_errors.xml	2023-03-14 20:11:07.202531	144	EXECUTED	8:c1ac62c21c5664ae8f67a15c66823d25	addColumn tableName=cwd_synchronisation_status		\N	4.16.1	\N	\N	8824663734
KRAK-3494: Add the node_name column to cwd_synchronisation_status	crowd	liquibase/crowd_4_2_0/02_cwd_synchronisation_status_node_name.xml	2023-03-14 20:11:07.205012	145	EXECUTED	8:cd6a13d960ddd4d3c33f3fb73ad79606	addColumn tableName=cwd_synchronisation_status		\N	4.16.1	\N	\N	8824663734
XDSSO-17	crowd	liquibase/crowd_4_4_0/01_saml_application_name_id_format_config.xml	2023-03-14 20:11:07.20937	146	EXECUTED	8:c21042c3952b6c1d35eaa0fb47952efe	addColumn tableName=cwd_application_saml_config; update tableName=cwd_application_saml_config; addNotNullConstraint columnName=name_id_format, tableName=cwd_application_saml_config	Adding name_id_format property for app SAML config	\N	4.16.1	\N	\N	8824663734
XDSSO-17	crowd	liquibase/crowd_4_4_0/02_saml_application_add_user_attributes_enabled_config.xml	2023-03-14 20:11:07.21368	147	EXECUTED	8:b98a82400b1cba6f011535aaed710dc5	addColumn tableName=cwd_application_saml_config; update tableName=cwd_application_saml_config; addNotNullConstraint columnName=add_user_attributes_enabled, tableName=cwd_application_saml_config	Adding add_user_attributes_enabled property for app SAML config	\N	4.16.1	\N	\N	8824663734
XDSSO-35	crowd	liquibase/crowd_4_4_0/03_expirable_user_token_type.xml	2023-03-14 20:11:07.220666	148	EXECUTED	8:4a590096df3cdb5eac94499fad0c486a	addColumn tableName=cwd_expirable_user_token; update tableName=cwd_expirable_user_token; addNotNullConstraint columnName=token_type, tableName=cwd_expirable_user_token	Extend ExpirableUserToken to include various types. Default to unspecified	\N	4.16.1	\N	\N	8824663734
XDSSO-42	crowd	liquibase/crowd_4_4_0/04_cwd_app_emails_scan.xml	2023-03-14 20:11:07.233533	149	EXECUTED	8:2059d0ac1f4b94a5f36ae9f4ee2c6b93	createTable tableName=cwd_app_emails_scan; addForeignKeyConstraint baseTableName=cwd_app_emails_scan, constraintName=fk_application_id, referencedTableName=cwd_application	Crate cwd_app_emails_scan table	\N	4.16.1	\N	\N	8824663734
\.


--
-- Data for Name: cwd_databasechangeloglock; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cwd_databasechangeloglock (id, locked, lockgranted, lockedby) FROM stdin;
1	f	\N	\N
\.


--
-- Data for Name: cwd_directory; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cwd_directory (id, directory_name, lower_directory_name, created_date, updated_date, active, description, impl_class, lower_impl_class, directory_type) FROM stdin;
131073	Crowd Server	crowd server	2023-03-14 20:12:05.91	2023-03-14 20:13:56.436	T		com.atlassian.crowd.directory.InternalDirectory	com.atlassian.crowd.directory.internaldirectory	INTERNAL
\.


--
-- Data for Name: cwd_directory_attribute; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cwd_directory_attribute (directory_id, attribute_name, attribute_value) FROM stdin;
131073	user_encryption_method	atlassian-security
131073	password_max_change_time	0
131073	password_max_attempts	0
131073	password_history_count	0
131073	configuration.change.timestamp	1678824836010
\.


--
-- Data for Name: cwd_directory_operation; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cwd_directory_operation (directory_id, operation_type) FROM stdin;
131073	CREATE_GROUP
131073	UPDATE_USER_ATTRIBUTE
131073	DELETE_GROUP
131073	CREATE_USER
131073	DELETE_USER
131073	UPDATE_GROUP_ATTRIBUTE
131073	UPDATE_USER
131073	UPDATE_GROUP
\.


--
-- Data for Name: cwd_expirable_user_token; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cwd_expirable_user_token (id, token, user_name, email_address, expiry_date, directory_id, token_type) FROM stdin;
\.


--
-- Data for Name: cwd_granted_perm; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cwd_granted_perm (id, created_date, permission_id, app_dir_mapping_id, group_name) FROM stdin;
393217	2023-03-14 20:13:51.439	2	327681	crowd-administrators
393218	2023-03-14 20:13:56.21	2	327681	crowd-administrators
\.


--
-- Data for Name: cwd_group; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cwd_group (id, group_name, lower_group_name, active, created_date, updated_date, description, group_type, directory_id, is_local, external_id) FROM stdin;
262145	crowd-administrators	crowd-administrators	T	2023-03-14 20:13:51.378	2023-03-14 20:13:51.378	\N	GROUP	131073	F	\N
\.


--
-- Data for Name: cwd_group_admin_group; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cwd_group_admin_group (id, group_id, target_group_id) FROM stdin;
\.


--
-- Data for Name: cwd_group_admin_user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cwd_group_admin_user (id, user_id, target_group_id) FROM stdin;
\.


--
-- Data for Name: cwd_group_attribute; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cwd_group_attribute (id, group_id, directory_id, attribute_name, attribute_value, attribute_lower_value) FROM stdin;
\.


--
-- Data for Name: cwd_membership; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cwd_membership (id, parent_id, child_id, membership_type, group_type, parent_name, lower_parent_name, child_name, lower_child_name, directory_id, created_date) FROM stdin;
294913	262145	163841	GROUP_USER	GROUP	crowd-administrators	crowd-administrators	admin	admin	131073	2023-03-14 20:13:51.401
\.


--
-- Data for Name: cwd_property; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cwd_property (property_key, property_name, property_value) FROM stdin;
crowd	deployment.title	Crowd Server
crowd	des.encryption.key	pINw/tMcswE=
crowd	session.time	1800000
crowd	cache.enabled	true
crowd	base.url	http://localhost:8095/crowd
crowd	mailserver.message.template	Hello $firstname $lastname,\n\nYou (or someone else) have requested to reset your password for $deploymenttitle on $date.\n\nIf you follow the link below you will be able to personally reset your password.\n$resetlink\n\nThis password reset request is valid for the next 24 hours.\n\nHere are the details of your account:\n\nUsername: $username\nFull name: $firstname $lastname\nYour account is currently: $active\n\n$deploymenttitle administrator
crowd	email.template.forgotten.username	Hello $firstname $lastname,\n\nYou have requested the username for your email address: $email.\n\nYour username(s) are: $username\n\nIf you think this email was sent incorrectly, please contact one of the administrators at: $admincontact\n\n$deploymenttitle administrator
crowd	mailserver.prefix	[Crowd Server - Atlassian Crowd]
crowd	email.template.password.expiration.reminder	Hello $username,\n\nyour password will expire in $daysToPasswordExpiration day(s). Use the following link to change your password to avoid losing access to Crowd and connected applications.\n\n$changePasswordlink\n\n$deploymenttitle administrator
crowd	current.license.resource.total	0
crowd	secure.cookie	false
crowd	com.sun.jndi.ldap.connect.pool.initsize	1
crowd	com.sun.jndi.ldap.connect.pool.prefsize	0
crowd	com.sun.jndi.ldap.connect.pool.maxsize	0
crowd	com.sun.jndi.ldap.connect.pool.timeout	300000
crowd	com.sun.jndi.ldap.connect.pool.protocol	plain ssl
crowd	com.sun.jndi.ldap.connect.pool.authentication	simple
crowd	mailserver.timeout	60
crowd	notification.email	[""]
crowd	crowd.encryption.encryptor.AES.keyPath	KEY_DIR/javax.crypto.spec.SecretKeySpec_1678824836410
crowd	crowd.encryption.encryptor.default	AES_CBC_PKCS5Padding
crowd	email.template.email.change.validation	Hello $firstname $lastname,\n\nClick the link below to confirm that this is your email address.\n\n$validationlink
crowd	email.template.email.change.info	Hello $firstname $lastname,\n\nWe've noticed you've changed the email assigned to your account. To confirm the change, please check $newemail to confirm the new address and complete updating your account.\n\nIf you didn't request this change, please contact one of the administrators at: $admincontact
crowd	build.number	1891
plugin.null	com.atlassian.upm:notifications:notification-plugin.request	#java.util.List\n
plugin.null	com.atlassian.upm:notifications:notification-edition.mismatch	#java.util.List\n
plugin.null	com.atlassian.upm:notifications:notification-evaluation.expired	#java.util.List\n
plugin.null	com.atlassian.upm:notifications:notification-evaluation.nearlyexpired	#java.util.List\n
plugin.null	com.atlassian.upm:notifications:notification-maintenance.expired	#java.util.List\n
plugin.null	com.atlassian.upm:notifications:notification-maintenance.nearlyexpired	#java.util.List\n
plugin.null	com.atlassian.upm:notifications:notification-license.expired	#java.util.List\n
plugin.null	com.atlassian.upm:notifications:notification-license.nearlyexpired	#java.util.List\n
plugin.null	com.atlassian.analytics.client.configuration..analytics_enabled	true
plugin.null	crowd-saml-plugin:build	1
plugin.null	com.atlassian.upm.log.PluginSettingsAuditLogService:log:upm_audit_log_v3	#java.util.List\n{"userKey":"Crowd","date":1678824837232,"i18nKey":"upm.auditLog.upm.startup","entryType":"UPM_STARTUP","params":[]}
plugin.null	com.atlassian.troubleshooting.thready.configuration.enabled	false
plugin.null	com.atlassian.analytics.client.configuration..policy_acknowledged	true
plugin.null	com.atlassian.analytics.client.configuration.uuid	8577d832-4553-4455-99ef-7e74c4cfb2c0
plugin.null	com.atlassian.analytics.client.configuration.serverid	BR20-AMMS-P6G7-TY8N
plugin.null	com.atlassian.labs.crowd.directory-pruning-plugin:build	2
plugin.null	com.atlassian.upm.atlassian-universal-plugin-manager-plugin:build	5
plugin.null	crowd.analytics.instance.startup.info	#java.util.Map\nstart_time\f1678824837881\nbuild_number\f1891\nclustered\ftrue
plugin.null	com.atlassian.upm:notifications:notification-update	#java.util.List\n
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             \.


--
-- Data for Name: cwd_remember_me_token; Type: TABLE DATA; Schema: public; Owner: postgres
--

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             COPY public.cwd_remember_me_token (id, username, remote_address, token, series, created_date, used_date, directory_id) FROM stdin;
655361	admin	172.17.0.1	34dcdd09e1f5dffdb15502d8b45c91799492f2ed	46b836488117a8ac28f5f58b21da23bc024b3ba9	2023-03-14 20:14:11.163347	2023-03-14 22:22:14.367854	131073
655362	admin	\N	71d94828f288269163699dcdec4b379a61450128	46b836488117a8ac28f5f58b21da23bc024b3ba9	2023-03-14 20:14:11.163347	\N	131073
\.


--
-- Data for Name: cwd_saml_trust_entity_idp; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cwd_saml_trust_entity_idp (id, certificate, created_date, expiration_date, private_key) FROM stdin;
\.


--
-- Data for Name: cwd_synchronisation_status; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cwd_synchronisation_status (id, directory_id, node_id, sync_start, sync_end, sync_status, status_parameters, incremental_sync_error, full_sync_error, node_name) FROM stdin;
\.


--
-- Data for Name: cwd_synchronisation_token; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cwd_synchronisation_token (directory_id, sync_status_token) FROM stdin;
\.


--
-- Data for Name: cwd_token; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cwd_token (id, directory_id, entity_name, random_number, identifier_hash, random_hash, created_date, last_accessed_date, last_accessed_time, duration) FROM stdin;
622594	131073	admin	3112099423528460574	Oxtei1Ngl2hKL06Rq30pEw	wTV8FIq__JtJpvieMoYI-QAAAAAAAgABYWRtaW4	2023-03-14 22:22:14.477	2023-03-14 22:22:14.477	1678832543324	\N
\.


--
-- Data for Name: cwd_tombstone; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cwd_tombstone (id, tombstone_type, tombstone_timestamp, entity_name, directory_id, parent, application_id) FROM stdin;
425985	APPLICATION_UPDATED	1678824831481	\N	\N	\N	2
425986	EVENTS	1678824835963	com.atlassian.crowd.event.directory.DirectoryUpdatedEvent	131073	\N	\N
425987	EVENTS	1678824835989	com.atlassian.crowd.event.directory.DirectoryUpdatedEvent	131073	\N	\N
425988	EVENTS	1678824836017	com.atlassian.crowd.event.directory.DirectoryUpdatedEvent	131073	\N	\N
425989	APPLICATION_UPDATED	1678824836059	\N	\N	\N	2
425990	APPLICATION_UPDATED	1678824836064	\N	\N	\N	3
425991	APPLICATION_UPDATED	1678824836162	\N	\N	\N	2
425992	APPLICATION_UPDATED	1678824836167	\N	\N	\N	3
425993	APPLICATION_UPDATED	1678824836174	\N	\N	\N	1
524289	APPLICATION_UPDATED	1678824836469	\N	\N	\N	2
524290	APPLICATION_UPDATED	1678825363923	\N	\N	\N	3
524291	APPLICATION_UPDATED	1678832543460	\N	\N	\N	3
524292	APPLICATION_UPDATED	1678832543469	\N	\N	\N	3
\.


--
-- Data for Name: cwd_user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cwd_user (id, user_name, lower_user_name, active, created_date, updated_date, first_name, lower_first_name, last_name, lower_last_name, display_name, lower_display_name, email_address, lower_email_address, directory_id, credential, external_id) FROM stdin;
163841	admin	admin	T	2023-03-14 20:13:51.299	2023-03-14 22:22:14.466	Admin	admin	Crowd	crowd	Admin Crowd	admin crowd	admin@admin.com	admin@admin.com	131073	{PKCS5S2}7POecuSBXQBJ3tCGHrSERZ5d5QCQSwZdaVrMFE995yJC3UCgmkq7izdgOEWXXlKK	0a5cc43e-1a04-4280-90bd-b1a1c3860466
\.


--
-- Data for Name: cwd_user_attribute; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cwd_user_attribute (id, user_id, directory_id, attribute_name, attribute_value, attribute_lower_value, attribute_numeric_value) FROM stdin;
229377	163841	131073	requiresPasswordChange	false	false	\N
229378	163841	131073	invalidPasswordAttempts	0	0	0
229379	163841	131073	passwordLastChanged	1678824831339	1678824831339	1678824831339
589825	163841	131073	lastAuthenticated	1678832534465	1678832534465	1678832534465
589826	163841	131073	lastActive	1678832543324	1678832543324	1678832543324
\.


--
-- Data for Name: cwd_user_credential_record; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cwd_user_credential_record (id, user_id, password_hash, list_index) FROM stdin;
196609	163841	{PKCS5S2}7POecuSBXQBJ3tCGHrSERZ5d5QCQSwZdaVrMFE995yJC3UCgmkq7izdgOEWXXlKK	0
\.


--
-- Data for Name: cwd_webhook; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cwd_webhook (id, endpoint_url, application_id, token, oldest_failure_date, failures_since_last_success) FROM stdin;
\.


--
-- Data for Name: hibernate_unique_key; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hibernate_unique_key (next_hi) FROM stdin;
21
\.


--
-- Name: cwd_app_dir_default_groups cwd_app_dir_default_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_app_dir_default_groups
    ADD CONSTRAINT cwd_app_dir_default_groups_pkey PRIMARY KEY (id);


--
-- Name: cwd_app_dir_group_mapping cwd_app_dir_group_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_app_dir_group_mapping
    ADD CONSTRAINT cwd_app_dir_group_mapping_pkey PRIMARY KEY (id);


--
-- Name: cwd_app_dir_mapping cwd_app_dir_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_app_dir_mapping
    ADD CONSTRAINT cwd_app_dir_mapping_pkey PRIMARY KEY (id);


--
-- Name: cwd_app_dir_operation cwd_app_dir_operation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_app_dir_operation
    ADD CONSTRAINT cwd_app_dir_operation_pkey PRIMARY KEY (app_dir_mapping_id, operation_type);


--
-- Name: cwd_app_licensed_user cwd_app_licensed_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_app_licensed_user
    ADD CONSTRAINT cwd_app_licensed_user_pkey PRIMARY KEY (id);


--
-- Name: cwd_app_licensing_dir_info cwd_app_licensing_dir_info_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_app_licensing_dir_info
    ADD CONSTRAINT cwd_app_licensing_dir_info_pkey PRIMARY KEY (id);


--
-- Name: cwd_app_licensing cwd_app_licensing_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_app_licensing
    ADD CONSTRAINT cwd_app_licensing_pkey PRIMARY KEY (id);


--
-- Name: cwd_application_address cwd_application_address_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_application_address
    ADD CONSTRAINT cwd_application_address_pkey PRIMARY KEY (application_id, remote_address);


--
-- Name: cwd_application_alias cwd_application_alias_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_application_alias
    ADD CONSTRAINT cwd_application_alias_pkey PRIMARY KEY (id);


--
-- Name: cwd_application_attribute cwd_application_attribute_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_application_attribute
    ADD CONSTRAINT cwd_application_attribute_pkey PRIMARY KEY (application_id, attribute_name);


--
-- Name: cwd_application cwd_application_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_application
    ADD CONSTRAINT cwd_application_pkey PRIMARY KEY (id);


--
-- Name: cwd_application_saml_config cwd_application_saml_config_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_application_saml_config
    ADD CONSTRAINT cwd_application_saml_config_pkey PRIMARY KEY (application_id);


--
-- Name: cwd_audit_log_changeset cwd_audit_log_changeset_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_audit_log_changeset
    ADD CONSTRAINT cwd_audit_log_changeset_pkey PRIMARY KEY (id);


--
-- Name: cwd_audit_log_entity cwd_audit_log_entity_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_audit_log_entity
    ADD CONSTRAINT cwd_audit_log_entity_pkey PRIMARY KEY (id);


--
-- Name: cwd_audit_log_entry cwd_audit_log_entry_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_audit_log_entry
    ADD CONSTRAINT cwd_audit_log_entry_pkey PRIMARY KEY (id);


--
-- Name: cwd_cluster_heartbeat cwd_cluster_heartbeat_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_cluster_heartbeat
    ADD CONSTRAINT cwd_cluster_heartbeat_pkey PRIMARY KEY (node_id);


--
-- Name: cwd_cluster_info cwd_cluster_info_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_cluster_info
    ADD CONSTRAINT cwd_cluster_info_pkey PRIMARY KEY (node_id);


--
-- Name: cwd_cluster_job cwd_cluster_job_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_cluster_job
    ADD CONSTRAINT cwd_cluster_job_pkey PRIMARY KEY (id);


--
-- Name: cwd_cluster_lock cwd_cluster_lock_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_cluster_lock
    ADD CONSTRAINT cwd_cluster_lock_pkey PRIMARY KEY (lock_name);


--
-- Name: cwd_cluster_message cwd_cluster_message_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_cluster_message
    ADD CONSTRAINT cwd_cluster_message_pkey PRIMARY KEY (id);


--
-- Name: cwd_cluster_safety cwd_cluster_safety_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_cluster_safety
    ADD CONSTRAINT cwd_cluster_safety_pkey PRIMARY KEY (entry_key);


--
-- Name: cwd_databasechangeloglock cwd_databasechangeloglock_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_databasechangeloglock
    ADD CONSTRAINT cwd_databasechangeloglock_pkey PRIMARY KEY (id);


--
-- Name: cwd_directory_attribute cwd_directory_attribute_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_directory_attribute
    ADD CONSTRAINT cwd_directory_attribute_pkey PRIMARY KEY (directory_id, attribute_name);


--
-- Name: cwd_directory_operation cwd_directory_operation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_directory_operation
    ADD CONSTRAINT cwd_directory_operation_pkey PRIMARY KEY (directory_id, operation_type);


--
-- Name: cwd_directory cwd_directory_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_directory
    ADD CONSTRAINT cwd_directory_pkey PRIMARY KEY (id);


--
-- Name: cwd_expirable_user_token cwd_expirable_user_token_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_expirable_user_token
    ADD CONSTRAINT cwd_expirable_user_token_pkey PRIMARY KEY (id);


--
-- Name: cwd_granted_perm cwd_granted_perm_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_granted_perm
    ADD CONSTRAINT cwd_granted_perm_pkey PRIMARY KEY (id);


--
-- Name: cwd_group_admin_group cwd_group_admin_group_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_group_admin_group
    ADD CONSTRAINT cwd_group_admin_group_pkey PRIMARY KEY (id);


--
-- Name: cwd_group_admin_user cwd_group_admin_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_group_admin_user
    ADD CONSTRAINT cwd_group_admin_user_pkey PRIMARY KEY (id);


--
-- Name: cwd_group_attribute cwd_group_attribute_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_group_attribute
    ADD CONSTRAINT cwd_group_attribute_pkey PRIMARY KEY (id);


--
-- Name: cwd_group cwd_group_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_group
    ADD CONSTRAINT cwd_group_pkey PRIMARY KEY (id);


--
-- Name: cwd_membership cwd_membership_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_membership
    ADD CONSTRAINT cwd_membership_pkey PRIMARY KEY (id);


--
-- Name: cwd_property cwd_property_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_property
    ADD CONSTRAINT cwd_property_pkey PRIMARY KEY (property_key, property_name);


--
-- Name: cwd_remember_me_token cwd_remember_me_token_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_remember_me_token
    ADD CONSTRAINT cwd_remember_me_token_pkey PRIMARY KEY (id);


--
-- Name: cwd_saml_trust_entity_idp cwd_saml_trust_entity_idp_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_saml_trust_entity_idp
    ADD CONSTRAINT cwd_saml_trust_entity_idp_pkey PRIMARY KEY (id);


--
-- Name: cwd_synchronisation_status cwd_synchronisation_status_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_synchronisation_status
    ADD CONSTRAINT cwd_synchronisation_status_pkey PRIMARY KEY (id);


--
-- Name: cwd_synchronisation_token cwd_synchronisation_token_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_synchronisation_token
    ADD CONSTRAINT cwd_synchronisation_token_pkey PRIMARY KEY (directory_id);


--
-- Name: cwd_token cwd_token_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_token
    ADD CONSTRAINT cwd_token_pkey PRIMARY KEY (id);


--
-- Name: cwd_tombstone cwd_tombstone_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_tombstone
    ADD CONSTRAINT cwd_tombstone_pkey PRIMARY KEY (id);


--
-- Name: cwd_user_attribute cwd_user_attribute_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_user_attribute
    ADD CONSTRAINT cwd_user_attribute_pkey PRIMARY KEY (id);


--
-- Name: cwd_user_credential_record cwd_user_credential_record_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_user_credential_record
    ADD CONSTRAINT cwd_user_credential_record_pkey PRIMARY KEY (id);


--
-- Name: cwd_user cwd_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_user
    ADD CONSTRAINT cwd_user_pkey PRIMARY KEY (id);


--
-- Name: cwd_webhook cwd_webhook_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_webhook
    ADD CONSTRAINT cwd_webhook_pkey PRIMARY KEY (id);


--
-- Name: cwd_application_alias uk_alias_app_l_alias; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_application_alias
    ADD CONSTRAINT uk_alias_app_l_alias UNIQUE (application_id, lower_alias_name);


--
-- Name: cwd_application_alias uk_alias_app_l_username; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_application_alias
    ADD CONSTRAINT uk_alias_app_l_username UNIQUE (application_id, lower_user_name);


--
-- Name: cwd_app_dir_mapping uk_app_dir; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_app_dir_mapping
    ADD CONSTRAINT uk_app_dir UNIQUE (application_id, directory_id);


--
-- Name: cwd_app_dir_group_mapping uk_app_dir_group; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_app_dir_group_mapping
    ADD CONSTRAINT uk_app_dir_group UNIQUE (app_dir_mapping_id, group_name);


--
-- Name: cwd_application uk_app_l_name; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_application
    ADD CONSTRAINT uk_app_l_name UNIQUE (lower_application_name);


--
-- Name: cwd_app_dir_default_groups uk_appmapping_groupname; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_app_dir_default_groups
    ADD CONSTRAINT uk_appmapping_groupname UNIQUE (application_mapping_id, group_name);


--
-- Name: cwd_directory uk_dir_l_name; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_directory
    ADD CONSTRAINT uk_dir_l_name UNIQUE (lower_directory_name);


--
-- Name: cwd_expirable_user_token uk_expirable_user_token; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_expirable_user_token
    ADD CONSTRAINT uk_expirable_user_token UNIQUE (token);


--
-- Name: cwd_group_admin_group uk_group_and_target_group; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_group_admin_group
    ADD CONSTRAINT uk_group_and_target_group UNIQUE (group_id, target_group_id);


--
-- Name: cwd_group_attribute uk_group_name_attr_lval; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_group_attribute
    ADD CONSTRAINT uk_group_name_attr_lval UNIQUE (group_id, attribute_name, attribute_lower_value);


--
-- Name: cwd_group uk_group_name_dir_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_group
    ADD CONSTRAINT uk_group_name_dir_id UNIQUE (lower_group_name, directory_id);


--
-- Name: cwd_membership uk_mem_parent_child_type; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_membership
    ADD CONSTRAINT uk_mem_parent_child_type UNIQUE (parent_id, child_id, membership_type);


--
-- Name: cwd_remember_me_token uk_rmt_token_and_series; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_remember_me_token
    ADD CONSTRAINT uk_rmt_token_and_series UNIQUE (token, series);


--
-- Name: cwd_token uk_token_id_hash; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_token
    ADD CONSTRAINT uk_token_id_hash UNIQUE (identifier_hash);


--
-- Name: cwd_group_admin_user uk_user_and_target_group; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_group_admin_user
    ADD CONSTRAINT uk_user_and_target_group UNIQUE (user_id, target_group_id);


--
-- Name: cwd_user_attribute uk_user_attr_name_lval; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_user_attribute
    ADD CONSTRAINT uk_user_attr_name_lval UNIQUE (user_id, attribute_name, attribute_lower_value);


--
-- Name: cwd_user uk_user_name_dir_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_user
    ADD CONSTRAINT uk_user_name_dir_id UNIQUE (lower_user_name, directory_id);


--
-- Name: cwd_webhook uk_webhook_url_app; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_webhook
    ADD CONSTRAINT uk_webhook_url_app UNIQUE (endpoint_url, application_id);


--
-- Name: idx_admin_group; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_admin_group ON public.cwd_group_admin_group USING btree (group_id);


--
-- Name: idx_admin_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_admin_user ON public.cwd_group_admin_user USING btree (user_id);


--
-- Name: idx_app_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_app_active ON public.cwd_application USING btree (active);


--
-- Name: idx_app_dir_group_group_dir; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_app_dir_group_group_dir ON public.cwd_app_dir_group_mapping USING btree (directory_id, group_name);


--
-- Name: idx_app_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_app_id ON public.cwd_app_licensing USING btree (application_id);


--
-- Name: idx_app_id_subtype_version; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_app_id_subtype_version ON public.cwd_app_licensing USING btree (application_id, application_subtype, version);


--
-- Name: idx_app_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_app_type ON public.cwd_application USING btree (application_type);


--
-- Name: idx_audit_authid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_audit_authid ON public.cwd_audit_log_changeset USING btree (author_id);


--
-- Name: idx_audit_authname; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_audit_authname ON public.cwd_audit_log_changeset USING btree (author_name);


--
-- Name: idx_audit_authtype; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_audit_authtype ON public.cwd_audit_log_changeset USING btree (author_type);


--
-- Name: idx_audit_entid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_audit_entid ON public.cwd_audit_log_entity USING btree (entity_id);


--
-- Name: idx_audit_entname; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_audit_entname ON public.cwd_audit_log_entity USING btree (entity_name);


--
-- Name: idx_audit_enttype_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_audit_enttype_id ON public.cwd_audit_log_entity USING btree (entity_type, entity_id);


--
-- Name: idx_audit_enttype_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_audit_enttype_name ON public.cwd_audit_log_entity USING btree (entity_type, entity_name);


--
-- Name: idx_audit_ip; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_audit_ip ON public.cwd_audit_log_changeset USING btree (ip_address);


--
-- Name: idx_audit_propname; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_audit_propname ON public.cwd_audit_log_entry USING btree (property_name);


--
-- Name: idx_audit_source; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_audit_source ON public.cwd_audit_log_changeset USING btree (event_source);


--
-- Name: idx_audit_timestamp; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_audit_timestamp ON public.cwd_audit_log_changeset USING btree (audit_timestamp);


--
-- Name: idx_auth_eventtype; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_auth_eventtype ON public.cwd_audit_log_changeset USING btree (event_type);


--
-- Name: idx_changeset_entity; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_changeset_entity ON public.cwd_audit_log_entity USING btree (changeset_id);


--
-- Name: idx_dir_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_dir_active ON public.cwd_directory USING btree (active);


--
-- Name: idx_dir_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_dir_id ON public.cwd_app_licensing_dir_info USING btree (directory_id);


--
-- Name: idx_dir_l_impl_class; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_dir_l_impl_class ON public.cwd_directory USING btree (lower_impl_class);


--
-- Name: idx_dir_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_dir_type ON public.cwd_directory USING btree (directory_type);


--
-- Name: idx_directory_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_directory_id ON public.cwd_synchronisation_status USING btree (directory_id);


--
-- Name: idx_entry_changeset; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_entry_changeset ON public.cwd_audit_log_entry USING btree (changeset_id);


--
-- Name: idx_external_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_external_id ON public.cwd_user USING btree (external_id);


--
-- Name: idx_group_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_group_active ON public.cwd_group USING btree (active, directory_id);


--
-- Name: idx_group_attr_dir_name_lval; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_group_attr_dir_name_lval ON public.cwd_group_attribute USING btree (directory_id, attribute_name, attribute_lower_value);


--
-- Name: idx_group_attr_group_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_group_attr_group_id ON public.cwd_group_attribute USING btree (group_id);


--
-- Name: idx_group_dir_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_group_dir_id ON public.cwd_group USING btree (directory_id);


--
-- Name: idx_group_external_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_group_external_id ON public.cwd_group USING btree (external_id);


--
-- Name: idx_group_target_group; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_group_target_group ON public.cwd_group_admin_group USING btree (target_group_id);


--
-- Name: idx_hb_timestamp; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_hb_timestamp ON public.cwd_cluster_heartbeat USING btree (hearbeat_timestamp);


--
-- Name: idx_mem_dir_child; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_mem_dir_child ON public.cwd_membership USING btree (directory_id, lower_child_name, membership_type);


--
-- Name: idx_mem_dir_parent; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_mem_dir_parent ON public.cwd_membership USING btree (directory_id, lower_parent_name, membership_type);


--
-- Name: idx_mem_dir_parent_child; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_mem_dir_parent_child ON public.cwd_membership USING btree (directory_id, lower_parent_name, lower_child_name, membership_type);


--
-- Name: idx_rmt_created_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_rmt_created_date ON public.cwd_remember_me_token USING btree (created_date);


--
-- Name: idx_rmt_directory_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_rmt_directory_id ON public.cwd_remember_me_token USING btree (directory_id);


--
-- Name: idx_rmt_used_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_rmt_used_date ON public.cwd_remember_me_token USING btree (used_date);


--
-- Name: idx_rmt_username; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_rmt_username ON public.cwd_remember_me_token USING btree (username);


--
-- Name: idx_summary_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_summary_id ON public.cwd_app_licensing_dir_info USING btree (licensing_summary_id);


--
-- Name: idx_sync_end; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sync_end ON public.cwd_synchronisation_status USING btree (sync_end);


--
-- Name: idx_sync_status_node_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sync_status_node_id ON public.cwd_synchronisation_status USING btree (node_id);


--
-- Name: idx_token_dir_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_token_dir_id ON public.cwd_token USING btree (directory_id);


--
-- Name: idx_token_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_token_key ON public.cwd_token USING btree (random_hash);


--
-- Name: idx_token_last_access; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_token_last_access ON public.cwd_token USING btree (last_accessed_date);


--
-- Name: idx_token_name_dir_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_token_name_dir_id ON public.cwd_token USING btree (directory_id, entity_name);


--
-- Name: idx_tombstone_type_timestamp; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tombstone_type_timestamp ON public.cwd_tombstone USING btree (tombstone_type, tombstone_timestamp);


--
-- Name: idx_user_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_active ON public.cwd_user USING btree (active, directory_id);


--
-- Name: idx_user_attr_dir_name_lval; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_attr_dir_name_lval ON public.cwd_user_attribute USING btree (directory_id, attribute_name, attribute_lower_value);


--
-- Name: idx_user_attr_nval; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_attr_nval ON public.cwd_user_attribute USING btree (attribute_name, attribute_numeric_value);


--
-- Name: idx_user_attr_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_attr_user_id ON public.cwd_user_attribute USING btree (user_id);


--
-- Name: idx_user_lower_display_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_lower_display_name ON public.cwd_user USING btree (lower_display_name, directory_id);


--
-- Name: idx_user_lower_email_address; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_lower_email_address ON public.cwd_user USING btree (lower_email_address, directory_id);


--
-- Name: idx_user_lower_first_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_lower_first_name ON public.cwd_user USING btree (lower_first_name, directory_id);


--
-- Name: idx_user_lower_last_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_lower_last_name ON public.cwd_user USING btree (lower_last_name, directory_id);


--
-- Name: idx_user_name_dir_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_name_dir_id ON public.cwd_user USING btree (directory_id);


--
-- Name: idx_user_target_group; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_target_group ON public.cwd_group_admin_user USING btree (target_group_id);


--
-- Name: nextRunTime_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "nextRunTime_idx" ON public.cwd_cluster_job USING btree (next_run_timestamp);


--
-- Name: runnerKey_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "runnerKey_idx" ON public.cwd_cluster_job USING btree (runner_key);


--
-- Name: sender_node_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sender_node_id_idx ON public.cwd_cluster_message USING btree (sender_node_id);


--
-- Name: timestamp_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX timestamp_idx ON public.cwd_cluster_message USING btree (msg_timestamp);


--
-- Name: cwd_group_admin_group fk_admin_group; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_group_admin_group
    ADD CONSTRAINT fk_admin_group FOREIGN KEY (group_id) REFERENCES public.cwd_group(id);


--
-- Name: cwd_group_admin_user fk_admin_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_group_admin_user
    ADD CONSTRAINT fk_admin_user FOREIGN KEY (user_id) REFERENCES public.cwd_user(id) ON DELETE CASCADE;


--
-- Name: cwd_application_alias fk_alias_app_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_application_alias
    ADD CONSTRAINT fk_alias_app_id FOREIGN KEY (application_id) REFERENCES public.cwd_application(id);


--
-- Name: cwd_app_dir_mapping fk_app_dir_app; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_app_dir_mapping
    ADD CONSTRAINT fk_app_dir_app FOREIGN KEY (application_id) REFERENCES public.cwd_application(id);


--
-- Name: cwd_app_dir_mapping fk_app_dir_dir; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_app_dir_mapping
    ADD CONSTRAINT fk_app_dir_dir FOREIGN KEY (directory_id) REFERENCES public.cwd_directory(id);


--
-- Name: cwd_app_dir_group_mapping fk_app_dir_group_app; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_app_dir_group_mapping
    ADD CONSTRAINT fk_app_dir_group_app FOREIGN KEY (application_id) REFERENCES public.cwd_application(id);


--
-- Name: cwd_app_dir_group_mapping fk_app_dir_group_dir; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_app_dir_group_mapping
    ADD CONSTRAINT fk_app_dir_group_dir FOREIGN KEY (directory_id) REFERENCES public.cwd_directory(id);


--
-- Name: cwd_app_dir_group_mapping fk_app_dir_group_mapping; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_app_dir_group_mapping
    ADD CONSTRAINT fk_app_dir_group_mapping FOREIGN KEY (app_dir_mapping_id) REFERENCES public.cwd_app_dir_mapping(id);


--
-- Name: cwd_app_dir_operation fk_app_dir_mapping; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_app_dir_operation
    ADD CONSTRAINT fk_app_dir_mapping FOREIGN KEY (app_dir_mapping_id) REFERENCES public.cwd_app_dir_mapping(id);


--
-- Name: cwd_app_licensing fk_app_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_app_licensing
    ADD CONSTRAINT fk_app_id FOREIGN KEY (application_id) REFERENCES public.cwd_application(id);


--
-- Name: cwd_app_dir_default_groups fk_app_mapping; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_app_dir_default_groups
    ADD CONSTRAINT fk_app_mapping FOREIGN KEY (application_mapping_id) REFERENCES public.cwd_app_dir_mapping(id);


--
-- Name: cwd_application_saml_config fk_app_sso_config; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_application_saml_config
    ADD CONSTRAINT fk_app_sso_config FOREIGN KEY (application_id) REFERENCES public.cwd_application(id) ON DELETE CASCADE;


--
-- Name: cwd_application_address fk_application_address; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_application_address
    ADD CONSTRAINT fk_application_address FOREIGN KEY (application_id) REFERENCES public.cwd_application(id);


--
-- Name: cwd_application_attribute fk_application_attribute; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_application_attribute
    ADD CONSTRAINT fk_application_attribute FOREIGN KEY (application_id) REFERENCES public.cwd_application(id);


--
-- Name: cwd_app_emails_scan fk_application_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_app_emails_scan
    ADD CONSTRAINT fk_application_id FOREIGN KEY (application_id) REFERENCES public.cwd_application(id);


--
-- Name: cwd_audit_log_entity fk_changeset_entity; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_audit_log_entity
    ADD CONSTRAINT fk_changeset_entity FOREIGN KEY (changeset_id) REFERENCES public.cwd_audit_log_changeset(id) ON DELETE CASCADE;


--
-- Name: cwd_directory_attribute fk_directory_attribute; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_directory_attribute
    ADD CONSTRAINT fk_directory_attribute FOREIGN KEY (directory_id) REFERENCES public.cwd_directory(id);


--
-- Name: cwd_group fk_directory_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_group
    ADD CONSTRAINT fk_directory_id FOREIGN KEY (directory_id) REFERENCES public.cwd_directory(id);


--
-- Name: cwd_directory_operation fk_directory_operation; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_directory_operation
    ADD CONSTRAINT fk_directory_operation FOREIGN KEY (directory_id) REFERENCES public.cwd_directory(id);


--
-- Name: cwd_audit_log_entry fk_entry_changeset; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_audit_log_entry
    ADD CONSTRAINT fk_entry_changeset FOREIGN KEY (changeset_id) REFERENCES public.cwd_audit_log_changeset(id) ON DELETE CASCADE;


--
-- Name: cwd_granted_perm fk_granted_perm_dir_mapping; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_granted_perm
    ADD CONSTRAINT fk_granted_perm_dir_mapping FOREIGN KEY (app_dir_mapping_id) REFERENCES public.cwd_app_dir_mapping(id);


--
-- Name: cwd_group_attribute fk_group_attr_dir_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_group_attribute
    ADD CONSTRAINT fk_group_attr_dir_id FOREIGN KEY (directory_id) REFERENCES public.cwd_directory(id);


--
-- Name: cwd_group_attribute fk_group_attr_id_group_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_group_attribute
    ADD CONSTRAINT fk_group_attr_id_group_id FOREIGN KEY (group_id) REFERENCES public.cwd_group(id);


--
-- Name: cwd_group_admin_group fk_group_target_group; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_group_admin_group
    ADD CONSTRAINT fk_group_target_group FOREIGN KEY (target_group_id) REFERENCES public.cwd_group(id) ON DELETE CASCADE;


--
-- Name: cwd_app_licensed_user fk_licensed_user_dir_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_app_licensed_user
    ADD CONSTRAINT fk_licensed_user_dir_id FOREIGN KEY (directory_id) REFERENCES public.cwd_app_licensing_dir_info(id);


--
-- Name: cwd_app_licensing_dir_info fk_licensing_dir_dir_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_app_licensing_dir_info
    ADD CONSTRAINT fk_licensing_dir_dir_id FOREIGN KEY (directory_id) REFERENCES public.cwd_directory(id);


--
-- Name: cwd_app_licensing_dir_info fk_licensing_dir_summary_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_app_licensing_dir_info
    ADD CONSTRAINT fk_licensing_dir_summary_id FOREIGN KEY (licensing_summary_id) REFERENCES public.cwd_app_licensing(id);


--
-- Name: cwd_membership fk_membership_dir; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_membership
    ADD CONSTRAINT fk_membership_dir FOREIGN KEY (directory_id) REFERENCES public.cwd_directory(id);


--
-- Name: cwd_remember_me_token fk_rmt_directory_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_remember_me_token
    ADD CONSTRAINT fk_rmt_directory_id FOREIGN KEY (directory_id) REFERENCES public.cwd_directory(id) ON DELETE CASCADE;


--
-- Name: cwd_synchronisation_status fk_sync_status_dir; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_synchronisation_status
    ADD CONSTRAINT fk_sync_status_dir FOREIGN KEY (directory_id) REFERENCES public.cwd_directory(id);


--
-- Name: cwd_synchronisation_token fk_sync_token_dir; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_synchronisation_token
    ADD CONSTRAINT fk_sync_token_dir FOREIGN KEY (directory_id) REFERENCES public.cwd_directory(id);


--
-- Name: cwd_user_attribute fk_user_attr_dir_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_user_attribute
    ADD CONSTRAINT fk_user_attr_dir_id FOREIGN KEY (directory_id) REFERENCES public.cwd_directory(id);


--
-- Name: cwd_user_attribute fk_user_attribute_id_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_user_attribute
    ADD CONSTRAINT fk_user_attribute_id_user_id FOREIGN KEY (user_id) REFERENCES public.cwd_user(id);


--
-- Name: cwd_user_credential_record fk_user_cred_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_user_credential_record
    ADD CONSTRAINT fk_user_cred_user FOREIGN KEY (user_id) REFERENCES public.cwd_user(id);


--
-- Name: cwd_user fk_user_dir_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_user
    ADD CONSTRAINT fk_user_dir_id FOREIGN KEY (directory_id) REFERENCES public.cwd_directory(id);


--
-- Name: cwd_group_admin_user fk_user_target_group; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_group_admin_user
    ADD CONSTRAINT fk_user_target_group FOREIGN KEY (target_group_id) REFERENCES public.cwd_group(id) ON DELETE CASCADE;


--
-- Name: cwd_webhook fk_webhook_app; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cwd_webhook
    ADD CONSTRAINT fk_webhook_app FOREIGN KEY (application_id) REFERENCES public.cwd_application(id);


--
-- PostgreSQL database dump complete
--

