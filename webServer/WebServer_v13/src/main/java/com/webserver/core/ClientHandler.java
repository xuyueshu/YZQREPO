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
 * 处理客户端请求
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
			HttpRequest request=new HttpRequest(socket); //如果出现空请求，以下的代码不执行
			
			HttpResponse response=new HttpResponse(socket);
			
			/*
			 * 2.处理请求
			 * 
			 * 根据请求的资源路径，从weapps中找到对应的资源，
			 * 若存在资源，将资源响应给客户
			 * 若没有找到资源则响应404页面给客户端
			 */
			String url=request.getRequestURI();
			
			//首先判断该请求是否是请求的一个业务处理（即在html文件中有无设置action和method）
			//是否处理注册
			if("/myweb/reg".equals(url)) {
				
				
				RegServlet servlet=new RegServlet();//单独一个处理注册的类
				servlet.service(request, response);
				
				
			}else if("/myweb/login".equals(url)){
				
				LoginServlet ls=new LoginServlet();
				ls.service(request, response);
				
			}else {
			
				File file =new File("webapps"+url);
				if(file.exists()) {
					System.out.println("该文件已经找到");
					response.setEntity(file);
				}else {
					System.out.println("该资源不存在");
					//响应404页面
					response.setStatusCode(404);
					response.setEntity(new File("webapps/root/404.html"));
				}
			}
			
			
			//响应客户端
			response.flush();
		}catch(EmptyRequestException e){
			//空请求不处理 阻止不走下步操作
		}catch(Exception e) {
			
		}finally {
			//处理与客户端断开连接的操作
			try {
				socket.close();
			} catch (IOException e) {
				//e.printStackTrace();
			}
		}
		
	}
	

}















