package com.libmgmt.librarymgmt.repository;

import java.util.List;

import com.libmgmt.librarymgmt.model.Book;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

@Repository
public interface BookRepo extends JpaRepository<Book, Integer> {
    @Query("select b from Book b where b.isbn like %?1%")
    List<Book> findByIsbn(Integer isbn);

    @Query("select b from Book b where b.isbn like %?1% AND b.price between 0 AND ?2")
    List<Book> findByIsbnWithPrice(Integer isbn, Integer price);

    @Query("select b from Book b where b.bookName like %?1%")
    public List<Book> findByBookName(String bookName);

    @Query("select b from Book b where b.bookName like %?1% AND b.price between 0 AND ?2")
    public List<Book> findByBookNameWithPrice(String bookName, Integer price);

    // @Query("select b from Book b where b.price between 0 AND ?1")
    // public List<Book> findByPrice(Integer price);
}