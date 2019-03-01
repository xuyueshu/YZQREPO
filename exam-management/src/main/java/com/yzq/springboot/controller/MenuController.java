package com.yzq.springboot.controller;

import java.util.List;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.yzq.springboot.bean.Manu;
import com.yzq.springboot.bean.User;
import com.yzq.springboot.service.IManuService;

@Controller
@RequestMapping("/manu")
public class MenuController extends BaseController {
	@Autowired 
	private IManuService service;
	
	@RequestMapping("/showManu")
	@ResponseBody
	public List<Manu> showManu(HttpSession session) {
		User user=(User)session.getAttribute("user");
		List<Manu> list=service.getManuList(user.getId());
		for (Manu manu : list) {
			System.out.println(manu);
		}
		return list;
	}

}
