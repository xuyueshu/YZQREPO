package com.webserver.http;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.dom4j.io.SAXReader;
import org.dom4j.Document;
import org.dom4j.DocumentException;
import org.dom4j.Element;

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
//		mimeMapping.put("html", "text/html");
//		mimeMapping.put("css", "text/css");
//		mimeMapping.put("js", "application/javascript");
//		mimeMapping.put("png", "image/png");
//		mimeMapping.put("jpg", "image/jpeg");
//		mimeMapping.put("gif", "image/gif");
		
		/*
		 * 通過解析conf/web.xml文件來完成初始化操作
		 * 
		 * 將web.xml文檔中根標籤下所有名爲：
		 * <extension>中間的文本作爲key
		 * <mime-type>中間的文本作爲value
		 * 來初始化mimeMapping這個Map。
		 */
		
		try {
			SAXReader reader=new SAXReader();
			Document document =reader.read(new FileInputStream("./conf/web.xml"));
			Element root=document.getRootElement();
			List<Element> list=root.elements("mime-mapping"); //获取根标签下的所有mime-mapping子标签
			for(Element e:list) {
				Element e1=e.element("extension");
				Element e2=e.element("mime-type");
				
				String key=e1.getText().trim();
				
				String value=e2.getText().trim();
				mimeMapping.put(key, value);
				
			}
			System.out.println(mimeMapping);
			System.out.println(mimeMapping.size());
			
			
			
			
			
			
		} catch (Exception e) {
			e.printStackTrace();
		} 
		
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




















