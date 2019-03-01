package com.yzq.springboot.bean;

public class Student<T> {
	private Integer id;
	private String name;
	private Integer clazzId;
	private Integer gradeId;
	private T info;
	public Integer getId() {
		return id;
	}
	public void setId(Integer id) {
		this.id = id;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public Integer getClazzId() {
		return clazzId;
	}
	public void setClazzId(Integer clazzId) {
		this.clazzId = clazzId;
	}
	public Integer getGradeId() {
		return gradeId;
	}
	public void setGradeId(Integer gradeId) {
		this.gradeId = gradeId;
	}
	
	public T getInfo() {
		return info;
	}
	public void setInfo(T info) {
		this.info = info;
	}
	@Override
	public String toString() {
		return "Student [id=" + id + ", name=" + name + ", clazzId=" + clazzId + ", gradeId=" + gradeId + ", info="
				+ info + "]";
	}
	

}
