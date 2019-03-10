package com.webserver.http;

import java.io.IOException;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.net.Socket;
import java.net.URLDecoder;
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
	
	//url中请求的部分 url中“？”左侧内容
	private String requestURI;
	//url中参数部分 url中“？”右侧的内容
	private String queryString;
	//所有的参数
	private Map<String,String>parameters=new HashMap<String,String>();
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
	public HttpRequest(Socket socket) throws EmptyRequestException{
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
			if(str.length<3) {
				//空请求
				throw new EmptyRequestException();
			}
			method=str[0];
			url=str[1];
			//进一步解析url
			parseUrl();
			protocol=str[2];
			
			System.out.println("method:"+method);
			System.out.println("url:"+url);
			System.out.println("protocol:"+protocol);
			System.out.println("请求行解析完毕");
			
		}catch(Exception e) {
			e.printStackTrace();
		}
		
		
	}
	//进一步解析Url部分
	private void parseUrl() {
		//首先将url进行转码，将含有的%xx内容转换为对应的字符
		/*
		 * 例如：
		 * 原url的样子大致为：
		 *myweb/login?username=%E5%BC%A0%E4%B8%89
		 * 
		 * 经过：URLDecoder.decode(url,"utf-8)后，得到字符串的样子为：
		 * /myweb/login?username=张三
		 * 
		 */
		
		try {
			this.url=URLDecoder.decode(url, "utf-8");
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		
		/*
		 * 1:先判断当前url是否含有参数部分（是否含有“？”）
		 * 	若没有参数部分，直接将url赋值给requestURI
		 * 	含有问号才进行下面的操作
		 * 2：按照？将url才分为两个部分
		 * 	 将？之前的内容设置到属性requestURI上
		 *   将？子之后的内容设置到属性queryString上
		 * 3：将queryString内容进行进一步解析
		 * 	首先按照“&“拆分每一个参数，然后将每一个参数按照”=“
		 * 拆分为参数名与参数值，并put到属性parameters这个Map中。
		 */
		if(!url.contains("?")) {
			requestURI=url;
		}else {
			int index=url.indexOf("?");
			requestURI=url.substring(0, index);
			queryString=url.substring(index+1);
			String[]dou=queryString.split("&");
			for(String d:dou) {
				String[]sim=d.split("=");
				/*
				 * 这里判断dou.length>1的原因是因为，如果在单位表中某个输入框没有输入值
				 * 那末传递过来的数据会是：
				 * myweb/reg?username=&password=123&...
				 * 向用户名这样，如果没有输入，=右边时没有内容的，拆分后不判断数组长度
				 * 的会导致由下标越界的情况。
				 */
				
				
				if(sim.length>1) {
					parameters.put(sim[0], sim[1]);
				}else {
					parameters.put(sim[0], null);
				}
			}
		}
		
		
		System.out.println("requestURI:"+requestURI);
		System.out.println("queryString:"+queryString);
		System.out.println("parameters"+parameters);
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
			if(c1==HttpContext.CR&&c2==HttpContext.LF) {
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


	public String getRequestURI() {
		return requestURI;
	}


	public String getQueryString() {
		return queryString;
	}
	
	/**
	 * 根据给定的参数名获取对应的参数值
	 * @param name
	 * @return
	 */
	
	public String getParameters(String name) {
		return this.parameters.get(name);
	}
	

}
























