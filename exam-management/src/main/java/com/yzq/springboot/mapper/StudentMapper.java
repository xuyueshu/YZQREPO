package com.yzq.springboot.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.yzq.springboot.bean.Student;

public interface StudentMapper {
	/**
	 *获取指定班级的学生列表
	 * @param clazzId
	 * @return
	 */
	List<Student<Integer>> getStudentListByClazzid(Integer clazzId);
	/**
	 * 添加学生
	 * @param student
	 * @return
	 */
	Integer addStudent(Student<Void> student);
	
}
