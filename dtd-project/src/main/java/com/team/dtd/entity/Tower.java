package com.team.dtd.entity;

import com.team.dtd.enums.TowerAttackType;
import com.team.dtd.enums.TowerType;
import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;

@Entity
@Table(name = "towers")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
public class Tower {

    @Id
    private Integer idx; // 101, 102 등 기획 데이터이므로 자동생성 아님

    @Column(name = "tower_name", nullable = false, length = 50)
    private String towerName;

    @Column(name = "base_damage", nullable = false)
    private int baseDamage;

    @Column(name = "base_range", nullable = false)
    private int baseRange;

    @Column(name = "base_build_cost", nullable = false)
    private int baseBuildCost;

    @Enumerated(EnumType.STRING)
    @Column(name = "base_type", nullable = false)
    private TowerType baseType;

    @Enumerated(EnumType.STRING)
    @Column(name = "attack_type", nullable = false)
    private TowerAttackType attackType;

    @Column(name = "base_cooldown", nullable = false, precision = 5, scale = 2)
    private BigDecimal baseCooldown;

    @Column(name = "base_upgrade_cost", nullable = false)
    private int baseUpgradeCost;

    // 성장 계수
    @Column(name = "damage_growth", nullable = false)
    private double damageGrowth;

    @Column(name = "cost_growth", nullable = false)
    private double costGrowth;

    @Builder.Default
    private int tier = 1;

    @Column(columnDefinition = "TEXT")
    private String description;
}