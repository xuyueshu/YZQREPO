package com.yzq.springboot.service.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.yzq.springboot.bean.Course;
import com.yzq.springboot.mapper.CourseMapper;
import com.yzq.springboot.service.ICourseService;

@Service
public class CourseServiceImpl implements ICourseService{
	@Autowired
	private CourseMapper courseMapper;

	@Override
	public Course getCourseByTeacherId(Integer teacherId) {
		
		return courseMapper.getCourseByTeacherId(teacherId);
	}

	@Override
	public List<Course> getCourseListByClazzId(Integer clazzId) {
		
		return courseMapper.getCourseListByClazzId(clazzId);
	}
	

}
