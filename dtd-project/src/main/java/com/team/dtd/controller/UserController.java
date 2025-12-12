package com.team.dtd.controller;

import com.team.dtd.dto.*;
import com.team.dtd.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @GetMapping("/me")
    public ResponseEntity<UserInfoResponseDto> getMyInfo() {
        return ResponseEntity.ok(userService.getMyInfo());
    }

    // ❌ getMyTowers 삭제됨

    @GetMapping("/me/inventory")
    public ResponseEntity<List<UserInventoryResponseDto>> getMyInventory() {
        return ResponseEntity.ok(userService.getMyInventory());
    }

    // ❌ selectStarterTower 삭제됨 (모든 타워 소유 기획)

    @PostMapping("/me/shop/buy")
    public ResponseEntity<String> buyItem(@RequestBody BuyItemRequestDto request) {
        userService.buyItem(request);
        return ResponseEntity.ok("아이템 구매가 완료되었습니다.");
    }

    @PostMapping("/me/main-tower")
    public ResponseEntity<String> setMainTower(@RequestBody SetMainTowerRequestDto request) {
        userService.setMainTower(request);
        return ResponseEntity.ok("대표 타워가 설정되었습니다.");
    }

    @PostMapping("/me/enhance-tower")
    public ResponseEntity<String> enhanceTower(@RequestBody EnhanceTowerRequestDto request) {
        userService.enhanceTower(request);
        return ResponseEntity.ok("강화 성공!");
    }
}