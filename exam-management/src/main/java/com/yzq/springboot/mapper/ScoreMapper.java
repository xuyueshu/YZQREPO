package com.yzq.springboot.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.yzq.springboot.bean.CourseVSscore;
import com.yzq.springboot.bean.Escore;

public interface ScoreMapper {
	/**
	 * 添加分数
	 * @param escore
	 * @return
	 */
	Integer addScore(Escore escore);
	/**
	 * 查询指定学生，指定科目考试的成绩
	 * @param studentId
	 * @param ExamId
	 * @return
	 */
	Integer getScoreByStudentIdAndExamId(@Param("studentId")Integer studentId,@Param("examId")Integer examId);
	/**
	 * 查询指定学生，指定考试类型的科目，成绩列表
	 * @return
	 */
	List<CourseVSscore> getCourseVSscoreListBystudentIdExamtypeId(@Param("studentId")Integer studentId,@Param("examtypeId")Integer examtypeId);

}
