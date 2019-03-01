package com.yzq.springboot.service;

import java.util.List;

import com.yzq.springboot.bean.Course;

public interface ICourseService {
	/**
	 * 通过teacherId获取对应的course
	 * @param teacherId
	 * @return
	 */
	Course getCourseByTeacherId(Integer teacherId);
	/**
	 *通过班级id获取学科列表
	 * @param clazzId
	 * @return
	 */
	List<Course> getCourseListByClazzId(Integer clazzId);

}
