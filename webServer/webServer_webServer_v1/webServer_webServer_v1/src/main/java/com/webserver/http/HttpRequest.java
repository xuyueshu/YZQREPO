package com.webserver.http;

import java.io.IOException;
import java.io.InputStream;
import java.net.Socket;
import java.util.HashMap;
import java.util.Map;

public class HttpRequest {
	
	private Socket socket;
	
	private String method;//方法
	
	private String url;//路径
	
	private String protocol;//协议版本
	
	private InputStream in;
	
	private String requestURI;//问号左边的
	
	private String queryString;//问号右边的
	//参数
	private Map<String,String>parameters=new HashMap<String,String>();
	
	private Map<String,String> headers=new HashMap<String,String>();
	
	//构造方法，初始化
	public HttpRequest(Socket socket) throws EmptyRequestException{
		
		try {
			this.socket=socket;
			in=socket.getInputStream();
		} catch (IOException e1) {
			e1.printStackTrace();
		}
		/*
		 * 请求行，消息头，消息正文
		 */
		parseRequestLine();
		parseHeaders();
		parseContent();
		 parseUrl();
		
		
		
		
		
		try {
			InputStream in=socket.getInputStream();
		} catch (IOException e) {
 			
			e.printStackTrace();
		}
		
		
	}
	
	//解析请求行：
	private void parseRequestLine() throws EmptyRequestException{
		
		
		try {
			System.out.println("解析请求行");
			String line=readLine(in);
			System.out.println("请求行： "+line);
			String[] str=line.split("\\s");
			if(str.length<3){
				throw new EmptyRequestException();
			}
			
			method=str[0];
			url=str[1];
			protocol=str[2];
			
			System.out.println("method: "+method);
			System.out.println("url: "+url);
			System.out.println("protocol: "+protocol);
			
			System.out.println("解析完毕！");
		} catch (IOException e) {
			e.printStackTrace();
		}
		
		
	}
	
	//进一步解析url
	private void parseUrl() {
		
		if(url.contains("?")) {
			int index=url.indexOf("?");
			requestURI=url.substring(0,index);
			queryString=url.substring(index+1);
			System.out.println("此处的queryString:"+queryString);
			String[] query=queryString.split("&");
			for(String qu:query) {
				String[] q=qu.split("=");
				
				if(q.length>1) {
					parameters.put(q[0], q[1]);
				}else {
					parameters.put(q[0], null);
				}
				
				
			}
			System.out.println(parameters);
			
		}else {
			requestURI=url;
			queryString=null;
		}
		System.out.println("此时的requestURI为：    "+requestURI);
	}
	
	
	
	//解析消息头
	private void parseHeaders() {
		
		try {
			System.out.println("解析消息头..");
			
			
			while(true) {
				String line=readLine(in);
				if(!"".equals(line)) {
					
					String[] str=line.split(":");
					
					headers.put(str[0], str[1]);
					
				}else {
					break;
				}
				
			}
			System.out.println(headers);
			
			System.out.println("解析完毕！");
		} catch (IOException e) {
			e.printStackTrace();
		}
		
	}
	
	
	
	//消息正文
	private void parseContent() {
		System.out.println("解析消息正文");
		System.out.println("解析完毕！");
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
			if(c1==HttpContext.CR&&c2==HttpContext.LF) {
				break;
			}
			builder.append(c2);
			c1=c2;
			
			
		}
		
		return builder.toString().trim();//trim()表示把最后的回车去掉
		//最后一个CRLF相当于下一行读取
	}

	
	//获取方法
	public String getMethod() {
		return method;
	}

	public String getUrl() {
		return url;
	}

	public String getProtocol() {
		return protocol;
	}
	//获取参数parameters
	public String  getParameters(String name) {
		return parameters.get(name);
	}
	
	public String getRequestURI() {
		return requestURI;
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	

}
