package com.yzq.springboot;

import java.util.List;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import com.yzq.springboot.bean.ExamAndTypeAndCourse;
import com.yzq.springboot.mapper.ExamTypeCourseMapper;
import com.yzq.springboot.service.IExamTypeCouseService;

@RunWith(SpringJUnit4ClassRunner.class)
@SpringBootTest(classes=ExamManagementApplication.class)
public class ExamTypeTest {
	
	@Autowired
	private ExamTypeCourseMapper examTypeCourseMapper;
	@Autowired
	private IExamTypeCouseService examTypeCourseService;
	@Test
	public void getExamTypeCourseList() {
		List<ExamAndTypeAndCourse> list=examTypeCourseMapper.getExamAndTypeAndCourse(1);
		System.out.println(list);
	}
	
	@Test
	public void getExamTypeByStudentId() {
		List<ExamAndTypeAndCourse> list=examTypeCourseService.getExamtypeByStudentId(1);
		System.out.println(list);
	}

}
