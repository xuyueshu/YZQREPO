package com.webserver.servlets;

import java.io.File;
import java.io.RandomAccessFile;
import java.util.Arrays;

import com.webserver.http.HttpRequest;
import com.webserver.http.HttpResponse;

/**
 * Servlet是JAVA EE标准定义的内容
 * @author soft01
 *
 */
public class RegServlet {
	public void service(HttpRequest request,HttpResponse response) {//用于处理业务
		System.out.println("开始处理注册");
		/*
		 * 处理注册流程
		 * 1：通过request获取用户表单提交上来的注册用户信息
		 * 2：将该信息写入到文件user.dat中
		 * 3：设置response对象，将注册成功页面响应给客户端
		 * 
		 */
		//1
		String username=request.getParameters("username");
		String password=request.getParameters("password");
		String nickname=request.getParameters("nickname");
		int age=Integer.parseInt(request.getParameters("age"));
		
		System.out.println(username+","+password+","+nickname+","+age);
		
		/*
		 * 2
		 * 将注册信息写入user.dat文件
		 * 每条记录占用100字节，其中，用户名，密码，昵称
		 * 为字符串，各占用32字节，年龄int值占用4字节
		 */
		
		try(
			RandomAccessFile raf=new RandomAccessFile("user.dat", "rw");
				){
			raf.seek(raf.length());
			//写用户名
			byte[]data=username.getBytes("utf-8");
			data=Arrays.copyOf(data, 32);
			raf.write(data);
			//写密码
			data=password.getBytes("utf-8");
			data=Arrays.copyOf(data, 32);
			raf.write(data);
			//写昵称
			data=nickname.getBytes("utf-8");
			data=Arrays.copyOf(data, 32);
			raf.write(data);
			//写年龄
			raf.writeInt(age);
			
			
		}catch (Exception e) {
			e.printStackTrace();
		}
		
		//3 响应注册成功页面
		File file=new File("webapps/myweb/reg_success.html");
		response.setEntity(file);
			
			
		
		
		
		
		
		
		
		
		
		
		
		
		System.out.println("注册处理完毕");
	}

}
