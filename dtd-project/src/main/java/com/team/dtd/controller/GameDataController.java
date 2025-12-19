package com.team.dtd.controller;

import com.team.dtd.dto.TowerStatusResponseDto;
import com.team.dtd.entity.*;
import com.team.dtd.repository.ShopProductRepository;
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
    private final ShopProductRepository shopProductRepository;

    @GetMapping("/monsters")
    public ResponseEntity<List<Monster>> getMonsters() {
        return ResponseEntity.ok(gameDataService.getAllMonsters());
    }

    // 전체 스테이지 목록 조회
    @GetMapping("/stages")
    public ResponseEntity<List<Stage>> getStages() {
        return ResponseEntity.ok(gameDataService.getAllStages());
    }

    // 스테이지 단건 조회
    @GetMapping("/stages/{idx}")
    public ResponseEntity<Stage> getStage(@PathVariable Integer idx) {
        return ResponseEntity.ok(gameDataService.getStage(idx));
    }

    @GetMapping("/items")
    public ResponseEntity<List<Item>> getItems() {
        return ResponseEntity.ok(gameDataService.getAllItems());
    }

    @GetMapping("/towers")
    public ResponseEntity<List<TowerStatusResponseDto>> getTowers() {
        return ResponseEntity.ok(gameDataService.getTowersWithStats());
    }

    @GetMapping("/shop/products")
    public ResponseEntity<List<ShopProduct>> getShopProducts() {
        return ResponseEntity.ok(shopProductRepository.findAll());
    }
}