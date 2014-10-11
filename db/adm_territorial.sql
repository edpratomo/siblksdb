DROP TABLE IF EXISTS districts;
DROP TABLE IF EXISTS regencies_cities;
DROP TABLE IF EXISTS provinces;

CREATE TABLE provinces (
  id SERIAL PRIMARY KEY,
  code varchar(2) NOT NULL UNIQUE,
  name varchar(30) NOT NULL
);

CREATE TABLE regencies_cities (
  id SERIAL PRIMARY KEY,
  code varchar(4) NOT NULL UNIQUE,
  province_code varchar(2) NOT NULL,
  name varchar(30) NOT NULL
);

CREATE TABLE districts (
  id SERIAL PRIMARY KEY,
  code varchar(7) NOT NULL UNIQUE,
  regency_city_code varchar(4) NOT NULL,
  name varchar(30) NOT NULL
);

CREATE INDEX districts_name ON districts(name);

