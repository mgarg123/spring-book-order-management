<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Checkout Page</title>
    <script src="https://code.jquery.com/jquery-3.5.1.min.js" integrity="sha256-9/aliU8dGd2tb6OSsuzixeV4y/faTqgFtohetphbbj0=" crossorigin="anonymous"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    <style>
        .result {
            margin: 10px auto;
            height: 130px;
            width: 200px;
            padding: 10px;
            background-color: aqua;
        }
        
        h1 {
            text-align: center;
        }
        
        .result i {
            padding: 10px;
            cursor: pointer;
        }
        
        input[name="orderQuantity"] {
            width: 30px;
            text-align: center;
        }
        
        .total-cart {
            display: flex;
            justify-content: center;
            align-items: center;
        }
        
        #total-title {
            font-size: 20px;
            font-weight: bold;
        }
        
        #total-price {
            font-size: 20px;
            font-weight: bold;
        }
        
        .checkout,
        .card-details,
        .address {
            display: flex;
            justify-content: center;
            align-items: center;
            margin: 10px;
        }
        
        #checkout-btn {
            width: 200px;
            height: 30px;
            font-weight: bold;
            border: 1px solid aqua;
            border-radius: 5px;
            background: transparent;
            cursor: pointer;
        }
        
        #checkout-btn:hover {
            background: aqua;
            transition: background 0.6s ease-in-out;
        }
    </style>
</head>

<body>

    <main>
        <h1>Items in your cart</h1>
        <div class="cart-container">
            <div class="cart-items">

            </div>
            <div class="total-cart">
                <span id="total-title">Total cart value: </span>
                <span id="total-price"></span>
            </div>
            <div class="address">
                <label for="address-input">Shipping Address: </label>
                <input type="text" name="address" value="" id="address-input" placeholder="Enter shipping address" required />
            </div>
            <!-- <div class="payment-options">
                <div class="title">
                    <span>Pay Through</span>
                </div>
                <div>
                    <label for="stripe">Stripe</label>
                    <input type="radio" name="pay-through" value="Stripe" id="stripe" />
                </div>
            </div> -->
            <div class="card-details">
                <form action="/charge" id="checkout-form" method="POST">
                    <input type="hidden" name="billingAddress" id="billing-address" value="" />
                    <input type="hidden" name="isbns" id="isbns" value="" />
                    <input type="hidden" name="totalAmount" id="total-amount" value="" />
                    <input type="hidden" name="orderQuantity" id="order-quantity" value="" />
                    <label for="cardholder-name">Name on Card: </label>
                    <input type="text" name="cardholderName" value="Test" id="cardholder-name" required /><br /><br />
                    <label for="card-no">Card Number: </label>
                    <input type="number" name="cardNo" id="card-no" value="4242424242424242" required /><br /><br />
                    <label for="expiry">Expiry: </label>
                    <input type="text" name="expiry" value="10/2023" id="expiry" required /><br /><br />
                    <label for="cvv">CVV: </label>
                    <input type="number" name="cvv" value="789" id="cvv" required/><br /><br />
                    <Button onclick="submitForm()" id="checkout-btn">Pay Now</Button>
                </form>
            </div>
            <!-- <div class="checkout">
                <button id="checkout-btn">Checkout Now</button>
            </div> -->
        </div>
    </main>

    <script>
        let sessionCart = JSON.parse(sessionStorage.getItem("lib_cart"))

        function submitForm() {
            event.preventDefault();
            let sessionCart = JSON.parse(sessionStorage.getItem("lib_cart"));
            console.log(sessionCart);
            let address = $("#address-input").val()
            let isbns = ""
            let quantities = ""
            let amounts = 0
            for (let i in sessionCart) {
                isbns += sessionCart[i].isbn + ","
                quantities += sessionCart[i].quantity + ","
                amounts += sessionCart[i].price * sessionCart[i].quantity
                console.log("isbn: " + isbns + ' quant: ' + quantities + ' amount:' + amounts);
            }
            $("#billing-address").val(address + "");
            $("#isbns").val(isbns + "");
            $("#total-amount").val(amounts + "");
            $("#order-quantity").val(quantities + "");
            console.log($("#checkout-form").serialize());
            let csrfToken = ""
            $.ajax({
                url: "/checkout-page",
                success: function(data, textStatus, request) {
                    csrfToken += request.getResponseHeader("x-csrf-token")
                    console.log("token: " + csrfToken);
                    $.ajax({
                        url: "/charge",
                        method: "POST",
                        headers: {
                            "X-CSRF-TOKEN": csrfToken
                        },
                        data: $("#checkout-form").serialize(),
                        success: function(data) {
                            console.log(data);
                            window.location = "/success?paymentID=" + data;
                        },
                        error: function(err) {
                            console.log(err);
                        }
                    });
                }
            });


        }

        $(window).on('load', function() {
            let sessionCart = JSON.parse(sessionStorage.getItem("lib_cart"))
            if (sessionCart === null) {
                window.location = "/buy-books"
            }
        })
        $(document).ready(function() {
            let sessionCart = JSON.parse(sessionStorage.getItem("lib_cart"))



            for (let i in sessionCart) {
                let isbn = sessionCart[i].isbn
                let bookName = sessionCart[i].bookName
                let price = sessionCart[i].price
                let quantity = sessionCart[i].quantity
                let purchasedYear = sessionCart[i].purchaseYear
                $(".cart-items").append("<div><input type='hidden' name='id' value='" + isbn + "' /><div class='result' id='" + isbn + "'" + "><div><span id='isbn'>" + isbn + "</span></div><div><span>" + bookName + "</span></div>" +
                    "<div><span>Rs. " + price + "</span></div>" +
                    "<div><label for='quant-no'>Quantity:</label><i class='fa fa-minus-circle'></i><input type='number' disabled value='" + quantity + "' min='0' name='orderQuantity' id='quant-no" + isbn + "' /><i class='fa fa-plus-circle'></i></div>" +
                    "<div id='trash-"+isbn+"'><i class='fa fa-trash'></i></div>"+ "</div>");

            }
            let totalValue = 0
            for (let i in sessionCart) {
                let quant = sessionCart[i].quantity
                let price = sessionCart[i].price
                totalValue += quant * price
            }
            $("#total-price").text("Rs. " + totalValue)

            $(".cart-items").on('click', ".fa-minus-circle", function(event) {
                let selectedIsbn = parseInt(event.target.parentElement.parentElement.id)
                let currQuant = parseInt($("#quant-no" + selectedIsbn).val())
                if (currQuant > 0) {
                    $("#quant-no" + selectedIsbn).val(currQuant - 1)
                    for (let i in sessionCart) {
                        if (sessionCart[i].isbn === selectedIsbn) {
                            sessionCart[i].quantity = currQuant - 1
                            sessionStorage.setItem("lib_cart", JSON.stringify(sessionCart));
                        }
                    }
                }
                let totalValue = 0
                for (let i in sessionCart) {
                    let quant = sessionCart[i].quantity
                    let price = sessionCart[i].price
                    totalValue += quant * price
                }
                $("#total-price").text("Rs. " + totalValue)

            });

            $(".cart-items").on('click', ".fa-plus-circle", function(event) {
                let selectedIsbn = parseInt(event.target.parentElement.parentElement.id)

                let currQuant = parseInt($("#quant-no" + selectedIsbn).val())
                $("#quant-no" + selectedIsbn).val(currQuant + 1)
                for (let i in sessionCart) {
                    if (sessionCart[i].isbn === selectedIsbn) {
                        sessionCart[i].quantity = currQuant + 1
                        sessionStorage.setItem("lib_cart", JSON.stringify(sessionCart));
                    }
                }
                let totalValue = 0
                for (let i in sessionCart) {
                    let quant = sessionCart[i].quantity
                    let price = sessionCart[i].price
                    totalValue += quant * price
                }
                $("#total-price").text("Rs. " + totalValue)
            });

            $(".cart-items").on('click',".fa-trash",function(event){
                let selectedIsbn = parseInt(event.target.parentElement.parentElement.id)
                let sessionCart = JSON.parse(sessionStorage.getItem("lib_cart"));
                let newSessionCart = sessionCart.filter(x => x.isbn!==selectedIsbn);
                sessionStorage.setItem("lib_cart",newSessionCart);
                 $(".cart-items").empty();
                 for (let i in newSessionCart) {
                let isbn = newSessionCart[i].isbn
                let bookName = newSessionCart[i].bookName
                let price = newSessionCart[i].price
                let quantity = newSessionCart[i].quantity
                let purchasedYear = newSessionCart[i].purchaseYear
                $(".cart-items").append("<div><input type='hidden' name='id' value='" + isbn + "' /><div class='result' id='" + isbn + "'" + "><div><span id='isbn'>" + isbn + "</span></div><div><span>" + bookName + "</span></div>" +
                    "<div><span>Rs. " + price + "</span></div>" +
                    "<div><label for='quant-no'>Quantity:</label><i class='fa fa-minus-circle'></i><input type='number' disabled value='" + quantity + "' min='0' name='orderQuantity' id='quant-no" + isbn + "' /><i class='fa fa-plus-circle'></i></div>" +
                    "<div id='trash-"+isbn+"'><i class='fa fa-trash'></i></div>"+ "</div>");

            }

                
            });
        });
    </script>
</body>

</html>