package com.webserver.Http;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.net.Socket;


/**
 * 响应对象
 * 一个响应对象应当包含三个部分：
 * 状态行
 * 响应头
 * 响应正文
 * @author soft01
 *
 */
public class HttpResponse {
	/*
	 * 响应正文相关信息定义
	 */
	//状态代码
	private int statusCode=200;
	//状态描述
	private String statusReason="OK";
	
	
	/*
	 * 
	 */
	/*
	 * 
	 */
	//响应实体文件
	private File entity;
	private Socket socket;
	//通过Socket获取的输出流，用于给客户端发送响应内容
	private OutputStream out;
	
	public HttpResponse(Socket socket) {
		
		try {
			
			this.socket=socket;
			this.out=socket.getOutputStream();
			
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	
	/*
	 * 将当前响应对象内容发送给客户端
	 */
	public void flush() {
		/*
		 * 1.发送状态行
		 * 2.发送响应头
		 * 3.发送响应正文
		 */
		sendStausLine();
		sendHeaders(); 
		sendContent();
		
	}
	
	//发送状态行
	private void sendStausLine() {
		
		try {
			String line="HTTP/1.1"+""+statusCode+""+statusReason;
			out.write(line.getBytes("ISO8859-1"));
			out.write(13);//write CR
			out.write(10);//write LF
		} catch (UnsupportedEncodingException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
	}
	
	
	
	//发送响应头
	private void sendHeaders() {
		//发送响应头
		try {
			 String line="Content-Type: text/html";
			out.write(line.getBytes("ISO8859-1"));
			out.write(13);//write CR
			out.write(10);//write LF
			
			line="Content-Length: "+entity.length();
			out.write(line.getBytes("ISO8859-1"));
			out.write(13);//write CR
			out.write(10);//write LF
			//单独发送CRLF表示响应头发送完毕
			out.write(13);//write CR
			out.write(10);//write LF
		}catch(Exception e) {
			e.printStackTrace();
		}
		
		
	}
	
	
	
	//发送响应正文
	private void sendContent() {
		
		
		try (FileInputStream fis = new FileInputStream(entity);){//括号中防止报错，priperty中将jdk改成1.8
			
			
			byte[] data=new byte[1024*10];
			int len=-1;
			while((len=fis.read(data))!=-1) {
				out.write(data, 0, len);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	
		}


	public File getEntity() {
		return entity;
	}


	public void setEntity(File entity) {
		this.entity = entity;
	}

//状态代码及描述的设置和获取
	public int getStatusCode() {
		return statusCode;
	}
/**
 * 设置状态代码
 * 在设置状态代码的同时会将对应的状态描述设置为默认值
 * 自动设置好
 * 若希望自行设置状态描述，可以单独调用对应的方法。
 * @param statusCode
 */

	public void setStatusCode(int statusCode) {
		this.statusCode = statusCode;
		this.statusReason=HttpContext.getStatusReason(statusCode);//设置状态代码的同时，将对应的状态描述进行设置
	}


	public String getStatusReason() {
		return statusReason;
	}


	public void setStatusReason(String statusReason) {
		this.statusReason = statusReason;
	}
	
	
	
	
	
	
	
	

}
