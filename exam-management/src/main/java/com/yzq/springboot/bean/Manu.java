package com.yzq.springboot.bean;

import java.util.List;

import com.fasterxml.jackson.annotation.JsonProperty;

public class Manu {
	private Integer id;
	@JsonProperty(value="text")
	private String name;
	private Integer parentId;
	//自定义树形菜单树形attributes下面只有一个属性可以这样使用
	/*@JsonProperty(value="attributes")*/
	private String url;
	//attributes下面多个属性要封装成Attributes类
	private Attributes attributes;
	private List<Manu> children;
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
	public Integer getParentId() {
		return parentId;
	}
	public void setParentId(Integer parentId) {
		this.parentId = parentId;
	}
	public String getUrl() {
		return url;
	}
	public void setUrl(String url) {
		this.url = url;
	}
	public List<Manu> getChildren() {
		return children;
	}
	public void setChildren(List<Manu> children) {
		this.children = children;
	}
	
	public Attributes getAttributes() {
		return attributes;
	}
	public void setAttributes(Attributes attributes) {
		this.attributes = attributes;
	}
	@Override
	public String toString() {
		return "Manu [id=" + id + ", name=" + name + ", parentId=" + parentId + ", url=" + url + ", attributes="
				+ attributes + ", children=" + children + "]";
	}
	

}
