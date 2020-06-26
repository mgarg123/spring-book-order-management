<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Update Book</title>
</head>

<body>
    <main>
        <div>
            <form action="update-book" method="GET">
                <input type="text" name="isbn" value="${book.getIsbn()}" disabled /><br /><br />
                <input type="hidden" name="isbn" value="${book.getIsbn()}" />
                <input type="text" name="bookName" value="${book.getBookName()}" placeholder="Enter Book Name" /><br /><br />
                <input type="text" name="authorsName" value="${authors}" placeholder="Enter Author Name Seperated with comma (,)" /><br /><br />
                <input type="text" name="price" value="${book.getPrice()}" placeholder="Enter price" /><br /><br />
                <input type="text" name="quantity" value="${book.getQuantity()}" placeholder="Enter Quantity" /><br /><br />
                <input type="text" name="purchasedYear" value="${book.getPurchasedYear()}" placeholder="Enter Purchased Year" /><br /><br />
                <input type="text" name="publishedYear" value="${book.getPublishedYear()}" placeholder="Enter Published Year" /><br /><br />
                <input type="submit" value="Update" />
            </form>
        </div>
    </main>
</body>

</html>