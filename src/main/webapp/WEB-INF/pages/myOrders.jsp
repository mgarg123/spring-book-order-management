<%@ page pageEncoding="UTF-8" isELIgnored="false" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>My Orders</title>
            <script src="https://code.jquery.com/jquery-3.5.1.min.js" integrity="sha256-9/aliU8dGd2tb6OSsuzixeV4y/faTqgFtohetphbbj0=" crossorigin="anonymous"></script>
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
            <style>
                .orders {
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    flex-wrap: wrap;
                }
                
                .order-container {
                    background: aqua;
                    color: black;
                    width: 300px;
                    margin: 5px;
                    padding: 10px;
                }
                
                .order-item-main {
                    display: flex;
                    justify-content: center;
                    flex-wrap:wrap;
                }
                
                .order-item-container {
                    background: lightgreen;
                    margin: 5px;
                    padding: 5px;
                }
                
                .order-cancel {
                    text-align: center;
                }
                
                .order-cancel button {
                    border: 1px solid skyblue;
                    outline: none;
                    width: 100px;
                    height: 30px;
                    background: rgb(100, 207, 145);
                }
                
                .order-cancel button:hover {
                    cursor: pointer;
                    background: rgb(28, 144, 240);
                    transition: background ease-in-out 0.3s;
                }
            </style>
        </head>

        <body>
            <h1>Hello ${user.getUsername()}</h1>
            <main>
                <div class="orders">
                    <c:forEach items="${user.getOrders()}" var="order">
                        <div class="order-container">
                            <div class="order-id">
                                <span>Order ID: ${order.getId()}</span>
                            </div>
                            <div class="order-status">
                                <span id="orderstat-${order.getId()}">Order status: ${order.getOrderStatus()}</span>
                            </div>
                            <div class="order-cancel">
                                <button id="order-${order.getId()}"
                                 style="display:${order.getOrderStatus().toLowerCase().equals("cancelled")?'none':'block'}">
                                 Cancel Order
                                 </button>
                            </div>
                            <div class="order-item-main">
                                <c:forEach items="${order.getOrderItems()}" var="orderItems">
                                    <div class="order-item-container">
                                        <div class="isbn">
                                            <span>ISBN: ${orderItems.getIsbn()}</span>
                                        </div>
                                        <div class="book-name">
                                            <span>Name: 
                                            ${books.stream().filter(b -> b.getIsbn()==orderItems.getIsbn()).findFirst().get().getBookName()}
                                        </span>
                                        </div>
                                        <div class="quantity">
                                            <span>Quantity: ${orderItems.getQuantity()}</span>
                                        </div>
                                        <div class="order-item-status">
                                            <span id="itemstat-${orderItems.getId()}">Item Status: ${orderItems.getItemStatus()?"Placed":"Cancelled"}</span>
                                        </div>
                                        <div class="order-cancel cancel-item" style="display:${orderItems.getItemStatus()?'block':'none'}">
                                            <button id="item-${orderItems.getId()}" data-order="${order.getId()}">Cancel Item
                                             </button>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </main>
            <script>
                $(document).ready(function() {


                    $("button").on('click', function(event) {
                        let elementId = event.target.id
                        let type = elementId.split("-")[0]
                        let id = elementId.split("-")[1]
                        let orderId = $(event.target).attr("data-order")

                        let csrfToken = ""
                        $.ajax({
                            url: "/my-orders",
                            method: "get",
                            success: function(data, textStatus, request) {
                                csrfToken += request.getResponseHeader("x-csrf-token")
                                console.log("token: " + csrfToken);
                                $.ajax({
                                    url: "/cancel-order",
                                    method: "post",
                                    headers: {
                                        "X-CSRF-TOKEN": csrfToken
                                    },
                                    data: {
                                        "type": type,
                                        "id": id,
                                        "orderId": orderId
                                    },
                                    success: function(data) {
                                        console.log(data);
                                        let orderStatusElement;
                                        let itemStatusElement;
                                        let orderStatus = data.split(",")[0].split(":")[1]
                                        let itemStatus = data.split(",")[1].split(":")[1]
                                        if (type === "item") {
                                            orderStatusElement = $(document).find("#orderstat-" + orderId);
                                            itemStatusElement = $(document).find("#itemstat-" + id);
                                            $(orderStatusElement).text(orderStatus);
                                            $(itemStatusElement).text(itemStatus);
                                            $(event.target).css("display", "none");
                                        } else {
                                            orderStatusElement = $(document).find("#orderstat-" + id);
                                            itemStatusElement = $(event.target.parentElement.parentElement).find(".order-item-status");
                                            //console.log(itemStatusElement);
                                            $(orderStatusElement).text("Cancelled");
                                            $(itemStatusElement).each(function(index, element) {
                                                $(element).text("Cancelled");
                                            });
                                            $("button").css("display", "none")
                                        }
                                        //console.log(orderStatusElement);
                                        //console.log(itemStatusElement);



                                    }
                                });

                            }
                        });

                    });
                });
            </script>
        </body>

        </html>