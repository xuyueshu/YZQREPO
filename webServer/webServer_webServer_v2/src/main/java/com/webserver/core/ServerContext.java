package com.webserver.core;

import java.io.File;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.dom4j.Document;
import org.dom4j.DocumentException;
import org.dom4j.Element;
import org.dom4j.io.SAXReader;

public class ServerContext {
	public  static String URIEncoding;
	
	public  static int port;
	
	public  static String protocol;
	
	public  static int maxThreads;
	
	private static Map<String,String> servletMapping=new HashMap<String,String>();
	
	
	static {
		init();
		initServletMapping();
	}
	
	private  static void init(){
		
		try {
			SAXReader reader=new SAXReader();
			Document document=reader.read(new File("./conf/server.xml"));
			Element root=document.getRootElement();
			Element ele=root.element("Connector");
			URIEncoding=ele.attributeValue("URIEncoding");
			protocol=ele.attributeValue("protocol");
			port= Integer.parseInt(ele.attributeValue("port"));
			maxThreads=Integer.parseInt(ele.attributeValue("maxThreads"));
			
		} catch (DocumentException e) {
			e.printStackTrace();
		}
	}
	private static void initServletMapping(){
		
		try {
			SAXReader reader=new SAXReader();
			Document doc=reader.read(new File("./conf/servlets.xml"));
			Element root=doc.getRootElement();
			List<Element> element=root.elements("servlet");
			for(Element ele:element){
				String url=ele.attributeValue("url");
				String className=ele.attributeValue("className");
				servletMapping.put(url, className);
			}
			
		} catch (DocumentException e) {
			e.printStackTrace();
		}
	}
	public static String getServletName(String url){
		return servletMapping.get(url);
	}
	
	public static void main(String[] args) {
		System.out.println(URIEncoding+","+protocol+","+port+","+maxThreads);
		System.out.println(getServletName("/myweb/reg"));
	}

}
