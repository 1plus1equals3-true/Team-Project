package com.team.dtd.enums;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public enum TowerAttackType {
    SINGLE("단일공격"),
    MULTI("다중공격"),
    SLOW("이동속도감소"),
    STUN("스턴"),
    DEFENSE_DOWN("방어력감소");

    private final String description;
}