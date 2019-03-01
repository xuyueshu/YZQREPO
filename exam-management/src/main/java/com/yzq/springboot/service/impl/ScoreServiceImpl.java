package com.yzq.springboot.service.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.yzq.springboot.bean.CourseVSscore;
import com.yzq.springboot.bean.Escore;
import com.yzq.springboot.mapper.ScoreMapper;
import com.yzq.springboot.service.IScoreService;
@Service
public class ScoreServiceImpl implements IScoreService {
	@Autowired
	private ScoreMapper scoreMapper;

	@Override
	public Integer addScore(Escore escore) {
		
		return scoreMapper.addScore(escore);
	}

	@Override
	public Integer getScoreByStudentIdAndExamId(Integer studentId, Integer examId) {
		
		return scoreMapper.getScoreByStudentIdAndExamId(studentId, examId);
	}

	@Override
	public List<CourseVSscore> getCourseVSscoreListBystudentIdExamtypeId(Integer studentId, Integer examtypeId) {
		
		return scoreMapper.getCourseVSscoreListBystudentIdExamtypeId(studentId, examtypeId);
	}

}
