package com.yzq.springboot.service;

import java.util.Map;

public interface IShowCourseVSscore {
	/**
	 * 获取科目及成绩列表的数据
	 * @return
	 */
	Map getColumnsVSMap(Integer clazzId,Integer examtypeId);

}
