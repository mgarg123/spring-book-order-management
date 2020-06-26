package com.libmgmt.librarymgmt.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.security.Principal;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.libmgmt.librarymgmt.model.Order;
import com.libmgmt.librarymgmt.model.OrderItem;
import com.libmgmt.librarymgmt.model.User;
import com.libmgmt.librarymgmt.repository.BookRepo;
import com.libmgmt.librarymgmt.repository.UserRepo;
import com.libmgmt.librarymgmt.service.StripeService;
import com.stripe.Stripe;
import com.stripe.exception.StripeException;
import com.stripe.model.Card;
import com.stripe.model.CardCollection;
import com.stripe.model.Charge;
import com.stripe.model.Customer;
import com.stripe.model.ExternalAccountCollection;
import com.stripe.model.PaymentSource;
import com.stripe.model.PaymentSourceCollection;
import com.stripe.model.Token;

@Controller
public class PaymentController {

    @Value("${stripe.keys.public}")
    private String API_PUBLIC_KEY;

    @Value("${stripe.keys.secret}")
    private String API_SECRET_KEY;

    @Autowired
    private BookRepo bookRepo;

    @Autowired
    private UserRepo userRepo;

    @Autowired
    private StripeService stripeService;

    @PostMapping("/charge")
    public ResponseEntity<?> chargeCard(String billingAddress, Integer totalAmount, String orderQuantity, String isbns,
            String cardholderName, String cardNo, String expiry, Integer cvv, Authentication authentication,
            Model model) throws StripeException {
        System.out.println("inside charge");
        Stripe.apiKey = API_SECRET_KEY;
        String isbn = isbns.substring(0, isbns.length() - 1);
        String quant = orderQuantity.substring(0, orderQuantity.length() - 1);
        String[] isbnAll = isbn.split(",");
        String[] orderQuant = quant.split(",");
        Map<Integer, Integer> map = new HashMap<>();
        for (int i = 0; i < isbnAll.length; i++) {
            map.put(Integer.parseInt(isbnAll[i]), Integer.parseInt(orderQuant[i]));
        }
        int verifyTotalAmount = 0;
        for (Integer keys : map.keySet()) {
            int thisPrice = bookRepo.findById(keys).get().getPrice();
            int thisQuant = map.get(keys);
            verifyTotalAmount += thisPrice * thisQuant;
        }
        System.out.println("verifiedAmount: " + verifyTotalAmount);

        String chargeId = null;
        User currentUserDetail = userRepo.findById(authentication.getName()).get();
        if (totalAmount == verifyTotalAmount) {
            Integer amountToPay = totalAmount * 100;
            Customer cust = null;
            if (currentUserDetail.getStripeUserId() == null) {
                Map<String, Object> customerParam = new HashMap<>();
                customerParam.put("email", currentUserDetail.getUsername() + "@gmail.com");
                Customer customer = Customer.create(customerParam);
                currentUserDetail.setStripeUserId(customer.getId());
                userRepo.save(currentUserDetail);
                System.out.println(currentUserDetail.getStripeUserId());
            } else {
                cust = Customer.retrieve(currentUserDetail.getStripeUserId());
            }
            Map<String, Object> cardParams = new HashMap<>();
            cardParams.put("number", cardNo);
            cardParams.put("exp_month", expiry.split("/")[0]);
            cardParams.put("exp_year", expiry.split("/")[1]);
            cardParams.put("cvc", cvv);
            cardParams.put("name", cardholderName);
            cardParams.put("address_line1", billingAddress);
            cardParams.put("address_line2", billingAddress);
            cardParams.put("address_city", "Ranchi");
            cardParams.put("address_state", "Jharkhand");
            cardParams.put("address_country", "India");
            cardParams.put("address_zip", "834001");
            Map<String, Object> tokenParams = new HashMap<>();
            tokenParams.put("card", cardParams);
            System.out.println("here1 " + tokenParams.get("card"));
            Token token = Token.create(tokenParams);

            // Add card if not exists
            boolean doCardExist = false;
            Map<String, Object> addCardParam = new HashMap<>();
            addCardParam.put("source", token.getId());

            // Retrieving card
            Map<String, Object> cardListParam = new HashMap<>();
            cardListParam.put("object", "card");

            PaymentSourceCollection allCards = cust.getSources().list(cardListParam);
            Card cardToCharge = null;
            Card addedCard = null;
            // Retrieving list of cards and matching the fingerprint with entered card to
            // determine if card exist or not and which
            // card to charge
            for (int i = 0; i < allCards.getData().size(); i++) {
                Card card = (Card) allCards.getData().get(i);
                System.out.println("FingerPrint of card " + i + ": " + card.getFingerprint());
                System.out.println("FingerPrint of newCard " + ": " + token.getCard().getFingerprint());
                if (card.getFingerprint().equals(token.getCard().getFingerprint())) {
                    System.out.println(card.getLast4() + " " + token.getCard().getLast4());
                    doCardExist = true;
                    // If card exists then charge the below card
                    cardToCharge = (Card) allCards.getData().get(i);
                    break;
                } else {
                    doCardExist = false;
                }
            }
            // System.out.println("Card Exist?: " + doCardExist);
            // Add the card if not exist
            if (!doCardExist) {
                addedCard = (Card) cust.getSources().create(addCardParam);
            }

            System.out.println(token.toJson());
            System.out.println(authentication.getName() + " " + token.getId() + " " + amountToPay);
            try {
                chargeId = stripeService.createCharge(authentication.getName(), amountToPay,
                        addedCard != null ? addedCard.getId() : cardToCharge.getId(), cust.getId());
                Order order = new Order(chargeId, totalAmount, billingAddress, "Success", new Date().toString());
                for (Integer keys : map.keySet()) {
                    OrderItem orderItem = new OrderItem(keys, map.get(keys), new Date().toString(), true);
                    order.getOrderItems().add(orderItem);
                }
                currentUserDetail.addOrder(order);
                System.out.println(currentUserDetail.getOrders().toString());
                userRepo.save(currentUserDetail);
            } catch (Exception e) {
                System.out.println("Oops! Some Error Occured.");
            }

            System.out.println("Charged successfully with id:" + chargeId);
            System.out.println("Charged : Rs. " + totalAmount);
        }

        return new ResponseEntity<>(chargeId, HttpStatus.OK);

    }

    @GetMapping("/success")
    public String paymentSuccess(String paymentID, Model model) {
        model.addAttribute("chargeId", paymentID);
        System.out.println("Inside Success!");
        return "success";
    }

}