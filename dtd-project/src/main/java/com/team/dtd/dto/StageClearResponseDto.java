package com.team.dtd.dto;

import lombok.Builder;
import lombok.Getter;

import java.util.List;
import java.util.Map;

@Getter
@Builder
public class StageClearResponseDto {
    private int earnedGold;
    private int earnedExp;
    private List<Map<String, Object>> earnedItems;
    private boolean isFirstClear;
}