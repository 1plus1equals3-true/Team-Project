package com.team.dtd.util;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

public class SecurityUtil {

    private SecurityUtil() { }

    // 현재 로그인한 유저의 userid(String)를 반환
    public static String getCurrentUserid() {
        final Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        if (authentication == null || authentication.getName() == null) {
            throw new RuntimeException("Security Context에 인증 정보가 없습니다.");
        }

        // TokenProvider에서 subject에 userid를 넣었으므로, getName()이 userid입니다.
        return authentication.getName();
    }
}