package org.boot.minichatproject;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;

@SpringBootApplication
@ComponentScan({"org.boot.minichatproject.*"})
public class MiniChatProjectApplication {
    
    public static void main(String[] args) {
        SpringApplication.run(MiniChatProjectApplication.class, args);
    }
    
}
