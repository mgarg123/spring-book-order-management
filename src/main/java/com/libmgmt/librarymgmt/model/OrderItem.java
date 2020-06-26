package com.libmgmt.librarymgmt.model;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@Entity
public class OrderItem {

    @Id
    @GeneratedValue
    private Integer id;

    private Integer isbn;

    private Integer quantity;

    private boolean itemStatus;

    private String timestamp;

    public OrderItem(Integer isbn, Integer quantity, String timestamp, boolean itemStatus) {
        this.isbn = isbn;
        this.quantity = quantity;
        this.timestamp = timestamp;
        this.itemStatus = itemStatus;
    }

    public boolean getItemStatus() {
        return itemStatus;
    }

    public void setItemStatus(boolean itemStatus) {
        this.itemStatus = itemStatus;
    }

}