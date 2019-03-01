package com.yzq.springboot.bean;

public class ExamAndTypeAndCourse {
	private Integer examtypeId;
	private String examtypeName;
	private Integer examId;
	private String examName;
	private Integer couseId;
	private String couseName;
	public Integer getExamtypeId() {
		return examtypeId;
	}
	public void setExamtypeId(Integer examtypeId) {
		this.examtypeId = examtypeId;
	}
	public String getExamtypeName() {
		return examtypeName;
	}
	public void setExamtypeName(String examtypeName) {
		this.examtypeName = examtypeName;
	}
	public Integer getExamId() {
		return examId;
	}
	public void setExamId(Integer examId) {
		this.examId = examId;
	}
	public String getExamName() {
		return examName;
	}
	public void setExamName(String examName) {
		this.examName = examName;
	}
	public Integer getCouseId() {
		return couseId;
	}
	public void setCouseId(Integer couseId) {
		this.couseId = couseId;
	}
	public String getCouseName() {
		return couseName;
	}
	public void setCouseName(String couseName) {
		this.couseName = couseName;
	}
	@Override
	public String toString() {
		return "ExamAndTypeAndCourse [examtypeId=" + examtypeId + ", examtypeName=" + examtypeName + ", examId="
				+ examId + ", examName=" + examName + ", couseId=" + couseId + ", couseName=" + couseName + "]";
	}
	
}
