DROP DATABASE IF EXISTS supertour;
CREATE DATABASE supertour;
USE supertour;

DROP TABLE IF EXISTS clients;
CREATE TABLE clients (
	id SERIAL PRIMARY KEY,
	firstname VARCHAR(50),
    lastname VARCHAR(50) COMMENT 'Фамилия',
    middle_name VARCHAR(50) COMMENT 'Отчество',
    email VARCHAR(100) UNIQUE,
    phone BIGINT,
    address VARCHAR(250),
    passport VARCHAR(250),
    INDEX clients_firstname_lastname_idx(firstname, lastname),
    INDEX clients_phone_idx(phone)
);

DROP TABLE IF EXISTS countries;
CREATE TABLE countries (
	id SERIAL PRIMARY KEY,
	name VARCHAR(250),
	INDEX countries_name_idx (name)
);

DROP TABLE IF EXISTS cities;
CREATE TABLE cities (
	id SERIAL PRIMARY KEY,
	name VARCHAR(250),
	countries_id BIGINT UNSIGNED NOT NULL,
	description TEXT,
	photo JSON,
	INDEX cities_name_idx (name),
	FOREIGN KEY (countries_id) REFERENCES countries (id) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS currencies;
CREATE TABLE currencies (
	id SERIAL PRIMARY KEY,
	designation VARCHAR(3),
	name VARCHAR(50),
	exchange_rate FLOAT,
	INDEX cur_idx (designation)
);

DROP TABLE IF EXISTS hotels;
CREATE TABLE hotels (
	id SERIAL PRIMARY KEY,
	name VARCHAR(250),
	ht_country_id BIGINT UNSIGNED NOT NULL,
	ht_city_id BIGINT UNSIGNED NOT NULL,
	address VARCHAR(250),
	number_of_stars ENUM ('1', '2', '3', '4', '5'),
	photo JSON,
	description TEXT,
	INDEX hotels_name_idx (name),
	FOREIGN KEY (ht_country_id) REFERENCES countries (id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (ht_city_id) REFERENCES cities (id) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS excursions;
CREATE TABLE excursions (
	id SERIAL PRIMARY KEY,
	name VARCHAR(250),
	ex_country_id BIGINT UNSIGNED NOT NULL,
	ex_city_id BIGINT UNSIGNED NOT NULL,
	description TEXT,
	photo JSON,
	rout TEXT,
	begin_at DATETIME,
	finish_at DATETIME,
	INDEX excursions_name_idx (name),
	FOREIGN KEY (ex_country_id) REFERENCES countries (id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (ex_city_id) REFERENCES cities (id) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS flights;
CREATE TABLE flights (
	`number` VARCHAR (10) UNIQUE PRIMARY KEY,
	city_from VARCHAR(250),
	city_to VARCHAR(250),
	departure DATETIME,
	arrival DATETIME,
	INDEX flights_num_idx (`number`),
	FOREIGN KEY (city_from) REFERENCES cities (name) ON UPDATE CASCADE ON DELETE SET NULL,
	FOREIGN KEY (city_to) REFERENCES cities (name) ON UPDATE CASCADE ON DELETE SET NULL 
);

DROP TABLE IF EXISTS `catalog`;
CREATE TABLE `catalog` (
	id SERIAL PRIMARY KEY,
	name_of_tour VARCHAR(100),
	country_id BIGINT UNSIGNED NOT NULL,
	city_id BIGINT UNSIGNED NOT NULL,
	hotel_id BIGINT UNSIGNED NOT NULL,
	description TEXT,
	photo JSON,
	flight VARCHAR (10),
	excursion_includ_id BIGINT UNSIGNED NOT NULL,
	price FLOAT,
	currency_des VARCHAR(3),
	begin_at DATETIME,
	finish_at DATETIME,
	INDEX catalog_idx (name_of_tour, country_id, city_id, hotel_id),
	FOREIGN KEY (country_id) REFERENCES countries (id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (city_id) REFERENCES cities (id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (hotel_id) REFERENCES hotels (id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (flight) REFERENCES flights (`number`) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (excursion_includ_id) REFERENCES excursions (id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (currency_des) REFERENCES currencies (designation) ON UPDATE CASCADE ON DELETE SET NULL
);

DROP TABLE IF EXISTS applications;
CREATE TABLE applications (
	id SERIAL PRIMARY KEY,
	client_id BIGINT UNSIGNED NOT NULL,
	tour_id BIGINT UNSIGNED NOT NULL,
	created_at DATETIME DEFAULT NOW(),
	updated_at DATETIME on update now(),
	`status` ENUM ('created', 'confirmed', 'paid_for'),
	FOREIGN KEY (client_id) REFERENCES clients (id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (tour_id) REFERENCES `catalog` (id) ON UPDATE CASCADE ON DELETE CASCADE
); 