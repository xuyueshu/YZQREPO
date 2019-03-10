package com.webserver.core;

import java.io.IOException;
import java.io.InputStream;
import java.net.Socket;

/**
 * 处理客户端的请求
 * @author soft01
 *
 */
public class ClientHandler implements Runnable{
	private Socket socket;
	public ClientHandler(Socket socket) {
		this.socket=socket;
	}
	public void run() {
		try {
			//获取客户端
			InputStream in=socket.getInputStream();
//			int d=-1;
//			while((d=in.read())!=-1) {
//				System.out.print((char)d);
//			}
			String line=readLine(in);
			System.out.println("请求行内容："+line);
		}catch(Exception e) {
			
		}finally {
			//处理与客户端断开连接的操作
			try {
				socket.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
	}
	/*
	 * 读取一行字符串，结束是以连续读取到了CRLF符号为止
	 * 返回的字符串中不包含由最后读取到的CRLF
	 */
	private String readLine(InputStream in)throws IOException {
		StringBuilder builder=new StringBuilder();
		int d=-1;
		//c1表示上次读到的字符，c2表示本次读到的字符
		char c1='a',c2='a';
		while((d=in.read())!=-1) {//d为二进制
			c2=(char)d;
			//判断是否连续读取到了CRLF（CR 13,LF 10）
			if(c1==13&&c2==10) {
				break;
			}
			builder.append(c2);
			c1=c2;
			
		}
		
		return builder.toString().trim();//trim()表示把最后的回车去掉
		
	}
	
	

}
