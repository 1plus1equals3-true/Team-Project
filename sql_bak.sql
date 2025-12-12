-- --------------------------------------------------------
-- 호스트:                          127.0.0.1
-- 서버 버전:                        11.8.5-MariaDB - MariaDB Server
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


-- dtd_project 데이터베이스 구조 내보내기
DROP DATABASE IF EXISTS `dtd_project`;
CREATE DATABASE IF NOT EXISTS `dtd_project` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci */;
USE `dtd_project`;

-- 프로시저 dtd_project.insert_stage_config 구조 내보내기
DROP PROCEDURE IF EXISTS `insert_stage_config`;
DELIMITER //
CREATE PROCEDURE `insert_stage_config`(IN p_stage_idx INT)
BEGIN
    DECLARE i INT DEFAULT 1;
    -- 호환성을 위해 JSON 타입 대신 LONGTEXT 사용
    DECLARE v_waves_json LONGTEXT DEFAULT '[]'; 
    DECLARE v_delay INT;
    DECLARE v_enemy_id INT;
    DECLARE v_final_json LONGTEXT;
    
    -- 1. 웨이브 1~50 생성
    WHILE i <= 50 DO
        SET v_enemy_id = (p_stage_idx * 100) + i;
        
        IF i = 1 THEN 
            SET v_delay = 0;
        ELSE 
            SET v_delay = 5000;
        END IF;
        
        -- JSON_ARRAY_APPEND를 사용하여 배열에 객체 추가
        SET v_waves_json = JSON_ARRAY_APPEND(v_waves_json, '$', JSON_OBJECT(
            'waveNumber', i,
            'enemyId', v_enemy_id,
            'count', 100,
            'interval', 500,
            'startDelay', v_delay,
            'waveRewardBit', 0
        ));
        
        SET i = i + 1;
    END WHILE;

    -- 2. 최종 JSON 조립 (JSON_PRETTY로 포매팅 적용)
    SET v_final_json = JSON_PRETTY(JSON_OBJECT(
        'startBit', 200,
        'map', CONCAT(p_stage_idx, '-1'),
        'limitCount', 80,
        'waypoints', JSON_ARRAY(
            JSON_OBJECT('x', 579, 'y', 70),
            JSON_OBJECT('x', 579, 'y', 92),
            JSON_OBJECT('x', 580, 'y', 165),
            JSON_OBJECT('x', 475, 'y', 169),
            JSON_OBJECT('x', 477, 'y', 565),
            JSON_OBJECT('x', 1165, 'y', 569),
            JSON_OBJECT('x', 1166, 'y', 367),
            JSON_OBJECT('x', 778, 'y', 356),
            JSON_OBJECT('x', 758, 'y', 176),
            JSON_OBJECT('x', 590, 'y', 171)
        ),
        'waves', JSON_EXTRACT(v_waves_json, '$')
    ));

    -- 3. 데이터 저장
    DELETE FROM `stages` WHERE idx = p_stage_idx;
    
    INSERT INTO `stages` (`idx`, `stage_type`, `stage_name`, `rewards_json`, `map_config_json`) 
    VALUES (
        p_stage_idx, 
        'DEFENSE', 
        CONCAT('무한의 숲 ', p_stage_idx), 
        '{"gold": 1000, "exp": 500, "items": [{"itemId": 901, "count": 1}]}',
        v_final_json
    );
END//
DELIMITER ;

-- 테이블 dtd_project.items 구조 내보내기
DROP TABLE IF EXISTS `items`;
CREATE TABLE IF NOT EXISTS `items` (
  `idx` int(11) NOT NULL COMMENT '아이템 IDX',
  `item_name` varchar(50) NOT NULL COMMENT '아이템 이름',
  `description` text DEFAULT NULL COMMENT '아이템 설명',
  `effect_type` enum('HEAL','BUFF_ATK','BOMB','STUN','TICKET') NOT NULL COMMENT '아이템 효과',
  `effect_value` int(11) NOT NULL COMMENT '아이템 수치',
  `price_gold` int(11) NOT NULL COMMENT '아이템 가격 골드',
  `price_diamond` int(11) NOT NULL COMMENT '아이템 가격 다이아',
  PRIMARY KEY (`idx`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 테이블 데이터 dtd_project.items:~5 rows (대략적) 내보내기
INSERT INTO `items` (`idx`, `item_name`, `description`, `effect_type`, `effect_value`, `price_gold`, `price_diamond`) VALUES
	(101, '회복 물약', '체력을 50 회복합니다.', 'HEAL', 50, 100, 50),
	(201, '파워 포션', '10초간 모든 디지몬의 공격력이 10% 증가합니다.', 'BUFF_ATK', 10, 100, 50),
	(301, '소형 폭탄', '화면 전체 적에게 200의 데미지를 줍니다.', 'BOMB', 200, 200, 100),
	(401, '시간 정지', '모든 적을 3초간 정지시킵니다.', 'STUN', 3, 300, 150),
	(901, '디지몬 티켓 (1티어)', '1티어 디지몬 중 한 마리를 랜덤으로 획득합니다.', 'TICKET', 1, 1000, 500);

-- 테이블 dtd_project.monsters 구조 내보내기
DROP TABLE IF EXISTS `monsters`;
CREATE TABLE IF NOT EXISTS `monsters` (
  `idx` int(11) NOT NULL COMMENT '몬스터 IDX',
  `name` varchar(50) NOT NULL COMMENT '몬스터 이름',
  `hp` int(11) NOT NULL COMMENT '기본 체력',
  `speed` decimal(5,2) NOT NULL COMMENT '이동 속도',
  `defense` int(11) DEFAULT 0 COMMENT '방어력',
  `reward_bit` int(11) NOT NULL COMMENT '처치 시 획득 재화',
  `damage` int(11) NOT NULL COMMENT '라이프 차감',
  `image_file` varchar(100) NOT NULL COMMENT '이미지 파일명',
  `description` text DEFAULT NULL COMMENT '설명',
  PRIMARY KEY (`idx`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- 테이블 데이터 dtd_project.monsters:~250 rows (대략적) 내보내기
INSERT INTO `monsters` (`idx`, `name`, `hp`, `speed`, `defense`, `reward_bit`, `damage`, `image_file`, `description`) VALUES
	(101, 'Monster 1-1', 160, 1.81, 0, 10, 1, '101', '1스테이지 1웨이브 몬스터'),
	(102, 'Monster 1-2', 170, 1.82, 0, 10, 1, '102', '1스테이지 2웨이브 몬스터'),
	(103, 'Monster 1-3', 180, 1.83, 0, 10, 1, '103', '1스테이지 3웨이브 몬스터'),
	(104, 'Monster 1-4', 190, 1.84, 0, 10, 1, '104', '1스테이지 4웨이브 몬스터'),
	(105, 'Monster 1-5', 200, 1.85, 0, 10, 1, '105', '1스테이지 5웨이브 몬스터'),
	(106, 'Monster 1-6', 210, 1.86, 0, 10, 1, '106', '1스테이지 6웨이브 몬스터'),
	(107, 'Monster 1-7', 220, 1.87, 0, 10, 1, '107', '1스테이지 7웨이브 몬스터'),
	(108, 'Monster 1-8', 230, 1.88, 0, 10, 1, '108', '1스테이지 8웨이브 몬스터'),
	(109, 'Monster 1-9', 240, 1.89, 0, 10, 1, '109', '1스테이지 9웨이브 몬스터'),
	(110, 'Stage 1 Boss', 2500, 1.20, 6, 1000, 10, '110', '1스테이지의 강력한 보스입니다.'),
	(111, 'Monster 1-11', 260, 1.91, 0, 10, 1, '111', '1스테이지 11웨이브 몬스터'),
	(112, 'Monster 1-12', 270, 1.92, 0, 10, 1, '112', '1스테이지 12웨이브 몬스터'),
	(113, 'Monster 1-13', 280, 1.93, 0, 10, 1, '113', '1스테이지 13웨이브 몬스터'),
	(114, 'Monster 1-14', 290, 1.94, 0, 10, 1, '114', '1스테이지 14웨이브 몬스터'),
	(115, 'Monster 1-15', 300, 1.95, 0, 10, 1, '115', '1스테이지 15웨이브 몬스터'),
	(116, 'Monster 1-16', 310, 1.96, 0, 10, 1, '116', '1스테이지 16웨이브 몬스터'),
	(117, 'Monster 1-17', 320, 1.97, 0, 10, 1, '117', '1스테이지 17웨이브 몬스터'),
	(118, 'Monster 1-18', 330, 1.98, 0, 10, 1, '118', '1스테이지 18웨이브 몬스터'),
	(119, 'Monster 1-19', 340, 1.99, 0, 10, 1, '119', '1스테이지 19웨이브 몬스터'),
	(120, 'Stage 1 Boss', 3000, 1.20, 7, 1000, 10, '120', '1스테이지의 강력한 보스입니다.'),
	(121, 'Monster 1-21', 360, 2.01, 0, 10, 1, '121', '1스테이지 21웨이브 몬스터'),
	(122, 'Monster 1-22', 370, 2.02, 0, 10, 1, '122', '1스테이지 22웨이브 몬스터'),
	(123, 'Monster 1-23', 380, 2.03, 0, 10, 1, '123', '1스테이지 23웨이브 몬스터'),
	(124, 'Monster 1-24', 390, 2.04, 0, 10, 1, '124', '1스테이지 24웨이브 몬스터'),
	(125, 'Monster 1-25', 400, 2.05, 0, 10, 1, '125', '1스테이지 25웨이브 몬스터'),
	(126, 'Monster 1-26', 410, 2.06, 0, 10, 1, '126', '1스테이지 26웨이브 몬스터'),
	(127, 'Monster 1-27', 420, 2.07, 0, 10, 1, '127', '1스테이지 27웨이브 몬스터'),
	(128, 'Monster 1-28', 430, 2.08, 0, 10, 1, '128', '1스테이지 28웨이브 몬스터'),
	(129, 'Monster 1-29', 440, 2.09, 0, 10, 1, '129', '1스테이지 29웨이브 몬스터'),
	(130, 'Stage 1 Boss', 3500, 1.20, 8, 1000, 10, '130', '1스테이지의 강력한 보스입니다.'),
	(131, 'Monster 1-31', 460, 2.11, 0, 10, 1, '131', '1스테이지 31웨이브 몬스터'),
	(132, 'Monster 1-32', 470, 2.12, 0, 10, 1, '132', '1스테이지 32웨이브 몬스터'),
	(133, 'Monster 1-33', 480, 2.13, 0, 10, 1, '133', '1스테이지 33웨이브 몬스터'),
	(134, 'Monster 1-34', 490, 2.14, 0, 10, 1, '134', '1스테이지 34웨이브 몬스터'),
	(135, 'Monster 1-35', 500, 2.15, 0, 10, 1, '135', '1스테이지 35웨이브 몬스터'),
	(136, 'Monster 1-36', 510, 2.16, 0, 10, 1, '136', '1스테이지 36웨이브 몬스터'),
	(137, 'Monster 1-37', 520, 2.17, 0, 10, 1, '137', '1스테이지 37웨이브 몬스터'),
	(138, 'Monster 1-38', 530, 2.18, 0, 10, 1, '138', '1스테이지 38웨이브 몬스터'),
	(139, 'Monster 1-39', 540, 2.19, 0, 10, 1, '139', '1스테이지 39웨이브 몬스터'),
	(140, 'Stage 1 Boss', 4000, 1.20, 9, 1000, 10, '140', '1스테이지의 강력한 보스입니다.'),
	(141, 'Monster 1-41', 560, 2.21, 0, 10, 1, '141', '1스테이지 41웨이브 몬스터'),
	(142, 'Monster 1-42', 570, 2.22, 0, 10, 1, '142', '1스테이지 42웨이브 몬스터'),
	(143, 'Monster 1-43', 580, 2.23, 0, 10, 1, '143', '1스테이지 43웨이브 몬스터'),
	(144, 'Monster 1-44', 590, 2.24, 0, 10, 1, '144', '1스테이지 44웨이브 몬스터'),
	(145, 'Monster 1-45', 600, 2.25, 0, 10, 1, '145', '1스테이지 45웨이브 몬스터'),
	(146, 'Monster 1-46', 610, 2.26, 0, 10, 1, '146', '1스테이지 46웨이브 몬스터'),
	(147, 'Monster 1-47', 620, 2.27, 0, 10, 1, '147', '1스테이지 47웨이브 몬스터'),
	(148, 'Monster 1-48', 630, 2.28, 0, 10, 1, '148', '1스테이지 48웨이브 몬스터'),
	(149, 'Monster 1-49', 640, 2.29, 0, 10, 1, '149', '1스테이지 49웨이브 몬스터'),
	(150, 'Stage 1 Boss', 4500, 1.20, 10, 1000, 10, '150', '1스테이지의 강력한 보스입니다.'),
	(201, 'Monster 2-1', 320, 2.11, 2, 10, 1, '201', '2스테이지 1웨이브 몬스터'),
	(202, 'Monster 2-2', 340, 2.12, 2, 10, 1, '202', '2스테이지 2웨이브 몬스터'),
	(203, 'Monster 2-3', 360, 2.13, 2, 10, 1, '203', '2스테이지 3웨이브 몬스터'),
	(204, 'Monster 2-4', 380, 2.14, 2, 10, 1, '204', '2스테이지 4웨이브 몬스터'),
	(205, 'Monster 2-5', 400, 2.15, 2, 10, 1, '205', '2스테이지 5웨이브 몬스터'),
	(206, 'Monster 2-6', 420, 2.16, 2, 10, 1, '206', '2스테이지 6웨이브 몬스터'),
	(207, 'Monster 2-7', 440, 2.17, 2, 10, 1, '207', '2스테이지 7웨이브 몬스터'),
	(208, 'Monster 2-8', 460, 2.18, 2, 10, 1, '208', '2스테이지 8웨이브 몬스터'),
	(209, 'Monster 2-9', 480, 2.19, 2, 10, 1, '209', '2스테이지 9웨이브 몬스터'),
	(210, 'Stage 2 Boss', 9000, 1.40, 11, 1000, 10, '210', '2스테이지의 강력한 보스입니다.'),
	(211, 'Monster 2-11', 520, 2.21, 2, 10, 1, '211', '2스테이지 11웨이브 몬스터'),
	(212, 'Monster 2-12', 540, 2.22, 2, 10, 1, '212', '2스테이지 12웨이브 몬스터'),
	(213, 'Monster 2-13', 560, 2.23, 2, 10, 1, '213', '2스테이지 13웨이브 몬스터'),
	(214, 'Monster 2-14', 580, 2.24, 2, 10, 1, '214', '2스테이지 14웨이브 몬스터'),
	(215, 'Monster 2-15', 600, 2.25, 2, 10, 1, '215', '2스테이지 15웨이브 몬스터'),
	(216, 'Monster 2-16', 620, 2.26, 2, 10, 1, '216', '2스테이지 16웨이브 몬스터'),
	(217, 'Monster 2-17', 640, 2.27, 2, 10, 1, '217', '2스테이지 17웨이브 몬스터'),
	(218, 'Monster 2-18', 660, 2.28, 2, 10, 1, '218', '2스테이지 18웨이브 몬스터'),
	(219, 'Monster 2-19', 680, 2.29, 2, 10, 1, '219', '2스테이지 19웨이브 몬스터'),
	(220, 'Stage 2 Boss', 10000, 1.40, 12, 1000, 10, '220', '2스테이지의 강력한 보스입니다.'),
	(221, 'Monster 2-21', 720, 2.31, 2, 10, 1, '221', '2스테이지 21웨이브 몬스터'),
	(222, 'Monster 2-22', 740, 2.32, 2, 10, 1, '222', '2스테이지 22웨이브 몬스터'),
	(223, 'Monster 2-23', 760, 2.33, 2, 10, 1, '223', '2스테이지 23웨이브 몬스터'),
	(224, 'Monster 2-24', 780, 2.34, 2, 10, 1, '224', '2스테이지 24웨이브 몬스터'),
	(225, 'Monster 2-25', 800, 2.35, 2, 10, 1, '225', '2스테이지 25웨이브 몬스터'),
	(226, 'Monster 2-26', 820, 2.36, 2, 10, 1, '226', '2스테이지 26웨이브 몬스터'),
	(227, 'Monster 2-27', 840, 2.37, 2, 10, 1, '227', '2스테이지 27웨이브 몬스터'),
	(228, 'Monster 2-28', 860, 2.38, 2, 10, 1, '228', '2스테이지 28웨이브 몬스터'),
	(229, 'Monster 2-29', 880, 2.39, 2, 10, 1, '229', '2스테이지 29웨이브 몬스터'),
	(230, 'Stage 2 Boss', 11000, 1.40, 13, 1000, 10, '230', '2스테이지의 강력한 보스입니다.'),
	(231, 'Monster 2-31', 920, 2.41, 2, 10, 1, '231', '2스테이지 31웨이브 몬스터'),
	(232, 'Monster 2-32', 940, 2.42, 2, 10, 1, '232', '2스테이지 32웨이브 몬스터'),
	(233, 'Monster 2-33', 960, 2.43, 2, 10, 1, '233', '2스테이지 33웨이브 몬스터'),
	(234, 'Monster 2-34', 980, 2.44, 2, 10, 1, '234', '2스테이지 34웨이브 몬스터'),
	(235, 'Monster 2-35', 1000, 2.45, 2, 10, 1, '235', '2스테이지 35웨이브 몬스터'),
	(236, 'Monster 2-36', 1020, 2.46, 2, 10, 1, '236', '2스테이지 36웨이브 몬스터'),
	(237, 'Monster 2-37', 1040, 2.47, 2, 10, 1, '237', '2스테이지 37웨이브 몬스터'),
	(238, 'Monster 2-38', 1060, 2.48, 2, 10, 1, '238', '2스테이지 38웨이브 몬스터'),
	(239, 'Monster 2-39', 1080, 2.49, 2, 10, 1, '239', '2스테이지 39웨이브 몬스터'),
	(240, 'Stage 2 Boss', 12000, 1.40, 14, 1000, 10, '240', '2스테이지의 강력한 보스입니다.'),
	(241, 'Monster 2-41', 1120, 2.51, 2, 10, 1, '241', '2스테이지 41웨이브 몬스터'),
	(242, 'Monster 2-42', 1140, 2.52, 2, 10, 1, '242', '2스테이지 42웨이브 몬스터'),
	(243, 'Monster 2-43', 1160, 2.53, 2, 10, 1, '243', '2스테이지 43웨이브 몬스터'),
	(244, 'Monster 2-44', 1180, 2.54, 2, 10, 1, '244', '2스테이지 44웨이브 몬스터'),
	(245, 'Monster 2-45', 1200, 2.55, 2, 10, 1, '245', '2스테이지 45웨이브 몬스터'),
	(246, 'Monster 2-46', 1220, 2.56, 2, 10, 1, '246', '2스테이지 46웨이브 몬스터'),
	(247, 'Monster 2-47', 1240, 2.57, 2, 10, 1, '247', '2스테이지 47웨이브 몬스터'),
	(248, 'Monster 2-48', 1260, 2.58, 2, 10, 1, '248', '2스테이지 48웨이브 몬스터'),
	(249, 'Monster 2-49', 1280, 2.59, 2, 10, 1, '249', '2스테이지 49웨이브 몬스터'),
	(250, 'Stage 2 Boss', 13000, 1.40, 15, 1000, 10, '250', '2스테이지의 강력한 보스입니다.'),
	(301, 'Monster 3-1', 480, 2.41, 4, 10, 1, '301', '3스테이지 1웨이브 몬스터'),
	(302, 'Monster 3-2', 510, 2.42, 4, 10, 1, '302', '3스테이지 2웨이브 몬스터'),
	(303, 'Monster 3-3', 540, 2.43, 4, 10, 1, '303', '3스테이지 3웨이브 몬스터'),
	(304, 'Monster 3-4', 570, 2.44, 4, 10, 1, '304', '3스테이지 4웨이브 몬스터'),
	(305, 'Monster 3-5', 600, 2.45, 4, 10, 1, '305', '3스테이지 5웨이브 몬스터'),
	(306, 'Monster 3-6', 630, 2.46, 4, 10, 1, '306', '3스테이지 6웨이브 몬스터'),
	(307, 'Monster 3-7', 660, 2.47, 4, 10, 1, '307', '3스테이지 7웨이브 몬스터'),
	(308, 'Monster 3-8', 690, 2.48, 4, 10, 1, '308', '3스테이지 8웨이브 몬스터'),
	(309, 'Monster 3-9', 720, 2.49, 4, 10, 1, '309', '3스테이지 9웨이브 몬스터'),
	(310, 'Stage 3 Boss', 19500, 1.60, 16, 1000, 10, '310', '3스테이지의 강력한 보스입니다.'),
	(311, 'Monster 3-11', 780, 2.51, 4, 10, 1, '311', '3스테이지 11웨이브 몬스터'),
	(312, 'Monster 3-12', 810, 2.52, 4, 10, 1, '312', '3스테이지 12웨이브 몬스터'),
	(313, 'Monster 3-13', 840, 2.53, 4, 10, 1, '313', '3스테이지 13웨이브 몬스터'),
	(314, 'Monster 3-14', 870, 2.54, 4, 10, 1, '314', '3스테이지 14웨이브 몬스터'),
	(315, 'Monster 3-15', 900, 2.55, 4, 10, 1, '315', '3스테이지 15웨이브 몬스터'),
	(316, 'Monster 3-16', 930, 2.56, 4, 10, 1, '316', '3스테이지 16웨이브 몬스터'),
	(317, 'Monster 3-17', 960, 2.57, 4, 10, 1, '317', '3스테이지 17웨이브 몬스터'),
	(318, 'Monster 3-18', 990, 2.58, 4, 10, 1, '318', '3스테이지 18웨이브 몬스터'),
	(319, 'Monster 3-19', 1020, 2.59, 4, 10, 1, '319', '3스테이지 19웨이브 몬스터'),
	(320, 'Stage 3 Boss', 21000, 1.60, 17, 1000, 10, '320', '3스테이지의 강력한 보스입니다.'),
	(321, 'Monster 3-21', 1080, 2.61, 4, 10, 1, '321', '3스테이지 21웨이브 몬스터'),
	(322, 'Monster 3-22', 1110, 2.62, 4, 10, 1, '322', '3스테이지 22웨이브 몬스터'),
	(323, 'Monster 3-23', 1140, 2.63, 4, 10, 1, '323', '3스테이지 23웨이브 몬스터'),
	(324, 'Monster 3-24', 1170, 2.64, 4, 10, 1, '324', '3스테이지 24웨이브 몬스터'),
	(325, 'Monster 3-25', 1200, 2.65, 4, 10, 1, '325', '3스테이지 25웨이브 몬스터'),
	(326, 'Monster 3-26', 1230, 2.66, 4, 10, 1, '326', '3스테이지 26웨이브 몬스터'),
	(327, 'Monster 3-27', 1260, 2.67, 4, 10, 1, '327', '3스테이지 27웨이브 몬스터'),
	(328, 'Monster 3-28', 1290, 2.68, 4, 10, 1, '328', '3스테이지 28웨이브 몬스터'),
	(329, 'Monster 3-29', 1320, 2.69, 4, 10, 1, '329', '3스테이지 29웨이브 몬스터'),
	(330, 'Stage 3 Boss', 22500, 1.60, 18, 1000, 10, '330', '3스테이지의 강력한 보스입니다.'),
	(331, 'Monster 3-31', 1380, 2.71, 4, 10, 1, '331', '3스테이지 31웨이브 몬스터'),
	(332, 'Monster 3-32', 1410, 2.72, 4, 10, 1, '332', '3스테이지 32웨이브 몬스터'),
	(333, 'Monster 3-33', 1440, 2.73, 4, 10, 1, '333', '3스테이지 33웨이브 몬스터'),
	(334, 'Monster 3-34', 1470, 2.74, 4, 10, 1, '334', '3스테이지 34웨이브 몬스터'),
	(335, 'Monster 3-35', 1500, 2.75, 4, 10, 1, '335', '3스테이지 35웨이브 몬스터'),
	(336, 'Monster 3-36', 1530, 2.76, 4, 10, 1, '336', '3스테이지 36웨이브 몬스터'),
	(337, 'Monster 3-37', 1560, 2.77, 4, 10, 1, '337', '3스테이지 37웨이브 몬스터'),
	(338, 'Monster 3-38', 1590, 2.78, 4, 10, 1, '338', '3스테이지 38웨이브 몬스터'),
	(339, 'Monster 3-39', 1620, 2.79, 4, 10, 1, '339', '3스테이지 39웨이브 몬스터'),
	(340, 'Stage 3 Boss', 24000, 1.60, 19, 1000, 10, '340', '3스테이지의 강력한 보스입니다.'),
	(341, 'Monster 3-41', 1680, 2.81, 4, 10, 1, '341', '3스테이지 41웨이브 몬스터'),
	(342, 'Monster 3-42', 1710, 2.82, 4, 10, 1, '342', '3스테이지 42웨이브 몬스터'),
	(343, 'Monster 3-43', 1740, 2.83, 4, 10, 1, '343', '3스테이지 43웨이브 몬스터'),
	(344, 'Monster 3-44', 1770, 2.84, 4, 10, 1, '344', '3스테이지 44웨이브 몬스터'),
	(345, 'Monster 3-45', 1800, 2.85, 4, 10, 1, '345', '3스테이지 45웨이브 몬스터'),
	(346, 'Monster 3-46', 1830, 2.86, 4, 10, 1, '346', '3스테이지 46웨이브 몬스터'),
	(347, 'Monster 3-47', 1860, 2.87, 4, 10, 1, '347', '3스테이지 47웨이브 몬스터'),
	(348, 'Monster 3-48', 1890, 2.88, 4, 10, 1, '348', '3스테이지 48웨이브 몬스터'),
	(349, 'Monster 3-49', 1920, 2.89, 4, 10, 1, '349', '3스테이지 49웨이브 몬스터'),
	(350, 'Stage 3 Boss', 25500, 1.60, 20, 1000, 10, '350', '3스테이지의 강력한 보스입니다.'),
	(401, 'Monster 4-1', 640, 2.71, 6, 10, 1, '401', '4스테이지 1웨이브 몬스터'),
	(402, 'Monster 4-2', 680, 2.72, 6, 10, 1, '402', '4스테이지 2웨이브 몬스터'),
	(403, 'Monster 4-3', 720, 2.73, 6, 10, 1, '403', '4스테이지 3웨이브 몬스터'),
	(404, 'Monster 4-4', 760, 2.74, 6, 10, 1, '404', '4스테이지 4웨이브 몬스터'),
	(405, 'Monster 4-5', 800, 2.75, 6, 10, 1, '405', '4스테이지 5웨이브 몬스터'),
	(406, 'Monster 4-6', 840, 2.76, 6, 10, 1, '406', '4스테이지 6웨이브 몬스터'),
	(407, 'Monster 4-7', 880, 2.77, 6, 10, 1, '407', '4스테이지 7웨이브 몬스터'),
	(408, 'Monster 4-8', 920, 2.78, 6, 10, 1, '408', '4스테이지 8웨이브 몬스터'),
	(409, 'Monster 4-9', 960, 2.79, 6, 10, 1, '409', '4스테이지 9웨이브 몬스터'),
	(410, 'Stage 4 Boss', 34000, 1.80, 21, 1000, 10, '410', '4스테이지의 강력한 보스입니다.'),
	(411, 'Monster 4-11', 1040, 2.81, 6, 10, 1, '411', '4스테이지 11웨이브 몬스터'),
	(412, 'Monster 4-12', 1080, 2.82, 6, 10, 1, '412', '4스테이지 12웨이브 몬스터'),
	(413, 'Monster 4-13', 1120, 2.83, 6, 10, 1, '413', '4스테이지 13웨이브 몬스터'),
	(414, 'Monster 4-14', 1160, 2.84, 6, 10, 1, '414', '4스테이지 14웨이브 몬스터'),
	(415, 'Monster 4-15', 1200, 2.85, 6, 10, 1, '415', '4스테이지 15웨이브 몬스터'),
	(416, 'Monster 4-16', 1240, 2.86, 6, 10, 1, '416', '4스테이지 16웨이브 몬스터'),
	(417, 'Monster 4-17', 1280, 2.87, 6, 10, 1, '417', '4스테이지 17웨이브 몬스터'),
	(418, 'Monster 4-18', 1320, 2.88, 6, 10, 1, '418', '4스테이지 18웨이브 몬스터'),
	(419, 'Monster 4-19', 1360, 2.89, 6, 10, 1, '419', '4스테이지 19웨이브 몬스터'),
	(420, 'Stage 4 Boss', 36000, 1.80, 22, 1000, 10, '420', '4스테이지의 강력한 보스입니다.'),
	(421, 'Monster 4-21', 1440, 2.91, 6, 10, 1, '421', '4스테이지 21웨이브 몬스터'),
	(422, 'Monster 4-22', 1480, 2.92, 6, 10, 1, '422', '4스테이지 22웨이브 몬스터'),
	(423, 'Monster 4-23', 1520, 2.93, 6, 10, 1, '423', '4스테이지 23웨이브 몬스터'),
	(424, 'Monster 4-24', 1560, 2.94, 6, 10, 1, '424', '4스테이지 24웨이브 몬스터'),
	(425, 'Monster 4-25', 1600, 2.95, 6, 10, 1, '425', '4스테이지 25웨이브 몬스터'),
	(426, 'Monster 4-26', 1640, 2.96, 6, 10, 1, '426', '4스테이지 26웨이브 몬스터'),
	(427, 'Monster 4-27', 1680, 2.97, 6, 10, 1, '427', '4스테이지 27웨이브 몬스터'),
	(428, 'Monster 4-28', 1720, 2.98, 6, 10, 1, '428', '4스테이지 28웨이브 몬스터'),
	(429, 'Monster 4-29', 1760, 2.99, 6, 10, 1, '429', '4스테이지 29웨이브 몬스터'),
	(430, 'Stage 4 Boss', 38000, 1.80, 23, 1000, 10, '430', '4스테이지의 강력한 보스입니다.'),
	(431, 'Monster 4-31', 1840, 3.01, 6, 10, 1, '431', '4스테이지 31웨이브 몬스터'),
	(432, 'Monster 4-32', 1880, 3.02, 6, 10, 1, '432', '4스테이지 32웨이브 몬스터'),
	(433, 'Monster 4-33', 1920, 3.03, 6, 10, 1, '433', '4스테이지 33웨이브 몬스터'),
	(434, 'Monster 4-34', 1960, 3.04, 6, 10, 1, '434', '4스테이지 34웨이브 몬스터'),
	(435, 'Monster 4-35', 2000, 3.05, 6, 10, 1, '435', '4스테이지 35웨이브 몬스터'),
	(436, 'Monster 4-36', 2040, 3.06, 6, 10, 1, '436', '4스테이지 36웨이브 몬스터'),
	(437, 'Monster 4-37', 2080, 3.07, 6, 10, 1, '437', '4스테이지 37웨이브 몬스터'),
	(438, 'Monster 4-38', 2120, 3.08, 6, 10, 1, '438', '4스테이지 38웨이브 몬스터'),
	(439, 'Monster 4-39', 2160, 3.09, 6, 10, 1, '439', '4스테이지 39웨이브 몬스터'),
	(440, 'Stage 4 Boss', 40000, 1.80, 24, 1000, 10, '440', '4스테이지의 강력한 보스입니다.'),
	(441, 'Monster 4-41', 2240, 3.11, 6, 10, 1, '441', '4스테이지 41웨이브 몬스터'),
	(442, 'Monster 4-42', 2280, 3.12, 6, 10, 1, '442', '4스테이지 42웨이브 몬스터'),
	(443, 'Monster 4-43', 2320, 3.13, 6, 10, 1, '443', '4스테이지 43웨이브 몬스터'),
	(444, 'Monster 4-44', 2360, 3.14, 6, 10, 1, '444', '4스테이지 44웨이브 몬스터'),
	(445, 'Monster 4-45', 2400, 3.15, 6, 10, 1, '445', '4스테이지 45웨이브 몬스터'),
	(446, 'Monster 4-46', 2440, 3.16, 6, 10, 1, '446', '4스테이지 46웨이브 몬스터'),
	(447, 'Monster 4-47', 2480, 3.17, 6, 10, 1, '447', '4스테이지 47웨이브 몬스터'),
	(448, 'Monster 4-48', 2520, 3.18, 6, 10, 1, '448', '4스테이지 48웨이브 몬스터'),
	(449, 'Monster 4-49', 2560, 3.19, 6, 10, 1, '449', '4스테이지 49웨이브 몬스터'),
	(450, 'Stage 4 Boss', 42000, 1.80, 25, 1000, 10, '450', '4스테이지의 강력한 보스입니다.'),
	(501, 'Monster 5-1', 800, 3.01, 8, 10, 1, '501', '5스테이지 1웨이브 몬스터'),
	(502, 'Monster 5-2', 850, 3.02, 8, 10, 1, '502', '5스테이지 2웨이브 몬스터'),
	(503, 'Monster 5-3', 900, 3.03, 8, 10, 1, '503', '5스테이지 3웨이브 몬스터'),
	(504, 'Monster 5-4', 950, 3.04, 8, 10, 1, '504', '5스테이지 4웨이브 몬스터'),
	(505, 'Monster 5-5', 1000, 3.05, 8, 10, 1, '505', '5스테이지 5웨이브 몬스터'),
	(506, 'Monster 5-6', 1050, 3.06, 8, 10, 1, '506', '5스테이지 6웨이브 몬스터'),
	(507, 'Monster 5-7', 1100, 3.07, 8, 10, 1, '507', '5스테이지 7웨이브 몬스터'),
	(508, 'Monster 5-8', 1150, 3.08, 8, 10, 1, '508', '5스테이지 8웨이브 몬스터'),
	(509, 'Monster 5-9', 1200, 3.09, 8, 10, 1, '509', '5스테이지 9웨이브 몬스터'),
	(510, 'Stage 5 Boss', 52500, 2.00, 26, 1000, 10, '510', '5스테이지의 강력한 보스입니다.'),
	(511, 'Monster 5-11', 1300, 3.11, 8, 10, 1, '511', '5스테이지 11웨이브 몬스터'),
	(512, 'Monster 5-12', 1350, 3.12, 8, 10, 1, '512', '5스테이지 12웨이브 몬스터'),
	(513, 'Monster 5-13', 1400, 3.13, 8, 10, 1, '513', '5스테이지 13웨이브 몬스터'),
	(514, 'Monster 5-14', 1450, 3.14, 8, 10, 1, '514', '5스테이지 14웨이브 몬스터'),
	(515, 'Monster 5-15', 1500, 3.15, 8, 10, 1, '515', '5스테이지 15웨이브 몬스터'),
	(516, 'Monster 5-16', 1550, 3.16, 8, 10, 1, '516', '5스테이지 16웨이브 몬스터'),
	(517, 'Monster 5-17', 1600, 3.17, 8, 10, 1, '517', '5스테이지 17웨이브 몬스터'),
	(518, 'Monster 5-18', 1650, 3.18, 8, 10, 1, '518', '5스테이지 18웨이브 몬스터'),
	(519, 'Monster 5-19', 1700, 3.19, 8, 10, 1, '519', '5스테이지 19웨이브 몬스터'),
	(520, 'Stage 5 Boss', 55000, 2.00, 27, 1000, 10, '520', '5스테이지의 강력한 보스입니다.'),
	(521, 'Monster 5-21', 1800, 3.21, 8, 10, 1, '521', '5스테이지 21웨이브 몬스터'),
	(522, 'Monster 5-22', 1850, 3.22, 8, 10, 1, '522', '5스테이지 22웨이브 몬스터'),
	(523, 'Monster 5-23', 1900, 3.23, 8, 10, 1, '523', '5스테이지 23웨이브 몬스터'),
	(524, 'Monster 5-24', 1950, 3.24, 8, 10, 1, '524', '5스테이지 24웨이브 몬스터'),
	(525, 'Monster 5-25', 2000, 3.25, 8, 10, 1, '525', '5스테이지 25웨이브 몬스터'),
	(526, 'Monster 5-26', 2050, 3.26, 8, 10, 1, '526', '5스테이지 26웨이브 몬스터'),
	(527, 'Monster 5-27', 2100, 3.27, 8, 10, 1, '527', '5스테이지 27웨이브 몬스터'),
	(528, 'Monster 5-28', 2150, 3.28, 8, 10, 1, '528', '5스테이지 28웨이브 몬스터'),
	(529, 'Monster 5-29', 2200, 3.29, 8, 10, 1, '529', '5스테이지 29웨이브 몬스터'),
	(530, 'Stage 5 Boss', 57500, 2.00, 28, 1000, 10, '530', '5스테이지의 강력한 보스입니다.'),
	(531, 'Monster 5-31', 2300, 3.31, 8, 10, 1, '531', '5스테이지 31웨이브 몬스터'),
	(532, 'Monster 5-32', 2350, 3.32, 8, 10, 1, '532', '5스테이지 32웨이브 몬스터'),
	(533, 'Monster 5-33', 2400, 3.33, 8, 10, 1, '533', '5스테이지 33웨이브 몬스터'),
	(534, 'Monster 5-34', 2450, 3.34, 8, 10, 1, '534', '5스테이지 34웨이브 몬스터'),
	(535, 'Monster 5-35', 2500, 3.35, 8, 10, 1, '535', '5스테이지 35웨이브 몬스터'),
	(536, 'Monster 5-36', 2550, 3.36, 8, 10, 1, '536', '5스테이지 36웨이브 몬스터'),
	(537, 'Monster 5-37', 2600, 3.37, 8, 10, 1, '537', '5스테이지 37웨이브 몬스터'),
	(538, 'Monster 5-38', 2650, 3.38, 8, 10, 1, '538', '5스테이지 38웨이브 몬스터'),
	(539, 'Monster 5-39', 2700, 3.39, 8, 10, 1, '539', '5스테이지 39웨이브 몬스터'),
	(540, 'Stage 5 Boss', 60000, 2.00, 29, 1000, 10, '540', '5스테이지의 강력한 보스입니다.'),
	(541, 'Monster 5-41', 2800, 3.41, 8, 10, 1, '541', '5스테이지 41웨이브 몬스터'),
	(542, 'Monster 5-42', 2850, 3.42, 8, 10, 1, '542', '5스테이지 42웨이브 몬스터'),
	(543, 'Monster 5-43', 2900, 3.43, 8, 10, 1, '543', '5스테이지 43웨이브 몬스터'),
	(544, 'Monster 5-44', 2950, 3.44, 8, 10, 1, '544', '5스테이지 44웨이브 몬스터'),
	(545, 'Monster 5-45', 3000, 3.45, 8, 10, 1, '545', '5스테이지 45웨이브 몬스터'),
	(546, 'Monster 5-46', 3050, 3.46, 8, 10, 1, '546', '5스테이지 46웨이브 몬스터'),
	(547, 'Monster 5-47', 3100, 3.47, 8, 10, 1, '547', '5스테이지 47웨이브 몬스터'),
	(548, 'Monster 5-48', 3150, 3.48, 8, 10, 1, '548', '5스테이지 48웨이브 몬스터'),
	(549, 'Monster 5-49', 3200, 3.49, 8, 10, 1, '549', '5스테이지 49웨이브 몬스터'),
	(550, 'Stage 5 Boss', 62500, 2.00, 30, 1000, 10, '550', '5스테이지의 강력한 보스입니다.');

-- 테이블 dtd_project.stages 구조 내보내기
DROP TABLE IF EXISTS `stages`;
CREATE TABLE IF NOT EXISTS `stages` (
  `idx` int(11) NOT NULL COMMENT '스테이지 IDX',
  `stage_type` enum('DEFENSE','BOSS') NOT NULL COMMENT '스테이지 타입',
  `stage_name` varchar(100) NOT NULL COMMENT '스테이지 이름',
  `rewards_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '스테이지 보상',
  `map_config_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '스테이지 정보',
  PRIMARY KEY (`idx`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 테이블 데이터 dtd_project.stages:~6 rows (대략적) 내보내기
INSERT INTO `stages` (`idx`, `stage_type`, `stage_name`, `rewards_json`, `map_config_json`) VALUES
	(1, 'DEFENSE', '무한의 숲', '{\r\n  "gold": 20000,\r\n  "exp": 5000,\r\n  "items": [{"itemId": 901, "count": 1}]\r\n}', '{\n    "startBit": 200,\n    "map": "1-1",\n    "limitCount": 80,\n    "waypoints": \n    [\n        {\n            "x": 579,\n            "y": 70\n        },\n        {\n            "x": 579,\n            "y": 92\n        },\n        {\n            "x": 580,\n            "y": 165\n        },\n        {\n            "x": 475,\n            "y": 169\n        },\n        {\n            "x": 477,\n            "y": 565\n        },\n        {\n            "x": 1165,\n            "y": 569\n        },\n        {\n            "x": 1166,\n            "y": 367\n        },\n        {\n            "x": 778,\n            "y": 356\n        },\n        {\n            "x": 758,\n            "y": 176\n        },\n        {\n            "x": 590,\n            "y": 171\n        }\n    ],\n    "waves": \n    [\n        {\n            "waveNumber": "1",\n            "enemyId": "101",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "0",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "2",\n            "enemyId": "102",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "3",\n            "enemyId": "103",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "4",\n            "enemyId": "104",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "5",\n            "enemyId": "105",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "6",\n            "enemyId": "106",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "7",\n            "enemyId": "107",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "8",\n            "enemyId": "108",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "9",\n            "enemyId": "109",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "10",\n            "enemyId": "110",\n            "count": 1,\n            "interval": 500,\n            "startDelay": "50000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "11",\n            "enemyId": "111",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "12",\n            "enemyId": "112",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "13",\n            "enemyId": "113",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "14",\n            "enemyId": "114",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "15",\n            "enemyId": "115",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "16",\n            "enemyId": "116",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "17",\n            "enemyId": "117",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "18",\n            "enemyId": "118",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "19",\n            "enemyId": "119",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "20",\n            "enemyId": "120",\n            "count": 1,\n            "interval": 500,\n            "startDelay": "50000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "21",\n            "enemyId": "121",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "22",\n            "enemyId": "122",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "23",\n            "enemyId": "123",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "24",\n            "enemyId": "124",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "25",\n            "enemyId": "125",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "26",\n            "enemyId": "126",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "27",\n            "enemyId": "127",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "28",\n            "enemyId": "128",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "29",\n            "enemyId": "129",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "30",\n            "enemyId": "130",\n            "count": 1,\n            "interval": 500,\n            "startDelay": "50000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "31",\n            "enemyId": "131",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "32",\n            "enemyId": "132",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "33",\n            "enemyId": "133",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "34",\n            "enemyId": "134",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "35",\n            "enemyId": "135",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "36",\n            "enemyId": "136",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "37",\n            "enemyId": "137",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "38",\n            "enemyId": "138",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "39",\n            "enemyId": "139",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "40",\n            "enemyId": "140",\n            "count": 1,\n            "interval": 500,\n            "startDelay": "50000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "41",\n            "enemyId": "141",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "42",\n            "enemyId": "142",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "43",\n            "enemyId": "143",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "44",\n            "enemyId": "144",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "45",\n            "enemyId": "145",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "46",\n            "enemyId": "146",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "47",\n            "enemyId": "147",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "48",\n            "enemyId": "148",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "49",\n            "enemyId": "149",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "50",\n            "enemyId": "150",\n            "count": 1,\n            "interval": 500,\n            "startDelay": "50000",\n            "waveRewardBit": 0\n        }\n    ]\n}'),
	(2, 'DEFENSE', '무한의 숲', '{\r\n  "gold": 1000,\r\n  "exp": 500,\r\n  "items": [{"itemId": 901, "count": 1}]\r\n}', '{\n    "startBit": 200,\n    "map": "2-1",\n    "limitCount": 80,\n    "waypoints": \n    [\n        {\n            "x": 579,\n            "y": 70\n        },\n        {\n            "x": 579,\n            "y": 92\n        },\n        {\n            "x": 580,\n            "y": 165\n        },\n        {\n            "x": 475,\n            "y": 169\n        },\n        {\n            "x": 477,\n            "y": 565\n        },\n        {\n            "x": 1165,\n            "y": 569\n        },\n        {\n            "x": 1166,\n            "y": 367\n        },\n        {\n            "x": 778,\n            "y": 356\n        },\n        {\n            "x": 758,\n            "y": 176\n        },\n        {\n            "x": 590,\n            "y": 171\n        }\n    ],\n    "waves": \n    [\n        {\n            "waveNumber": "1",\n            "enemyId": "201",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "0",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "2",\n            "enemyId": "202",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "3",\n            "enemyId": "203",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "4",\n            "enemyId": "204",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "5",\n            "enemyId": "205",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "6",\n            "enemyId": "206",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "7",\n            "enemyId": "207",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "8",\n            "enemyId": "208",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "9",\n            "enemyId": "209",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "10",\n            "enemyId": "210",\n            "count": 1,\n            "interval": 500,\n            "startDelay": "50000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "11",\n            "enemyId": "211",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "12",\n            "enemyId": "212",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "13",\n            "enemyId": "213",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "14",\n            "enemyId": "214",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "15",\n            "enemyId": "215",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "16",\n            "enemyId": "216",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "17",\n            "enemyId": "217",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "18",\n            "enemyId": "218",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "19",\n            "enemyId": "219",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "20",\n            "enemyId": "220",\n            "count": 1,\n            "interval": 500,\n            "startDelay": "50000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "21",\n            "enemyId": "221",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "22",\n            "enemyId": "222",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "23",\n            "enemyId": "223",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "24",\n            "enemyId": "224",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "25",\n            "enemyId": "225",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "26",\n            "enemyId": "226",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "27",\n            "enemyId": "227",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "28",\n            "enemyId": "228",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "29",\n            "enemyId": "229",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "30",\n            "enemyId": "230",\n            "count": 1,\n            "interval": 500,\n            "startDelay": "50000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "31",\n            "enemyId": "231",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "32",\n            "enemyId": "232",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "33",\n            "enemyId": "233",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "34",\n            "enemyId": "234",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "35",\n            "enemyId": "235",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "36",\n            "enemyId": "236",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "37",\n            "enemyId": "237",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "38",\n            "enemyId": "238",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "39",\n            "enemyId": "239",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "40",\n            "enemyId": "240",\n            "count": 1,\n            "interval": 500,\n            "startDelay": "50000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "41",\n            "enemyId": "241",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "42",\n            "enemyId": "242",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "43",\n            "enemyId": "243",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "44",\n            "enemyId": "244",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "45",\n            "enemyId": "245",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "46",\n            "enemyId": "246",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "47",\n            "enemyId": "247",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "48",\n            "enemyId": "248",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "49",\n            "enemyId": "249",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "50",\n            "enemyId": "250",\n            "count": 1,\n            "interval": 500,\n            "startDelay": "50000",\n            "waveRewardBit": 0\n        }\n    ]\n}'),
	(3, 'DEFENSE', '무한의 숲', '{\r\n  "gold": 1000,\r\n  "exp": 500,\r\n  "items": [{"itemId": 901, "count": 1}]\r\n}', '{\n    "startBit": 200,\n    "map": "3-1",\n    "limitCount": 80,\n    "waypoints": \n    [\n        {\n            "x": 579,\n            "y": 70\n        },\n        {\n            "x": 579,\n            "y": 92\n        },\n        {\n            "x": 580,\n            "y": 165\n        },\n        {\n            "x": 475,\n            "y": 169\n        },\n        {\n            "x": 477,\n            "y": 565\n        },\n        {\n            "x": 1165,\n            "y": 569\n        },\n        {\n            "x": 1166,\n            "y": 367\n        },\n        {\n            "x": 778,\n            "y": 356\n        },\n        {\n            "x": 758,\n            "y": 176\n        },\n        {\n            "x": 590,\n            "y": 171\n        }\n    ],\n    "waves": \n    [\n        {\n            "waveNumber": "1",\n            "enemyId": "301",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "0",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "2",\n            "enemyId": "302",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "3",\n            "enemyId": "303",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "4",\n            "enemyId": "304",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "5",\n            "enemyId": "305",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "6",\n            "enemyId": "306",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "7",\n            "enemyId": "307",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "8",\n            "enemyId": "308",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "9",\n            "enemyId": "309",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "10",\n            "enemyId": "310",\n            "count": 1,\n            "interval": 500,\n            "startDelay": "50000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "11",\n            "enemyId": "311",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "12",\n            "enemyId": "312",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "13",\n            "enemyId": "313",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "14",\n            "enemyId": "314",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "15",\n            "enemyId": "315",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "16",\n            "enemyId": "316",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "17",\n            "enemyId": "317",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "18",\n            "enemyId": "318",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "19",\n            "enemyId": "319",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "20",\n            "enemyId": "320",\n            "count": 1,\n            "interval": 500,\n            "startDelay": "50000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "21",\n            "enemyId": "321",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "22",\n            "enemyId": "322",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "23",\n            "enemyId": "323",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "24",\n            "enemyId": "324",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "25",\n            "enemyId": "325",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "26",\n            "enemyId": "326",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "27",\n            "enemyId": "327",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "28",\n            "enemyId": "328",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "29",\n            "enemyId": "329",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "30",\n            "enemyId": "330",\n            "count": 1,\n            "interval": 500,\n            "startDelay": "50000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "31",\n            "enemyId": "331",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "32",\n            "enemyId": "332",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "33",\n            "enemyId": "333",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "34",\n            "enemyId": "334",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "35",\n            "enemyId": "335",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "36",\n            "enemyId": "336",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "37",\n            "enemyId": "337",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "38",\n            "enemyId": "338",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "39",\n            "enemyId": "339",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "40",\n            "enemyId": "340",\n            "count": 1,\n            "interval": 500,\n            "startDelay": "50000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "41",\n            "enemyId": "341",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "42",\n            "enemyId": "342",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "43",\n            "enemyId": "343",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "44",\n            "enemyId": "344",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "45",\n            "enemyId": "345",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "46",\n            "enemyId": "346",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "47",\n            "enemyId": "347",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "48",\n            "enemyId": "348",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "49",\n            "enemyId": "349",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "50",\n            "enemyId": "350",\n            "count": 1,\n            "interval": 500,\n            "startDelay": "50000",\n            "waveRewardBit": 0\n        }\n    ]\n}'),
	(4, 'DEFENSE', '무한의 숲', '{\r\n  "gold": 1000,\r\n  "exp": 500,\r\n  "items": [{"itemId": 901, "count": 1}]\r\n}', '{\n    "startBit": 200,\n    "map": "4-1",\n    "limitCount": 80,\n    "waypoints": \n    [\n        {\n            "x": 579,\n            "y": 70\n        },\n        {\n            "x": 579,\n            "y": 92\n        },\n        {\n            "x": 580,\n            "y": 165\n        },\n        {\n            "x": 475,\n            "y": 169\n        },\n        {\n            "x": 477,\n            "y": 565\n        },\n        {\n            "x": 1165,\n            "y": 569\n        },\n        {\n            "x": 1166,\n            "y": 367\n        },\n        {\n            "x": 778,\n            "y": 356\n        },\n        {\n            "x": 758,\n            "y": 176\n        },\n        {\n            "x": 590,\n            "y": 171\n        }\n    ],\n    "waves": \n    [\n        {\n            "waveNumber": "1",\n            "enemyId": "401",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "0",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "2",\n            "enemyId": "402",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "3",\n            "enemyId": "403",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "4",\n            "enemyId": "404",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "5",\n            "enemyId": "405",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "6",\n            "enemyId": "406",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "7",\n            "enemyId": "407",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "8",\n            "enemyId": "408",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "9",\n            "enemyId": "409",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "10",\n            "enemyId": "410",\n            "count": 1,\n            "interval": 500,\n            "startDelay": "50000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "11",\n            "enemyId": "411",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "12",\n            "enemyId": "412",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "13",\n            "enemyId": "413",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "14",\n            "enemyId": "414",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "15",\n            "enemyId": "415",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "16",\n            "enemyId": "416",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "17",\n            "enemyId": "417",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "18",\n            "enemyId": "418",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "19",\n            "enemyId": "419",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "20",\n            "enemyId": "420",\n            "count": 1,\n            "interval": 500,\n            "startDelay": "50000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "21",\n            "enemyId": "421",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "22",\n            "enemyId": "422",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "23",\n            "enemyId": "423",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "24",\n            "enemyId": "424",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "25",\n            "enemyId": "425",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "26",\n            "enemyId": "426",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "27",\n            "enemyId": "427",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "28",\n            "enemyId": "428",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "29",\n            "enemyId": "429",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "30",\n            "enemyId": "430",\n            "count": 1,\n            "interval": 500,\n            "startDelay": "50000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "31",\n            "enemyId": "431",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "32",\n            "enemyId": "432",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "33",\n            "enemyId": "433",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "34",\n            "enemyId": "434",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "35",\n            "enemyId": "435",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "36",\n            "enemyId": "436",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "37",\n            "enemyId": "437",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "38",\n            "enemyId": "438",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "39",\n            "enemyId": "439",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "40",\n            "enemyId": "440",\n            "count": 1,\n            "interval": 500,\n            "startDelay": "50000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "41",\n            "enemyId": "441",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "42",\n            "enemyId": "442",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "43",\n            "enemyId": "443",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "44",\n            "enemyId": "444",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "45",\n            "enemyId": "445",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "46",\n            "enemyId": "446",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "47",\n            "enemyId": "447",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "48",\n            "enemyId": "448",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "49",\n            "enemyId": "449",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "50",\n            "enemyId": "450",\n            "count": 1,\n            "interval": 500,\n            "startDelay": "50000",\n            "waveRewardBit": 0\n        }\n    ]\n}'),
	(5, 'DEFENSE', '무한의 숲', '{\r\n  "gold": 1000,\r\n  "exp": 500,\r\n  "items": [{"itemId": 901, "count": 1}]\r\n}', '{\n    "startBit": 200,\n    "map": "5-1",\n    "limitCount": 80,\n    "waypoints": \n    [\n        {\n            "x": 579,\n            "y": 70\n        },\n        {\n            "x": 579,\n            "y": 92\n        },\n        {\n            "x": 580,\n            "y": 165\n        },\n        {\n            "x": 475,\n            "y": 169\n        },\n        {\n            "x": 477,\n            "y": 565\n        },\n        {\n            "x": 1165,\n            "y": 569\n        },\n        {\n            "x": 1166,\n            "y": 367\n        },\n        {\n            "x": 778,\n            "y": 356\n        },\n        {\n            "x": 758,\n            "y": 176\n        },\n        {\n            "x": 590,\n            "y": 171\n        }\n    ],\n    "waves": \n    [\n        {\n            "waveNumber": "1",\n            "enemyId": "501",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "0",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "2",\n            "enemyId": "502",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "3",\n            "enemyId": "503",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "4",\n            "enemyId": "504",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "5",\n            "enemyId": "505",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "6",\n            "enemyId": "506",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "7",\n            "enemyId": "507",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "8",\n            "enemyId": "508",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "9",\n            "enemyId": "509",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "10",\n            "enemyId": "510",\n            "count": 1,\n            "interval": 500,\n            "startDelay": "50000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "11",\n            "enemyId": "511",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "12",\n            "enemyId": "512",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "13",\n            "enemyId": "513",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "14",\n            "enemyId": "514",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "15",\n            "enemyId": "515",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "16",\n            "enemyId": "516",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "17",\n            "enemyId": "517",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "18",\n            "enemyId": "518",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "19",\n            "enemyId": "519",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "20",\n            "enemyId": "520",\n            "count": 1,\n            "interval": 500,\n            "startDelay": "50000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "21",\n            "enemyId": "521",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "22",\n            "enemyId": "522",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "23",\n            "enemyId": "523",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "24",\n            "enemyId": "524",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "25",\n            "enemyId": "525",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "26",\n            "enemyId": "526",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "27",\n            "enemyId": "527",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "28",\n            "enemyId": "528",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "29",\n            "enemyId": "529",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "30",\n            "enemyId": "530",\n            "count": 1,\n            "interval": 500,\n            "startDelay": "50000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "31",\n            "enemyId": "531",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "32",\n            "enemyId": "532",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "33",\n            "enemyId": "533",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "34",\n            "enemyId": "534",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "35",\n            "enemyId": "535",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "36",\n            "enemyId": "536",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "37",\n            "enemyId": "537",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "38",\n            "enemyId": "538",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "39",\n            "enemyId": "539",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "40",\n            "enemyId": "540",\n            "count": 1,\n            "interval": 500,\n            "startDelay": "50000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "41",\n            "enemyId": "541",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "42",\n            "enemyId": "542",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "43",\n            "enemyId": "543",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "44",\n            "enemyId": "544",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "45",\n            "enemyId": "545",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "46",\n            "enemyId": "546",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "47",\n            "enemyId": "547",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "48",\n            "enemyId": "548",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "49",\n            "enemyId": "549",\n            "count": 100,\n            "interval": 500,\n            "startDelay": "5000",\n            "waveRewardBit": 0\n        },\n        {\n            "waveNumber": "50",\n            "enemyId": "550",\n            "count": 1,\n            "interval": 500,\n            "startDelay": "50000",\n            "waveRewardBit": 0\n        }\n    ]\n}'),
	(10, 'BOSS', '숲의 주인 쿠가몬', '{\r\n  "gold": 1000,\r\n  "exp": 500,\r\n  "items": [{"itemId": 901, "count": 1}]\r\n}', '{\r\n    "bossId": 901,\r\n    "bossName": "쿠가몬",\r\n    "hp": 5000,\r\n    "attack": 150,\r\n    "skills": ["ROAR", "STUN_SLAM"],\r\n    "bgImage": "forest_boss_bg.png"\r\n }');

-- 테이블 dtd_project.towers 구조 내보내기
DROP TABLE IF EXISTS `towers`;
CREATE TABLE IF NOT EXISTS `towers` (
  `idx` int(11) NOT NULL COMMENT '타워 IDX',
  `tower_name` varchar(50) NOT NULL COMMENT '타워 이름',
  `base_damage` int(11) NOT NULL COMMENT '타워 기본 공격력',
  `base_range` int(11) NOT NULL COMMENT '타워 기본 사거리',
  `base_build_cost` int(11) NOT NULL DEFAULT 0 COMMENT '기본 설치 비용',
  `base_type` enum('FIRE','PLANT','ELECTRIC','WATER','LIGHT','DARK') NOT NULL COMMENT '타워 기본 타입',
  `attack_type` enum('SINGLE','MULTI','SLOW','STUN','DEFENSE_DOWN') NOT NULL COMMENT '타워 공격 유형',
  `base_cooldown` decimal(5,2) NOT NULL COMMENT '타워 기본 쿨타임',
  `base_upgrade_cost` int(11) NOT NULL DEFAULT 0 COMMENT '타워 기본 강화 비용',
  `tier` int(11) DEFAULT 1 COMMENT '타워 등급',
  `description` text DEFAULT NULL COMMENT '타워 설명',
  `damage_growth` decimal(5,2) NOT NULL DEFAULT 1.05 COMMENT '공격력 증가율',
  `cost_growth` decimal(5,2) NOT NULL DEFAULT 1.10 COMMENT '강화 비용 증가율',
  PRIMARY KEY (`idx`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 테이블 데이터 dtd_project.towers:~32 rows (대략적) 내보내기
INSERT INTO `towers` (`idx`, `tower_name`, `base_damage`, `base_range`, `base_build_cost`, `base_type`, `attack_type`, `base_cooldown`, `base_upgrade_cost`, `tier`, `description`, `damage_growth`, `cost_growth`) VALUES
	(101, '코로몬', 20, 130, 100, 'FIRE', 'SINGLE', 0.90, 150, 1, '작은 불꽃을 뱉어 공격합니다.', 1.05, 1.10),
	(102, '아구몬', 50, 140, 250, 'FIRE', 'SINGLE', 0.85, 400, 2, '화염의 힘으로 적을 태웁니다.', 1.05, 1.10),
	(103, '그레이몬', 180, 150, 800, 'FIRE', 'SINGLE', 0.80, 1200, 3, '거대한 화염으로 적을 압도합니다.', 1.05, 1.10),
	(104, '메탈그레이몬', 600, 160, 2500, 'FIRE', 'SINGLE', 0.70, 3600, 4, '초고열의 에너지로 모든 것을 소멸시킵니다.', 1.05, 1.10),
	(201, '뿔몬', 15, 140, 120, 'WATER', 'SLOW', 1.20, 180, 1, '적에게 물을 뿌려 움직임을 둔하게 만듭니다.', 1.05, 1.10),
	(202, '파피몬', 40, 150, 300, 'WATER', 'SLOW', 1.10, 450, 2, '차가운 입김으로 적을 얼어붙게 합니다.', 1.05, 1.10),
	(203, '가루몬', 120, 160, 900, 'WATER', 'SLOW', 1.00, 1300, 3, '푸른 화염으로 적의 속도를 크게 늦춥니다.', 1.05, 1.10),
	(204, '워가루몬', 450, 180, 2700, 'WATER', 'SLOW', 0.90, 3900, 4, '절대영도의 냉기로 적을 정지 수준으로 만듭니다.', 1.05, 1.10),
	(301, '시드몬', 12, 120, 150, 'PLANT', 'MULTI', 1.50, 200, 1, '씨앗을 흩뿌려 주변 적들을 공격합니다.', 1.05, 1.10),
	(302, '팔몬', 35, 130, 350, 'PLANT', 'MULTI', 1.40, 500, 2, '독 줄기를 뻗어 다수의 적을 타격합니다.', 1.05, 1.10),
	(303, '니드몬', 110, 140, 1000, 'PLANT', 'MULTI', 1.30, 1500, 3, '바늘 뿜기로 넓은 범위의 적을 공격합니다.', 1.05, 1.10),
	(304, '릴리몬', 400, 160, 3000, 'PLANT', 'MULTI', 1.20, 4500, 4, '꽃잎포로 전장의 적들을 쓸어버립니다.', 1.05, 1.10),
	(401, '모티몬', 18, 130, 130, 'ELECTRIC', 'STUN', 1.80, 190, 1, '약한 전기로 적을 깜짝 놀라게 합니다.', 1.05, 1.10),
	(402, '텐타몬', 45, 140, 320, 'ELECTRIC', 'STUN', 1.70, 480, 2, '전기를 방출하여 적을 잠시 마비시킵니다.', 1.05, 1.10),
	(403, '캅테리몬', 140, 150, 950, 'ELECTRIC', 'STUN', 1.60, 1400, 3, '강력한 전기충격으로 적을 기절시킵니다.', 1.05, 1.10),
	(404, '아트라캅테리몬', 550, 170, 2800, 'ELECTRIC', 'STUN', 1.50, 4200, 4, '초고압 전류로 적을 완전히 무력화합니다.', 1.05, 1.10),
	(501, '토코몬', 40, 200, 180, 'LIGHT', 'SINGLE', 2.50, 250, 1, '멀리서 빛의 알갱이를 뱉습니다.', 1.05, 1.10),
	(502, '파닥몬', 100, 220, 450, 'LIGHT', 'SINGLE', 2.40, 600, 2, '공기팡을 모아 강력한 한 방을 날립니다.', 1.05, 1.10),
	(503, '엔젤몬', 350, 250, 1300, 'LIGHT', 'SINGLE', 2.20, 1800, 3, '천사의 권능으로 원거리의 적을 저격합니다.', 1.05, 1.10),
	(504, '홀리엔젤몬', 1500, 300, 4000, 'LIGHT', 'SINGLE', 2.00, 5400, 4, '천국의 문으로 적 하나를 확실하게 소멸시킵니다.', 1.05, 1.10),
	(601, '어니몬', 15, 130, 140, 'DARK', 'DEFENSE_DOWN', 1.00, 200, 1, '적을 약올려 방어 태세를 무너뜨립니다.', 1.05, 1.10),
	(602, '피요몬', 40, 140, 340, 'DARK', 'DEFENSE_DOWN', 1.00, 500, 2, '빙빙 회오리로 적의 갑옷을 파괴시킵니다.', 1.05, 1.10),
	(603, '버드라몬', 130, 150, 950, 'DARK', 'DEFENSE_DOWN', 1.00, 1400, 3, '불길로 적의 방어력을 크게 낮춥니다.', 1.05, 1.10),
	(604, '가루다몬', 500, 170, 2900, 'DARK', 'DEFENSE_DOWN', 1.00, 4200, 4, '설명없음.', 1.05, 1.10),
	(701, '둥실몬', 8, 90, 150, 'WATER', 'SINGLE', 0.40, 220, 1, '빠르게 몸통박치기를 합니다.', 1.05, 1.10),
	(702, '쉬라몬', 20, 100, 380, 'WATER', 'SINGLE', 0.35, 550, 2, '물고기 대행진함', 1.05, 1.10),
	(703, '원뿔몬', 70, 110, 1100, 'WATER', 'SINGLE', 0.30, 1600, 3, '뿔미사일 발사함', 1.05, 1.10),
	(704, '쥬드몬', 250, 120, 3200, 'WATER', 'SINGLE', 0.20, 4800, 4, '망치망치~', 1.05, 1.10),
	(801, '야옹몬', 30, 140, 250, 'LIGHT', 'MULTI', 1.30, 350, 1, '신성한 기운을 담아 돌진해 공격합니다.', 1.05, 1.10),
	(802, '플롯트몬', 80, 150, 600, 'LIGHT', 'MULTI', 1.20, 900, 2, '신성한 고리를 던져 주변을 공격합니다.', 1.05, 1.10),
	(803, '가트몬', 250, 170, 1800, 'LIGHT', 'MULTI', 1.10, 2500, 3, '고양이 주먹으로 범위 내 적들을 타격합니다.', 1.05, 1.10),
	(804, '엔젤우몬', 900, 200, 5000, 'LIGHT', 'MULTI', 1.00, 7500, 4, '천상의 화살비로 광범위한 지역을 정화합니다.', 1.05, 1.10);

-- 테이블 dtd_project.users 구조 내보내기
DROP TABLE IF EXISTS `users`;
CREATE TABLE IF NOT EXISTS `users` (
  `idx` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '유저 IDX',
  `userid` varchar(50) NOT NULL COMMENT '로그인 ID',
  `username` varchar(50) NOT NULL COMMENT '유저 닉네임',
  `pwd` varchar(255) NOT NULL COMMENT '로그인 PWD',
  `birth` date DEFAULT NULL COMMENT '유저 생일',
  `gold` int(11) DEFAULT 0 COMMENT '유저 재화1',
  `diamond` int(11) DEFAULT 0 COMMENT '유저 재화2',
  `exp` int(11) NOT NULL DEFAULT 0 COMMENT '유저 경험치(진화 재료)',
  `refresh_token` varchar(500) DEFAULT NULL COMMENT '리프레시 토큰',
  `created_at` timestamp NULL DEFAULT current_timestamp() COMMENT 'ID 생성일',
  `last_login` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT '마지막 로그인',
  `main_tower_idx` bigint(20) DEFAULT NULL COMMENT '대표 타워',
  PRIMARY KEY (`idx`),
  UNIQUE KEY `userid` (`userid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 테이블 데이터 dtd_project.users:~9 rows (대략적) 내보내기
INSERT INTO `users` (`idx`, `userid`, `username`, `pwd`, `birth`, `gold`, `diamond`, `exp`, `refresh_token`, `created_at`, `last_login`, `main_tower_idx`) VALUES
	(1, 'agumon', '아구몬', '$2a$10$U5HQHE.H5oVgvdUthKqDNOvjBzFrqZSrljmRThAOi3xfyYU8OYmty', '2020-02-02', 368736, 0, 97000, 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhZ3Vtb24iLCJleHAiOjE3NjYxMjg1Mjh9.OUAmZv59TxIOmYcRcx-zddsMH3FdMk1QKf-sTWdXB4gK39LeidgMQvmnaWTZjWqzhY-vqxTQlcncB26wkfhDOQ', '2025-12-03 01:41:06', '2025-12-12 07:15:28', 1),
	(2, 'qqqq123', 'q1q1', '$2a$10$XqgOOzUZ3hnZxsHlKb/ekeedBqsw0oud159TEMktegmNmoQpG0vNC', '2025-12-17', 73348, 0, 0, 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJxcXFxMTIzIiwiZXhwIjoxNzY2MTE2MjUxfQ.qxL2GcZHemHVuoo5pB-vpHtYwyHQQdWCIMYS-wsW-NKCCJOzhFShhKgnEYF8RmVjKXVRa4r9d69frm8FHtS_9w', '2025-12-04 01:52:59', '2025-12-12 03:56:32', 16),
	(3, 'qq123', 'q1q2', '$2a$10$e4bKCC.JEEhSbs2eOtIGQefJsnSJX60okwQrzo8esx0qmytMpCqJm', '2025-12-10', 500, 0, 0, NULL, '2025-12-04 02:35:34', '2025-12-05 05:58:11', NULL),
	(4, 'erer123', 'q1q3', '$2a$10$0StiLQgc6JPsKYYK68A3s.SuohZp3bmly6Bjk/GRG3AU5Ym3YOdQ6', '2025-12-17', 500, 0, 0, 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJlcmVyMTIzIiwiZXhwIjoxNzY1ODUwNjA0fQ.a9UOO0BtOVSOdlSPUkSUhCalgDBUbLqww2RePRUOlZPXDzJzPHEEPfWtiRe2GeVG2dJfd9yUpG-pcts-iAiZoQ', '2025-12-04 02:42:42', '2025-12-09 02:03:24', NULL),
	(5, 'qqq123', 'q3q3', '$2a$10$oDRVy/5Bnjs0Uk2I9mtFF.vwqgeIFXkgoA3.OUvnTqKspD8XcQWBa', '2025-12-18', 500, 0, 0, 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJxcXExMjMiLCJleHAiOjE3NjU0MjY0Mzl9.v9c-RTw1rsZhViamfV5yP4M4NwjLo1WyogEHAtRtQ9x_VSzQmSMvFcnZX-ipl2pXClkMJuzE80K_qVflpIKRmA', '2025-12-04 04:13:53', '2025-12-05 05:58:17', NULL),
	(6, 'qq123123', 'qwe1231', '$2a$10$xy3EOo3brvtKHsn5Hjf7v.2zLX5vHQKfRFVgmCTR7.S/YexPuBK.i', '2025-12-10', 500, 0, 0, NULL, '2025-12-04 04:39:42', '2025-12-05 05:58:19', NULL),
	(7, 'testUser1', '테스터1', '$2a$10$iXQcPzW33zshmZBko0MT4epSRnxJ/Mi.52wdh7xmdSSr/zCdZMFNi', '2000-01-01', 500, 0, 0, NULL, '2025-12-05 06:01:04', '2025-12-05 06:01:53', NULL),
	(8, 'testUser2', '테스터2', '$2a$10$0wgj5lvhOoxLdBH0F2Nob.FgQyVGi//VzpgvPBBNi5nn2HFnApFCq', '2000-01-02', 500, 0, 0, NULL, '2025-12-05 06:01:38', '2025-12-05 06:01:38', NULL),
	(9, 'bossbaby', 'baby', '$2a$10$yVQHVdWeWyKlEXBT.RYzlenDicP7zooeAfMVqCtKRArKUSM25dpmi', '2025-12-08', 500, 0, 0, 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJib3NzYmFieSIsImV4cCI6MTc2NjEyNTY3MH0.Cv9srhM5EhBQfyBKL5JU9t6gwHe_XNLtkxGE_Neo7f5f4WXefc_M618wVklvpwLMbJgqcRBNsk3ub8hm8QrubA', '2025-12-09 06:45:15', '2025-12-12 06:27:50', NULL);

-- 테이블 dtd_project.user_inventory 구조 내보내기
DROP TABLE IF EXISTS `user_inventory`;
CREATE TABLE IF NOT EXISTS `user_inventory` (
  `user_idx` bigint(20) NOT NULL COMMENT '유저 IDX 참조',
  `item_idx` int(11) NOT NULL COMMENT '아이템 IDX 참조',
  `quantity` int(11) DEFAULT 0 COMMENT '수량',
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`user_idx`,`item_idx`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 테이블 데이터 dtd_project.user_inventory:~2 rows (대략적) 내보내기
INSERT INTO `user_inventory` (`user_idx`, `item_idx`, `quantity`, `updated_at`) VALUES
	(1, 101, 4, '2025-12-10 07:03:06'),
	(1, 201, 1, '2025-12-08 06:57:27');

-- 테이블 dtd_project.user_stage_clear 구조 내보내기
DROP TABLE IF EXISTS `user_stage_clear`;
CREATE TABLE IF NOT EXISTS `user_stage_clear` (
  `user_idx` bigint(20) NOT NULL COMMENT '유저 IDX 참조',
  `stage_idx` int(11) NOT NULL COMMENT '스테이지 IDX 참조',
  `is_cleared` tinyint(1) DEFAULT 0 COMMENT '클리어 유무',
  `score` int(11) DEFAULT 0 COMMENT '스테이지 점수',
  `cleared_at` timestamp NULL DEFAULT current_timestamp() COMMENT '최초 클리어 날짜',
  PRIMARY KEY (`user_idx`,`stage_idx`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 테이블 데이터 dtd_project.user_stage_clear:~2 rows (대략적) 내보내기
INSERT INTO `user_stage_clear` (`user_idx`, `stage_idx`, `is_cleared`, `score`, `cleared_at`) VALUES
	(1, 1, 1, 10000, '2025-12-12 05:58:06'),
	(1, 2, 1, 10000, '2025-12-12 05:58:45');

-- 테이블 dtd_project.user_towers 구조 내보내기
DROP TABLE IF EXISTS `user_towers`;
CREATE TABLE IF NOT EXISTS `user_towers` (
  `idx` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '유저 타워 IDX',
  `user_idx` bigint(20) NOT NULL COMMENT '유저 IDX 참조',
  `tower_idx` int(11) NOT NULL COMMENT '타워 IDX 참조',
  `level` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`idx`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 테이블 데이터 dtd_project.user_towers:~20 rows (대략적) 내보내기
INSERT INTO `user_towers` (`idx`, `user_idx`, `tower_idx`, `level`) VALUES
	(1, 1, 101, 24),
	(2, 1, 201, 0),
	(3, 2, 201, 19),
	(4, 2, 103, 0),
	(5, 2, 104, 2),
	(6, 2, 101, 26),
	(7, 2, 801, 18),
	(8, 2, 501, 38),
	(9, 2, 601, 1),
	(10, 2, 102, 1),
	(11, 2, 202, 1),
	(12, 2, 302, 1),
	(13, 2, 203, 5),
	(14, 2, 503, 20),
	(15, 2, 703, 14),
	(16, 2, 702, 1),
	(17, 2, 403, 1),
	(18, 2, 303, 2),
	(19, 2, 603, 1),
	(20, 2, 802, 47);

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
