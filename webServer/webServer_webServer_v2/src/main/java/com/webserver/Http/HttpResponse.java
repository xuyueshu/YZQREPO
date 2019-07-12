package com.webserver.Http;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.net.Socket;
import java.util.HashMap;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

import com.webserver.core.ServerContext;



public class HttpResponse {
	private Socket socket;
	private OutputStream out;
	private File entity;
	private int statusCode=200;
	private String statusReason="OK";
	
	private Map<String,String>headers=new HashMap<String,String>();
	
	public HttpResponse(Socket socket){
		
		try {
			this.socket=socket;
			this.out=socket.getOutputStream();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	
	public void flush() {
		
		/*
		 * 调方法
		 * 1.发送状态行
		 * 2.发送响应头
		 * 3.发送响应正文
		 */
		sendStatusLine();
		sendHeaders();
		sendContent();
	}
	
	//发送状态行
	private void sendStatusLine() {
		
		
		try {
			System.out.println("发送状态行...");
			String line=ServerContext.protocol+""+""+statusCode+""+statusReason;
			out.write(line.getBytes("ISO8859-1"));
			out.write(HttpContext.CR);
			out.write(HttpContext.LF);
			
			System.out.println("状态行发送完毕！");
		} catch (Exception e) {
			e.printStackTrace();
		} 
		
	}
	//发送响应头
	private void sendHeaders() {
		
		
		try {
			System.out.println("发送消息头....");
			Set<Entry<String,String>> entrySet=headers.entrySet();
			for(Entry<String,String>entry:entrySet ){
				String key=entry.getKey();
				String value=entry.getValue();
				String line=key+": "+value;
				println(line);
			}
//			String line="Content-Type: text/html";
//			out.write(line.getBytes("ISO8859-1"));
//			out.write(13);
//			out.write(10);
//			
//			 line="Content-Length: "+entity.length();
//			out.write(line.getBytes("ISO8859-1"));
//			out.write(13);
//			out.write(10);
//			
			out.write(HttpContext.CR);
			out.write(HttpContext.LF);
			System.out.println("消息头发送完毕！");
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	//建println方法
	private void println(String line){
		try {
			out.write(line.getBytes("ISO8859-1"));
			out.write(13);
			out.write(10);
		} catch (Exception e) {
			e.printStackTrace();
		} 
		
	}
	//发送响应正文
	private void sendContent() {
		
		try {
			System.out.println("发送正文....");
			FileInputStream fis=new FileInputStream(entity);
			byte[] data=new byte[10*1024];
			int len=-1;
			while((len=fis.read(data))!=-1) {
				out.write(data, 0, len);
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
		
		System.out.println("响应正文发送完毕！");
	}
	
	

	
	//

	public File getEntity() {
		return entity;
	}


	public void setEntity(File entity) {
		this.entity = entity;
		headers.put("Content-Length", entity.length()+"");
		String fileName=entity.getName();
		int index=fileName.indexOf(".")+1;
		String exe=fileName.substring(index);
		String ContentType=HttpContext.getContentType(exe);
		headers.put("Content-Type", ContentType);
	}

//
	public int getStatusCode() {
		return statusCode;
	}


	public void setStatusCode(int statusCode) {
		this.statusCode = statusCode;
		this.statusReason=HttpContext.getStatusReason(statusCode);
	}


	public String getStatusReason() {
		return statusReason;
	}


	public void setStatusReason(String statusReason) {
		this.statusReason = statusReason;
	}
	
	
	//
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

}
