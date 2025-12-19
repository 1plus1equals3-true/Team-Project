package com.team.dtd.dto;

import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class BuyProductRequestDto {
    private Integer productIdx;
    // 실제 결제 연동 시 여기에 'receiptToken' 등의 검증용 필드
}