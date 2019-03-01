package com.yzq.springboot.bean;

import java.util.List;

public class Columns {
	private String nameField="studentName";
	private List<Course> courses;
	public String getNameField() {
		return nameField;
	}
	public void setNameField(String nameField) {
		this.nameField = nameField;
	}
	public List<Course> getCourses() {
		return courses;
	}
	public void setCourses(List<Course> courses) {
		this.courses = courses;
	}
	@Override
	public String toString() {
		return "Columns [nameField=" + nameField + ", courses=" + courses + "]";
	}
	
	
}
