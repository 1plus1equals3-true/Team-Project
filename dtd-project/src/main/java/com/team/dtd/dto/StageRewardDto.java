package com.team.dtd.dto;

import lombok.Getter;
import lombok.NoArgsConstructor;
import java.util.List;

@Getter
@NoArgsConstructor
public class StageRewardDto {
    private int gold;
    private int exp;
    private List<RewardItem> items;

    @Getter
    @NoArgsConstructor
    public static class RewardItem {
        private int itemId;
        private int count;
    }
}