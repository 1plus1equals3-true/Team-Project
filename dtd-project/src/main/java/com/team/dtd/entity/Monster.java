package com.team.dtd.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;

@Entity
@Table(name = "monsters")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
public class Monster {

    @Id
    private Integer idx;

    @Column(nullable = false, length = 50)
    private String name;

    @Column(nullable = false)
    private int hp;

    @Column(nullable = false, precision = 5, scale = 2)
    private BigDecimal speed;

    @Builder.Default
    private int defense = 0;

    @Column(name = "reward_bit", nullable = false)
    private int rewardBit;

    @Column(nullable = false)
    private int damage;

    @Column(name = "image_file", nullable = false, length = 100)
    private String imageFile;

    @Column(columnDefinition = "TEXT")
    private String description;
}