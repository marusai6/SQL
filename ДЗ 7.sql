/* 1. Составьте список пользователей users, которые осуществили хотя бы один заказ orders в интернет магазине.*/

USE shop;

SELECT name FROM users u 
WHERE id IN (SELECT user_id FROM orders o);

/* 2. Выведите список товаров products и разделов catalogs, который соответствует товару.*/

SELECT products.name AS product, catalogs.name AS catalog_ FROM products JOIN catalogs
ON products.catalog_id = catalogs.id;

/* 3. Пусть имеется таблица рейсов flights (id, from, to) и таблица городов cities (label, name). Поля from, 
to и label содержат английские названия городов, поле name — русское. Выведите список рейсов flights с русскими 
названиями городов.*/

CREATE TABLE flights (
	id SERIAL PRIMARY KEY,
	`from` VARCHAR(50),
	`to` VARCHAR(50)
);

INSERT INTO flights
	(`from`, `to`)
VALUES
	('moscow', 'omsk'),
	('novgorod', 'kazan'),
	('irkutsk', 'moscow'),
	('omsk', 'irkutsk'),
	('moscow', 'kazan');

CREATE TABLE Cities (
	label VARCHAR (50),
	name VARCHAR (50)
);

INSERT INTO Cities
	(label, name)
VALUES
	('moscow', 'Москва'),
	('irkutsk', 'Иркутск'),
	('novgorod', 'Новгород'),
	('kazan', 'Казань'),
	('omsk', 'Омск');

SELECT flights.id, ci.name AS `from_`, cs.name AS `to_` FROM cities AS ci
JOIN flights
ON ci.label = flights.`from`
JOIN cities AS cs
ON cs.label = flights.`to`
ORDER BY flights.id;


 