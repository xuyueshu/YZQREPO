package com.yzq.springboot;

import java.util.List;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import com.yzq.springboot.bean.AchieveScore;
import com.yzq.springboot.bean.EasyUIDatagrid;
import com.yzq.springboot.mapper.AchieveScoreMapper;
import com.yzq.springboot.service.IAchieveScoreService;

@RunWith(SpringJUnit4ClassRunner.class)
@SpringBootTest(classes=ExamManagementApplication.class)
public class AchieveScoreTest {
	@Autowired
	private AchieveScoreMapper mapper;
	@Autowired
	private IAchieveScoreService achieveScoreService;
	@Test
	public void achieveScore() {
		List<AchieveScore> achieveScores=mapper.queryScoreByUid(2,6,90,1);
		System.out.println(achieveScores);
	}
	@Test
	public void getCount() {
		Integer num=mapper.countScore(90,1);
		System.out.println("num="+num);
	}
	@Test
	public void getDatagrid() {
		EasyUIDatagrid data=achieveScoreService.getAchieveScore(6, 1, 3,1);
		System.out.println(data);
	}
}
