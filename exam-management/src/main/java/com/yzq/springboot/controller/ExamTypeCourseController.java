package com.yzq.springboot.controller;

import java.util.List;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.yzq.springboot.bean.ExamAndTypeAndCourse;
import com.yzq.springboot.service.IExamTypeCouseService;

@RestController
@RequestMapping("/examTypeCourse")
public class ExamTypeCourseController extends BaseController {
	@Autowired
	private IExamTypeCouseService service;
	
	@RequestMapping("/getList")
	public List<ExamAndTypeAndCourse> getExamTypeList(HttpSession session){
		Integer teacherId=getTeacherIdBySession(session);
		List<ExamAndTypeAndCourse> list=service.getExamTypeCourseList(teacherId);
		
		return list;
	}
	
	@RequestMapping("/studentExamtypeList")
	public List<ExamAndTypeAndCourse> getStudentExamTypeList(HttpSession session){
		Integer studentId=getStudentIdBySession(session);
		List<ExamAndTypeAndCourse> list=service.getExamtypeByStudentId(studentId);
		
		return list;
	}
	

}
