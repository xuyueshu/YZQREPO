package com.yzq.springboot.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.yzq.springboot.bean.AchieveScore;

public interface AchieveScoreMapper {
	/**
	 * 通过用户id插叙成绩单
	 * @param pageSize
	 * @param pageNum
	 * @param uid
	 * @return
	 */
	List<AchieveScore> queryScoreByUid(@Param("pageStart")Integer pageStart,
			@Param("pageSize")Integer pageSize,
			@Param("studentId") Integer studentId,
			@Param("examtypeId") Integer examtypeId
			);
	/**
	 * 获取成绩条数
	 * @return
	 */
	Integer countScore(@Param("studentId") Integer studentId,@Param("examtypeId") Integer examtypeId);
	
	
}
