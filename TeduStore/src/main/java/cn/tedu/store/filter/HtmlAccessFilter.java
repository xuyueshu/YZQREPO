package cn.tedu.store.filter;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class HtmlAccessFilter implements Filter {
	/**
	 * 允许直接访问的html文件
	 */
	private List<String> accessiableHtml;
	
	public void init(FilterConfig config) throws ServletException {
		System.out.println("HtmlAccessFilter的init方法");
		//穷举允许直接访问的html文件
		accessiableHtml=new ArrayList<String>();
		accessiableHtml.add("register.html");
		accessiableHtml.add("login.html");
		accessiableHtml.add("index.html");
		accessiableHtml.add("goods_details.html");
		System.out.println("可以直接访问的html文件有 ："+accessiableHtml);
		
	}
	
	public void doFilter(ServletRequest arg0, ServletResponse arg1, FilterChain filterChain)
			throws IOException, ServletException {
		System.out.println("HtmlAccessFilter的doFilter方法");
		HttpServletRequest request=(HttpServletRequest)arg0;
		HttpServletResponse response=(HttpServletResponse)arg1;
		String uri=request.getRequestURI();
		System.out.println(uri);
		String[] pathArray=uri.split("/");
		String file=pathArray[pathArray.length-1];
		System.out.println("file="+file);
		
		if(accessiableHtml.contains(file)) {
			filterChain.doFilter(arg0, arg1);
		}else {
			//
			HttpSession session=request.getSession();
			if(session.getAttribute("uid")!=null) {
				filterChain.doFilter(arg0, arg1);
				return;
			}
			response.sendRedirect(request.getContextPath()+"/web/login.html");
		}
		
	}

	public void destroy() {
		System.out.println("HtmlAccessFilter的destroy方法");
	}

}
