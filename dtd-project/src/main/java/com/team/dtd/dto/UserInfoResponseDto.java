package com.team.dtd.dto;

import com.team.dtd.entity.User;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class UserInfoResponseDto {
    private String username; // 닉네임
    private int gold;
    private int diamond;

    // Entity -> DTO 변환 생성자
    public UserInfoResponseDto(User user) {
        this.username = user.getUsername();
        this.gold = user.getGold();
        this.diamond = user.getDiamond();
    }
}