package com.yzq.springboot.bean;

public class AchieveScore {
	private String courseName;
	private Integer score;
	public String getCourseName() {
		return courseName;
	}
	public void setCourseName(String courseName) {
		this.courseName = courseName;
	}
	public Integer getScore() {
		return score;
	}
	public void setScore(Integer score) {
		this.score = score;
	}
	@Override
	public String toString() {
		return "AchieveScore [courseName=" + courseName + ", score=" + score + "]";
	}
	

}
