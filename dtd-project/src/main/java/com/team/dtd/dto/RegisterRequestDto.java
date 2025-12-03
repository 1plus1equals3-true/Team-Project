package com.team.dtd.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;

import java.time.LocalDate;

@Getter
@NoArgsConstructor
public class RegisterRequestDto {

    @NotBlank(message = "아이디는 필수 입력 값입니다.")
    @Pattern(regexp = "^[a-zA-Z0-9]{5,15}$", message = "아이디는 영문/숫자 5~15자리여야 합니다.")
    private String userid;

    @NotBlank(message = "비밀번호는 필수 입력 값입니다.")
    // 정규식 설명: 숫자, 영문, 특수문자 포함 8~20자
    @Pattern(regexp = "(?=.*[0-9])(?=.*[a-zA-Z])(?=.*\\W)(?=\\S+$).{8,20}",
            message = "비밀번호는 8~20자이며, 영문, 숫자, 특수문자를 포함해야 합니다.")
    private String pwd;

    @NotBlank(message = "닉네임은 필수 입력 값입니다.")
    @Pattern(regexp = "^[가-힣a-zA-Z0-9]{2,10}$",
            message = "닉네임은 2자 이상 10자 이하이며, 한글, 영문, 숫자만 사용할 수 있습니다.")
    private String username;

    @DateTimeFormat(pattern = "yyyy-MM-dd")
    private LocalDate birth;
}