package cn.tedu.store.intercepter;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;

public class LoginIntercepter implements HandlerInterceptor {

	public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler)
			throws Exception {
		System.out.println("LoginIntercepter的preHandle方法");
		HttpSession session =request.getSession();
		if(session.getAttribute("uid")!=null) {
			return true;
		}else {
			response.sendRedirect(request.getContextPath()+"/web/login.html");
			return false;
		}
	
	}

	public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler,
			ModelAndView modelAndView) throws Exception {
		System.out.println("LoginIntercepter的postHandle方法");
	}

	public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex)
			throws Exception {
		System.out.println("LoginIntercepter的afterCompletion方法");
	}

}
