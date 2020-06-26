<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Books</title>
</head>
<script>
    var isbn = `${isbn}`
    if (isbn) {
        alert("Book with " + isbn + " added successfully!");
    }
</script>

<body>
    <form action="addBook" method="GET">
        <input type="number" name="isbn" value="" placeholder="Enter ISBN" /><br /><br />
        <input type="text" name="bookName" value="" placeholder="Enter Book Name" /><br /><br />
        <input type="text" name="authorsName" value="" placeholder="Enter Authors Name seperated by comma" /><br /><br />
        <input type="number" name="price" id="price" value="" placeholder="Enter price" />
        <input type="number" name="quantity" id="quantity" value="" placeholder="Enter available quantity" />
        <input type="number" name="publishYear" id="publishYear" value="" placeholder="Enter Book Publish Year" />
        <input type="number" name="purchaseYear" id="purchaseYear" value="" placeholder="Enter Purchased Year" />
        <input type="submit" value="Submit" />
    </form>
</body>

</html>