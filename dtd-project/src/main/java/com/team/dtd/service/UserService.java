package com.team.dtd.service;

import com.team.dtd.dto.*;
import com.team.dtd.entity.*;
import com.team.dtd.enums.PaymentType;
import com.team.dtd.repository.*;
import com.team.dtd.util.SecurityUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final UserTowerRepository userTowerRepository;
    private final UserInventoryRepository userInventoryRepository;
    private final TowerRepository towerRepository;
    private final ItemRepository itemRepository;

    @Transactional(readOnly = true)
    public UserInfoResponseDto getMyInfo() {
        String userid = SecurityUtil.getCurrentUserid();
        User user = userRepository.findByUserid(userid)
                .orElseThrow(() -> new RuntimeException("로그인 유저 정보가 없습니다."));
        return new UserInfoResponseDto(user);
    }

    // ❌ getMyTowers() 삭제됨 (GameDataService의 getTowersWithStats로 대체)

    @Transactional(readOnly = true)
    public List<UserInventoryResponseDto> getMyInventory() {
        String userid = SecurityUtil.getCurrentUserid();
        User user = userRepository.findByUserid(userid)
                .orElseThrow(() -> new RuntimeException("로그인 유저 정보가 없습니다."));

        List<UserInventory> inventory = userInventoryRepository.findAllByUserOrderById_ItemIdxAsc(user);

        return inventory.stream()
                .map(UserInventoryResponseDto::new)
                .collect(Collectors.toList());
    }

    // 상점 아이템 구매
    @Transactional
    public void buyItem(BuyItemRequestDto request) {
        // ... (기존 코드 유지)
        String userid = SecurityUtil.getCurrentUserid();
        User user = userRepository.findByUserid(userid)
                .orElseThrow(() -> new RuntimeException("유저 정보가 없습니다."));

        Item item = itemRepository.findById(request.getItemId())
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 아이템입니다."));

        int quantity = request.getQuantity();
        if (quantity <= 0) throw new IllegalArgumentException("1개 이상 구매해야 합니다.");

        if (request.getPaymentType() == PaymentType.GOLD) {
            int totalCost = item.getPriceGold() * quantity;
            user.deductGold(totalCost);
        } else if (request.getPaymentType() == PaymentType.DIAMOND) {
            int totalCost = item.getPriceDiamond() * quantity;
            user.deductDiamond(totalCost);
        }

        UserInventory.UserInventoryId inventoryId = new UserInventory.UserInventoryId(user.getIdx(), item.getIdx());
        UserInventory inventory = userInventoryRepository.findById(inventoryId).orElse(null);

        if (inventory != null) {
            inventory.addQuantity(quantity);
        } else {
            inventory = UserInventory.builder()
                    .id(inventoryId)
                    .user(user)
                    .item(item)
                    .quantity(quantity)
                    .build();
            userInventoryRepository.save(inventory);
        }
    }

    // 대표 타워 설정
    @Transactional
    public void setMainTower(SetMainTowerRequestDto request) {
        String userid = SecurityUtil.getCurrentUserid();
        User user = userRepository.findByUserid(userid)
                .orElseThrow(() -> new RuntimeException("유저 정보가 없습니다."));

        // ⚠️ 로직 변경: "보유 중인 타워"를 찾는 게 아니라 "강화 기록"을 찾지만,
        // 기획상 모든 타워를 소유하므로 TowerRepository에서 바로 찾아서 설정해도 무방합니다.
        // 다만, '강화된 상태(UserTower)'를 대표로 걸고 싶다면 UserTower가 있어야 합니다.
        // 0강인 상태에서도 대표로 걸고 싶다면 아래 로직을 수정해야 합니다.

        // 여기서는 "0강이라도 대표설정 가능"하게 하기 위해 UserTower를 조회하되, 없으면 0강으로 생성 후 설정하거나
        // 단순히 Tower ID만 User에 저장하는 방식도 고려해볼 만합니다.
        // 일단 기존 로직(UserTower 필수)을 유지하려면 "강화된 타워만 대표 가능"이 됩니다.

        // 수정 제안: UserTower를 찾고 없으면(0강이면) 새로 만들어서 대표로 설정
        UserTower targetTower = userTowerRepository.findByUserAndTower_Idx(user, request.getUserTowerIdx().intValue())
                .orElse(null);

        if (targetTower == null) {
            // 0강 타워를 대표로 설정하려는 경우 -> 0강 데이터 생성
            Tower tower = towerRepository.findById(request.getUserTowerIdx().intValue())
                    .orElseThrow(()->new IllegalArgumentException("존재하지 않는 타워"));
            targetTower = UserTower.builder().user(user).tower(tower).level(0).build();
            userTowerRepository.save(targetTower);
        }

        user.updateMainTower(targetTower);
    }

    // 타워 강화
    @Transactional
    public void enhanceTower(EnhanceTowerRequestDto request) {
        // ... (기존 코드 유지)
        String userid = SecurityUtil.getCurrentUserid();
        User user = userRepository.findByUserid(userid)
                .orElseThrow(() -> new RuntimeException("유저 정보 없음"));

        Tower tower = towerRepository.findById(request.getTowerIdx())
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 타워입니다."));

        UserTower userTower = userTowerRepository.findByUserAndTower_Idx(user, tower.getIdx())
                .orElse(null);

        int currentLevel = (userTower != null) ? userTower.getLevel() : 0;
        int cost = (int) (tower.getBaseUpgradeCost() * Math.pow(tower.getCostGrowth(), currentLevel));

        user.deductGold(cost);

        if (userTower == null) {
            userTower = UserTower.builder().user(user).tower(tower).level(1).build();
            userTowerRepository.save(userTower);
        } else {
            userTower.levelUp();
        }
    }
}