package com.libmgmt.librarymgmt.controller;

import java.security.Principal;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Optional;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.libmgmt.librarymgmt.model.Author;
import com.libmgmt.librarymgmt.model.Book;
import com.libmgmt.librarymgmt.model.Order;
import com.libmgmt.librarymgmt.model.OrderItem;
import com.libmgmt.librarymgmt.model.User;
import com.libmgmt.librarymgmt.repository.BookRepo;
import com.libmgmt.librarymgmt.repository.OrderRepo;
import com.libmgmt.librarymgmt.repository.UserRepo;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.csrf.CsrfToken;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
public class MainController {

    @Autowired
    BookRepo bookRepo;

    @Autowired
    UserRepo userRepo;

    @Autowired
    OrderRepo orderRepo;

    @Autowired
    PasswordEncoder passwordEncoder;

    // Authentication auth = SecurityContextHolder.getContext().getAuthentication();

    @GetMapping("/addBook")
    public String addCourse(Model model, @RequestParam("isbn") Integer isbn, @RequestParam("bookName") String bookName,
            @RequestParam("authorsName") String authorsName, Integer price, Integer quantity, Integer publishYear,
            Integer purchaseYear, HttpServletRequest request, HttpServletResponse response) {
        String authors[] = authorsName.split(",");
        Book book = new Book(isbn, bookName, price, quantity, publishYear, purchaseYear);
        ArrayList<Author> authorList = new ArrayList<>();
        for (String s : authors) {
            authorList.add(new Author(s));
        }
        for (int i = 0; i < authorList.size(); i++) {
            book.getAuthor().add(authorList.get(i));
        }
        bookRepo.save(book);
        model.addAttribute("isbn", isbn);
        CsrfToken csrfToken = (CsrfToken) request.getAttribute("_csrf");

        response.setHeader("X-CSRF-HEADER", csrfToken.getHeaderName());
        // Spring Security will allow the token to be included in this parameter name
        response.setHeader("X-CSRF-PARAM", csrfToken.getParameterName());
        // this is the value of the token to be included as either a header or an HTTP
        // parameter
        response.setHeader("X-CSRF-TOKEN", csrfToken.getToken());
        return "addBook";
    }

    @GetMapping("/")
    public String home(Authentication authentication, Model model) {
        model.addAttribute("name", authentication.getName());
        return "index";
    }

    @GetMapping("/add-book")
    public String addBookView() {
        return "addBook";
    }

    @GetMapping("/view-books")
    public String getAllBooks(Model model) {
        List<Book> booksList = bookRepo.findAll();
        model.addAttribute("booksList", booksList);
        return "booksList";
    }

    @GetMapping(value = "/edit-books")
    public String editBooksPage(@RequestParam(value = "id", required = false) Integer isbn) {
        if (isbn != null) {
            if (bookRepo.existsById(isbn)) {
                bookRepo.deleteById(isbn);
            }
        }
        return "editBooks";
    }

    @GetMapping("/searchBook")
    @ResponseBody
    public ResponseEntity<?> searchBook(@RequestParam(value = "value", required = false) String value,
            @RequestParam(value = "range", required = false) Integer price) {
        Integer isbn = 0;
        List<Book> books = null;
        if (value == null || value.trim().length() == 0) {
            books = bookRepo.findAll();
        } else {
            try {
                isbn = Integer.parseInt(value);
                if (price != null) {
                    books = bookRepo.findByIsbnWithPrice(isbn, price);
                } else {
                    books = bookRepo.findByIsbn(isbn);
                }

            } catch (NumberFormatException ex) {
                if (price != null) {
                    books = bookRepo.findByBookNameWithPrice(value, price);
                } else {
                    books = bookRepo.findByBookName(value);
                }
            }

        }

        return new ResponseEntity<List<Book>>(books, HttpStatus.OK);

    }

    @GetMapping("/update-book")
    public String updateBook(Integer isbn, String bookName, String authorsName, Integer price, Integer quantity,
            Integer purchasedYear, Integer publishedYear, Model model) {
        Book book = bookRepo.findById(isbn).get();

        if (bookName != null) {
            book.setBookName(bookName);
        }
        if (price != null)
            book.setPrice(price);
        if (quantity != null)
            book.setQuantity(quantity);
        if (purchasedYear != null)
            book.setPurchasedYear(purchasedYear);
        if (publishedYear != null)
            book.setPublishedYear(publishedYear);
        if (authorsName != null) {
            String authors[] = authorsName.split(",");
            ArrayList<Author> authorList = new ArrayList<>();
            for (String s : authors) {
                authorList.add(new Author(s));
            }
            for (int i = 0; i < authorList.size(); i++) {
                book.getAuthor().add(authorList.get(i));
            }
        }
        String authorsList = "";
        for (Author auth : book.getAuthor()) {
            authorsList += auth.getAuthorName() + ",";
        }
        model.addAttribute("book", book);
        model.addAttribute("authors", authorsList);

        bookRepo.save(book);
        return "updateBook";
    }

    @GetMapping("/buy-books")
    public String buyBooks() {
        return "purchaseBook";
    }

    @GetMapping("/checkout-page")
    public String checkoutPage(HttpServletRequest request, HttpServletResponse response) {
        CsrfToken csrfToken = (CsrfToken) request.getAttribute("_csrf");

        response.setHeader("X-CSRF-HEADER", csrfToken.getHeaderName());
        // Spring Security will allow the token to be included in this parameter name
        response.setHeader("X-CSRF-PARAM", csrfToken.getParameterName());
        // this is the value of the token to be included as either a header or an HTTP
        // parameter
        response.setHeader("X-CSRF-TOKEN", csrfToken.getToken());
        return "checkoutPage";
    }

    // @GetMapping("/test")
    // @ResponseBody
    // public String test() {
    // User user = new User("test", "Mani", "Garg", passwordEncoder.encode("test"),
    // "USER", true);
    // // Order order = new Order("txn12345", 1000, "Pink Villa", true, new
    // Date().toString());
    // // OrderItem item1 = new OrderItem(90001, new Date().toString(), true);
    // // OrderItem item2 = new OrderItem(90002, new Date().toString(), true);
    // user.addOrder(order);
    // order.getOrderItems().add(item1);
    // order.getOrderItems().add(item2);

    // userRepo.save(user);
    // return "Done";
    // }

    // @GetMapping("/tests")
    // @ResponseBody
    // public List<User> getDet(Authentication authentication) {
    // UserDetails userDetails = (UserDetails) authentication.getPrincipal();
    // System.out.println("Username is: " + userDetails.getUsername());
    // return userRepo.findAll();
    // }

    @GetMapping("/my-orders")
    public String myOrders(Model model, Authentication auth, HttpServletRequest request, HttpServletResponse response) {
        CsrfToken csrfToken = (CsrfToken) request.getAttribute("_csrf");

        response.setHeader("X-CSRF-HEADER", csrfToken.getHeaderName());
        // Spring Security will allow the token to be included in this parameter name
        response.setHeader("X-CSRF-PARAM", csrfToken.getParameterName());
        // this is the value of the token to be included as either a header or an HTTP
        // parameter
        response.setHeader("X-CSRF-TOKEN", csrfToken.getToken());
        User user = userRepo.findById(auth.getName()).get();
        model.addAttribute("user", user);
        List<Book> bookList = new ArrayList<>();
        for (Order o : user.getOrders()) {
            for (OrderItem oi : o.getOrderItems()) {
                bookList.add(bookRepo.findById(oi.getIsbn()).get());
            }
        }
        model.addAttribute("bookRepo", user);
        model.addAttribute("books", bookList);
        // System.out.println(bookList.stream().filter(b -> b.getIsbn() ==
        // 90002).findFirst().get().getBookName());

        return "myOrders";
    }

    @PostMapping("/cancel-order")
    public ResponseEntity<?> cancelOrder(String type, Integer id, Integer orderId) {
        Order order;
        if (orderId != null) {
            order = orderRepo.findById(orderId).get();
        } else {
            order = orderRepo.findById(id).get();
        }

        boolean itemStatus = true;
        String orderStatus = "success";
        if (type.equals("order")) {
            order.setOrderStatus("Cancelled");
            for (OrderItem oItem : order.getOrderItems()) {
                oItem.setItemStatus(false);
            }
            orderRepo.save(order);
            return new ResponseEntity<>("orderStatus:" + "Cancelled" + ",itemStatus:" + "Cancelled", HttpStatus.OK);
        } else {
            int trueCount = 0;
            int falseCount = 0;
            for (OrderItem oi : order.getOrderItems()) {
                if (oi.getId() == id) {
                    oi.setItemStatus(false);
                    itemStatus = oi.getItemStatus();
                }
                if (oi.getItemStatus() == true) {
                    trueCount++;
                } else {
                    falseCount++;
                }

            }
            if (trueCount > 0 && falseCount > 0) {
                order.setOrderStatus("Partially Cancelled");
                orderStatus = "Partially Cancelled";
            } else if (trueCount == 0) {
                order.setOrderStatus("Cancelled");
                orderStatus = "Cancelled";
            }
            orderRepo.save(order);
            if (!itemStatus) {
                return new ResponseEntity<>("orderStatus:" + orderStatus + ",itemStatus:" + "Cancelled", HttpStatus.OK);
            } else {
                return new ResponseEntity<>("orderStatus:" + orderStatus + ",itemStatus:" + "Cancelled", HttpStatus.OK);
            }

        }

    }
}