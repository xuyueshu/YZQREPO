package com.webserver.core;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.net.Socket;

import com.webserver.Http.EmptyRequestException;
import com.webserver.Http.HttpRequest;
import com.webserver.Http.HttpResponse;
import com.webserver.servlet.HttpServlet;
import com.webserver.servlet.LoginServlet;
import com.webserver.servlet.RegServlet;

public class ClientHandler implements Runnable {
	private Socket socket;
	private InputStream in;
	//初始化
	public ClientHandler(Socket socket) {
		
	 try {
		 this.socket=socket;
		this.in=socket.getInputStream();
		
	} catch (IOException e) {
		e.printStackTrace();
	}
	}
	
	
	public void run() {
		try {
			HttpRequest request=new HttpRequest(socket);
			HttpResponse response=new HttpResponse(socket);
			String url=request.getRequestURI();
			System.out.println("ClientHandler中传过来的url:"+url);
			String servletName=ServerContext.getServletName(url);
			
//			if("/myweb/reg".equals(url)){
//				RegServlet servlet=new RegServlet();
//				servlet.service(request, response);
//			
//			}else if("/myweb/login".equals(url)){
//				LoginServlet servlet=new LoginServlet();
//				servlet.service(request, response);
			System.out.println("利用反射得到的： "+servletName);
			if(servletName!=null){
				System.out.println("利用反射得到的： "+servletName);
				Class cls=Class.forName(servletName);
				HttpServlet servlet=(HttpServlet) cls.newInstance();
				servlet.service(request, response);
			} else{
				File file=new File("webapps"+url);
				if(file.exists()) {
					System.out.println("资源已找到！");
					response.setEntity(file);
					
				}else {
					System.out.println("资源没找到！");
					response.setEntity(new File("webapps/myweb/404.html"));
					
				}
			} 
			response.flush();
		}catch(EmptyRequestException e){
			
		} catch (Exception e) {
			e.printStackTrace();
		}finally {
			try {
				socket.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
		
	}
	
	

}
