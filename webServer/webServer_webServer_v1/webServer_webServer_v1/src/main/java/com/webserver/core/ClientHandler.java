package com.webserver.core;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.Socket;

import com.webserver.http.EmptyRequestException;
import com.webserver.http.HttpRequest;
import com.webserver.http.HttpResponse;
import com.webserver.servlets.LoginServlet;
import com.webserver.servlets.RegServlet;

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
			
			//1.解析请求
			//2.处理请求
			//3.响应客户端
			
			HttpRequest request=new HttpRequest(socket);
			HttpResponse response=new HttpResponse(socket);
			String url=request.getRequestURI();
			
			if("/myweb/reg".equals(url)) {
				RegServlet servlet=new RegServlet();
				servlet.service(request, response);
				
			}else if("/myweb/login".equals(url)){
				LoginServlet servlet=new LoginServlet();
				servlet.service(request, response);
				
			}else {
				File file=new File("webapps"+url);
				if(file.exists()) {
					System.out.println("该资源存在！");
					//存在的情况下，给客户端发送一个响应
					
					response.setEntity(file);
				
					
					
					System.out.println("响应完毕！");
					
					
					
			
				}else {
					System.out.println("该资源不存在！");
					//设置404页面
					response.setStatusCode(404);
					response.setEntity(new File("webapps/root/404.html"));
					System.out.println("响应404页面！");
				}
				
			}
			
			
			
			
			
			
			response.flush();
		
		}catch(EmptyRequestException e){
			//不做处理
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
