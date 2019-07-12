package com.webserver.http;

import java.util.HashMap;
import java.util.Map;

/**
 * Http协议相关信息定义
 * 
 * @author soft01
 *
 */
public class HttpContext {
	/*
	 * 状态代码与描述的关系
	 * key：状态代码
	 * value：状态描述
	 */
	
	private static Map<Integer,String>statusCode_Reason_MapPing=new HashMap<Integer,String>();
	
	/*
	 * 介质类型的映射
	 * Key：资源后缀名
	 * value：Content-Type对应的值
	 */
	private static Map<String,String> mimeMapping=new HashMap<String,String>();
	
	static {
		initStatusCodeReasonMapping();
		initMimeMapping() ;
	}
	
	/*初始化介质类型
	 * 
	 */
	private static void initMimeMapping() {
		mimeMapping.put("html", "text/html");
		mimeMapping.put("css", "text/css");
		mimeMapping.put("js", "application/javascript");
		mimeMapping.put("png", "image/png");
		mimeMapping.put("jpg", "image/jpeg");
		mimeMapping.put("gif", "image/gif");
		
	}
	
	
	/*
	 * 初始化状态代码与对应描述的关系
	 */
	private static void initStatusCodeReasonMapping() {
		statusCode_Reason_MapPing.put(200, "OK");
		statusCode_Reason_MapPing.put(201, "Created");
		statusCode_Reason_MapPing.put(202, "Accepted");
		statusCode_Reason_MapPing.put(204, "No Content");
		statusCode_Reason_MapPing.put(301, "Moved Permanently");
		statusCode_Reason_MapPing.put(302, "Moved Temporarily");
		statusCode_Reason_MapPing.put(304, "Not Modified");
		statusCode_Reason_MapPing.put(400, "Bad Request");
		statusCode_Reason_MapPing.put(401, "Unauthorized");
		statusCode_Reason_MapPing.put(403, "Forbidden");
		statusCode_Reason_MapPing.put(404, "Not Found");
		statusCode_Reason_MapPing.put(500, "Internal Server Error");
		statusCode_Reason_MapPing.put(501, "Not Implemented");
		statusCode_Reason_MapPing.put(502, "Bad Gateway");
		statusCode_Reason_MapPing.put(503, "Service Unavailable");
	}
	public static String getStatusReason(int statusCode) {
		return statusCode_Reason_MapPing.get(statusCode);
	}
	
	/*
	 * 根据资源的后缀获取对应的介质类型
	 */
	public static String getContentType(String ext) {
		return mimeMapping.get(ext);
	}
	
	public static void main(String[] args) {
		String reason =getStatusReason(404);
		System.out.println(reason);
		
		String line=getContentType("png");
		System.out.println(line);
	}

}




















