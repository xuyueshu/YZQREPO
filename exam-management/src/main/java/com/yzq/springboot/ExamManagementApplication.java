package com.yzq.springboot;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.transaction.annotation.EnableTransactionManagement;

@SpringBootApplication
@MapperScan("com.yzq.springboot.mapper")
@EnableTransactionManagement//该项目开启事务
public class ExamManagementApplication {

	public static void main(String[] args) {
		SpringApplication.run(ExamManagementApplication.class, args);
	}
}
