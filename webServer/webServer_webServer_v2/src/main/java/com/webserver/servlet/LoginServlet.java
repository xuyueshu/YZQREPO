package com.webserver.servlet;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.RandomAccessFile;

import com.webserver.Http.HttpRequest;
import com.webserver.Http.HttpResponse;
import com.webserver.core.ServerContext;

public class LoginServlet extends HttpServlet{
	
	public void service(HttpRequest request,HttpResponse response){
		
		String name=request.getParameters("username");
		String psw=request.getParameters("password");
		
		try {
			RandomAccessFile raf=new RandomAccessFile("user.dat", "r");
			boolean check=false;
			for(int i=0;i<raf.length()/100;i++){
				raf.seek(100*i);
				byte[] data=new byte[32];
				raf.read(data);
				String username=new String(data,ServerContext.URIEncoding).trim();
				if(name.equals(username)){
					System.out.println("用户名匹配成功！");
					raf.read(data);
					String password=new String(data,ServerContext.URIEncoding).trim();
					if(psw.equals(password)){
						System.out.println("密码匹配成功！");
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
		} catch (Exception e) {
			
			e.printStackTrace();
		}
		
		
	}

}
