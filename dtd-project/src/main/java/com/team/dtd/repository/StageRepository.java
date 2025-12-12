package com.team.dtd.repository;

import com.team.dtd.entity.Stage;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface StageRepository extends JpaRepository<Stage, Integer> {
    // 스테이지 번호 순서대로 조회
    List<Stage> findAllByOrderByIdxAsc();
}