package com.yzq.springboot.service;

import java.util.List;

import com.yzq.springboot.bean.Clazz;

public interface IClazzService {
	/**
	 * 通过teacherid获取班级列表
	 * @param teacherId
	 * @return
	 */
	List<Clazz> getClassListByTeacherId(Integer teacherId);
	/**
	 * 通过班主任的teacherid查询clazz
	 * @param teacherId
	 * @return
	 */
	Clazz getClazzByleaderTeacherId(Integer teacherId);
	/**
	 * 通过studentI的获取对应的班级
	 * @param studentId
	 * @return
	 */
	Clazz getClazzByStudentId(Integer studentId);

}
