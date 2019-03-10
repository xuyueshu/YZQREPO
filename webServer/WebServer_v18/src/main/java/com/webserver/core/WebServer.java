package com.webserver.core;

import java.io.IOException;
import java.io.InputStream;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * WebServer主类
 * @author soft01
 *
 */
public class WebServer {
	private ServerSocket server;
	//管理线程的线程池
  private ExecutorService threadPool;
	/*
	 * 构造方法用来初始化服务端
	 */
	public WebServer() {
		try {
			System.out.println("正在启动服务端...");
			server=new ServerSocket(ServerContext.port);
			
			//建一个线程池
			threadPool =Executors.newFixedThreadPool(ServerContext.maxThreads);
			System.out.println("服务端启动完毕！");
		} catch (IOException e) {
			e.printStackTrace();
		}
		
	}
	/*
	 * 启动服务端方法
	 */
	public void start() {
		try {
			/*
			 * 循环接受客户端请求的工作暂不启动，测试阶段只接受一次请求
			 */
			while(true) {
			System.out.println("等待客户端...");
			Socket socket=server.accept();
			System.err.println("一个客户端连接了！");
			
			//启动一个线程来处理该客户端的请求
			
			ClientHandler handler=new ClientHandler(socket);
//			Thread thread=new Thread(handler);
//			thread.start();
			
			//将任务丢给线程池来执行
			threadPool.execute(handler);
			
			
		}
		}catch(Exception e) {
			e.printStackTrace();
		}
		
	}
	public static void main(String[] args) {
		WebServer server=new WebServer();
		server.start();
	}

}

























