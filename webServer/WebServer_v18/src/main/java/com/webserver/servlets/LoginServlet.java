package com.webserver.servlets;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.RandomAccessFile;

import com.webserver.http.HttpRequest;
import com.webserver.http.HttpResponse;

public class LoginServlet {
	
	public  void service(HttpRequest request,HttpResponse response) {
		System.out.println("开始登录.....");
		
    String username=request.getParameter("username");
		
		String password=request.getParameter("password");
		
		try {
			RandomAccessFile raf
			= new RandomAccessFile("user.dat", "r");		
//		for(int i=0;i<raf.length()/100;i++){
//			//将指针移动到每条开始的位置
//			raf.seek(i*100);
//			//读用户名
//			//连续读取32字节，将其转换为字符串
//			byte[] data = new byte[32];
//			raf.read(data);
//			String username1 = new String(data,"UTF-8").trim();
//			
//			//读密码
//			raf.read(data);
//			String password1 = new String(data,"UTF-8").trim();
//			
//			
//			
//			System.out.println(username1+","+password1);
//			if(username.equals(username1)&&password.equals(password1)) {
//				File file=new File("webapps/myweb/login_success.html");
//				response.setEntity(file);
//				System.out.println("登录成功！");
//				System.out.println(username+","+password);
//				break;
//				
//			}else if(i==raf.length()/100-1){
//				File file=new File("webapps/myweb/login_fail.html");
//				response.setEntity(file);
//				System.out.println("登录失败！");
//				
//			}
//		}
		
			
			//第二种
			boolean check=false;
			for(int i=0;i<raf.length()/100;i++) {
				
			   raf.seek(i*100);
			   byte[] data=new byte[32];
			   raf.read(data);
			   String name=new String(data,"UTF-8").trim();
			   if(name.equals(username)) {
				   raf.read(data);
				   String psw=new String(data,"UTF-8").trim();
				   if(psw.equals(password)) {
					   check=true;
					   break;
				   }
			   }

			}
			if(check) {
				File file=new File("webapps/myweb/login_success.html");
				response.setEntity(file);
				System.out.println("登录成功！");
			}else  {
				File file=new File("webapps/myweb/login_fail.html");
				response.setEntity(file);
				System.out.println("登录失败！");
			}
			
			
			
			
			
			
		raf.close();
		}catch(IOException e) {
			e.printStackTrace();
		}
		
		
		
		
		
	
		
		
	

	
	}
	
	
}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	


