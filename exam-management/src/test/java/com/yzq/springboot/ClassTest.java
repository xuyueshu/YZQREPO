package com.yzq.springboot;

import java.util.List;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import com.yzq.springboot.bean.Clazz;
import com.yzq.springboot.service.IClazzService;

@RunWith(SpringJUnit4ClassRunner.class)
@SpringBootTest(classes=ExamManagementApplication.class)
public class ClassTest {
	@Autowired
	private IClazzService classService;
	
	@Test
	public void classTest() {
		List<Clazz> list=classService.getClassListByTeacherId(2);
		System.out.println(list);
	}
	
	@Test
	public void classTest1() {
		Clazz clazz=classService.getClazzByleaderTeacherId(2);
		System.out.println(clazz);
	}
	

	@Test
	public void classTest2() {
		Clazz clazz=classService.getClazzByStudentId(1);
		System.out.println(clazz);
	}
	

}
