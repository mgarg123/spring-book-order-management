package com.libmgmt.librarymgmt.repository;

import com.libmgmt.librarymgmt.model.Order;

import org.springframework.data.jpa.repository.JpaRepository;

public interface OrderRepo extends JpaRepository<Order, Integer> {

}