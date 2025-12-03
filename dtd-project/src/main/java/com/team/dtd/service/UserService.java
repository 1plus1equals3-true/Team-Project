package com.team.dtd.service;

import com.team.dtd.dto.UserInfoResponseDto;
import com.team.dtd.entity.User;
import com.team.dtd.repository.UserRepository;
import com.team.dtd.util.SecurityUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;

    @Transactional(readOnly = true)
    public UserInfoResponseDto getMyInfo() {
        // 1. 유틸을 통해 현재 로그인한 userid 가져오기
        String userid = SecurityUtil.getCurrentUserid();

        // 2. DB 조회
        User user = userRepository.findByUserid(userid)
                .orElseThrow(() -> new RuntimeException("로그인 유저 정보가 없습니다."));

        // 3. DTO로 변환해서 반환
        return new UserInfoResponseDto(user);
    }
}