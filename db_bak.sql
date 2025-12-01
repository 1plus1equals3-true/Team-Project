-- --------------------------------------------------------
-- 호스트:                          127.0.0.1
-- 서버 버전:                        9.3.0 - MySQL Community Server - GPL
-- 서버 OS:                        Win64
-- HeidiSQL 버전:                  12.11.0.7065
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- 테이블 dtd_project.items 구조 내보내기
DROP TABLE IF EXISTS `items`;
CREATE TABLE IF NOT EXISTS `items` (
  `idx` int NOT NULL,
  `item_name` varchar(50) NOT NULL,
  `description` text,
  `effect_type` enum('HEAL','BUFF_ATK','BOMB','STUN') NOT NULL,
  `effect_value` int NOT NULL,
  PRIMARY KEY (`idx`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 테이블 데이터 dtd_project.items:~0 rows (대략적) 내보내기

-- 테이블 dtd_project.stages 구조 내보내기
DROP TABLE IF EXISTS `stages`;
CREATE TABLE IF NOT EXISTS `stages` (
  `idx` int NOT NULL,
  `stage_type` enum('DEFENSE','BOSS') NOT NULL,
  `stage_name` varchar(100) NOT NULL,
  `rewards_json` json DEFAULT NULL,
  `map_config_json` json DEFAULT NULL,
  PRIMARY KEY (`idx`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 테이블 데이터 dtd_project.stages:~0 rows (대략적) 내보내기

-- 테이블 dtd_project.towers 구조 내보내기
DROP TABLE IF EXISTS `towers`;
CREATE TABLE IF NOT EXISTS `towers` (
  `idx` int NOT NULL,
  `tower_name` varchar(50) NOT NULL,
  `base_damage` int NOT NULL,
  `base_range` int NOT NULL,
  `base_cooldown` decimal(5,2) NOT NULL,
  `tier` int DEFAULT '1',
  `description` text,
  PRIMARY KEY (`idx`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 테이블 데이터 dtd_project.towers:~0 rows (대략적) 내보내기

-- 테이블 dtd_project.users 구조 내보내기
DROP TABLE IF EXISTS `users`;
CREATE TABLE IF NOT EXISTS `users` (
  `idx` bigint NOT NULL AUTO_INCREMENT,
  `userid` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `username` varchar(50) NOT NULL,
  `pwd` varchar(255) NOT NULL,
  `birth` date DEFAULT NULL,
  `gold` int DEFAULT '0',
  `diamond` int DEFAULT '0',
  `refresh_token` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `last_login` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`idx`),
  UNIQUE KEY `userid` (`userid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 테이블 데이터 dtd_project.users:~0 rows (대략적) 내보내기

-- 테이블 dtd_project.user_inventory 구조 내보내기
DROP TABLE IF EXISTS `user_inventory`;
CREATE TABLE IF NOT EXISTS `user_inventory` (
  `user_idx` bigint NOT NULL,
  `item_idx` int NOT NULL,
  `quantity` int DEFAULT '0',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_idx`,`item_idx`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 테이블 데이터 dtd_project.user_inventory:~0 rows (대략적) 내보내기

-- 테이블 dtd_project.user_stage_clear 구조 내보내기
DROP TABLE IF EXISTS `user_stage_clear`;
CREATE TABLE IF NOT EXISTS `user_stage_clear` (
  `user_idx` bigint NOT NULL,
  `stage_idx` int NOT NULL,
  `is_cleared` tinyint(1) DEFAULT '0',
  `score` int DEFAULT '0',
  `stars` tinyint DEFAULT '0',
  `cleared_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_idx`,`stage_idx`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 테이블 데이터 dtd_project.user_stage_clear:~0 rows (대략적) 내보내기

-- 테이블 dtd_project.user_towers 구조 내보내기
DROP TABLE IF EXISTS `user_towers`;
CREATE TABLE IF NOT EXISTS `user_towers` (
  `idx` bigint NOT NULL AUTO_INCREMENT,
  `user_idx` bigint NOT NULL,
  `tower_idx` int NOT NULL,
  `level` int DEFAULT '1',
  `exp` int DEFAULT '0',
  `obtained_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`idx`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 테이블 데이터 dtd_project.user_towers:~0 rows (대략적) 내보내기

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
