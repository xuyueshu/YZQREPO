package com.webserver.servlets;

import com.webserver.http.HttpRequest;
import com.webserver.http.HttpResponse;

/**
 * 该类是所有Servlet的超类，规定了所有Servlet具有的
 * 相同行为
 * @author soft01
 *
 */
public abstract class HttpServlet {
	/**
	 * 这里定义一个抽象方法service，要求所有的Servlet都必须
	 * 含有该方法，用于处理业务。但是由于不同 的Servlet处理的
	 * 业务不同，对此，该方法才是抽象的。
	 */
	
	public abstract void service(HttpRequest request,HttpResponse response);

}
