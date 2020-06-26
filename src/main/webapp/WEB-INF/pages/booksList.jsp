<%@ page pageEncoding="UTF-8"%>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Books List</title>
            <style>
                * {
                    margin: 0;
                    padding: 0;
                    box-sizing: border-box;
                }
                
                .box-cont {
                    width: 100%;
                    height: 100vh;
                    display: flex;
                    flex-wrap: wrap;
                    justify-content: center;
                    align-items: center;
                }
                
                .box {
                    margin: 15px auto;
                    border: 1px solid green;
                }
            </style>
        </head>

        <body>
            <main>
                <div>Books List </div>
                <div class="box-cont">
                    <c:forEach items="${booksList}" var="book">
                        <div class="box">
                            <div class="isbn">
                                <span>${book.getIsbn()}</span>
                            </div>
                            <div class="book-name">
                                <span>${book.getBookName()}</span>
                            </div>
                            <div class="authors">
                                <span>${book.getAuthor().toString()}</span>
                            </div>
                            <div class="price">
                                <span>${book.getPrice()}</span>
                            </div>
                            <div class="publish-year">
                                <span>${book.getPublishedYear()}</span>
                            </div>
                            <div class="purchase-year">
                                <span>${book.getPurchasedYear()}</span>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </main>
        </body>

        </html>