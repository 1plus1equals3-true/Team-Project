package com.team.dtd.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "users")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long idx;

    @Column(nullable = false, unique = true, length = 50)
    private String userid;

    @Column(nullable = false, unique = true, length = 50)
    private String username;

    @Column(nullable = false)
    private String pwd;

    private LocalDate birth;

    @Column(columnDefinition = "INT DEFAULT 0")
    @Builder.Default
    private int gold = 0;

    @Column(columnDefinition = "INT DEFAULT 0")
    @Builder.Default
    private int diamond = 0;

    @Column(columnDefinition = "INT DEFAULT 0")
    @Builder.Default
    private int exp = 0;

    @Column(length = 500)
    private String refreshToken;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "main_tower_idx")
    private UserTower mainTower;

    @CreationTimestamp
    @Column(updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    private LocalDateTime lastLogin;

    public void updateRefreshToken(String refreshToken) {
        this.refreshToken = refreshToken;
    }

    public void deductGold(int amount) {
        if (this.gold < amount) {
            throw new RuntimeException("골드가 부족합니다.");
        }
        this.gold -= amount;
    }

    public void addGold(int amount) {
        this.gold += amount;
    }

    public void deductDiamond(int amount) {
        if (this.diamond < amount) {
            throw new RuntimeException("다이아가 부족합니다.");
        }
        this.diamond -= amount;
    }

    public void addDiamond(int amount) {
        this.diamond += amount;
    }

    public void addExp(int amount) {
        this.exp += amount;
    }

    public void deductExp(int amount) {
        if (this.exp < amount) {
            throw new RuntimeException("경험치(진화 재료)가 부족합니다.");
        }
        this.exp -= amount;
    }

    public void updateMainTower(UserTower userTower) {
        this.mainTower = userTower;
    }
}