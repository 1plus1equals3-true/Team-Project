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
    private int exp;

    // 대표 타워 정보 (null 가능)
    private UserTowerResponseDto mainTower;

    // Entity -> DTO 변환 생성자
    public UserInfoResponseDto(User user) {
        this.username = user.getUsername();
        this.gold = user.getGold();
        this.diamond = user.getDiamond();
        this.exp = user.getExp();

        // 유저가 대표 타워를 설정했으면 DTO로 변환해서 넣음
        if (user.getMainTower() != null) {
            this.mainTower = new UserTowerResponseDto(user.getMainTower());
        }
    }
}