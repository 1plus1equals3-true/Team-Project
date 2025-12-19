package com.team.dtd.dto;

import com.team.dtd.entity.User;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class UserInfoResponseDto {
    private String username;
    private int gold;
    private int diamond;
    private int exp;

    private UserTowerResponseDto mainTower;

    public UserInfoResponseDto(User user) {
        this.username = user.getUsername();
        this.gold = user.getGold();
        this.diamond = user.getDiamond();
        this.exp = user.getExp();

        if (user.getMainTower() != null) {
            this.mainTower = new UserTowerResponseDto(user.getMainTower());
        }
    }
}