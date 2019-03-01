package com.yzq.springboot.service.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.yzq.springboot.bean.ExamAndTypeAndCourse;
import com.yzq.springboot.bean.ExamType;
import com.yzq.springboot.mapper.ExamTypeCourseMapper;
import com.yzq.springboot.service.IExamTypeCouseService;
@Service
public class ExamTypeCourseServiceImpl implements IExamTypeCouseService {
	@Autowired
	private ExamTypeCourseMapper examTypeMapper;
	@Override
	public List<ExamAndTypeAndCourse> getExamTypeCourseList(Integer teacherId) {
		
		return examTypeMapper.getExamAndTypeAndCourse(teacherId);
	}
	
	@Override
	public List<ExamAndTypeAndCourse> getExamtypeByStudentId(Integer studentId) {
		return examTypeMapper.getExamtypeByStudentId(studentId);
	}
	
	

}
