package com.yzq.springboot;

import java.util.List;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import com.yzq.springboot.bean.Course;
import com.yzq.springboot.service.ICourseService;

@RunWith(SpringJUnit4ClassRunner.class)
@SpringBootTest(classes=ExamManagementApplication.class)
public class CourseTest {
	@Autowired
	private ICourseService courseService;
	
	@Test
	public  void courseTest() {
		Course course=courseService.getCourseByTeacherId(1);
		System.out.println("course="+course);
	}
	@Test
	public  void courseTest1() {
		List<Course> courses=courseService.getCourseListByClazzId(1);
		System.out.println("courses="+courses);
	}
	
	

}
