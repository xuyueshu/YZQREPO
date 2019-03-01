package com.yzq.springboot.service.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.yzq.springboot.bean.Clazz;
import com.yzq.springboot.mapper.ClazzMapper;
import com.yzq.springboot.service.IClazzService;
@Service
public class ClazzServiceImpl implements IClazzService {
	@Autowired
	private ClazzMapper classMapper;

	@Override
	public List<Clazz> getClassListByTeacherId(Integer teacherId) {
		
		return classMapper.getClassListByTeacherId(teacherId);
	}

	@Override
	public Clazz getClazzByleaderTeacherId(Integer teacherId) {
		
		return classMapper.getClazzByleaderTeacherId(teacherId);
	}

	@Override
	public Clazz getClazzByStudentId(Integer studentId) {
		
		return classMapper.getClazzByStudentId(studentId);
	}

}
