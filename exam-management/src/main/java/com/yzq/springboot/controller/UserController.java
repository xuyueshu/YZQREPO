package com.yzq.springboot.controller;

import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.yzq.springboot.bean.Clazz;
import com.yzq.springboot.bean.Course;
import com.yzq.springboot.bean.OutUserInfo;
import com.yzq.springboot.bean.ResponseResult;
import com.yzq.springboot.bean.Role;
import com.yzq.springboot.bean.User;
import com.yzq.springboot.service.IClazzService;
import com.yzq.springboot.service.ICourseService;
import com.yzq.springboot.service.IRoleService;
import com.yzq.springboot.service.IUserService;

@Controller
@RequestMapping("/user")
public class UserController extends BaseController {
	@Autowired
	private IUserService service;
	@Autowired
	private IRoleService roleService;
	@Autowired
	private IClazzService clazzService;
	@Autowired
	private ICourseService courseService;
	
	@RequestMapping("/toLogin")
	public String toLogin() {
		
		return "login";
	}
	

	@RequestMapping("/login")
	@ResponseBody
	public ResponseResult<List<Object>> login(HttpSession session,@RequestParam("account")String account,@RequestParam("password")String password) {
		String url="/jsp/main.jsp";
		User user=service.login(account, password);
		session.setAttribute("user", user);
		saveOutUserInfoIntoSession(session,user);
		List<Object> list=new ArrayList<Object>();
		list.add(user);
		list.add(url);
		ResponseResult<List<Object>> rr=new  ResponseResult<List<Object>>();
		rr.setData(list);
		System.out.println("////////////////////");
		System.out.println(user);
		System.out.println("////////////////////");
		return rr;
	}
	
	@RequestMapping("/addStudent")
	@ResponseBody
	public Integer addStudent(HttpSession session,User user) {
		System.out.println("user="+user);
		Integer leaderTeacherId=getTeacherIdBySession(session);
		Integer addUserRows=service.addStudentUser(user, leaderTeacherId);
		return addUserRows;
	}
	
	
	////////////工具方法///////////////
	private void saveOutUserInfoIntoSession(HttpSession session,User user) {
		OutUserInfo outUserInfo=new OutUserInfo();
		outUserInfo.setUser(user);
		Role role=roleService.getRoleByUid(user.getId());
		outUserInfo.setRole(role);
		Integer teacherId=getTeacherIdBySession(session);
		Integer studentId=getStudentIdBySession(session);
		if(role.getId()==3) {
			Clazz studentClazz=clazzService.getClazzByStudentId(studentId);
			outUserInfo.setStudentClazz(studentClazz);
		}
		if(role.getId()==2||role.getId()==4) {
			List<Clazz> clazzs=clazzService.getClassListByTeacherId(teacherId);
			outUserInfo.setClazzs(clazzs);
			Course course=courseService.getCourseByTeacherId(teacherId);
			outUserInfo.setCourse(course);
		}
		if(role.getId()==4) {
			Clazz leaderClazz=clazzService.getClazzByleaderTeacherId(teacherId);
			outUserInfo.setLeaderClazz(leaderClazz);
		}
		System.out.println("outUserInfo="+outUserInfo);
		session.setAttribute("outUserInfo", outUserInfo);
	}
	
}
