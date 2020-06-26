<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Book Details</title>
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
            height: 100px;
            width: 200px;
            padding: 10px;
            background-color: aqua;
        }
        
        .search-bar {
            display: flex;
            justify-content: center;
            align-items: center;
        }
        
        .result i {
            padding: 10px;
            cursor: pointer;
        }
    </style>
</head>

<body>
    <main>
        <div class="main-content">
            <div class="search-bar">
                <input type="text" value="" name="searchBook" id="search-book" placeholder="Enter book name or isbn or author to search" onkeydown="callApi()" />
            </div>
            <div class="search-result">

            </div>
        </div>
        <!-- <div>
            $(document).ready(function() {
            $(".search-result").on('click', '.fa-trash', function() {
            let isbn = $("#isbn").val();
            $.ajax({
            url: "/delete?isbn=" + isbn,
            success: function(data) {
            console.log(data);
            },
            statusCode: {
            200: function() {
            alert("hi");
            $("#" + isbn).css("display", "none");
            }
            }
            })
            })
            })
        </div> -->
    </main>
    <script>
        $(document).ready(function() {
            $(".search-result").on('click', ".fa-trash", function() {
                let confirmDelete = window.confirm("Are you sure you want to delete this book?")
                if (confirmDelete) {
                    $("#edit-form" + $("#id").val()).submit();
                }
            })
            $('#edit-form').submit()
        })

        function callApi() {
            $.ajax({
                url: "/searchBook?value=" + $("#search-book").val(),
                success: function(data) {
                    console.log(data);
                    $(".search-result").empty();
                    for (let i in data) {
                        let isbn = data[i].isbn
                        let bookName = data[i].bookName
                        let price = data[i].price
                        $(".search-result").append("<form id='edit-form" + isbn + "' action='/edit-books' method='get'><input type='hidden' name='id' value='" + isbn + "' /><div class='result' id='" + isbn + "'" + "><div><span id='isbn'>" + isbn + "</span></div><div><span>" + bookName + "</span></div>" +
                            "<div><span>" + price + "</span></div>" + "<div><a href='/update-book?isbn=" + isbn + "'><i class=\"fa fa-pencil\"></i></a><i class=\"fa fa-trash\"></i><div /></div></form>");
                    }
                }
            })
        }
    </script>
</body>

</html>