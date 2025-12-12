package com.team.dtd.dto;

import com.team.dtd.enums.PaymentType;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class BuyItemRequestDto {
    private Integer itemId;
    private int quantity;
    private PaymentType paymentType; // GOLD or DIAMOND
}