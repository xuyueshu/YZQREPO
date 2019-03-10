package com.webserver.demo;


import java.io.IOException;
import java.io.RandomAccessFile;
import java.sql.Date;

/**
 * 显示user.dat文件中所有用户信息
 * @author
 *
 */
public class ShowAllUserDemo {
	public static void main(String[] args) throws IOException {
		RandomAccessFile raf
			= new RandomAccessFile("user.dat", "r");		
		for(int i=0;i<raf.length()/100;i++){
			//读用户名
			//连续读取32字节，将其转换为字符串
			byte[] data = new byte[32];
			raf.read(data);
			String username = new String(data,"UTF-8").trim();
			
			//读密码
			raf.read(data);
			String password = new String(data,"UTF-8").trim();
			
			//读昵称
			raf.read(data);
			String nickname = new String(data,"UTF-8").trim();
			
			//读年龄
			int age = raf.readInt();
			System.out.println(username+","+password+","+nickname+","+age);
		}
		
		raf.close();
	}
}

