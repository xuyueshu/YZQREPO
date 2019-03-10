package com.webserver.core;

import java.io.IOException;
import java.io.InputStream;
import java.net.Socket;

import com.webserver.Http.HttpRequest;

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
		/*
		 * 1.解析请求
		 * 2.处理请求
		 * 3.响应客户端
		 */
			//
			HttpRequest request=new HttpRequest(socket);
			
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
	
	
	

}
