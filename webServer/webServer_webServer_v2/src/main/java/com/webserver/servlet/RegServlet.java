package com.webserver.servlet;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.RandomAccessFile;
import java.util.Arrays;

import com.webserver.Http.HttpRequest;
import com.webserver.Http.HttpResponse;
import com.webserver.core.ServerContext;

public class RegServlet extends HttpServlet {
	
	public void service(HttpRequest request,HttpResponse response) {
		System.out.println("开始注册....");
		String username=request.getParameters("username");
		String password=request.getParameters("password");
		String nickname=request.getParameters("nickname");
		int age=Integer.parseInt(request.getParameters("age"));
		
		 String line=username+","+password+","+nickname+","+age;
		 System.out.println("写入的用户信息为： "+line);
		 
		 
		 try {
			RandomAccessFile raf=new RandomAccessFile("user.dat", "rw");
			raf.seek(raf.length());
			byte[] data=username.getBytes(ServerContext.URIEncoding);
			data=Arrays.copyOf(data, 32);
			raf.write(data);
			data=password.getBytes(ServerContext.URIEncoding);
			data=Arrays.copyOf(data, 32);
			raf.write(data);
			data=nickname.getBytes(ServerContext.URIEncoding);
			data=Arrays.copyOf(data, 32);
			raf.write(data);
			raf.writeInt(age);
			System.out.println("用户信息写入完毕！");
			System.out.println("user.dat文件长度为： "+raf.length());
			
			response.setEntity(new File("webapps/myweb/reg_success.html"));
			System.out.println("注册成功！");
			
			
		} catch (Exception e) {
			e.printStackTrace();
		}
		 
		 
		 
	}

}
