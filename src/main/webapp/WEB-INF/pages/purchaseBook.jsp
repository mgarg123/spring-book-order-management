<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Purchase Book</title>
    <script src="https://code.jquery.com/jquery-3.5.1.min.js" integrity="sha256-9/aliU8dGd2tb6OSsuzixeV4y/faTqgFtohetphbbj0=" crossorigin="anonymous"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    <style>
        .search-result {
            width: 100%;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
        }
        
        .result {
            margin: 10px auto;
            height: 130px;
            width: 200px;
            padding: 10px;
            background-color: aqua;
        }
        
        input[type="submit"] {
            margin: 8px 50px;
        }
        
        .search-bar {
            width: 57%;
            float: left;
            text-align: right;
        }
        
        .result i {
            padding: 10px;
            cursor: pointer;
        }
        
        input[name="orderQuantity"] {
            width: 30px;
            text-align: center;
        }
        
        .cart {
            text-align: right;
            position: relative;
            width: 43%;
            float: right;
            margin-right: 10px;
        }
        
        .filters {
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 25px 0px;
        }
        
        .range-slider {}
        
        .sort-result {}
        
        .fa-shopping-cart {
            font-size: 40px;
            color: #222;
            cursor: pointer;
        }
        
        #cart-quantity {
            border-radius: 25px;
            position: absolute;
            font-weight: bolder;
            font-size: 18px;
            color: rgb(126, 255, 255);
            right: 0;
            top: 5;
        }
    </style>
</head>

<body>
    <main>
        <div>
            <div class="search-and-cart">
                <div class="search-bar">
                    <input type="text" name="search-val" id="search-book" value="" placeholder="Search for books" />
                    <button onclick="callApi()">Search</button>
                </div>

                <div class="cart">
                    <div class="cart-icon">
                        <i class="fa fa-shopping-cart"></i>
                        <span id="cart-quantity">0</span>
                    </div>
                </div>
            </div>
            <div class="filters">
                <div class="range-slider">
                    <label for="price-range">Price Range:</label>
                    <input type="range" name="priceRange" value="5000" min="500" max="5000" step="500" id="price-range" value="" onchange="slider()" />
                    <span id="range-label">Rs. 0 - 5000</span>
                </div>
                <div class="sort-result">
                    <label for="sort-dropdown">Sort By:</label>
                    <select name="sortResult" id="sort-dropdown" onchange="sortBy()">
                        <option value="None">None</option>
                        <option value="PLtoH">Price:Low to High</option>
                        <option value="PHtoL">Price:High to Low</option>
                        <option value="ANtoO">Arrival:Newest to Oldest</option>
                        <option value="AOtoN">Arrival:Oldest to Newest</option>
                    </select>
                </div>
            </div>
            <div class="search-result">

            </div>
        </div>
    </main>
    <script>
        $(document).ready(function() {

            let sessionCart = JSON.parse(sessionStorage.getItem("lib_cart"))
            if (sessionCart != null) {
                let itemsInCart = sessionCart.length
                $("#cart-quantity").text(itemsInCart);
            }


            //Cart Checkout logic
            $(".fa-shopping-cart").click(function() {
                let cartQuantity = parseInt($("#cart-quantity").text())
                if (cartQuantity !== 0) {
                    window.location = "/checkout-page";
                }
            });

            $(".search-result").on('click', ".fa-minus-circle", function(event) {
                let selectedIsbn = event.target.parentElement.parentElement.id
                let selectedQuantity = parseInt($("#quant-no" + selectedIsbn).val())

                let currQuant = parseInt($("#quant-no" + selectedIsbn).val())
                if (currQuant !== 0)
                    $("#quant-no" + selectedIsbn).val(currQuant - 1)
            })

            $(".search-result").on('click', ".fa-plus-circle", function(event) {
                let selectedIsbn = event.target.parentElement.parentElement.id
                let selectedQuantity = parseInt($("#quant-no" + selectedIsbn).val())

                let currQuant = parseInt($("#quant-no" + selectedIsbn).val())
                $("#quant-no" + selectedIsbn).val(currQuant + 1)
            })

            $(".search-result").on('click', "#atoc", function(event) {

                let selectedIsbn = parseInt(event.target.parentElement.parentElement.id)
                let purchaseYear = parseInt(event.target.parentElement.previousElementSibling.previousElementSibling.textContent)
                let price = parseInt(event.target.parentElement.previousElementSibling.previousElementSibling.previousElementSibling.textContent)
                let bookName = event.target.parentElement.previousElementSibling.previousElementSibling.previousElementSibling.previousElementSibling.textContent
                let quant = parseInt($("#quant-no" + selectedIsbn).val())

                let sessionCart = JSON.parse(sessionStorage.getItem("lib_cart"))
                let isPresent = false
                if (sessionCart !== null) {
                    //Settting up Total Quauntities Selected


                    isPresent = sessionCart.find(x => x.isbn === selectedIsbn) ? true : false
                    if (isPresent) {
                        for (let i in sessionCart) {
                            if (sessionCart[i].isbn === selectedIsbn) {
                                sessionCart[i].quantity = quant
                            }
                        }
                        sessionStorage.setItem("lib_cart", JSON.stringify(sessionCart));

                    } else {
                        let obj = {
                            isbn: selectedIsbn,
                            quantity: quant,
                            bookName: bookName,
                            price: price,
                            purchaseYear: purchaseYear
                        }
                        sessionCart.push(obj)
                        sessionStorage.setItem("lib_cart", JSON.stringify(sessionCart));
                    }

                } else {
                    let obj = [{
                        isbn: selectedIsbn,
                        quantity: quant,
                        bookName: bookName,
                        price: price,
                        purchaseYear: purchaseYear
                    }]

                    sessionStorage.setItem("lib_cart", JSON.stringify(obj));

                }
                let sessCart = JSON.parse(sessionStorage.getItem("lib_cart"))
                let quantities = 0
                if (sessCart.length > 1) {
                    let quantArray = sessCart.map(x => x.quantity)
                    quantities = quantArray.reduce((x, y) => x + y)
                } else {
                    quantities = sessCart[0].quantity
                }

                $("#cart-quantity").text(quantities);
            });

            $.ajax({
                url: "/searchBook",
                success: function(data) {
                    $(".search-result").empty();
                    for (let i in data) {
                        let isbn = data[i].isbn
                        let bookName = data[i].bookName
                        let price = data[i].price
                        let purchasedYear = data[i].purchasedYear
                        $(".search-result").append("<div><input type='hidden' name='id' value='" + isbn + "' /><div class='result' id='" + isbn + "'" + "><div><span id='isbn'>" + isbn + "</span></div><div class='bookName'><span>" + bookName + "</span></div>" +
                            "<div class='price'><span>" + price + "</span></div><div class='purchYear'><span>" + purchasedYear + "</span></div>" +
                            "<div><label for='quant-no'>Quantity:</label><i class='fa fa-minus-circle'></i><input type='number' disabled value='0' min='0' name='orderQuantity' id='quant-no" + isbn + "' /><i class='fa fa-plus-circle'></i></div>" + "<div><input type='submit' id='atoc' value='Add to cart' /></div></div>");
                    }
                }
            });

        });

        function sortBy() {
            let priceRange = $("#price-range").val();
            let searchVal = $("#search-book").val();
            let sortType = $("#sort-dropdown").val();
            $.ajax({
                url: "/searchBook?value=" + searchVal + "&range=" + priceRange,
                success: function(data) {
                    console.log(data);
                    $(".search-result").empty();
                    let result = []
                    if (sortType === "PLtoH") {
                        result = data.sort((x, y) => x.price - y.price);
                    } else if (sortType === "PHtoL") {
                        result = data.sort((x, y) => y.price - x.price);
                    } else if (sortType === "AOtoN") {
                        result = data.sort((x, y) => x.purchasedYear - y.purchasedYear);
                    } else if (sortType === "ANtoO") {
                        result = data.sort((x, y) => y.purchasedYear - x.purchasedYear);
                    } else {
                        result = data
                    }
                    for (let i in result) {
                        let isbn = result[i].isbn
                        let bookName = result[i].bookName
                        let price = result[i].price
                        let purchasedYear = result[i].purchasedYear
                        $(".search-result").append("<input type='hidden' name='id' value='" + isbn + "' /><div class='result' id='" + isbn + "'" + "><div><span id='isbn'>" + isbn + "</span></div><div class='bookName'><span>" + bookName + "</span></div>" +
                            "<div class='price'><span>" + price + "</span></div><div class='purchYear'><span>" + purchasedYear + "</span></div>" +
                            "<div><label for='quant-no'>Quantity:</label><i class='fa fa-minus-circle'></i><input type='number' disabled value='' min='0' name='orderQuantity' id='quant-no" + isbn + "' /><i class='fa fa-plus-circle'></i></div>" + "<div><input type='submit' id='atoc' value='Add to cart' /></div></div>");
                    }
                }
            })

        }

        function slider() {
            let priceRange = $("#price-range").val();
            let searchVal = $("#search-book").val();
            let sortType = $("#sort-dropdown").val();
            $("#range-label").text("Rs. 0" + "- Rs. " + priceRange);
            $.ajax({
                url: "/searchBook?value=" + searchVal + "&range=" + priceRange,
                success: function(data) {
                    console.log(data);
                    let result = []
                    if (sortType === "PLtoH") {
                        result = data.sort((x, y) => x.price - y.price);
                    } else if (sortType === "PHtoL") {
                        result = data.sort((x, y) => y.price - x.price);
                    } else if (sortType === "AOtoN") {
                        result = data.sort((x, y) => x.purchasedYear - y.purchasedYear);
                    } else if (sortType === "ANtoO") {
                        result = data.sort((x, y) => y.purchasedYear - x.purchasedYear);
                    } else {
                        result = data
                    }
                    $(".search-result").empty();
                    for (let i in result) {
                        let isbn = result[i].isbn
                        let bookName = result[i].bookName
                        let price = result[i].price
                        let purchasedYear = result[i].purchasedYear
                        $(".search-result").append("<div><input type='hidden' name='id' value='" + isbn + "' /><div class='result' id='" + isbn + "'" + "><div><span id='isbn'>" + isbn + "</span></div><div class='bookName'><span>" + bookName + "</span></div>" +
                            "<div class='price'><span>" + price + "</span></div><div class='purchYear'><span>" + purchasedYear + "</span></div>" +
                            "<div><label for='quant-no'>Quantity:</label><i class='fa fa-minus-circle'></i><input type='number' disabled value='' min='0' name='orderQuantity' id='quant-no" + isbn + "' /><i class='fa fa-plus-circle'></i></div>" +
                            "<div><input type='submit' id='atoc' value='Add to cart' /></div></div>");
                    }
                }
            })
        }

        function callApi() {
            let sortType = $("#sort-dropdown").val();
            $.ajax({
                url: "/searchBook?value=" + $("#search-book").val() + "&range=" + $("#price-range").val(),
                success: function(data) {
                    console.log(data);
                    let result = []
                    if (sortType === "PLtoH") {
                        result = data.sort((x, y) => x.price - y.price);
                    } else if (sortType === "PHtoL") {
                        result = data.sort((x, y) => y.price - x.price);
                    } else if (sortType === "AOtoN") {
                        result = data.sort((x, y) => x.purchasedYear - y.purchasedYear);
                    } else if (sortType === "ANtoO") {
                        result = data.sort((x, y) => y.purchasedYear - x.purchasedYear);
                    } else {
                        result = data
                    }
                    $(".search-result").empty();
                    for (let i in result) {
                        let isbn = result[i].isbn
                        let bookName = result[i].bookName
                        let price = result[i].price
                        let purchasedYear = result[i].purchasedYear
                        $(".search-result").append("<div><input type='hidden' name='id' value='" + isbn + "' /><div class='result' id='" + isbn + "'" + "><div><span id='isbn'>" + isbn + "</span></div><div class='bookName'><span>" + bookName + "</span></div>" +
                            "<div class='price'><span>" + price + "</span></div><div class='purchYear'><span>" + purchasedYear + "</span></div>" +
                            "<div><label for='quant-no'>Quantity:</label><i class='fa fa-minus-circle'></i><input type='number' disabled value='' min='0' name='orderQuantity' id='quant-no" + isbn + "' /><i class='fa fa-plus-circle'></i></div>" + "<div><input type='submit' id='atoc' value='Add to cart' /></div></div>");
                    }
                }
            })
        }
    </script>
</body>

</html>