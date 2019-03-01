package com.yzq.springboot.service.impl;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.yzq.springboot.bean.Columns;
import com.yzq.springboot.bean.Course;
import com.yzq.springboot.bean.CourseVSscore;
import com.yzq.springboot.bean.Student;
import com.yzq.springboot.mapper.StudentMapper;
import com.yzq.springboot.service.ICourseService;
import com.yzq.springboot.service.IScoreService;
import com.yzq.springboot.service.IShowCourseVSscore;
@Service
public class ShowCourseVSscoreImpl implements IShowCourseVSscore {
	@Autowired
	private StudentMapper studentMapper;
	@Autowired
	private IScoreService scoreService;
	@Autowired
	private ICourseService courseService;
	
	@Override
	public Map<String,Object> getColumnsVSMap(Integer clazzId,Integer examtypeId) {
		Map<String,Object> jsonMap=new HashMap<String,Object>();
		List<Map<Object,Object>> mapList=new ArrayList<Map<Object,Object>>();
		//获取到各个学科
		List<Course> courses=courseService.getCourseListByClazzId(clazzId);
		Columns columns=new Columns();
		columns.setCourses(courses);
		System.out.println("//////////业务层  / /   // ");
		//获取学生集合
		List<Student<Integer>> studentList=studentMapper.getStudentListByClazzid(clazzId);
		System.out.println("studentList="+studentList);
		for (Student<Integer> student : studentList) {
			Map<Object,Object> studentMap=new HashMap<Object,Object>();
		//将"studentname"和名字作为key-value存入map中
			studentMap.put("studentname", student.getName());
			System.out.println("studentMap1="+studentMap);
			Integer totalScore=0;
			//获取该班级所有学生的各科成绩
			List<CourseVSscore> courseVSscores=scoreService.getCourseVSscoreListBystudentIdExamtypeId(student.getId(), examtypeId);
			for (CourseVSscore courseVSscore : courseVSscores) {
				Integer score=courseVSscore.getScore();
				//将学科的id和对应的分数作为key-value存入map中
				studentMap.put(courseVSscore.getCourseId(),score);
				System.out.println("studentMap2="+studentMap);
				if(score==null) {
					score=0;
				}
				totalScore+=score;
			}
			studentMap.put("totalScore", totalScore);
			//一起添加到集合中
			mapList.add(studentMap);
		}
		jsonMap.put("columns", columns);
		jsonMap.put("mapList", mapList);
		return jsonMap;
	}

}
