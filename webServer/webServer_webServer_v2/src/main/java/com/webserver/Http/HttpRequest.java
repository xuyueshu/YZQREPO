package com.webserver.Http;

import java.io.IOException;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.net.Socket;
import java.net.URLDecoder;
import java.util.HashMap;
import java.util.Map;

import com.webserver.core.ServerContext;

public class HttpRequest {
	
	private Socket socket;
	private InputStream in;
	private String protocol;
	
	private String url;
	
	private String method;
	private String requestURI;
	private String queryString;
	private Map<String,String> parameters=new HashMap<String,String>();
	private Map<String,String>headers=new HashMap<String,String>();
	
	public HttpRequest(Socket socket)  throws EmptyRequestException{
		
		
		try {
			this.in=socket.getInputStream();
			this.socket=socket;
		} catch (IOException e) {
			e.printStackTrace();
		}
		
		/*
		 * 1.解析请求行
		 * 2.解析消息头
		 * 3.解析消息正文
		 * 
		 */
		parseRequestLine();
		parseURL();
		parseHeaders(); 
		parseContent();
		
	}
	
	
	private void parseRequestLine() throws EmptyRequestException {
		
		
		try {
			System.out.println("开始解析请求行...");
			String line = readLine(in);
			System.out.println("请求行的内容为： "+line);
			String[] str=line.split("\\s");
			if(str.length<3){
				throw new EmptyRequestException();
			}
			method =str[0];
			url=str[1];
			protocol=str[2];
			System.out.println("method  :"+method);
			System.out.println("url  :"+url);
			System.out.println("protocol  :"+protocol);
			System.out.println("请求行解析完毕！");
		} catch (IOException e) {
			e.printStackTrace();
		}
		
	}
	//进一步解析url
	private void parseURL(){
		
		try {
			System.out.println("。。。。开始进一步解析url...");
			this.url=URLDecoder.decode(url,ServerContext.URIEncoding);
		} catch (UnsupportedEncodingException e) {
			
			e.printStackTrace();
		}
		if(url.contains("?")){
			System.out.println("包含？问号。。。。。");
			String[] str=url.split("\\?");
			requestURI=str[0];
			queryString=str[1];
			parseParameters(queryString);
			
		}else{
			System.out.println("不包含？问号。。。。。");
			requestURI=url;
			queryString=null;
		}
		System.out.println("进一步解析url完毕！！");
		System.out.println("requestURI :"+requestURI);
		System.out.println("parameters  :"+parameters);
		
	}
	
	//定义parameters方法
	private void parseParameters(String parseLine){
		String[] que=parseLine.split("&");
		for(String qu:que){
			String[] q=qu.split("=");
			if(q.length>1){
				parameters.put(q[0], q[1]);
			}else{
				parameters.put(q[0], null);
			}
			
		}
	}
	
	
	private void parseHeaders() {
		try {
			System.out.println("开始解析消息头.....");
			while(true) {
				
				String line=readLine(in);
				if(!"".equals(line)) {
					String[] str=line.split(": ");
					headers.put(str[0], str[1]);
					
				}else {
					break;
				}
				
				
			}
			System.out.println("输出headers为：  "+headers);
			System.out.println("消息头解析完毕！");
		}catch(Exception e) {
			e.printStackTrace();
		}
		
	}
	
	private void parseContent() {
		System.out.println("开始解析消息正文...");
		if(headers.containsKey("Content-Length")){
			int length=Integer.parseInt(headers.get("Content-Length"));
			System.out.println("消息正文长度为： "+length);
			
			try {
				byte[] data=new byte[length];
				in.read(data);
				String ContentType=headers.get("Content-Type");
				if("application/x-www-form-urlencoded".equals(ContentType)){
					System.out.println("开始解析Post提交的form表单....");
					String line=new String(data,"ISO8859-1");
					line=URLDecoder.decode(line,ServerContext.URIEncoding);
					parseParameters(line);
					
				}
			} catch (IOException e) {
				e.printStackTrace();
			}
		}else{
			
		}
		
		System.out.println("消息正文解析完毕！");
	}
	

	
	
	//读取
	public String readLine(InputStream in) throws IOException {
		StringBuilder builder=new StringBuilder();
		int d=-1;
		char c1='a',c2='a';
		while((d=in.read())!=-1) {
			c2=(char)d;
			if(c1==HttpContext.CR&&c2==HttpContext.LF) {
				break;
			}
			builder.append(c2);
			c1=c2;
		}
		return builder.toString().trim();
	
		
		
	}

	//获取method url protocol方法
	public String getProtocol() {
		return protocol;
	}


	public String getUrl() {
		return url;
	}


	public String getMethod() {
		return method;
	}

	//获取requestURI和parameters方法
	public String getRequestURI() {
		return requestURI;
	}


	public String getParameters(String name) {
		return parameters.get(name);
	}
	
	
	
	
	
	
	
}
