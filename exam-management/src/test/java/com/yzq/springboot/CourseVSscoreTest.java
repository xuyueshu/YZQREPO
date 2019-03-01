package com.yzq.springboot;

import java.util.List;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import com.yzq.springboot.bean.CourseVSscore;
import com.yzq.springboot.service.IScoreService;

@RunWith(SpringJUnit4ClassRunner.class)
@SpringBootTest(classes=ExamManagementApplication.class)
public class CourseVSscoreTest {
	@Autowired
	private IScoreService service;
	
	@Test
	public void getCourseVSscore() {
		List<CourseVSscore> list=service.getCourseVSscoreListBystudentIdExamtypeId(1, 1);
		System.out.println(list);
	}

}
