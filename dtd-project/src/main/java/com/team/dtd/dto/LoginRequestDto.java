package com.team.dtd.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class LoginRequestDto {
    @NotBlank(message = "아이디를 입력해주세요.")
    private String userid;

    @NotBlank(message = "비밀번호를 입력해주세요.")
    private String pwd;
}