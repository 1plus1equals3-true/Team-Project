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
    private List<Map<String, Object>> earnedItems; // 획득한 아이템 목록
    private boolean isFirstClear; // 최초 클리어 여부 (UI 연출용)
}