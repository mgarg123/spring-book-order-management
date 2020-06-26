package com.libmgmt.librarymgmt.service;

import java.util.Optional;

import com.libmgmt.librarymgmt.model.MyUserDetails;
import com.libmgmt.librarymgmt.model.User;
import com.libmgmt.librarymgmt.repository.UserRepo;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
public class MyUserDetailsService implements UserDetailsService {

    @Autowired
    UserRepo userRepo;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        Optional<User> user = userRepo.findById(username);
        user.orElseThrow(() -> new UsernameNotFoundException("Invalid username " + username));
        return user.map(MyUserDetails::new).get();

    }

}