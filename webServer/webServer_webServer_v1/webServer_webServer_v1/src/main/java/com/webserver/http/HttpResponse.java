package com.webserver.http;

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

public class HttpResponse {
	private Socket socket;
	private OutputStream out;
	private File entity;
	
	private int statusCode=200;//定义状态代码
	
	private String statusReason="OK";//定义对应的状态描述
	
	private Map<String,String> headers=new HashMap<String,String>();
	
	public HttpResponse(Socket socket) {//构造方法
		
		this.socket=socket;
		
		try {
			this.out=socket.getOutputStream();
		} catch (IOException e) {
			
			e.printStackTrace();
		}
		
			
	}
	
	public void flush() {
		
		sendStausLine();
		sendHeaders();
		sendContent();
		
		
		
	}
	
	
	//发送状态行
	private void sendStausLine() {
		try {
			String line="HTTP/1.1"+""+statusCode+""+statusReason;
			println(line);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
	}
	
	//发送响应头
	private void sendHeaders() {
		
		try {
//			String line="Content-Type: text/html";
//			out.write(line.getBytes("ISO8859-1"));
//			out.write(13);
//			out.write(10);
//			
//			line="Content-Length: "+entity.length();
//			out.write(line.getBytes("ISO8859-1"));
			Set<Entry<String,String>> entrySet=headers.entrySet();
			for(Entry<String,String> entry:entrySet) {
				String key=entry.getKey();
				String value=entry.getValue();
				String line=key+": "+value;
				println(line);
			}
			
			
			
			
			println("");
		}catch(Exception e) {
			e.printStackTrace();
		}
		
		
	}
	
	
	//发送响应正文
	private void sendContent() {
		try(FileInputStream fis=new FileInputStream(entity);) {
			
			byte[] data=new byte[1024*10];
			int len=-1;
			while((len=fis.read(data))!=-1) {
				out.write(data, 0, len);
		}
			
		}catch(Exception e) {
			e.printStackTrace();
		}
		
		
	
	}
	
	private void println(String line){
		try {
			out.write(line.getBytes("ISO8859-1"));
			out.write(13);
			out.write(10);
		} catch (Exception e) {
			
			e.printStackTrace();
		}
		
	}

	public File getEntity() {
		return entity;
	}

	public void setEntity(File entity) {
		this.entity = entity;
		this.headers.put("Content-Length", entity.length()+"");
		String FileName=entity.getName();
		int index=FileName.indexOf(".")+1;
		String ext=FileName.substring(index);
		String ContentType=HttpContext.getContentType(ext);
		this.headers.put("Content-Type", ContentType);
				
		
	}

	//设置状态代码，状态描述，获取状态代码，状态描述
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
	
	
	
	
	
	
	
	
	

}
