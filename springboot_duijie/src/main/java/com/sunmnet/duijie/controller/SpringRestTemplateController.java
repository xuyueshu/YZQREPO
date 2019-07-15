package com.sunmnet.duijie.controller;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.sunmnet.duijie.entity.BtcoinEntity;
import com.sunmnet.duijie.service.GetJson;
import org.json.JSONArray;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

import java.util.List;

//编写controller，调用第三方的API，浏览器模拟get请求，postman模拟post请求
@RestController
public class SpringRestTemplateController {
    @Autowired
    private RestTemplate restTemplate;
    /***********HTTP GET method*************/
    @GetMapping("/testGetApi")
    public String getJson(){
        String url="http://localhost:8089/o2o/getshopbyid?shopId=19";
        //String json =restTemplate.getForObject(url,Object.class);
        ResponseEntity<String> results = restTemplate.exchange(url, HttpMethod.GET, null, String.class);
        String json = results.getBody();
        return json;
    }

    /**********HTTP POST method**************/
    @PostMapping(value = "/testPost")
    public Object postJson(@RequestBody JSONObject param) {
        System.out.println(param.toJSONString());
        param.put("action", "post");
        param.put("username", "tester");
        param.put("pwd", "123456748");
        return param;
    }

    @PostMapping(value = "/testPostApi")
    public Object testPost() {
        String url = "http://localhost:8081/girl/testPost";
        JSONObject postData = new JSONObject();
        postData.put("descp", "request for post");
        JSONObject json = restTemplate.postForEntity(url, postData, JSONObject.class).getBody();
        return json;
    }

    public List<BtcoinEntity> getEntityList(){
        String url="https://api.psy.com.cn/school/member-test?";
        //访问获得json数据
        org.json.JSONObject dayLine = new GetJson().getHttpJson(url,1);
//        System.out.println(dayLine);
        //取得data的json数据
        JSONArray json=dayLine.getJSONArray("data");
        //将json数据转化为对象列表
        List<BtcoinEntity> list= JSON.parseArray(json.toString(),BtcoinEntity.class);
        return list;
    }

}
