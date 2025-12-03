package com.team.dtd.entity;

import com.team.dtd.enums.ItemEffectType;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "items")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
public class Item {

    @Id
    private Integer idx;

    @Column(name = "item_name", nullable = false, length = 50)
    private String itemName;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Enumerated(EnumType.STRING)
    @Column(name = "effect_type", nullable = false)
    private ItemEffectType effectType;

    @Column(name = "effect_value", nullable = false)
    private int effectValue;
}