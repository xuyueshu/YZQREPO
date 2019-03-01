package com.yzq.springboot.bean;

public class Attributes {
	private String url;
	
	public Attributes(String url) {
		super();
		this.url = url;
	}

	public String getUrl() {
		return url;
	}

	public void setUrl(String url) {
		this.url = url;
	}

	@Override
	public String toString() {
		return "Attributes [url=" + url + "]";
	}
	
}
