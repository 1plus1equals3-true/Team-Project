package com.team.dtd.controller;

import com.team.dtd.dto.TowerStatusResponseDto;
import com.team.dtd.entity.Item;
import com.team.dtd.entity.Monster;
import com.team.dtd.entity.Stage;
import com.team.dtd.entity.Tower;
import com.team.dtd.service.GameDataService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class GameDataController {

    private final GameDataService gameDataService;

    @GetMapping("/monsters")
    public ResponseEntity<List<Monster>> getMonsters() {
        return ResponseEntity.ok(gameDataService.getAllMonsters());
    }

    // 전체 스테이지 목록 조회 (게임 로딩 시 사용 추천)
    @GetMapping("/stages")
    public ResponseEntity<List<Stage>> getStages() {
        return ResponseEntity.ok(gameDataService.getAllStages());
    }

    // 특정 스테이지 단건 조회 (필요 시 사용)
    // 사용법: GET /api/stages/1
    @GetMapping("/stages/{idx}")
    public ResponseEntity<Stage> getStage(@PathVariable Integer idx) {
        return ResponseEntity.ok(gameDataService.getStage(idx));
    }

    @GetMapping("/items")
    public ResponseEntity<List<Item>> getItems() {
        return ResponseEntity.ok(gameDataService.getAllItems());
    }

    // 타워 도감 API (전체 or 티어별)
    // GET /api/towers 또는 /api/towers?tier=1
    @GetMapping("/towers")
    public ResponseEntity<List<TowerStatusResponseDto>> getTowers() {
        // 이제 로그인한 유저의 강화 수치까지 계산해서 줍니다.
        return ResponseEntity.ok(gameDataService.getTowersWithStats());
    }


}