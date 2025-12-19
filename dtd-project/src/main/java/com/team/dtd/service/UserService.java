package com.team.dtd.service;

import com.team.dtd.dto.*;
import com.team.dtd.entity.*;
import com.team.dtd.enums.PaymentType;
import com.team.dtd.enums.RewardType;
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
    private final ShopProductRepository shopProductRepository;

    @Transactional(readOnly = true)
    public UserInfoResponseDto getMyInfo() {
        String userid = SecurityUtil.getCurrentUserid();
        User user = userRepository.findByUserid(userid)
                .orElseThrow(() -> new RuntimeException("로그인 유저 정보가 없습니다."));
        return new UserInfoResponseDto(user);
    }

    // ❌ getMyTowers() 삭제

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

    @Transactional
    public void buyItem(BuyItemRequestDto request) {
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

    @Transactional
    public void setMainTower(SetMainTowerRequestDto request) {
        String userid = SecurityUtil.getCurrentUserid();
        User user = userRepository.findByUserid(userid)
                .orElseThrow(() -> new RuntimeException("유저 정보가 없습니다."));

        UserTower targetTower = userTowerRepository.findByUserAndTower_Idx(user, request.getUserTowerIdx().intValue())
                .orElse(null);

        if (targetTower == null) {
            Tower tower = towerRepository.findById(request.getUserTowerIdx().intValue())
                    .orElseThrow(()->new IllegalArgumentException("존재하지 않는 타워"));
            targetTower = UserTower.builder().user(user).tower(tower).level(0).build();
            userTowerRepository.save(targetTower);
        }

        user.updateMainTower(targetTower);
    }

    @Transactional
    public void enhanceTower(EnhanceTowerRequestDto request) {
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

    @Transactional
    public void buyShopProduct(BuyProductRequestDto request) {
        String userid = SecurityUtil.getCurrentUserid();
        User user = userRepository.findByUserid(userid)
                .orElseThrow(() -> new RuntimeException("유저 정보가 없습니다."));

        ShopProduct product = shopProductRepository.findById(request.getProductIdx())
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 상품입니다."));

        // (실제 서비스라면 여기서 결제 검증 로직)

        if (product.getRewardType() == RewardType.DIAMOND) {
            user.addDiamond(product.getRewardValue());
        } else if (product.getRewardType() == RewardType.GOLD) {
            user.addGold(product.getRewardValue());
        }
    }
}