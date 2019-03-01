package com.yzq.springboot.bean;

import java.util.List;

public class OutUserInfo {
	private User user;
	private Role role;
	private List<Clazz> clazzs;
	private Clazz leaderClazz;
	private Clazz studentClazz;
	private Course course;
	public User getUser() {
		return user;
	}
	public void setUser(User user) {
		this.user = user;
	}
	public Role getRole() {
		return role;
	}
	public void setRole(Role role) {
		this.role = role;
	}
	public List<Clazz> getClazzs() {
		return clazzs;
	}
	public void setClazzs(List<Clazz> clazzs) {
		this.clazzs = clazzs;
	}
	public Clazz getLeaderClazz() {
		return leaderClazz;
	}
	public void setLeaderClazz(Clazz leaderClazz) {
		this.leaderClazz = leaderClazz;
	}
	public Clazz getStudentClazz() {
		return studentClazz;
	}
	public void setStudentClazz(Clazz studentClazz) {
		this.studentClazz = studentClazz;
	}
	public Course getCourse() {
		return course;
	}
	public void setCourse(Course course) {
		this.course = course;
	}
	@Override
	public String toString() {
		return "OutUserInfo [user=" + user + ", role=" + role + ", clazzs=" + clazzs + ", leaderClazz=" + leaderClazz
				+ ", studentClazz=" + studentClazz + ", course=" + course + "]";
	}
	

}
