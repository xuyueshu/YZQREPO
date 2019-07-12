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
	//服务端使用的协议版本
	public static String protocol;
	
	//服务端使用的端口号
	public static int port;
	
	//服务端解析URI时使用的字符集
	public static String URIEncoding;
	
	//服务端线程池线程数量
	public static int maxThreads=150;
	//请求与对应servlet的映射关系
	private static Map<String,String> servletMapping =new HashMap<String,String>();
	
	static {
		init();
		initServletMapping();
	}
	
	/*
	 *初始化Servlet映射 
	 */
	private static void initServletMapping() {
//		servletMapping.put("/myweb/reg", "com.webserver.servlets.RegServlet");
//		servletMapping.put("/myweb/login", "com.webserver.servlets.LoginServlet");
		/*
		 * 加载conf/servlet.xml
		 * 将每个<servlet>作为key，ClassName作为value
		 * 用于初始化servletMapping
		 */
		
		
		try {
			SAXReader reader=new SAXReader();
			Document doc =reader.read(new File("./conf/servlets.xml"));
			Element root=doc.getRootElement();
			List<Element> list=root.elements("servlet");
			for(Element element:list ) {
				String url=element.attributeValue("url");
				String className=element.attributeValue("className");
				servletMapping.put(url, className);
			}
		} catch (DocumentException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
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
	
	
	
	/*
	 * 根据请求获取对应的Servlet名字。若该请求没有
	 * 对应任何Servlet则返回值为null
	 */
	//获得ServletName方法
	public static String getServletName(String uri) {
		return servletMapping.get(uri);
	}
	
	
	public static void main(String[] args) {
		System.out.println(ServerContext.port);
		System.out.println(ServerContext.getServletName("/myweb/reg"));
	}

}
