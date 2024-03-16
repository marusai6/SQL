-- Операторы, фильтрация, сортировка, ограничения

/* 1. Пусть в таблице users поля created_at и updated_at оказались незаполненными. Заполните их текущими датой и временем.*/

USE example;

ALTER TABLE users
	MODIFY COLUMN created_at DATETIME,
	MODIFY COLUMN updated_at DATETIME; -- Изменили свойства колонок, чтобы они не заполнялись по умолчанию
	
INSERT INTO users (name) VALUES
	('Александр'),
	('Пётр'),
	('Константин'),
	('Иван');                 -- Заполнили колонку name, поля created_at и updated_at оказались незаполненными.
	
UPDATE users SET created_at = now(), updated_at = now(); -- Заполнили поля created_at и updated_at текущими датой и временем.

/* 2. Таблица users была неудачно спроектирована. Записи created_at и updated_at были заданы типом VARCHAR и в них долгое 
 * время помещались значения в формате 20.10.2017 8:10. Необходимо преобразовать поля к типу DATETIME, сохранив введённые 
 * ранее значения.*/

ALTER TABLE users
	MODIFY COLUMN created_at VARCHAR(50),
	MODIFY COLUMN updated_at VARCHAR(50); -- Изменили типы колонок created_at и updated_at на VARCHAR

UPDATE users SET created_at = '20.10.2017 8:10', updated_at = '20.10.2017 8:10'; -- Обновили записи в колонках

UPDATE users SET created_at = STR_TO_DATE(created_at, '%d.%m.%Y %H:%i');
UPDATE users SET updated_at = STR_TO_DATE(updated_at, '%d.%m.%Y %H:%i'); -- Привели строковые значения к дате по образцу

ALTER TABLE users
	MODIFY COLUMN created_at DATETIME,
	MODIFY COLUMN updated_at DATETIME;       -- Преобразовали поля к типу DATETIME

/* 3. В таблице складских запасов storehouses_products в поле value могут встречаться самые разные цифры: 0, если товар 
 * закончился и выше нуля, если на складе имеются запасы. Необходимо отсортировать записи таким образом, чтобы они 
 * выводились в порядке увеличения значения value. Однако нулевые запасы должны выводиться в конце, после всех записей.*/
	
CREATE TABLE storehouses_products(
	id SERIAL PRIMARY KEY,
	name VARCHAR(255),
	value FLOAT                      -- Создали таблицу storehouses_products
);

INSERT INTO storehouses_products (name, value) VALUES
	('Milk', '5.7'),
	('Cheese', '12'),
	('Oil', '0'),
	('yogurt', '0.5'),
	('Kefir', '0'),
	('Ice-cream', '23.65');           -- Заполнили таблицу значениями
	
SELECT * FROM storehouses_products ORDER BY value = 0, value;  -- Отсортировали записи

/* 4. Из таблицы users необходимо извлечь пользователей, родившихся в августе и мае. Месяцы заданы в виде списка 
 * английских названий (may, august)*/

SELECT name FROM users
	WHERE monthname(birthday_at) = 'May' OR monthname(birthday_at) = 'August'; 
 

-- Агрегация данных

/* 1. Подсчитайте средний возраст пользователей в таблице users.*/

ALTER TABLE users ADD COLUMN birthday_at DATE;  -- Добавили колонку birthday_at

UPDATE users SET birthday_at = '1986-05-02' WHERE id = 1; 
UPDATE users SET birthday_at = '1995-08-25' WHERE id = 2; 
UPDATE users SET birthday_at = '1978-12-15' WHERE id = 3; 
UPDATE users SET birthday_at = '1981-02-11' WHERE id = 4;   -- Заполнили значениями

SELECT AVG (TIMESTAMPDIFF (YEAR, birthday_at, now())) FROM users;  -- Посчитали средний возраст

/* 2. Подсчитайте количество дней рождения, которые приходятся на каждый из дней недели. Следует учесть, что необходимы 
 * дни недели текущего года, а не года рождения.*/

SELECT (dayname (date_format(birthday_at, '2022-%m-%d'))) AS day_of_week, COUNT(*) AS total FROM users 
	GROUP BY (dayname (date_format(birthday_at, '2022-%m-%d'))); 


