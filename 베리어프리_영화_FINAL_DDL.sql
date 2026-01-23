-- ============================================
-- 베리어프리 영화 서비스 - 최종 완전판 (FINAL)
-- 총 12개 테이블
-- 설문조사 제외, 핵심 기능만 포함
-- ============================================

SET FOREIGN_KEY_CHECKS=0;
DROP TABLE IF EXISTS PUSH_NOTIFICATION;
DROP TABLE IF EXISTS NOTICE;
DROP TABLE IF EXISTS POINT_HISTORY;
DROP TABLE IF EXISTS USER_POINT;
DROP TABLE IF EXISTS USER_DOWNLOAD;
DROP TABLE IF EXISTS USER_FAVORITE;
DROP TABLE IF EXISTS USER;
DROP TABLE IF EXISTS FEATURED_LIST_MOVIE;
DROP TABLE IF EXISTS FEATURED_LIST;
DROP TABLE IF EXISTS MOVIE;
DROP TABLE IF EXISTS PRODUCTION_COMPANY;
DROP TABLE IF EXISTS GENRE;
SET FOREIGN_KEY_CHECKS=1;

-- ============================================
-- 1. 영화 관련 테이블 (5개)
-- ============================================

CREATE TABLE GENRE (
    genre_id INT AUTO_INCREMENT PRIMARY KEY,
    genre_name VARCHAR(50) NOT NULL UNIQUE,
    genre_description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_genre_name (genre_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='장르 테이블';

CREATE TABLE PRODUCTION_COMPANY (
    company_id INT AUTO_INCREMENT PRIMARY KEY,
    company_name VARCHAR(200) NOT NULL,
    country VARCHAR(100),
    established_year INT,
    company_website VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_company_name (company_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='제작사 테이블';

CREATE TABLE MOVIE (
    movie_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    original_title VARCHAR(255),
    release_date DATE,
    director_name VARCHAR(200),
    running_time INT COMMENT '러닝타임(분)',
    synopsis TEXT,
    poster_url VARCHAR(500),
    rating VARCHAR(20) COMMENT '관람등급',
    has_audio_commentary TINYINT(1) NOT NULL DEFAULT 0 COMMENT '화면해설 제공 여부',
    has_closed_caption TINYINT(1) NOT NULL DEFAULT 0 COMMENT '한글자막 제공 여부',
    audio_commentary_file VARCHAR(500) COMMENT '화면해설 파일 경로',
    closed_caption_file VARCHAR(500) COMMENT '한글자막 파일 경로',
    is_latest TINYINT(1) NOT NULL DEFAULT 0 COMMENT '최신작 표시',
    is_popular TINYINT(1) NOT NULL DEFAULT 0 COMMENT '인기작 표시',
    genre_id INT,
    company_id INT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_movie_genre FOREIGN KEY (genre_id) REFERENCES GENRE(genre_id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_movie_company FOREIGN KEY (company_id) REFERENCES PRODUCTION_COMPANY(company_id) ON DELETE SET NULL ON UPDATE CASCADE,
    INDEX idx_title (title),
    INDEX idx_release_date (release_date),
    INDEX idx_barrier_free (has_audio_commentary, has_closed_caption),
    INDEX idx_featured (is_latest, is_popular)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='영화 메타데이터 테이블 (베리어프리 정보 포함)';

CREATE TABLE FEATURED_LIST (
    list_id INT AUTO_INCREMENT PRIMARY KEY,
    list_name VARCHAR(100) NOT NULL UNIQUE,
    list_description TEXT,
    max_items INT COMMENT '최대 항목 수',
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    display_order INT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='특별 목록 테이블 (최신작, 인기작 등)';

CREATE TABLE FEATURED_LIST_MOVIE (
    featured_id INT AUTO_INCREMENT PRIMARY KEY,
    list_id INT NOT NULL,
    movie_id INT NOT NULL,
    display_order INT NOT NULL COMMENT '목록 내 순서',
    featured_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_featured_list FOREIGN KEY (list_id) REFERENCES FEATURED_LIST(list_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_featured_movie FOREIGN KEY (movie_id) REFERENCES MOVIE(movie_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT uq_list_movie UNIQUE (list_id, movie_id),
    INDEX idx_list_order (list_id, display_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='특별목록-영화 연결 테이블';

-- ============================================
-- 2. 회원 관리 테이블 (3개)
-- ============================================

CREATE TABLE USER (
    user_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) UNIQUE,
    password_hash VARCHAR(255) COMMENT '비밀번호 해시 (bcrypt)',
    username VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    profile_image VARCHAR(500),
    auth_provider VARCHAR(20) NOT NULL COMMENT 'email/kakao/naver/google/apple',
    social_id VARCHAR(255) COMMENT '소셜 로그인 고유 ID',
    disability_type VARCHAR(50) COMMENT 'visual/hearing/none',
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    last_login_at TIMESTAMP NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_auth_provider CHECK (auth_provider IN ('email', 'kakao', 'naver', 'google', 'apple')),
    CONSTRAINT chk_disability_type CHECK (disability_type IN ('visual', 'hearing', 'none') OR disability_type IS NULL),
    INDEX idx_email (email),
    INDEX idx_social (auth_provider, social_id),
    INDEX idx_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='회원 테이블 (일반 + 소셜 로그인)';

CREATE TABLE USER_FAVORITE (
    favorite_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    movie_id INT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_favorite_user FOREIGN KEY (user_id) REFERENCES USER(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_favorite_movie FOREIGN KEY (movie_id) REFERENCES MOVIE(movie_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT uq_user_movie_favorite UNIQUE (user_id, movie_id),
    INDEX idx_user_id (user_id),
    INDEX idx_movie_id (movie_id),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='찜하기 테이블';

CREATE TABLE USER_DOWNLOAD (
    download_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    movie_id INT NOT NULL,
    file_type VARCHAR(20) NOT NULL COMMENT 'audio_commentary/closed_caption',
    file_path VARCHAR(500) NOT NULL,
    download_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_download_user FOREIGN KEY (user_id) REFERENCES USER(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_download_movie FOREIGN KEY (movie_id) REFERENCES MOVIE(movie_id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT chk_file_type CHECK (file_type IN ('audio_commentary', 'closed_caption')),
    INDEX idx_user_id (user_id),
    INDEX idx_movie_id (movie_id),
    INDEX idx_download_at (download_at),
    INDEX idx_user_movie (user_id, movie_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='다운로드 이력 테이블';

-- ============================================
-- 3. 마일리지 시스템 (2개 - 간소화)
-- ============================================

CREATE TABLE USER_POINT (
    point_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,
    total_points INT NOT NULL DEFAULT 0 COMMENT '현재 보유 포인트',
    earned_points INT NOT NULL DEFAULT 0 COMMENT '누적 적립 포인트',
    used_points INT NOT NULL DEFAULT 0 COMMENT '누적 사용 포인트',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_point_user FOREIGN KEY (user_id) REFERENCES USER(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_total_points CHECK (total_points >= 0),
    INDEX idx_user_id (user_id),
    INDEX idx_total_points (total_points)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='포인트 계정 테이블 (회원당 1개)';

CREATE TABLE POINT_HISTORY (
    history_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    point_type VARCHAR(10) NOT NULL COMMENT 'earn/use',
    points INT NOT NULL COMMENT '포인트 변동량',
    reason VARCHAR(100) NOT NULL COMMENT '사유',
    balance_after INT NOT NULL COMMENT '거래 후 잔액',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_history_user FOREIGN KEY (user_id) REFERENCES USER(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_point_type CHECK (point_type IN ('earn', 'use')),
    INDEX idx_user_id (user_id),
    INDEX idx_created_at (created_at),
    INDEX idx_user_created (user_id, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='포인트 거래 이력 테이블';

-- ============================================
-- 4. 커뮤니케이션 시스템 (2개)
-- ============================================

CREATE TABLE NOTICE (
    notice_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    notice_type VARCHAR(20) NOT NULL COMMENT 'general/update/event/important',
    is_important TINYINT(1) NOT NULL DEFAULT 0 COMMENT '상단 고정 여부',
    is_push_sent TINYINT(1) NOT NULL DEFAULT 0 COMMENT '푸시 발송 여부',
    push_title VARCHAR(100),
    push_message VARCHAR(200),
    thumbnail_url VARCHAR(500),
    link_url VARCHAR(500),
    view_count INT NOT NULL DEFAULT 0,
    published_at TIMESTAMP NULL,
    expires_at TIMESTAMP NULL COMMENT 'NULL이면 무기한',
    created_by BIGINT COMMENT '작성자 (관리자 ID)',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_notice_type CHECK (notice_type IN ('general', 'update', 'event', 'important')),
    INDEX idx_notice_type (notice_type),
    INDEX idx_published_at (published_at),
    INDEX idx_important (is_important, published_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='공지사항 테이블';

CREATE TABLE PUSH_NOTIFICATION (
    push_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    push_type VARCHAR(20) NOT NULL COMMENT 'notice/movie/point/event',
    title VARCHAR(100) NOT NULL,
    message VARCHAR(200) NOT NULL,
    image_url VARCHAR(500),
    link_type VARCHAR(20) COMMENT 'notice/movie/url',
    link_id BIGINT COMMENT '링크 대상 ID',
    link_url VARCHAR(500),
    target_users VARCHAR(50) NOT NULL DEFAULT 'all' COMMENT 'all/visual/hearing/specific',
    target_user_ids TEXT COMMENT '특정 사용자 ID 목록 (JSON)',
    scheduled_at TIMESTAMP NULL COMMENT '발송 예약 시간',
    sent_at TIMESTAMP NULL COMMENT '실제 발송 시간',
    sent_count INT NOT NULL DEFAULT 0,
    read_count INT NOT NULL DEFAULT 0,
    click_count INT NOT NULL DEFAULT 0,
    created_by BIGINT COMMENT '작성자 (관리자 ID)',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_push_type CHECK (push_type IN ('notice', 'movie', 'point', 'event')),
    CONSTRAINT chk_link_type CHECK (link_type IN ('notice', 'movie', 'url') OR link_type IS NULL),
    CONSTRAINT chk_target_users CHECK (target_users IN ('all', 'visual', 'hearing', 'specific')),
    INDEX idx_push_type (push_type),
    INDEX idx_scheduled_at (scheduled_at),
    INDEX idx_sent_at (sent_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='푸시 알림 테이블';

-- ============================================
-- 샘플 데이터
-- ============================================

-- 장르
INSERT INTO GENRE (genre_name, genre_description) VALUES
('액션', '격투, 추격, 폭발 등 역동적인 장면이 주를 이루는 장르'),
('드라마', '인물의 내면과 인간관계를 중심으로 한 이야기'),
('코미디', '유머와 웃음을 주요 목적으로 하는 장르'),
('스릴러', '긴장감과 서스펜스가 강조되는 장르'),
('SF', '과학기술과 미래를 소재로 한 공상과학 장르');

-- 제작사
INSERT INTO PRODUCTION_COMPANY (company_name, country, established_year) VALUES
('NEW', '대한민국', 2008),
('CJ ENM', '대한민국', 1995),
('워너브라더스', '미국', 1923);

-- 특별 목록
INSERT INTO FEATURED_LIST (list_name, list_description, max_items, is_active, display_order) VALUES
('최신작', '최근 개봉한 베리어프리 영화', 5, 1, 1),
('인기작', '많은 관객이 선택한 인기 영화', 10, 1, 2),
('이번 주 추천', '이번 주 추천 영화', 5, 1, 3);

-- 영화 (베리어프리 지원)
INSERT INTO MOVIE (
    title, original_title, release_date, director_name, running_time, 
    synopsis, rating, 
    has_audio_commentary, has_closed_caption, 
    audio_commentary_file, closed_caption_file,
    is_latest, is_popular, 
    genre_id, company_id
) VALUES 
(
    '범죄도시 4', 'The Roundup: Punishment', '2024-04-24', '허명행', 109,
    '괴물형사 마석도, 신종 범죄를 소탕하다!', '15세',
    1, 1,
    '/storage/barrier_free/audio_commentary/2024/1_ac.mp3',
    '/storage/barrier_free/closed_caption/2024/1_cc.srt',
    1, 1,
    1, 1
),
(
    '파묘', 'Exhuma', '2024-02-22', '장재현', 134,
    '미국 LA, 거액의 의뢰를 받은 무당 화림과 봉길은 기이한 병이 대물림되는 집안의 장손을 만난다.', '15세',
    1, 1,
    '/storage/barrier_free/audio_commentary/2024/2_ac.mp3',
    '/storage/barrier_free/closed_caption/2024/2_cc.srt',
    1, 1,
    4, 2
);

-- 특별 목록에 영화 추가
INSERT INTO FEATURED_LIST_MOVIE (list_id, movie_id, display_order) VALUES
(1, 1, 1),  -- 최신작에 범죄도시 4
(1, 2, 2),  -- 최신작에 파묘
(2, 1, 1),  -- 인기작에 범죄도시 4
(2, 2, 2);  -- 인기작에 파묘

-- 회원
INSERT INTO USER (email, username, auth_provider, is_active) VALUES
('test@example.com', '테스트회원', 'email', 1),
('kakao_user@kakao.com', '카카오회원', 'kakao', 1);

-- 회원 포인트 계정 (회원가입 시 자동 생성)
INSERT INTO USER_POINT (user_id, total_points, earned_points, used_points) VALUES
(1, 1000, 1000, 0),  -- 가입 축하 1000P
(2, 1000, 1000, 0);

-- 포인트 적립 이력
INSERT INTO POINT_HISTORY (user_id, point_type, points, reason, balance_after) VALUES
(1, 'earn', 1000, '회원가입 축하', 1000),
(2, 'earn', 1000, '회원가입 축하', 1000);

-- 찜하기
INSERT INTO USER_FAVORITE (user_id, movie_id) VALUES
(1, 1),
(1, 2);

-- 다운로드 이력
INSERT INTO USER_DOWNLOAD (user_id, movie_id, file_type, file_path) VALUES
(1, 1, 'audio_commentary', '/storage/barrier_free/audio_commentary/2024/1_ac.mp3'),
(1, 1, 'closed_caption', '/storage/barrier_free/closed_caption/2024/1_cc.srt');

-- 공지사항
INSERT INTO NOTICE (title, content, notice_type, is_important, published_at, created_by) VALUES
('서비스 오픈 안내', '베리어프리 영화 서비스가 정식 오픈되었습니다! 화면해설과 한글자막이 제공되는 영화를 마음껏 즐기세요.', 
    'important', 1, NOW(), 1),
('신규 영화 추가', '이번 주 베리어프리 영화 10편이 새롭게 추가되었습니다.', 
    'update', 0, NOW(), 1);

-- 푸시 알림
INSERT INTO PUSH_NOTIFICATION (push_type, title, message, link_type, link_id, target_users, sent_at, sent_count, created_by) VALUES
('notice', '서비스 오픈', '베리어프리 영화 서비스가 오픈되었습니다!', 'notice', 1, 'all', NOW(), 2, 1);

-- ============================================
-- 유용한 쿼리 모음
-- ============================================

-- [베리어프리 영화 검색]
SELECT movie_id, title, has_audio_commentary, has_closed_caption
FROM MOVIE
WHERE has_audio_commentary = 1 OR has_closed_caption = 1
ORDER BY release_date DESC;

-- [내가 찜한 영화]
SELECT m.*, uf.created_at AS favorited_at
FROM USER_FAVORITE uf
INNER JOIN MOVIE m ON uf.movie_id = m.movie_id
WHERE uf.user_id = 1;

-- [공지사항 목록 (중요 공지 우선)]
SELECT * FROM NOTICE
WHERE published_at <= NOW()
  AND (expires_at IS NULL OR expires_at > NOW())
ORDER BY is_important DESC, published_at DESC;

-- [내 포인트 정보]
SELECT total_points, earned_points, used_points
FROM USER_POINT
WHERE user_id = 1;

-- ============================================
-- 테이블 확인
-- ============================================

SHOW TABLES;

SELECT 
    TABLE_NAME AS '테이블명',
    TABLE_COMMENT AS '설명'
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = DATABASE()
ORDER BY TABLE_NAME;
