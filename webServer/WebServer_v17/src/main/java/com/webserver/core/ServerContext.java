package com.webserver.core;

import java.io.File;
import java.util.HashMap;
import java.util.Map;

import org.dom4j.Document;
import org.dom4j.DocumentException;
import org.dom4j.Element;
import org.dom4j.io.SAXReader;

public class ServerContext {
	//服务端使用的协议版本
	public static String protocol;
	
	//服务端使用的端口号
	public static int port;
	
	//服务端解析URI时使用的字符集
	public static String URIEncoding;
	
	//服务端线程池线程数量
	public static int maxThreads=150;
	
	
	static {
		init();
	}
	
	/*
	 * 解析conf/server.xml,将所有配置项用于初始化
	 * ServerContext对应属性
	 * 
	 */
	private static  void  init() {
		/*
		 * 解析conf/server.xml文件，将根标签下的子标签
		 * <Connector>中各属性的值得到，并用于初始化
		 * 对应的属性
		 */
		
		
		try {
			SAXReader reader=new SAXReader();
			Document doc=reader.read(new File("./conf/server.xml"));
			Element root=doc.getRootElement();
			
			Element element=root.element("Connector");
			
			protocol=element.attributeValue("protocol");
			
			port=Integer.parseInt(element.attributeValue("port"));
			
			URIEncoding=element.attributeValue("URIEncoding");

			maxThreads=Integer.parseInt(element.attributeValue("maxThreads"));
			
		
			
		
			
		} catch (DocumentException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
	
	}
	
	public static void main(String[] args) {
		System.out.println(ServerContext.port);
		System.out.println(ServerContext.protocol);
		System.out.println(ServerContext.URIEncoding);
		System.out.println(ServerContext.maxThreads);
		
		
	}

}
