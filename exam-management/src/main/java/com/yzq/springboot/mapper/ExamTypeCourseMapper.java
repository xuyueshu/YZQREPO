package com.yzq.springboot.mapper;

import java.util.List;

import com.yzq.springboot.bean.ExamAndTypeAndCourse;

public interface ExamTypeCourseMapper {
	/**
	 * 通过教师获取考试类型
	 * @return
	 */
	List<ExamAndTypeAndCourse> getExamAndTypeAndCourse(Integer teacherId);
	/**
	 * 通过学生id查询考试类型
	 * @param studentId
	 * @return
	 */
	List<ExamAndTypeAndCourse> getExamtypeByStudentId(Integer studentId);
}
