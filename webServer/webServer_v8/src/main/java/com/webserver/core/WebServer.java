package com.webserver.core;

import java.io.IOException;
import java.io.InputStream;
import java.net.ServerSocket;
import java.net.Socket;

/**
 * WebServer主类
 * @author soft01
 *
 */
public class WebServer {
	private ServerSocket server;//
	/*
	 * 构造方法
	 */
   public WebServer(){
	   try {
		   
		   System.out.println("正在启动服务端......");
		   server=new ServerSocket(8088);
		   System.out.println("服务器启动完毕!");
	   }catch(Exception e) {
		   e.printStackTrace();
	   }
	   /*
	    * 服务端启动方法
	    */
	   
	  
   }
   public void start() {
	   
	   try {
		   /*
		    * 循环接收客户端请求的工作暂时不启动. 测试阶段只接收一次请求
		    */
		   while(true) {
			   System.out.println("等待客户端....");
				Socket socket=server.accept();
				System.out.println("一个客户端连接上了!");
				//
				ClientHandler handler=new ClientHandler(socket);//clienthandler用来处理客户请求
				Thread thread =new Thread(handler);
				thread.start();
				
		   }
		
	} catch (IOException e) {
		
		e.printStackTrace();
	}
	   
	   
   }
   public static void main(String[] args) {
	   WebServer server=new WebServer();
	   server.start();
	   
	
}

}
