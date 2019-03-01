package com.yzq.springboot;

import java.util.List;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import com.yzq.springboot.bean.Student;
import com.yzq.springboot.service.IStudentService;

@RunWith(SpringJUnit4ClassRunner.class)
@SpringBootTest(classes=ExamManagementApplication.class)
public class StudentTest {
	@Autowired
	private IStudentService studentService;
	
	@Test
	public  void studentListTest() {
		List<Student<Integer>> list=studentService.getStudentListByClazzidExamId(5, 7);
		System.out.println(list);
	}

}
