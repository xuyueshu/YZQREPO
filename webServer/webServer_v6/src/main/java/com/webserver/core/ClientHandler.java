package com.webserver.core;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.Socket;

import com.webserver.Http.HttpRequest;

/**
 * 处理客户端的请求
 * @author soft01
 *
 */
public class ClientHandler implements Runnable{
	private Socket socket;
	public ClientHandler(Socket socket) {
		this.socket=socket;
	}
	public void run() {
		try {
		/*
		 * 1.解析请求
		 * 2.处理请求
		 * 3.响应客户端
		 */
			
			//1.
			HttpRequest request=new HttpRequest(socket);//请求用一个对象表示
			/*
			 * 2.处理请求
			 * 
			 * 根据请求的资源路径，从webapps目录中找到对应的资源
			 * 若资源存在则将该资源响应给客户端
			 * 若没有找到该资源则响应404页面给客户端
			 */
			String url=request.getUrl();
			File file=new File("webapps"+url);
			
			
			
			if(file.exists()) {
				
				System.out.println("资源已找到！");
				//发送一个HTTP的响应给客户端
				OutputStream out=socket.getOutputStream();
				
				//发送状态行
				String line="HTTP/1.1 200 OK";
				out.write(line.getBytes("ISO8859-1"));
				out.write(13);//write CR
				out.write(10);//write LF
				
				//发送响应头
				line="Content-Type: text/html";
				out.write(line.getBytes("ISO8859-1"));
				out.write(13);//write CR
				out.write(10);//write LF
				
				line="Content-Length: "+file.length();
				out.write(line.getBytes("ISO8859-1"));
				out.write(13);//write CR
				out.write(10);//write LF
				//单独发送CRLF表示响应头发送完毕
				out.write(13);//write CR
				out.write(10);//write LF
				
				//发送响应正文
				FileInputStream fis=new FileInputStream(file);
				byte[] data=new byte[1024*10];
				int len=-1;
				while((len=fis.read(data))!=-1) {
					out.write(data, 0, len);
				}
				System.out.println("响应完毕！");
				
				
				
				
				
				
				
				
			}else {
				System.out.println("资源不存在");
			}
			
		}catch(Exception e) {
			
		}finally {
			//处理与客户端断开连接的操作
			try {
				socket.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
	}
	
	
	

}
