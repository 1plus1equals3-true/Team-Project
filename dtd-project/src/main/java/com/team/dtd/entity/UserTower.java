package com.team.dtd.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import java.time.LocalDateTime;

@Entity
@Table(name = "user_towers")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
public class UserTower {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long idx;

    // 외래키 관계 설정 (User)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_idx", nullable = false)
    private User user;

    // 외래키 관계 설정 (Tower)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "tower_idx", nullable = false)
    private Tower tower;

    // 레벨 : 데이터가 없으면 0, 있으면 1 이상
    @Builder.Default
    private int level = 0;

    public void levelUp() {
        this.level++;
    }
}