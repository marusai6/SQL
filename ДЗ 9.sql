-- Транзакции, переменные, представления.

/* 1. В базе данных shop и sample присутствуют одни и те же таблицы, учебной базы данных. Переместите запись id = 1 из 
таблицы shop.users в таблицу sample.users. Используйте транзакции.*/

-- В консоли:

mysql> START TRANSACTION;
Query OK, 0 rows affected (0.00 sec)

mysql> SELECT * FROM SHOP.USERS;
+----+-----------+-------------+---------------------+---------------------+
| id | name      | birthday_at | created_at          | updated_at          |
+----+-----------+-------------+---------------------+---------------------+
|  1 | Геннадий  | 1990-10-05  | 2022-09-09 16:43:48 | 2022-09-09 16:43:48 |
|  2 | Наталья   | 1984-11-12  | 2022-09-09 16:43:48 | 2022-09-09 16:43:48 |
|  3 | Александр | 1985-05-20  | 2022-09-09 16:43:48 | 2022-09-09 16:43:48 |
|  4 | Сергей    | 1988-02-14  | 2022-09-09 16:43:48 | 2022-09-09 16:43:48 |
|  5 | Иван      | 1998-01-12  | 2022-09-09 16:43:48 | 2022-09-09 16:43:48 |
|  6 | Мария     | 1992-08-29  | 2022-09-09 16:43:48 | 2022-09-09 16:43:48 |
+----+-----------+-------------+---------------------+---------------------+
6 rows in set (0.00 sec)

mysql> SELECT * FROM SAMPLE.USERS;
Empty set (0.00 sec)

mysql> INSERT INTO sample.users SELECT id, name FROM shop.users WHERE id = 1;
Query OK, 1 row affected (0.20 sec)
Records: 1  Duplicates: 0  Warnings: 0

mysql> DELETE FROM shop.users WHERE id = 1;
Query OK, 1 row affected (0.07 sec)

mysql> SELECT * FROM sample.users;
+----+----------+
| id | name     |
+----+----------+
|  1 | Геннадий |
+----+----------+
1 row in set (0.00 sec)

mysql> SELECT * FROM SHOP.USERS;
+----+-----------+-------------+---------------------+---------------------+
| id | name      | birthday_at | created_at          | updated_at          |
+----+-----------+-------------+---------------------+---------------------+
|  2 | Наталья   | 1984-11-12  | 2022-09-09 16:43:48 | 2022-09-09 16:43:48 |
|  3 | Александр | 1985-05-20  | 2022-09-09 16:43:48 | 2022-09-09 16:43:48 |
|  4 | Сергей    | 1988-02-14  | 2022-09-09 16:43:48 | 2022-09-09 16:43:48 |
|  5 | Иван      | 1998-01-12  | 2022-09-09 16:43:48 | 2022-09-09 16:43:48 |
|  6 | Мария     | 1992-08-29  | 2022-09-09 16:43:48 | 2022-09-09 16:43:48 |
+----+-----------+-------------+---------------------+---------------------+
5 rows in set (0.00 sec)

mysql> COMMIT;
Query OK, 0 rows affected (0.13 sec)

/* 2. Создайте представление, которое выводит название name товарной позиции из таблицы products и соответствующее 
название каталога name из таблицы catalogs.*/

CREATE VIEW my_view AS SELECT p.name AS product, c.name AS catalog_ FROM products p JOIN catalogs c ON p.catalog_id = c.id;
SELECT * FROM my_view;

-- Хранимые процедуры и функции, триггеры.

/* 1. Создайте хранимую функцию hello(), которая будет возвращать приветствие, в зависимости от текущего времени суток. 
С 6:00 до 12:00 функция должна возвращать фразу "Доброе утро", с 12:00 до 18:00 функция должна возвращать фразу 
"Добрый день", с 18:00 до 00:00 — "Добрый вечер", с 00:00 до 6:00 — "Доброй ночи".*/

DELIMITER //

CREATE FUNCTION hello()
RETURNS VARCHAR (30) NO SQL
BEGIN
	DECLARE my_result VARCHAR(30);
	IF CURRENT_TIME() >= '06:00:00' AND CURRENT_TIME() < '12:00:00' THEN 
		SET my_result = 'Доброе утро!';
	ELSEIF CURRENT_TIME() >= '12:00:00' AND CURRENT_TIME() < '18:00:00' THEN 
		SET my_result = 'Добрый день!';
	ELSEIF CURRENT_TIME() >= '18:00:00' AND CURRENT_TIME() < '00:00:00' THEN 
		SET my_result = 'Добрый вечер!';
	ELSE 
		SET my_result = 'Доброй ночи!';
	END IF;
	RETURN my_result;
END//

DELIMITER ;

SELECT hello();

/* 2. В таблице products есть два текстовых поля: name с названием товара и description с его описанием. Допустимо 
присутствие обоих полей или одно из них. Ситуация, когда оба поля принимают неопределенное значение NULL неприемлема. 
Используя триггеры, добейтесь того, чтобы одно из этих полей или оба поля были заполнены. При попытке присвоить 
полям NULL-значение необходимо отменить операцию.*/



DROP TRIGGER IF EXISTS my_trigger;

DELIMITER //

CREATE TRIGGER my_trigger BEFORE INSERT ON products
FOR EACH ROW 
BEGIN 
	IF NEW.name IS NULL AND NEW.description IS NULL THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Сработал ТРИГГЕР! Поля name и / или description должны быть заполнены!';
	END IF;
END//

DELIMITER ;

INSERT INTO products (name, description)
	VALUES (NULL, NULL);				-- проверяем триггер


DROP TRIGGER IF EXISTS before_update_tr;

DELIMITER //

CREATE TRIGGER before_update_tr BEFORE UPDATE ON products
FOR EACH ROW 
BEGIN 
	IF NEW.name IS NULL AND NEW.description IS NULL THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Сработал ТРИГГЕР! Поля name и / или description должны быть заполнены!';
	END IF;
END//

DELIMITER ;

UPDATE products SET description = NULL WHERE id = 2;		-- проверяем триггер, в поле name уже установлен NULL
