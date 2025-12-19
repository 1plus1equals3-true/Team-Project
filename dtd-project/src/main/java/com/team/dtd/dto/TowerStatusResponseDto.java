package com.team.dtd.dto;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class TowerStatusResponseDto {
    private Integer towerIdx;
    private String towerName;
    private int tier;
    private String description;

    // 현재 상태
    private int currentLevel;      // 현재 레벨 (0이면 미강화 상태)
    private int currentDamage;     // 현재 공격력 (계산됨)

    // 기본 상태
    private int baseRange;
    private int baseBuildCost;
    private String baseType;
    private String baseAttackType;
    private double baseCooldown;

    // 공격 이펙트 파일명
    private String attackEffectFile;

    // 다음 강화 정보
    private int nextLevelCost;     // 다음 레벨업 비용
}