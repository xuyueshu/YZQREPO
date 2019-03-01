package com.yzq.springboot.service.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.yzq.springboot.bean.AchieveScore;
import com.yzq.springboot.bean.EasyUIDatagrid;
import com.yzq.springboot.mapper.AchieveScoreMapper;
import com.yzq.springboot.service.IAchieveScoreService;
@Service
public class AchieveScoreServiceImpl implements IAchieveScoreService {
	@Autowired
	private AchieveScoreMapper achieveScoreMapper;

	@Override
	public EasyUIDatagrid getAchieveScore(Integer pageSize,
			Integer pageNum,
			Integer studentId,
			Integer examtypeId
			){
		List<AchieveScore> list= achieveScoreMapper.queryScoreByUid(pageSize*(pageNum-1), pageSize, studentId,examtypeId);
		Integer count=achieveScoreMapper.countScore(studentId,examtypeId);
		EasyUIDatagrid easyUIDatagrid=new EasyUIDatagrid();
		easyUIDatagrid.setRows(list);
		easyUIDatagrid.setTotal(count);
		return easyUIDatagrid;
	}

}
