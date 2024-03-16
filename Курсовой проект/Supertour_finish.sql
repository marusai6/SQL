//* База данных Supertour предназначена для хранения, изменения, обработки данных в туристическом агентстве. Состоит
из нескольких таблиц. Содержит данные о клиентах агентства, справочную информацию о странах и городах, куда
продаются туры, отелях, рейсах. В базе имеется каталог продаваемых туров, экскурсий. Таблица applications (заявки)
позволяет вести журнал заявок на туры от клиентов. База данных помогает автоматизировать работу агентства.*//

-- ВЫБОРКИ
//* 1) Вывести три самые посещаемые туристами страны по количеству заявок на туры.*//

SELECT c.name, COUNT(*) AS num_of_applications FROM countries c 
JOIN `catalog` c2 ON c.id = c2.country_id 
JOIN applications a ON c2.id = a.tour_id
GROUP BY c.name
ORDER BY COUNT(*) DESC 
LIMIT 3;

//* 2) Вывести количество продаваемых туров по странам *//

SELECT c.name, COUNT(*) AS number_of_tours FROM countries c
JOIN `catalog` c2 ON c.id = c2.country_id
GROUP BY c.name;

//* 3) Вывести среднюю цену туров в рублях по текущему курсу по городам*//

SELECT c.name, ROUND((avg(c2.price)*c3.exchange_rate),2) AS average_price, 'RUR' AS 'currency' FROM cities c 
JOIN `catalog` c2 ON c.id = c2.city_id 
JOIN currencies c3 ON c2.currency_des = c3.designation 
GROUP BY c.name 
ORDER BY avg(c2.price);

//* 4) Вывести три отеля с названием города, в которых самое дорогое проживание за сутки в рублях, 
исходя из продолжительности тура*//

SELECT h.name AS hotel, c.name AS city, ROUND((c2.price/TIMESTAMPDIFF(DAY, c2.begin_at, c2.finish_at))*c3.exchange_rate, 2) AS price FROM hotels h 
JOIN cities c ON h.ht_city_id = c.id 
JOIN `catalog` c2 ON h.id = c2.hotel_id
JOIN currencies c3 ON c2.currency_des = c3.designation
ORDER BY price DESC
LIMIT 3;

//* 5) Вывести имя и фамилию клиента, дату вылета, название дня недели*//

SELECT concat(c.firstname, ' ', c.lastname) AS client,  c2.begin_at AS departure_date, dayname(c2.begin_at)  AS day_of_week FROM clients c
JOIN applications a ON c.id = a.client_id 
JOIN `catalog` c2 ON a.tour_id = c2.id; 

//* 6) Вывести только те экскурсии, продолжительность которых менее 4 часов*//

SELECT id, name FROM excursions
WHERE TIMESTAMPDIFF(HOUR, begin_at, finish_at) < 4;

-- ПРЕДСТАВЛЕНИЯ
//* 1) Создать представление, которое выводит имя и фамилию клиента и номер рейса, которым он летит*//

DROP VIEW IF EXISTS view_1;

CREATE VIEW view_1 AS SELECT concat(c.firstname, ' ', c.lastname) AS client, c2.flight FROM clients c 
	JOIN applications a ON c.id = a.client_id 
	JOIN `catalog` c2 ON a.tour_id = c2.id;

SELECT * FROM view_1;

//* 2)Создать представление, которое выводит количество оплаченных заявок на туры по городам*//

DROP VIEW IF EXISTS view_2;

CREATE VIEW view_2 AS SELECT c.name, COUNT(a.status) AS paid_for FROM cities c 
JOIN `catalog` c2 ON c.id = c2.city_id 
JOIN applications a ON c2.id = a.tour_id
WHERE a.status = 'paid_for'
GROUP BY c.name;

SELECT * FROM view_2;

-- ТРИГГЕРЫ
//* 1) В таблице catalog есть два текстовых поля: name_of_tour с названием тура и description с его описанием. Допустимо 
присутствие обоих полей или одно из них. Ситуация, когда оба поля принимают неопределенное значение NULL неприемлема. 
Используя триггеры, добейтесь того, чтобы одно из этих полей или оба поля были заполнены. При попытке присвоить 
полям NULL-значение необходимо отменить операцию *//

DROP TRIGGER IF EXISTS trigger_1_before_ins;

DELIMITER //

CREATE TRIGGER trigger_1_before_ins BEFORE INSERT ON `catalog`
FOR EACH ROW 
BEGIN 
	IF NEW.name_of_tour IS NULL AND NEW.description IS NULL THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Сработал ТРИГГЕР! Поля name_of_tour и / или description должны быть заполнены!';
	END IF;
END//

DELIMITER ;

INSERT INTO `catalog` (name_of_tour, description)
	VALUES (NULL, NULL);				-- проверяем триггер
	
DROP TRIGGER IF EXISTS trigger_2_before_upd;

DELIMITER //

CREATE TRIGGER trigger_2_before_upd BEFORE UPDATE ON `catalog`
FOR EACH ROW 
BEGIN 
	IF NEW.name_of_tour IS NULL AND NEW.description IS NULL THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Сработал ТРИГГЕР! Поля name_of_tour и / или description должны быть заполнены!';
	END IF;
END//

DELIMITER ;

UPDATE `catalog` SET description = NULL WHERE id = 12;		-- проверяем триггер, в поле name_of_tour уже установлен NULL

//* 2) Создать триггер, который перед созданем новой заявки на тур будет проверять актуальность даты тура. Если дата
тура не актуальна, тогда заявка не должна быть создана*//

DROP TRIGGER IF EXISTS check_data;

DELIMITER //

CREATE TRIGGER check_data BEFORE INSERT ON applications
FOR EACH ROW 
BEGIN
	IF NEW.tour_id IN (SELECT c.id FROM `catalog` c WHERE c.begin_at <= CURRENT_DATE) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Сработал ТРИГГЕР! Дата тура не актуальна, проверьте дату!';
	END IF;
END//

DELIMITER ;

INSERT INTO applications (client_id, tour_id) VALUES (12, 2);		-- Проверка работы триггера

-- ПРОЦЕДУРЫ / ФУНКЦИИ
//* 1) Создать функцию, которая будет рассчитывать коэффициент популярности страны исходя из оформленных клиентами заявок*//

DROP FUNCTION IF EXISTS koeff;

DELIMITER //

CREATE FUNCTION koeff(check_country_id BIGINT)
RETURNS FLOAT READS SQL DATA
BEGIN
	DECLARE num_of_applications INT;
	DECLARE all_num_of_applications INT;
	SET num_of_applications = (
		SELECT COUNT(*)
		FROM applications
		WHERE tour_id IN (SELECT c.id FROM `catalog` c WHERE c.country_id = check_country_id)
	);
	SET all_num_of_applications = (
		SELECT COUNT(*)
		FROM applications
	);
	RETURN num_of_applications / all_num_of_applications;
	
END//

DELIMITER ;

SELECT koeff(5);	-- Проверка работы функции

//* 2) Создать функцию, которая будет пересчитывать стоимость тура в рубли*//

DROP FUNCTION IF EXISTS price_calculate;

DELIMITER //

CREATE FUNCTION price_calculate(tour_id_calc BIGINT)
RETURNS FLOAT READS SQL DATA
BEGIN
	DECLARE price_ FLOAT;
	DECLARE exchange_rate_ FLOAT;
	SET price_ = (
		SELECT price FROM `catalog` c
		WHERE c.id = tour_id_calc
	);
	SET exchange_rate_ = (
		SELECT exchange_rate FROM currencies c2
		JOIN `catalog` c ON c2.designation = c.currency_des 
		WHERE c.id = tour_id_calc
	);
	RETURN price_*exchange_rate_;

END//

DELIMITER ;

SELECT price_calculate(5);		-- Проверка работы функции
