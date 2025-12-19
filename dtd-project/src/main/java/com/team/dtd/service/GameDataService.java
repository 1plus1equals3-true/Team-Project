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

    @Transactional(readOnly = true)
    public List<TowerStatusResponseDto> getTowersWithStats() {
        User user = null;
        try {
            String userid = SecurityUtil.getCurrentUserid();
            user = userRepository.findByUserid(userid).orElse(null);
        } catch (Exception e) {
            // 비로그인 상태면 모든 레벨 0
        }

        List<Tower> allTowers = towerRepository.findAllByOrderByTierAscIdxAsc();

        Map<Integer, UserTower> myEnhanceMap;
        if (user != null) {
            myEnhanceMap = userTowerRepository.findAllByUser(user)
                    .stream()
                    .collect(Collectors.toMap(ut -> ut.getTower().getIdx(), ut -> ut));
        } else {
            myEnhanceMap = Map.of();
        }

        return allTowers.stream().map(tower -> {
            // 강화 기록 없으면 0레벨
            UserTower userTower = myEnhanceMap.get(tower.getIdx());
            int currentLevel = (userTower != null) ? userTower.getLevel() : 0;

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
                    .attackEffectFile(tower.getAttackEffectFile())
                    .build();
        }).collect(Collectors.toList());
    }
}