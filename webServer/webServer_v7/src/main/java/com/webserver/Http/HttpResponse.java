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
			String line="HTTP/1.1 200 OK";
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
		
		
		try {
			FileInputStream fis;
			fis = new FileInputStream(entity);
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
	
	
	
	
	
	

}
