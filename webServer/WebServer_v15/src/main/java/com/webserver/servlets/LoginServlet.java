package com.webserver.servlets;

import java.io.File;
import java.io.RandomAccessFile;

import com.webserver.http.HttpRequest;
import com.webserver.http.HttpResponse;

public class LoginServlet {
	public void service(HttpRequest request,HttpResponse response) {
		System.out.println("开始登陆");
		String username=request.getParameters("username");
		String possword=request.getParameters("possword");
		System.out.println("username:"+username+"possword:"+possword);
		
		try {
			RandomAccessFile raf=new RandomAccessFile("user.dat", "r");
			//登陆状态：默认值为：登录失败
			boolean check=false;
			for(int i=0;i<raf.length()/100;i++) {
				//将指针移动到该条记录的初始位置
				raf.seek(i*100);
				byte[]data=new byte[32];
				raf.read(data);
				String username1=new String(data,"utf-8").trim();
				//查看是否为该用户
				if(username1.equals(username)) {
					//找到该用户
					//读取该用户的密码
					raf.read(data);
					String password=new String(data,"utf-8").trim();
					
					if(password.equals(possword)) {
						//密码正确
						check=true;
						break;
					}
					
				}
			}//循环结束
			
			if(check) {
				//调转到成功页面
				File file=new File("webapps/myweb/login_success.html");
				response.setEntity(file);
			}else {
				File file=new File("webapps/myweb/login_fail.html");
				response.setEntity(file);
			}
			raf.close();
			
			
			
			
//		for(int i=0;i<raf.length()/100;i++){
//			raf.seek(i*100);
//			//读用户名
//			//连续读取32字节，将其转换为字符串
//			byte[] data = new byte[32];
//			raf.read(data);
//			String username1 = new String(data,"UTF-8").trim();
//			
//			//读密码
//			raf.read(data);
//			String password = new String(data,"UTF-8").trim();
//			
//			
//			
//			
//			if(username.equals(username1)&&possword.equals(password)) {
//				System.out.println("登陆成功！");
//				File file=new File("webapps/myweb/login_success.html");
//				response.setEntity(file);
//			}else if(i==raf.length()/100-1){
//				System.out.println("登录失败");
//				File file=new File("webapps/myweb/login_fail.html");
//				response.setEntity(file);
//			}
//		}
//		raf.close();
		}catch(Exception e) {
			e.printStackTrace();
		}
		
	
		
		
		
		
		
		
		
		
		
		
		
		
		
	}
	
	
}
