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

    private TowerInfo tower;

    public UserTowerResponseDto(UserTower userTower) {
        this.id = userTower.getIdx();
        this.level = userTower.getLevel();

        this.tower = new TowerInfo(userTower.getTower());
    }

    @Getter
    @NoArgsConstructor
    public static class TowerInfo {
        private Integer idx;
        private String towerName;
        private int baseDamage;
        private int baseRange;
        private String baseType;
        private String attackType;
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