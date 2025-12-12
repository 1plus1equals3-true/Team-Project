package com.team.dtd.repository;

import com.team.dtd.entity.Tower;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface TowerRepository extends JpaRepository<Tower, Integer> {
    // 전체 조회 (정렬)
    List<Tower> findAllByOrderByTierAscIdxAsc();

    // [추가] 등급별 조회
    List<Tower> findAllByTierOrderByIdxAsc(int tier);
}