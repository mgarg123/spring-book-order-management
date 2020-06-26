package com.libmgmt.librarymgmt.model;

import java.util.ArrayList;
import java.util.List;

import javax.persistence.CascadeType;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.OneToMany;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@Entity
public class User {

    @Id
    private String username;

    private String firstName;

    private String lastName;

    private String password;

    private String roles;

    private boolean active;

    private String stripeUserId;

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL)
    private List<Order> orders = new ArrayList<>();

    public User(String username, String firstName, String lastName, String password, String roles, boolean active) {
        this.username = username;
        this.firstName = firstName;
        this.lastName = lastName;
        this.password = password;
        this.roles = roles;
        this.active = active;
    }

    public void addOrder(Order order) {
        this.orders.add(order);
        order.setUser(this);
    }

}