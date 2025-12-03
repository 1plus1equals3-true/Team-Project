package com.team.dtd.service;

import com.team.dtd.dto.LoginRequestDto;
import com.team.dtd.dto.RegisterRequestDto;
import com.team.dtd.entity.User;
import com.team.dtd.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    // 회원가입
    @Transactional
    public User register(RegisterRequestDto dto) {
        if (userRepository.existsByUserid(dto.getUserid())) {
            throw new RuntimeException("이미 존재하는 아이디입니다.");
        }
        if (userRepository.existsByUsername(dto.getUsername())) {
            throw new RuntimeException("이미 존재하는 닉네임입니다.");
        }

        User user = User.builder()
                .userid(dto.getUserid())
                .pwd(passwordEncoder.encode(dto.getPwd()))
                .username(dto.getUsername())
                .birth(dto.getBirth())
                .gold(0)
                .diamond(0)
                .build();

        return userRepository.save(user);
    }

    // 로그인
    @Transactional
    public User authenticate(LoginRequestDto dto) {
        User user = userRepository.findByUserid(dto.getUserid())
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 아이디입니다."));

        if (!passwordEncoder.matches(dto.getPwd(), user.getPwd())) {
            throw new IllegalArgumentException("비밀번호가 일치하지 않습니다.");
        }
        return user;
    }

    // 리프레시 토큰 DB업데이트
    @Transactional
    public void updateRefreshToken(Long userIdx, String refreshToken) {
        User user = userRepository.findById(userIdx)
                .orElseThrow(() -> new IllegalArgumentException("유저를 찾을 수 없습니다."));
        user.updateRefreshToken(refreshToken);
    }

    // 리프레시 토큰으로 유저 찾기
    @Transactional(readOnly = true)
    public Optional<User> findByRefreshToken(String refreshToken) {
        return userRepository.findByRefreshToken(refreshToken);
    }

    // 로그아웃 시 토큰 삭제 (null 처리)
    @Transactional
    public void deleteRefreshToken(String refreshToken) {
        userRepository.findByRefreshToken(refreshToken)
                .ifPresent(user -> user.updateRefreshToken(null));
    }
}