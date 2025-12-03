package com.team.dtd.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.UpdateTimestamp;
import java.io.Serializable;
import java.time.LocalDateTime;

@Entity
@Table(name = "user_inventory")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
public class UserInventory {

    @EmbeddedId
    private UserInventoryId id; // 복합키 클래스 사용

    @MapsId("userIdx") // UserInventoryId의 userIdx와 매핑
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_idx")
    private User user;

    @MapsId("itemIdx") // UserInventoryId의 itemIdx와 매핑
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "item_idx")
    private Item item;

    @Builder.Default
    private int quantity = 0;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    // --- 복합키 클래스 정의 (내부 클래스로 작성) ---
    @Embeddable
    @Getter
    @NoArgsConstructor
    @AllArgsConstructor
    @EqualsAndHashCode
    public static class UserInventoryId implements Serializable {
        private Long userIdx;
        private Integer itemIdx;
    }
}