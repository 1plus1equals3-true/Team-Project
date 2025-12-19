package com.team.dtd.entity;

import com.team.dtd.enums.RewardType;
import com.team.dtd.enums.ShopProductType;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "shop_products")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
public class ShopProduct {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer idx;

    @Column(nullable = false, length = 50)
    private String name;

    @Column(nullable = false)
    private int price;

    @Enumerated(EnumType.STRING)
    @Column(name = "product_type", nullable = false)
    private ShopProductType productType;

    @Enumerated(EnumType.STRING)
    @Column(name = "reward_type", nullable = false)
    private RewardType rewardType;

    @Column(name = "reward_value", nullable = false)
    private int rewardValue;

    @Column(columnDefinition = "TEXT")
    private String description;
}