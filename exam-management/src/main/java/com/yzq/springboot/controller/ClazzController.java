package com.yzq.springboot.controller;

import java.util.List;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.yzq.springboot.bean.Clazz;
import com.yzq.springboot.service.IClazzService;

@RestController
@RequestMapping("/clazz")
public class ClazzController extends BaseController {
	@Autowired
	private IClazzService service;
	
	@RequestMapping("/getList")
	public List<Clazz> getClazzList(HttpSession session){
		Integer teacherId=getTeacherIdBySession(session);
		List<Clazz> list=service.getClassListByTeacherId(teacherId);
		
		return list;
	}

}
