package com.webserver.Http;

import java.util.HashMap;
import java.util.Map;

/*
 * Http协议相关信息定义
 */
public class HttpContext {
	/*
	 * 状态代码与描述的关系
	 * key：状态代码
	 * value：状态描述
	 * 
	 */
	private static Map<Integer,String> statusCode_Reason_Mapping=new HashMap<Integer,String>();
	
	static {
		initStatusCodeReasonMapping();
	}
	/*
	 * 初始化状态代码与对应描述的关系
	 */
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
	
	public static String getStatusReason( int statusCode) {
		return statusCode_Reason_Mapping.get(statusCode);
	}
	
	
	public static void main(String[] args) {
		String reason=getStatusReason(503);
		System.out.println(reason);
	}

}
