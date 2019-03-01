package com.yzq.springboot.controller;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.yzq.springboot.bean.EasyUIDatagrid;
import com.yzq.springboot.bean.User;
import com.yzq.springboot.service.IAchieveScoreService;

@Controller
@RequestMapping("/score")
public class AchieveScoreController extends BaseController {
	@Autowired
	private IAchieveScoreService service;
	
	@RequestMapping("/showScore")
	@ResponseBody
	public EasyUIDatagrid showScore(
			HttpSession session,@RequestParam(defaultValue="6")Integer rows,
			@RequestParam(defaultValue="1")Integer page,
			Integer examtypeId
			) {
		System.out.println("rows="+rows+",page="+page);
		Integer studentId=getStudentIdBySession(session);
		EasyUIDatagrid easyUIDatagrid=service.getAchieveScore(rows, page, studentId,examtypeId);	
		
		return easyUIDatagrid;
	}

}
