package com.libmgmt.librarymgmt.model;

import java.util.ArrayList;
import java.util.List;

import javax.persistence.CascadeType;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.OneToMany;
import javax.persistence.Table;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonManagedReference;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "orders")
public class Order {

    @Id
    @GeneratedValue
    private Integer id;

    private String transactionId;

    private Integer totalAmount;

    private String shipmentAddress;

    private String timestamp;

    private String orderStatus;

    @OneToMany(cascade = CascadeType.ALL)
    @JoinColumn(name = "order_id")
    private List<OrderItem> orderItems = new ArrayList<>();

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_username")
    @JsonIgnore
    private User user;

    public Order(String transactionId, Integer totalAmount, String shipmentAddress, String orderStatus,
            String timestamp) {
        this.transactionId = transactionId;
        this.totalAmount = totalAmount;
        this.shipmentAddress = shipmentAddress;
        this.orderStatus = orderStatus;
        this.timestamp = timestamp;
    }

    @Override
    public String toString() {
        return "[" + id + ", " + transactionId + ", " + totalAmount + ", " + shipmentAddress + ", " + timestamp + ", "
                + orderStatus + "]";
    }

}