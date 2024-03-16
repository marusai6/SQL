/* 1. Пусть задан некоторый пользователь. Из всех друзей этого пользователя найдите человека, который больше всех 
 * общался с нашим пользователем.*/

USE vk;

SELECT from_user_id AS user_id , count(*) AS count_of_messages FROM  -- Примем, что больше всех общался тот, с кем больше сообщений
(SELECT from_user_id FROM messages
WHERE to_user_id = 1              -- Пусть задан пользователь с id = 1
UNION ALL
SELECT to_user_id FROM messages
WHERE from_user_id = 1) AS new_tbl
WHERE from_user_id IN 
(SELECT initiator_user_id FROM friend_requests
WHERE target_user_id = 1 AND status = 'approved'
UNION
SELECT target_user_id FROM friend_requests
WHERE initiator_user_id = 1 AND status = 'approved')  -- Выбираем только из друзей
GROUP BY user_id
ORDER BY count_of_messages DESC 
LIMIT 1;

/* 2. Подсчитать общее количество лайков, которые получили пользователи младше 11 лет.*/

SELECT count(*) AS count_of_likes FROM likes l 
WHERE media_id IN 
(SELECT id FROM media m 
WHERE user_id IN 
(SELECT user_id FROM profiles
WHERE TIMESTAMPDIFF(YEAR, birthday, now()) < 11));

/* 3. Определить кто больше поставил лайков (всего): мужчины или женщины.*/

SELECT (SELECT CASE WHEN gender = 'f' THEN 'женщины'
ELSE 'мужчины' END
FROM profiles 
WHERE user_id = likes.user_id) AS gender, COUNT(*) AS count_of_likes FROM likes
GROUP BY gender


