/* 1. Установите СУБД MySQL. Создайте в домашней директории файл .my.cnf, задав в нем логин и пароль, 
 который указывался при установке. 
 
 *СУБД MySQL установлена. Создан файл my.cnf в директории C:\Program Files\MySQL\MySQL Server 8.0. 
 *Содержание файла:
 [mysql]
 user=root
 password=qwerty
 
 *Файл работает, позволяет зайти в Mysql без ввода пользователя и пароля.*/
 
 /* 2. Создайте базу данных example, разместите в ней таблицу users, состоящую из двух столбцов, 
 *числового id и строкового name.*/

DROP DATABASE IF EXISTS example;
CREATE DATABASE example;
USE example;
DROP TABLE IF EXISTS users;
CREATE TABLE users (
	id SERIAL PRIMARY KEY,
	name VARCHAR(100)
);

/* 3. Создайте дамп базы данных example из предыдущего задания, разверните содержимое дампа в новую базу данных sample.*/

CREATE DATABASE sample;

-- В консоли операционной системы выполняем команды:

mysqldump example > dump.SQL

mysql sample < dump.sql

