package com.team.dtd.dto;

import com.team.dtd.entity.Item;
import com.team.dtd.entity.UserInventory;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class UserInventoryResponseDto {
    private Integer itemIdx;
    private String itemName;
    private String description;
    private String effectType;
    private int effectValue;
    private int quantity;

    public UserInventoryResponseDto(UserInventory userInventory) {
        Item item = userInventory.getItem();
        this.itemIdx = item.getIdx();
        this.itemName = item.getItemName();
        this.description = item.getDescription();
        this.effectType = item.getEffectType().name();
        this.effectValue = item.getEffectValue();
        this.quantity = userInventory.getQuantity();
    }
}