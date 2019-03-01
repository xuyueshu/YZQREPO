package com.yzq.springboot.service;

import java.util.List;

import com.yzq.springboot.bean.ExamAndTypeAndCourse;

public interface IExamTypeCouseService {
	/**
	 * 获取考试类型列表
	 * @return
	 */
	List<ExamAndTypeAndCourse> getExamTypeCourseList(Integer teacherId);
	/**
	 * 通过学生id查询考试类型
	 * @param studentId
	 * @return
	 */
	List<ExamAndTypeAndCourse> getExamtypeByStudentId(Integer studentId);

}
