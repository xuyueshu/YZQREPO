package cn.tedu.store.entity;

import java.io.Serializable;

public class District implements Serializable{//实现序列化型接口，tomcat管理时，可以对该对象的数据进行缓存
	/**
	 * 
	 */
	private static final long serialVersionUID = -2777570570541589252L;
	private Integer id;
	private String parent;
	private String code;
	private String name;
	public Integer getId() {
		return id;
	}
	public void setId(Integer id) {
		this.id = id;
	}
	public String getParent() {
		return parent;
	}
	public void setParent(String parent) {
		this.parent = parent;
	}
	public String getCode() {
		return code;
	}
	public void setCode(String code) {
		this.code = code;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	@Override
	public String toString() {
		return "District [id=" + id + ", parent=" + parent + ", code=" + code + ", name=" + name + "]";
	}
	
	

}
