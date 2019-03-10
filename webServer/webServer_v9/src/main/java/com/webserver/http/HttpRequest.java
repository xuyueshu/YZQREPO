package com.webserver.http;

import java.io.IOException;
import java.io.InputStream;
import java.net.Socket;
import java.util.HashMap;
import java.util.Map;

import javax.sound.sampled.Line;

/**
 * 请求对象
 * HttpRequest的个一个实例用于客户端发送过来的一个具体的请求内容。
 * 一个请求由三个部分组成：
 * 请求行，消息头，消息正文
 * @author soft01
 *
 */
public class HttpRequest {
	/*
	 * 请求行相关信息定义
	 */
	//请求方式
	private String method;
	//请求资源路径
	private String url;
	//协议版本
	private String protocol;
	
	/*
	 * 消息头相关信息定义
	 */
	private Map<String,String>headers=new HashMap<String,String>();
	
	/*
	 * 消息正文相关信息定义
	 */
	
	
	//对应客户端的Socket
	private Socket socket;
	
	//用于读取客户端发送过来的消息的输入流
	private InputStream in;
	
	
	
	/*
	 *构造方法，用来初始化HttpReqeust            
	 */
	public HttpRequest(Socket socket) {
		try {
			this.socket=socket;
			this.in=socket.getInputStream();
			/*
			 * 1.解析请求行
			 * 2.解析消息头
			 * 3.解析消息正文
			 */
			parseRequestLine();
			pareseHeaders();
			parseContent();//调用这三种方法
			
		} catch (IOException e) {
			
			e.printStackTrace();
		}
		
	}
	
	
	/*
	 * 解析请求行
	 */
	private void parseRequestLine() {
		try {
			System.out.println("解析请求行....");
			
			String line=readLine();
			System.out.println("请求行："+line);
			/*
			 * 解析请求行的步骤：
			 * 1：将请求行的内容按空格拆分为三部分
			 * 2：分别将三部分的内容设置到对应的属性上
			 * method，url,protocol
			 * 
			 * 
			 * 
			 * 
			 * 这里将来可能会抛出数组下标越界，原因在于HTTP协议中也有所提及，
			 * 允许客户端发空请求（实际什么也没发送过来），这时候若解析请求行
			 * 是拆分不出三项的。
			 * 后面遇到再解决
			 */
			String []str=line.split(" ");//   \\s也代表空格
			method=str[0];
			url=str[1];
			protocol=str[2];
			
			System.out.println("method:"+method);
			System.out.println("url:"+url);
			System.out.println("protocol:"+protocol);
			System.out.println("请求行解析完毕");
			
		}catch(Exception e) {
			
		}
		
	}
	/*
	 * 解析消息头
	 */
	private void pareseHeaders() {
		try {
			/*
			 * 循环调用readLine方法读取每一行字符串，如果循环读取到的字符串为空字符串，
			 * 则表示单独读取到了CRLF，那么表示消息头部分读取完毕，停止循环即可。
			 * 否则读取一行字符串后应当是一个消息头的内容，接下来将该字符串按照“：拆分为
			 * 两项，第一项是消息头的名字，第二项为对应的值，存入到属性Headers即可。
			 */
			System.out.println("解析消息头.....");
			while(true) {
				String line=readLine();
				//单独读取到了CRLF
				if(line.equals("")) {
					break;
				}
				String[]chs=line.split(": ");
				headers.put(chs[0], chs[1]);
				
			}
			System.out.println(headers);
			
		}catch(Exception e ) {
			e.printStackTrace();
		}
		System.out.println("消息头解析完毕");
	}
	/*
	 * 解析消息正文
	 */
	private void parseContent() {
		System.out.println("解析消息正文....");
		
		System.out.println("消息头解析完毕");
		
	}
	
	/*
	 * 读取一行字符串，结束是以连续读取到了CRLF符号为止
	 * 返回的字符串中不包含最后读取到的CRLF
	 * 
	 */
	private String readLine() throws IOException{
		StringBuilder builder=new StringBuilder();
		int d=-1;
		//c1表示上次读取到的字符，c2表示本次读取到的字符
		char c1='a',c2='a';
		while((d=in.read())!=-1) {
			c2=(char)d;
			//判断是否读取到了CRLF
			if(c1==13&&c2==10) {
				break;
			}
			builder.append(c2);
			c1=c2;
		}
		return builder.toString().trim();
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
























