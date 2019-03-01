package com.yzq.springboot.controller;

import javax.servlet.http.HttpSession;

import org.springframework.web.bind.annotation.ExceptionHandler;

import com.yzq.springboot.bean.ResponseResult;
import com.yzq.springboot.bean.User;
import com.yzq.springboot.service.exception.ResourceNotFoundException;
import com.yzq.springboot.service.exception.ResourceNotMatchException;
import com.yzq.springboot.service.exception.ServiceException;

public abstract class BaseController {
	
	@ExceptionHandler(ServiceException.class)
	public ResponseResult<Void> handleException(ServiceException e){
		if(e instanceof ResourceNotFoundException) {
			return new ResponseResult<Void>(401,e);
		}else if(e instanceof ResourceNotMatchException) {
			return new ResponseResult<Void>(402,e);
		}else {
			return new ResponseResult<Void>(403,e);
		}
		
	}
	/**
	 * 从session中获取用户的id
	 * @param session
	 * @return
	 */
	public Integer getUidBySession(HttpSession session) {
		User user=(User)session.getAttribute("user");
		return user.getId();
	}
	
	/**
	 * 从session中获取用户的teacherid
	 * @param session
	 * @return
	 */
	public Integer getTeacherIdBySession(HttpSession session) {
		User user=(User)session.getAttribute("user");
		return user.getTeacherId();
	}
	
	/**
	 * 从session中获取用户的adminId
	 * @param session
	 * @return
	 */
	public Integer getAdminIdBySession(HttpSession session) {
		User user=(User)session.getAttribute("user");
		return user.getAdminId();
	}
	/**
	 * 从session中获取用户的studentId
	 * @param session
	 * @return
	 */
	public Integer getStudentIdBySession(HttpSession session) {
		User user=(User)session.getAttribute("user");
		return user.getStudentId();
	}
}
