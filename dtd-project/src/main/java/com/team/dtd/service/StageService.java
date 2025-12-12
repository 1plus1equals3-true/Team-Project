package com.team.dtd.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.team.dtd.dto.StageClearRequestDto;
import com.team.dtd.dto.StageClearResponseDto;
import com.team.dtd.dto.StageRewardDto;
import com.team.dtd.entity.*;
import com.team.dtd.repository.*;
import com.team.dtd.util.SecurityUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class StageService {

    private final UserRepository userRepository;
    private final StageRepository stageRepository;
    private final UserStageClearRepository userStageClearRepository;
    private final ItemRepository itemRepository;
    private final UserInventoryRepository userInventoryRepository;
    private final ObjectMapper objectMapper;

    @Transactional
    public StageClearResponseDto clearStage(StageClearRequestDto request) {
        // 1. 유저 조회
        String userid = SecurityUtil.getCurrentUserid();
        User user = userRepository.findByUserid(userid)
                .orElseThrow(() -> new RuntimeException("유저 정보가 없습니다."));

        // 2. 스테이지 조회
        Stage stage = stageRepository.findById(request.getStageIdx())
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 스테이지입니다."));

        // 3. 기존 기록 조회
        UserStageClear userStageClear = userStageClearRepository.findByUserAndId_StageIdx(user, stage.getIdx())
                .orElse(null);

        // 최초 클리어 여부 판단
        boolean isFirstClear = (userStageClear == null || !userStageClear.isCleared());

        // 이번 요청이 승리인지 패배인지
        boolean isWin = request.isWin();

        // 4. 보상 계산
        int finalGold = 0;
        int finalExp = 0;
        List<Map<String, Object>> earnedItemsList = new ArrayList<>();

        try {
            if (stage.getRewardsJson() != null) {
                StageRewardDto baseReward = objectMapper.readValue(stage.getRewardsJson(), StageRewardDto.class);

                if (isWin) {
                    // === [승리 시] ===
                    if (isFirstClear) {
                        // 최초: 100% 지급 + 아이템 지급
                        finalGold = baseReward.getGold();
                        finalExp = baseReward.getExp();

                        if (baseReward.getItems() != null) {
                            for (StageRewardDto.RewardItem rewardItem : baseReward.getItems()) {
                                giveItemToUser(user, rewardItem.getItemId(), rewardItem.getCount());

                                Map<String, Object> itemMap = new HashMap<>();
                                itemMap.put("itemId", rewardItem.getItemId());
                                itemMap.put("count", rewardItem.getCount());
                                earnedItemsList.add(itemMap);
                            }
                        }
                    } else {
                        // 반복: 75% 지급, 아이템 제외
                        finalGold = (int) (baseReward.getGold() * 0.75);
                        finalExp = (int) (baseReward.getExp() * 0.75);
                    }
                } else {
                    // === [패배 시] ===
                    // 최소컷: 1000점(10%) 미만이면 보상 없음
                    if (request.getScore() >= 1000) {
                        // 1. 점수 비율 계산 (10000점 초과 시 1.0으로 제한)
                        double scoreRatio = Math.min(request.getScore() / 10000.0, 1.0);

                        // 2. 실패 패널티 적용 (점수 비율의 50%만 지급)
                        // 예: 10000점 -> 1.0 * 0.5 = 0.5 (50%)
                        // 예: 5000점  -> 0.5 * 0.5 = 0.25 (25%)
                        double finalRatio = scoreRatio * 0.5;

                        finalGold = (int) (baseReward.getGold() * finalRatio);
                        finalExp = (int) (baseReward.getExp() * finalRatio);
                    } else {
                        finalGold = 0;
                        finalExp = 0;
                    }
                    // 패배 시 아이템은 절대 지급 안 함
                }
            }
        } catch (JsonProcessingException e) {
            throw new RuntimeException("보상 데이터 파싱 중 오류가 발생했습니다.", e);
        }

        // 5. 유저 재화 지급
        if (finalGold > 0) user.addGold(finalGold);
        if (finalExp > 0) user.addExp(finalExp);

        // 6. 기록 저장 (DB 업데이트)
        if (userStageClear == null) {
            // 기록 생성
            UserStageClear.UserStageClearId id = new UserStageClear.UserStageClearId(user.getIdx(), stage.getIdx());
            userStageClear = UserStageClear.builder()
                    .id(id)
                    .user(user)
                    .stage(stage)
                    .isCleared(isWin)
                    .score(request.getScore())
                    .build();
            userStageClearRepository.save(userStageClear);
        } else {
            // 기록 갱신
            if (isWin && !userStageClear.isCleared()) {
                userStageClear.setCleared(true);
            }
            // 최고 점수 갱신
            if (request.getScore() > userStageClear.getScore()) {
                userStageClear.setScore(request.getScore());
            }
        }

        // 7. 응답 생성
        boolean isFirstClearAchieved = isFirstClear && isWin;

        return StageClearResponseDto.builder()
                .earnedGold(finalGold)
                .earnedExp(finalExp)
                .earnedItems(earnedItemsList)
                .isFirstClear(isFirstClearAchieved)
                .build();
    }

    private void giveItemToUser(User user, int itemId, int count) {
        Item item = itemRepository.findById(itemId)
                .orElseThrow(() -> new IllegalArgumentException("보상 아이템 정보가 존재하지 않습니다. ID: " + itemId));

        UserInventory.UserInventoryId invId = new UserInventory.UserInventoryId(user.getIdx(), item.getIdx());
        UserInventory inventory = userInventoryRepository.findById(invId).orElse(null);

        if (inventory != null) {
            inventory.addQuantity(count);
        } else {
            inventory = UserInventory.builder()
                    .id(invId)
                    .user(user)
                    .item(item)
                    .quantity(count)
                    .build();
            userInventoryRepository.save(inventory);
        }
    }
}