package com.webserver.core;

import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;

public class WebServer {
	private ServerSocket server;
	public WebServer(){
		
		
		try {
			
				System.out.println("正在启动服务器.....");
				server=new ServerSocket(ServerContext.port);
				System.out.println("服务器启动成功.!");
			
			
		
		} catch (IOException e) {
			e.printStackTrace();
		}
		
	}
	
	public void start() {
		
		try {
			while(true){
				System.out.println("开始连接客户端....");
				Socket socket=server.accept();
				System.out.println("一个客户端成功连接！");
				ClientHandler handler=new ClientHandler(socket);
				Thread thread=new Thread(handler);
				thread.start();
			}
			
		} catch (IOException e) {
			e.printStackTrace();
		}
		
	}
	
	public static void main(String[] args) {
		WebServer webServer=new WebServer();
		webServer.start();
	}

}
