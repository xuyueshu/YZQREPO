package com.webserver.servlets;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.RandomAccessFile;

import com.webserver.http.HttpRequest;
import com.webserver.http.HttpResponse;

public class LoginServlet {
	
	public void service(HttpRequest request,HttpResponse response){
		
		System.out.println("开始登录...");
		String name=request.getParameters("username");
		String psw=request.getParameters("password");
		
		System.out.println("获取的姓名密码为  ："+name+","+psw);
		
		
		try {
			RandomAccessFile raf=new RandomAccessFile("user.dat", "r");
			boolean check=false;
			for(int i=0;i<raf.length()/100;i++){
				raf.seek(i*100);
				System.out.println("ssssssssss");
				byte[] data=new byte[32];
				raf.read(data);
				String username=new String(data,"UTF-8").trim();
				System.out.println("读到的username有："+username);
				if(name.equals(username)){
					raf.read(data);
					String password=new String(data,"UTF-8").trim();
					if(psw.equals(password)){
						System.out.println("匹配成功!");
						System.out.println("读出文件的姓名密码  ："+username+","+password);
						check=true;
						break;
					}
				
				}
			}
			if(check){
				response.setEntity(new File("webapps/myweb/login_success.html"));
				System.out.println("登录成功！");
			}else{
				response.setEntity(new File("webapps/myweb/login_fail.html"));
				System.out.println("登录失败！");
			}
			raf.close();
			
			
		} catch (Exception e) {
			
			e.printStackTrace();
		}
		
		
		
		
		
		
		
	}
	
	
	


}
