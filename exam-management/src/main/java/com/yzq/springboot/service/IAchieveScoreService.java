package com.yzq.springboot.service;

import com.yzq.springboot.bean.EasyUIDatagrid;

public interface IAchieveScoreService {
	/**
	 * 分页获取成绩单
	 * @param pageSize 每页显示多少条
	 * @param pageNum
	 * @param uid
	 * @return
	 */
	EasyUIDatagrid getAchieveScore(Integer pageSize,
			Integer pageNum,
			Integer studentId,
			Integer examtypeId
			);
	

}
