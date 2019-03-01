package com.yzq.springboot.service;

import java.util.List;

import com.yzq.springboot.bean.Student;

public interface IStudentService {
	/**
	 * 通过clazzId获取学生列表
	 * @param clazzId
	 * @return
	 */
	List<Student<Integer>> getStudentListByClazzidExamId(Integer clazzId,Integer examId);
	/**
	 * 添加学生
	 * @param student
	 * @return
	 */
	Integer addStudent(Student<Void> student);

}
