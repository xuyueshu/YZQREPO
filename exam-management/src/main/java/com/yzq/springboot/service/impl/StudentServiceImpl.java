package com.yzq.springboot.service.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.yzq.springboot.bean.Student;
import com.yzq.springboot.mapper.ScoreMapper;
import com.yzq.springboot.mapper.StudentMapper;
import com.yzq.springboot.service.IScoreService;
import com.yzq.springboot.service.IStudentService;
@Service
public class StudentServiceImpl implements IStudentService {
	@Autowired
	private StudentMapper studentMapper;
	@Autowired
	private IScoreService scoreService ;
	
	@Override
	public List<Student<Integer>> getStudentListByClazzidExamId(Integer clazzId, Integer examId) {
		List<Student<Integer>> list=studentMapper.getStudentListByClazzid(clazzId);
		for (Student<Integer> student : list) {
			Integer score=scoreService.getScoreByStudentIdAndExamId(student.getId(), examId);
			student.setInfo(score);
		}
		return list;
	}
	@Override
	public Integer addStudent(Student<Void> student) {
		
		return studentMapper.addStudent(student);
	}

	

}
