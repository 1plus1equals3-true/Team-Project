package com.team.dtd.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import java.io.Serializable;
import java.time.LocalDateTime;

@Entity
@Table(name = "user_stage_clear")
@Getter
@Setter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
public class UserStageClear {

    @EmbeddedId
    private UserStageClearId id;

    @MapsId("userIdx")
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_idx")
    private User user;

    @MapsId("stageIdx")
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "stage_idx")
    private Stage stage;

    @Column(name = "is_cleared")
    @Builder.Default
    private boolean isCleared = false;

    @Builder.Default
    private int score = 0;

    @CreationTimestamp
    @Column(name = "cleared_at", updatable = false)
    private LocalDateTime clearedAt;

    // --- 복합키 클래스 정의 ---
    @Embeddable
    @Getter
    @NoArgsConstructor
    @AllArgsConstructor
    @EqualsAndHashCode
    public static class UserStageClearId implements Serializable {
        private Long userIdx;
        private Integer stageIdx;
    }
}