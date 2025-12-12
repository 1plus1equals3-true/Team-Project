package com.team.dtd.dto;

import com.team.dtd.entity.Tower;
import com.team.dtd.entity.UserTower;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Getter
@NoArgsConstructor
public class UserTowerResponseDto {
    private Long id;
    private int level;
    private int exp;
    private LocalDateTime obtainedAt;

    // ⭐️ Entity인 Tower 대신, 아래 만든 TowerInfo 객체를 사용합니다.
    private TowerInfo tower;

    public UserTowerResponseDto(UserTower userTower) {
        this.id = userTower.getIdx();
        this.level = userTower.getLevel();

        // ⭐️ 여기서 데이터를 꺼내서 새 객체에 담습니다. (프록시 해제 효과)
        this.tower = new TowerInfo(userTower.getTower());
    }

    // 내부 클래스로 타워 정보 정의 (필요한 정보만 골라서 넣으세요)
    @Getter
    @NoArgsConstructor
    public static class TowerInfo {
        private Integer idx;
        private String towerName;
        private int baseDamage;
        private int baseRange;
        private String baseType;   // Enum은 String으로 변환
        private String attackType; // Enum은 String으로 변환
        private int tier;
        private String description;

        public TowerInfo(Tower tower) {
            this.idx = tower.getIdx();
            this.towerName = tower.getTowerName();
            this.baseDamage = tower.getBaseDamage();
            this.baseRange = tower.getBaseRange();
            this.baseType = tower.getBaseType().name();
            this.attackType = tower.getAttackType().name();
            this.tier = tower.getTier();
            this.description = tower.getDescription();
        }
    }
}