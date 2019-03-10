package com.webserver.servlets;

import java.io.File;
import java.io.RandomAccessFile;
import java.util.Arrays;

import com.webserver.http.HttpRequest;
import com.webserver.http.HttpResponse;

/**
 * Servlet 是JAVA EE标准定义的内容
 * @author soft01
 *
 */
public class RegServlet {
	
	
	public void service(HttpRequest request,HttpResponse response) {//用来处理请求
		System.out.println("开始处理注册...");
		/*
		 * 处理注册流程
		 * 1.通过request获取用户表单提交上来的注册信息
		 * 2.将该信息写入到文件user.dat中
		 * 3.设置response对象，将注册成功的页面响应给客户端
		 * 
		 */
		String username=request.getParameter("username");
		
		String password=request.getParameter("password");
		
		String nickname=request.getParameter("nickname");
		
		int age= Integer.parseInt(request.getParameter("age"));
		System.out.println(username+","+password+","+nickname+","+age);
		
		/*
		 * 将注册信息写入eser.dat文件
		 * 每条记录占用100字节，其中，用户名，密码，昵称
		 * 为字符串，各占用32字节，年龄为int值占用4字节
		 * 
		 */
		try(RandomAccessFile raf= new RandomAccessFile("user.dat","rw");) {
			
			//将指针移动到文件的末尾
			raf.seek(raf.length());//为了书写下次的内容不覆盖
			byte[] data=username.getBytes("UTF-8");
			
			data=Arrays.copyOf(data, 32);
			raf.write(data);
			
			data=password.getBytes("UTF-8");
			data=Arrays.copyOf(data, 32);
			raf.write(data);
			
			data=nickname.getBytes("UTF-8");
			data=Arrays.copyOf(data, 32);
			raf.write(data);
			
			raf.writeInt(age);
			System.out.println("写出完毕！");
			
			raf.close();
			
			
		}catch(Exception e) {
			e.printStackTrace();
		}
		//3.响应注册成功页面
		File file =new File("webapps/myweb/reg_success.html");
		response.setEntity(file);
		System.out.println("该文件长度为："+file.length());
		
		
		System.out.println("注册处理完毕！");
	}

}
