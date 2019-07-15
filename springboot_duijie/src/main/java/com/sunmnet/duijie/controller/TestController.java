package com.sunmnet.duijie.controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/test")
public class TestController {
    @RequestMapping("/sayHello")
   public String response(){
        return "hello";
    }
}
