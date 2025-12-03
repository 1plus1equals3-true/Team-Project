package com.team.dtd.controller;

import com.team.dtd.dto.UserInfoResponseDto;
import com.team.dtd.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    // 내 정보 조회
    @GetMapping("/me")
    public ResponseEntity<UserInfoResponseDto> getMyInfo() {
        return ResponseEntity.ok(userService.getMyInfo());
    }
}