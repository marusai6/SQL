USE vk;

DROP TABLE IF EXISTS wall;
CREATE TABLE wall (
	id SERIAL PRIMARY KEY,
	user_published BIGINT UNSIGNED NOT NULL,
	body TEXT,
	media_publish_id BIGINT UNSIGNED,
	number_of_likes BIGINT UNSIGNED,
	number_of_reposts BIGINT UNSIGNED,
	comments TEXT,
	created_at DATETIME DEFAULT NOW(),
	
	FOREIGN KEY (user_published) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (media_publish_id) REFERENCES media(id) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS music;
CREATE TABLE music (
	id SERIAL PRIMARY KEY,
	`media_id` BIGINT unsigned NOT NULL,
	`name` varchar(255) DEFAULT NULL,
    `user_id` BIGINT UNSIGNED DEFAULT NULL,
	
	FOREIGN KEY (media_id) REFERENCES media(id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
	INDEX music_name_idx (name)
);

DROP TABLE IF EXISTS video;
CREATE TABLE video (
	id SERIAL PRIMARY KEY,
	`media_id` BIGINT unsigned NOT NULL,
	`name` varchar(255) DEFAULT NULL,
    `user_id` BIGINT UNSIGNED DEFAULT NULL,
	
	FOREIGN KEY (media_id) REFERENCES media(id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
	INDEX video_name_idx (name)
);