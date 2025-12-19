package com.team.dtd.repository;

import com.team.dtd.entity.ShopProduct;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ShopProductRepository extends JpaRepository<ShopProduct, Integer> {
}