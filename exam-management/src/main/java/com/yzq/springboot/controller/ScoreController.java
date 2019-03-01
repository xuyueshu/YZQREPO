package com.yzq.springboot.controller;

import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.yzq.springboot.bean.Escore;
import com.yzq.springboot.service.IScoreService;
import com.yzq.springboot.service.IShowCourseVSscore;

@RestController
@RequestMapping("/score")
public class ScoreController {
	@Autowired
	private IScoreService service;
	@Autowired
	private IShowCourseVSscore showCourseVSscore; 
	
	@RequestMapping("/addScore")
	public  Integer addScore(Escore escore) {
		System.out.println("escore="+escore);
		Integer rows=service.addScore(escore);
		return rows;
	}
	
	@RequestMapping("/showclazzscorelist")
	public Map<String,Object> showclazzscorelist(@RequestParam("clazzId")Integer clazzId,@RequestParam("examtypeId")Integer examtypeId) {
		Map<String,Object> jsonMap=showCourseVSscore.getColumnsVSMap(clazzId, examtypeId);
			System.out.println(jsonMap);
			return jsonMap;
	}
	
	
}
