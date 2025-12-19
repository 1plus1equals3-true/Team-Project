package com.team.dtd.repository;

import com.team.dtd.entity.User;
import com.team.dtd.entity.UserTower;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface UserTowerRepository extends JpaRepository<UserTower, Long> {
    // 유저의 모든 강화 기록 조회
    List<UserTower> findAllByUser(User user);

    // 특정 타워의 강화 기록 조회
    Optional<UserTower> findByUserAndTower_Idx(User user, Integer towerIdx);
}