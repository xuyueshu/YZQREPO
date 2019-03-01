package com.yzq.springboot.bean;

public class ExamType {
	private String examTypeName;
	private Integer examTypeId;
	public String getExamTypeName() {
		return examTypeName;
	}
	public void setExamTypeName(String examTypeName) {
		this.examTypeName = examTypeName;
	}
	public Integer getExamTypeId() {
		return examTypeId;
	}
	public void setExamTypeId(Integer examTypeId) {
		this.examTypeId = examTypeId;
	}
	@Override
	public String toString() {
		return "ExamType [examTypeName=" + examTypeName + ", examTypeId=" + examTypeId + "]";
	}
	

}
