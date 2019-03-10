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

/**
 * 响应对象
 * 一个响应对象应当包行三个部分：
 * 状态行
 * 响应头
 * 响应正文
 * @author soft01
 *
 */
public class HttpResponse {
	/*
	 * 状态行相关信息定义
	 * 
	 */
	//状态代码
	private int statusCode=200;
	//状态描述
	private String statusReason="ok";
	
	/*
	 * 响应头相关信息定义
	 */
	
	private Map<String,String>headers=new HashMap<String,String>();
	
	/*
	 * 响应正文相关信息定义
	 */
	
	//响应实体文件
	private File entity;
	
	private Socket  socket;
	//通过Socket获取输入流，用于给客户端发送响应内容
	
	private OutputStream out;
	
	public HttpResponse(Socket socket) {
		try {
			this.socket=socket;
			this.out=socket.getOutputStream();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	/**
	 * 将当前响应对象内容发送给客户端
	 */
	public void flush() {
		/*
		 * 1：发送状态行
		 * 2：发送响应头
		 * 3：发送响应正文
		 * 
		 */
		sendStatusLine();
		sendHeaders();
		sendContent();
		
	}
	
	/*
	 * 发送状态行
	 */
	private void sendStatusLine() {
		try {
			String line ="HTTP/1.1"+" "+statusCode+" "+statusReason;
			out.write(line.getBytes("ISO8859-1"));
			out.write(13);//Written CR
			out.write(10);//Written LF
		} catch (Exception e) {
			e.printStackTrace();
		}
		
	}
	
	/*
	 * 发送响应头
	 */
	private void sendHeaders() {
		try {
			Set<Entry<String,String>>entrySet=headers.entrySet();
			for(Entry<String,String>header:entrySet) {
				String key=header.getKey();
				String value=header.getValue();
				String line=key+": "+value;
				out.write(line.getBytes("ISO8859-1"));
				out.write(13);//Written CR
				out.write(10);//Written LF
			}
			
			//单独发送CRLF表示响应头发送完毕
			out.write(13);//Written CR
			out.write(10);//Written LF
		}catch(Exception e) {
			e.printStackTrace();
		}
	}
	/*
	 * 发送响应正文
	 */
	
	private void sendContent() {
		try (FileInputStream fis=new FileInputStream(entity);)
			{
			byte[]data=new byte[1024*10];
			int len=-1;
			while((len = fis.read(data))!=-1) {
				out.write(data,0,len);
			}
		}catch(Exception e ) {
			e.printStackTrace();
		}
	}

	
	public File getEntity() {
		return entity;
	}
	
	/**
	 * 设置要响应给客户端的实体资源文件
	 * 在设置的同时会自动添加两个响应头：
	 * Content-Type与Content-Length
	 * @param entity
	 */

	public void setEntity(File entity) {
		this.entity = entity;
		this.headers.put("Content-Length", entity.length()+"");
		/*
		 * 设置Content-Type时，要根据文加名的后缀的到对应的值
		 */
		String fileName=entity.getName();
		int index=fileName.lastIndexOf(".")+1;
		String ext =fileName.substring(index);
		String contentType=HttpContext.getContentType(ext);
		this.headers.put("Content_type", contentType);
	}

	public int getStatusCode() {
		return statusCode;
	}
	
	
	/*设置动态代码
	 * 在设置动态代码的同时会将对应的状态描述默认值自动设置好
	 * 
	 * 若希望自动设置状态行描述，可以单独调用对应的方法
	 * 
	 */

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
	
	/*
	 * 相当前响应中设置一个响应头消息
	 * （后期自行重构时，还会添加获取头，以及删除头的操作）
	 */
	public void putHeader(String name,String value) {
		this.headers.put(name, value);
	}
	

}





























