CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE SCHEMA IF NOT EXISTS aggregates_production;

CREATE TABLE IF NOT EXISTS aggregates_production.downloads (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    rollup_date DATE,
    pod_id INT,
    dependency_name TEXT,
    dependency_version TEXT,
    pod_tries INT,
    downloads INT,
    UNIQUE(pod_id, dependency_version, rollup_date)
);

CREATE TABLE IF NOT EXISTS aggregates_production.usage (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    rollup_date DATE,
    version TEXT,
    usages INT,
    UNIQUE(version, rollup_date)
);

CREATE TABLE cocoapods_stats_production.install_light (
    id character varying(512) PRIMARY KEY,
    dependency_name character varying(512),
    dependency_version character varying(512),
    pod_try boolean,
    sent_at timestamp without time zone,
);
