package com.webserver.Http;

import java.io.IOException;
import java.io.InputStream;
import java.net.Socket;

/**
 * 请求对象
 * HttpRequest的每一个实例用于表示客户端发过来的一个
 * 具体的请求内容。
 * 一个请求由三部分构成：
 * 请求行 ，消息头， 消息正文
 * @author soft01
 *
 */
public class HttpRequest {//HTTP的请求
	/*
	 * 请求行相关信息定义
	 */
	//请求方式
	private String method;
	//请求资源路径
	private String url;
	//协议版本
	private String protocol;
	//对应客户端的Socket
	private Socket socket;
	//用于读取客户端发送过来消息的输入流
	private InputStream in;
	/*
	 * 消息头的相关定义
	 */
	/*
	 * 消息正文相关信息定义
	 */
	/*
	 * 构造方法，用来初始化HttpRequest（解析请求）
	 */
	public HttpRequest(Socket socket) {//构造方法,传socket获得输入流
		
		
		try {
			this.socket=socket;
			this.in=socket.getInputStream();
			/*
			 * 1.解析请求行
			 * 2.解析消息头
			 * 3.解析消息正文
			 */
			 parseRequestLine();
			 parseHeaders();//调三个方法
			 parseContent();
			 
		} catch (IOException e) {
			e.printStackTrace();
		}
		
	}
	
	
	/*
	 * 解析请求行
	 */
	private void parseRequestLine() {
		try {
			System.out.println("解析请求行...");
			String line=readLine();
			System.out.println("请求行"+line);
			
			/*
			 * 请求行解析步骤：
			 * 1.将请求行的内容按照空格拆分为三部分
			 * 2.分别将三部分内容设置到对应的属性上
			 * method，url，protocol
			 * 
			 * 
			 * 这里将来可能会抛出数组下标越界，原因在于Http协议中也有所提及，
			 * 允许客户端连接后发送请求（实际就是什么也没有发送过来），这
			 * 时候若解析请求行是拆不出三项的。
			 * 后面遇到问题再解决
			 */
			String[] str=line.split(" ");//以空格拆分
			method=str[0];
			url=str[1];
			protocol=str[2];
			System.out.println("method:"+method);
			System.out.println("url:"+url);
			System.out.println("protocol:"+protocol);
			
			System.out.println("请求行解析完毕！");
		}catch(IOException e) {
			e.printStackTrace();
		}
		
	}
	/*
	 * 解析消息头
	 */
	private void parseHeaders() {
		System.out.println("解析消息头...");
		System.out.println("消息头解析完毕！");
	}
	/*
	 * 解析消息文本
	 */
	private void parseContent() {
		System.out.println("解析消息正文...");
		System.out.println("消息正文解析完毕！");
	}
	
	
	
	/*
	 * 读取一行字符串，结束是以连续读取到了CRLF符号为止
	 * 返回的字符串中不包含由最后读取到的CRLF
	 */
	private String readLine()throws IOException {
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


	public String getMethod() {
		return method;
	}


	public String getUrl() {
		return url;
	}


	public String getProtocol() {
		return protocol;
	}
	

}
