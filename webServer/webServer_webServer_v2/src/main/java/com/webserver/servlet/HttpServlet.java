package com.webserver.servlet;

import com.webserver.Http.HttpRequest;
import com.webserver.Http.HttpResponse;

public abstract class HttpServlet {
	
	public abstract void service(HttpRequest request,HttpResponse response);


}
