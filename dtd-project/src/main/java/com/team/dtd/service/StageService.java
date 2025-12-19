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
        String userid = SecurityUtil.getCurrentUserid();
        User user = userRepository.findByUserid(userid)
                .orElseThrow(() -> new RuntimeException("유저 정보가 없습니다."));

        Stage stage = stageRepository.findById(request.getStageIdx())
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 스테이지입니다."));

        UserStageClear userStageClear = userStageClearRepository.findByUserAndId_StageIdx(user, stage.getIdx())
                .orElse(null);

        boolean isFirstClear = (userStageClear == null || !userStageClear.isCleared());

        boolean isWin = request.isWin();

        int finalGold = 0;
        int finalExp = 0;
        List<Map<String, Object>> earnedItemsList = new ArrayList<>();

        try {
            if (stage.getRewardsJson() != null) {
                StageRewardDto baseReward = objectMapper.readValue(stage.getRewardsJson(), StageRewardDto.class);

                if (isWin) {
                    // 승리 시
                    if (isFirstClear) {
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
                        // 반복
                        finalGold = (int) (baseReward.getGold() * 0.75);
                        finalExp = (int) (baseReward.getExp() * 0.75);
                    }
                } else {
                    // 패배 시
                    if (request.getScore() >= 1000) {
                        double scoreRatio = Math.min(request.getScore() / 10000.0, 1.0);

                        double finalRatio = scoreRatio * 0.5;

                        finalGold = (int) (baseReward.getGold() * finalRatio);
                        finalExp = (int) (baseReward.getExp() * finalRatio);
                    } else {
                        finalGold = 0;
                        finalExp = 0;
                    }
                }
            }
        } catch (JsonProcessingException e) {
            throw new RuntimeException("보상 데이터 파싱 중 오류가 발생했습니다.", e);
        }

        if (finalGold > 0) user.addGold(finalGold);
        if (finalExp > 0) user.addExp(finalExp);

        if (userStageClear == null) {
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
            if (isWin && !userStageClear.isCleared()) {
                userStageClear.setCleared(true);
            }
            if (request.getScore() > userStageClear.getScore()) {
                userStageClear.setScore(request.getScore());
            }
        }

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