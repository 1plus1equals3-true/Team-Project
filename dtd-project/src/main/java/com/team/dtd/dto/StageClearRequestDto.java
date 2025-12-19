package com.team.dtd.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class StageClearRequestDto {
    private Integer stageIdx;
    private int score;

    @JsonProperty("isWin")
    private boolean isWin;
}