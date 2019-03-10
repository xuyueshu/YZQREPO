package com.webserver.http;

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
	
	public static final int LF=10;
	private static Map<Integer,String>  statusCode_Reason_Mapping= new HashMap<Integer,String>();
	//介质类型的映射
		private static Map<String,String> mimeMapping=new HashMap<String,String>();
		
	static {
		initStatusCodeReasonMapping();
		initMimeMapping();
	}
	
	
	
	private static void initStatusCodeReasonMapping() {
		
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
	
	
	private static void initMimeMapping() {
//		mimeMapping.put("html", "text/html");
//		mimeMapping.put("css", "text/css");
//		mimeMapping.put("js", "application/javascript");
//		mimeMapping.put("png", "image/png");
//		mimeMapping.put("jpg", "image/jpeg");
//		mimeMapping.put("gif", "image/gif");
		
		
		
		try {
			SAXReader reader=new SAXReader();
			Document doc=reader.read(new File("./conf/web.xml"));
			Element root=doc.getRootElement();
			List<Element> list=root.elements("mime-mapping");
			for(Element ele:list) {
				String key=ele.elementTextTrim("extension");
				String value=ele.elementTextTrim("mime-type");
				
				mimeMapping.put(key, value);
			}
			System.out.println(mimeMapping.size());
			System.out.println("mimeMapping"+mimeMapping);
		} catch (DocumentException e) {
			
			e.printStackTrace();
		}
		
		
		
		
	
	}
	
	
	
	public static String getStatusReason(int statusCode) {
		
		return statusCode_Reason_Mapping.get(statusCode);
	}
	
	public static String getContentType(String ext) {
		
		return mimeMapping.get(ext);
	}
	
	
	
	
	
	
	
	
	
	
	
	
	

}
