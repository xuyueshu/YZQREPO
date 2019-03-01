package com.yzq.springboot.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Select;

import com.yzq.springboot.bean.Course;

public interface CourseMapper {
	/**
	 * 通过teacherId获取对应的course
	 * @param teacherId
	 * @return
	 */
	@Select({"SELECT c.id, c.`name` FROM teacher t JOIN "
     +" teacher_course t_co ON t.id = t_co.teacherId"
			+" JOIN course c ON t_co.courseId = c.id WHERE t.id=#{teacherId}"})
	Course getCourseByTeacherId(Integer teacherId);
	
	/**
	 *通过班级id获取学科列表
	 * @param clazzId
	 * @return
	 */
	@Select({"SELECT course.id,course.`name` FROM\r\n" + 
			"	clazz\r\n" + 
			"	JOIN grade ON clazz.gradeid = grade.id\r\n" + 
			"	JOIN grade_course g_c ON grade.id = g_c.gradeid\r\n" + 
			"	JOIN course ON g_c.courseid = course.id \r\n" + 
			"WHERE\r\n" + 
			"	clazz.id =#{clazzId}"})
	List<Course> getCourseListByClazzId(Integer clazzId);

}
