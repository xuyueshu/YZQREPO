package com.yzq.springboot.bean;

public class Clazz {
	private String name;
	private Integer id;
	private Integer gradeId;
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public Integer getId() {
		return id;
	}
	public void setId(Integer id) {
		this.id = id;
	}
	
	public Integer getGradeId() {
		return gradeId;
	}
	public void setGradeId(Integer gradeId) {
		this.gradeId = gradeId;
	}
	@Override
	public String toString() {
		return "Clazz [name=" + name + ", id=" + id + ", gradeId=" + gradeId + "]";
	}
	
	
	
}
