package com.team.dtd.repository;

import com.team.dtd.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {
    boolean existsByUserid(String userid);
    boolean existsByUsername(String username);

    // 로그인 시 유저 정보 조회용
    Optional<User> findByUserid(String userid);

    // 리프레시 토큰으로 유저 찾기
    Optional<User> findByRefreshToken(String refreshToken);
}