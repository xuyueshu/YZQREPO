package com.webserver.servlets;

import java.io.File;
import java.io.RandomAccessFile;
import java.util.Arrays;

import com.webserver.http.HttpRequest;
import com.webserver.http.HttpResponse;

public class RegServlet {
	
	public void service(HttpRequest request,HttpResponse response) {
		
		String username=request.getParameters("username");
		
		String password=request.getParameters("password");
		
		String nickname=request.getParameters("nickname");
		
		int age=Integer.parseInt(request.getParameters("age"));
		
		String info=username+","+password+","+nickname+","+age;
		
		System.out.println("注册信息为  ："+info);
		
		
		//写入user.dat中
		
		
		
		try(RandomAccessFile raf=new RandomAccessFile("user.dat", "rw");){
			
			raf.seek(raf.length());
			
		byte[]	data=username.getBytes("UTF-8");
		data=Arrays.copyOf(data, 32);
			raf.write(data);
	
		data=password.getBytes("UTF-8");
		data=Arrays.copyOf(data, 32);
		raf.write(data);
		
		data=nickname.getBytes("UTF-8");
		data=Arrays.copyOf(data, 32);
		raf.write(data);
		
		raf.writeInt(age);
		System.out.println("信息写出完毕！");
		File file=new File("webapps/myweb/reg_success.html");
		response.setEntity(file);
		System.out.println("user文件长度为：  "+file.length());
		
		
			
			
			
		}catch(Exception e) {
			e.printStackTrace();
		}
		
		
		
		
		
		
		
		
		
	}


}
