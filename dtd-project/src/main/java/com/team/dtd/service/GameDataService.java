package com.team.dtd.service;

import com.team.dtd.dto.TowerStatusResponseDto;
import com.team.dtd.entity.*;
import com.team.dtd.repository.*;
import com.team.dtd.util.SecurityUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class GameDataService {

    private final MonsterRepository monsterRepository;
    private final StageRepository stageRepository;
    private final ItemRepository itemRepository;
    private final TowerRepository towerRepository;
    private final UserTowerRepository userTowerRepository;
    private final UserRepository userRepository;

    @Transactional(readOnly = true)
    public List<Monster> getAllMonsters() {
        return monsterRepository.findAll();
    }

    @Transactional(readOnly = true)
    public List<Stage> getAllStages() {
        return stageRepository.findAllByOrderByIdxAsc();
    }

    @Transactional(readOnly = true)
    public Stage getStage(Integer stageIdx) {
        return stageRepository.findById(stageIdx)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 스테이지입니다: " + stageIdx));
    }

    @Transactional(readOnly = true)
    public List<Item> getAllItems() {
        return itemRepository.findAll();
    }

    // ⭐️ [핵심] 유저의 강화 상태를 반영한 전체 타워 리스트 조회
    // 로그인 상태가 아닐 경우(비회원) 0레벨 기준으로 보여주는 예외처리 추가
    @Transactional(readOnly = true)
    public List<TowerStatusResponseDto> getTowersWithStats() {
        User user = null;
        try {
            String userid = SecurityUtil.getCurrentUserid();
            user = userRepository.findByUserid(userid).orElse(null);
        } catch (Exception e) {
            // 비로그인 상태면 user는 null -> 모든 레벨 0으로 계산
        }

        // 1. 모든 타워 원본 가져오기
        List<Tower> allTowers = towerRepository.findAllByOrderByTierAscIdxAsc(); // 정렬 메서드 사용 권장

        // 2. 내 강화 기록 가져오기 (Map으로 변환: TowerID -> UserTower)
        Map<Integer, UserTower> myEnhanceMap;
        if (user != null) {
            myEnhanceMap = userTowerRepository.findAllByUser(user)
                    .stream()
                    .collect(Collectors.toMap(ut -> ut.getTower().getIdx(), ut -> ut));
        } else {
            myEnhanceMap = Map.of(); // 빈 맵
        }

        // 3. 계산해서 DTO로 변환
        return allTowers.stream().map(tower -> {
            // 강화 기록 없으면 0레벨
            UserTower userTower = myEnhanceMap.get(tower.getIdx());
            int currentLevel = (userTower != null) ? userTower.getLevel() : 0;

            // 🧮 공식 적용: 기본값 * (증가율 ^ 레벨)
            int finalDamage = (int) (tower.getBaseDamage() * Math.pow(tower.getDamageGrowth(), currentLevel));
            int nextUpgradeCost = (int) (tower.getBaseUpgradeCost() * Math.pow(tower.getCostGrowth(), currentLevel));

            return TowerStatusResponseDto.builder()
                    .towerIdx(tower.getIdx())
                    .towerName(tower.getTowerName())
                    .tier(tower.getTier())
                    .description(tower.getDescription())
                    .currentLevel(currentLevel)
                    .currentDamage(finalDamage)
                    .nextLevelCost(nextUpgradeCost)
                    .baseType(tower.getBaseType().name())
                    .baseRange(tower.getBaseRange())
                    .baseAttackType(tower.getAttackType().name())
                    .baseBuildCost(tower.getBaseBuildCost())
                    .baseCooldown(tower.getBaseCooldown().doubleValue())
                    .build();
        }).collect(Collectors.toList());
    }
}