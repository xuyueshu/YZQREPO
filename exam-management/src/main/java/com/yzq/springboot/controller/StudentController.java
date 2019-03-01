package com.yzq.springboot.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.yzq.springboot.bean.Student;
import com.yzq.springboot.service.IStudentService;

@RestController
@RequestMapping("/student")
public class StudentController {
	@Autowired
	private IStudentService service;
	
	@RequestMapping("/getList")
	public List<Student<Integer>> getStudentList(@RequestParam("clazzId")Integer clazzId,@RequestParam("examId")Integer examId){
		List<Student<Integer>> list=service.getStudentListByClazzidExamId(clazzId, examId);
		System.out.println("studentlist="+list);
		
		return list;
	}

}
