package com.team.dtd.dto;

import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class SetMainTowerRequestDto {
    private Long userTowerIdx; // 내가 보유한 타워의 고유 ID (UserTower의 idx)
}