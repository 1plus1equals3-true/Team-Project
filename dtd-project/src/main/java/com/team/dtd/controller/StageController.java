package com.team.dtd.controller;

import com.team.dtd.dto.StageClearRequestDto;
import com.team.dtd.dto.StageClearResponseDto;
import com.team.dtd.service.StageService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/stages")
@RequiredArgsConstructor
public class StageController {

    private final StageService stageService;

    @PostMapping("/clear")
    public ResponseEntity<StageClearResponseDto> clearStage(@RequestBody StageClearRequestDto request) {
        return ResponseEntity.ok(stageService.clearStage(request));
    }
}