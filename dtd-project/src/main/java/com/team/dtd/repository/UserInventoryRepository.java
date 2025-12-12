package com.team.dtd.repository;

import com.team.dtd.entity.User;
import com.team.dtd.entity.UserInventory;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface UserInventoryRepository extends JpaRepository<UserInventory, UserInventory.UserInventoryId> {
    List<UserInventory> findAllByUserOrderById_ItemIdxAsc(User user);
}