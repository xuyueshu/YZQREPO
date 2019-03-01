package com.yzq.springboot.bean;

public class CourseVSscore {
	private String courseName;
	private Integer courseId;
	private Integer score;
	public String getCourseName() {
		return courseName;
	}
	public void setCourseName(String courseName) {
		this.courseName = courseName;
	}
	public Integer getCourseId() {
		return courseId;
	}
	public void setCourseId(Integer courseId) {
		this.courseId = courseId;
	}
	public Integer getScore() {
		return score;
	}
	public void setScore(Integer score) {
		this.score = score;
	}
	@Override
	public String toString() {
		return "CourseVSscore [courseName=" + courseName + ", courseId=" + courseId + ", score=" + score + "]";
	}
	

}
