package com.webserver.Http;

import java.io.File;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.dom4j.Document;
import org.dom4j.DocumentException;
import org.dom4j.Element;
import org.dom4j.io.SAXReader;

public class HttpContext {
	public static final int CR=13;
	
	public static  final int LF=10;		
	
	private static Map<Integer,String> statusCode_Reason_Mapping=new HashMap<Integer,String>();
	private static Map<String,String> mimeMapping=new HashMap<String,String>();
	
	static {
		initStatusCodeReasonMapping();
		initMimeMapping();
	}
	
	private static  void initStatusCodeReasonMapping() {
		statusCode_Reason_Mapping.put(200,"OK");
		statusCode_Reason_Mapping.put(201,"Created");
		statusCode_Reason_Mapping.put(202,"Accepted");
		statusCode_Reason_Mapping.put(204,"No Content" );
		statusCode_Reason_Mapping.put(301,"Moved Permanently");
		statusCode_Reason_Mapping.put(302,"Moved Temporarily" );
		statusCode_Reason_Mapping.put(304,"Not Modified" );
		statusCode_Reason_Mapping.put(400,"Bad Request" );
		statusCode_Reason_Mapping.put(401,"Unauthorized" );
		statusCode_Reason_Mapping.put(403,"Unauthorized" );
		statusCode_Reason_Mapping.put(404,"Not Found" );
		statusCode_Reason_Mapping.put(500,"Internal Server Error" );
		statusCode_Reason_Mapping.put(501,"Not Implemented" );
		statusCode_Reason_Mapping.put(502,"Bad Gateway" );
		statusCode_Reason_Mapping.put(503,"Service Unavailable" );
	}
	
	private static void initMimeMapping(){
		
		try {
			SAXReader reader=new SAXReader();
			Document doc=reader.read(new File("./conf/web.xml"));
			Element root=doc.getRootElement();
			List<Element> element=root.elements("mime-mapping");
			for(Element ele:element){
				String key=ele.elementTextTrim("extension");
				String value=ele.elementTextTrim("mime-type");
				mimeMapping.put(key, value);
			}
			System.out.println("输出mimeMapping集合  ："+mimeMapping);
			System.out.println("mimeMapping集合元素个数为 ："+mimeMapping.size());
		} catch (DocumentException e) {
			e.printStackTrace();
		}
		
	}
	
	
	
	public static  String getStatusReason(int statusCode) {
		
		return statusCode_Reason_Mapping.get(statusCode);
	}
	
	public static String getContentType(String exe){
		return mimeMapping.get(exe);
	}
	
	
	public static void main(String[] args) {
		System.out.println(getContentType("jpg"));
	}
	

}
