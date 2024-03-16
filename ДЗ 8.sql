/* 1. Пусть задан некоторый пользователь. Из всех друзей этого пользователя найдите человека, который больше всех 
общался с выбранным пользователем (написал ему сообщений).*/

USE VK;

SELECT 
	m.from_user_id AS user_id,
	count(*) AS count_of_messages 
FROM messages m
JOIN friend_requests fr ON (m.from_user_id = fr.target_user_id OR m.from_user_id = fr.initiator_user_id)
WHERE m.to_user_id =1 AND fr.status = 'approved' 
GROUP BY user_id
ORDER BY count_of_messages DESC 
LIMIT 1

/* 2. Подсчитать общее количество лайков, которые получили пользователи младше 11 лет.*/

SELECT count(*) AS count_of_likes FROM likes l
JOIN media m ON l.media_id = m.id
JOIN profiles p ON m.user_id = p.user_id
WHERE TIMESTAMPDIFF(YEAR, p.birthday, now()) < 11

/* 3. Определить кто больше поставил лайков (всего): мужчины или женщины.*/

SELECT CASE WHEN gender = 'f' THEN 'женщины'
ELSE 'мужчины' END AS gender_, count(*) AS count_of_likes  FROM profiles p 
JOIN likes ON p.user_id = likes.user_id
GROUP BY gender


	