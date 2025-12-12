package com.team.dtd.repository;

import com.team.dtd.entity.User;
import com.team.dtd.entity.UserStageClear;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface UserStageClearRepository extends JpaRepository<UserStageClear, UserStageClear.UserStageClearId> {
    // 유저와 스테이지 ID로 기록 조회
    Optional<UserStageClear> findByUserAndId_StageIdx(User user, Integer stageIdx);
}