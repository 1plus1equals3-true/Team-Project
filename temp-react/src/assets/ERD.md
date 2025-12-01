erDiagram
%% 1. 유저 테이블
users {
BIGINT idx PK "Auto Increment"
VARCHAR userid "로그인 ID (Unique)"
VARCHAR username "닉네임 (Unique)"
VARCHAR pwd "해시 비밀번호"
DATE birth "생년월일"
INT gold "게임 재화"
INT diamond "유료 재화"
VARCHAR refresh_token "JWT 리프레시 토큰"
TIMESTAMP created_at
TIMESTAMP last_login
}

    %% 2. 타워 메타 정보
    towers {
        INT idx PK "타워 ID (101, 102...)"
        VARCHAR tower_name
        INT base_damage
        INT base_range
        DECIMAL base_cooldown
        INT tier
        TEXT description
    }

    %% 3. 유저 보유 타워 (매핑 테이블)
    user_towers {
        BIGINT idx PK "Auto Increment"
        BIGINT user_idx FK "users.idx 참조"
        INT tower_idx FK "towers.idx 참조"
        INT level "강화 레벨"
        INT exp "타워 경험치"
        TIMESTAMP obtained_at "획득 시기"
    }

    %% 4. 아이템 메타 정보
    items {
        INT idx PK "아이템 ID"
        VARCHAR item_name
        TEXT description
        ENUM effect_type "HEAL, BUFF_ATK..."
        INT effect_value "회복 50..."
    }

    %% 5. 유저 인벤토리 (매핑 테이블)
    user_inventory {
        BIGINT user_idx PK, FK "users.idx 참조"
        INT item_idx PK, FK "items.idx 참조"
        INT quantity "수량"
        TIMESTAMP updated_at
    }

    %% 6. 스테이지 메타 정보
    stages {
        INT idx PK "스테이지 ID (1~50)"
        ENUM stage_type "DEFENSE, BOSS"
        VARCHAR stage_name
        JSON rewards_json "완료 보상 json"
        JSON map_config_json "스텟, 경로 등 json"
    }

    %% 7. 유저 스테이지 클리어 기록 (매핑 테이블)
    user_stage_clear {
        BIGINT user_idx PK, FK "users.idx 참조"
        INT stage_idx PK, FK "stages.idx 참조"
        BOOLEAN is_cleared "클리어 유무"
        INT score "스테이지 점수"
        TINYINT stars "스테이지 별점"
        TIMESTAMP cleared_at
    }

    %% 관계 정의 (Relationships)
    users ||--o{ user_towers : "소유"
    towers ||--o{ user_towers : "정의됨"

    users ||--o{ user_inventory : "보관"
    items ||--o{ user_inventory : "정의됨"

    users ||--o{ user_stage_clear : "기록"
    stages ||--o{ user_stage_clear : "정의됨"
