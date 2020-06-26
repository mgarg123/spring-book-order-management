package com.libmgmt.librarymgmt.model;

import java.util.ArrayList;
import java.util.List;

import javax.persistence.CascadeType;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.OneToMany;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Getter
@Setter
@NoArgsConstructor
public class Book {

    @Id
    private Integer isbn;

    private String bookName;

    private Integer price;

    private Integer quantity;

    private Integer publishedYear;

    private Integer purchasedYear;

    @OneToMany(cascade = CascadeType.ALL)
    @JoinColumn(name = "book_isbn")
    private List<Author> author = new ArrayList<>();

    public Book(Integer isbn, String bookName, Integer price, Integer quantity, Integer publishedYear,
            Integer purchasedYear) {
        this.isbn = isbn;
        this.bookName = bookName;
        this.price = price;
        this.quantity = quantity;
        this.publishedYear = publishedYear;
        this.purchasedYear = purchasedYear;
    }

}