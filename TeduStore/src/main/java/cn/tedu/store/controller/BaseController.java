package cn.tedu.store.controller;

import javax.servlet.http.HttpSession;

import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseBody;

import cn.tedu.store.entity.ResponseResult;
import cn.tedu.store.service.exception.AddressNotFoundException;
import cn.tedu.store.service.exception.ArgumentException;
import cn.tedu.store.service.exception.GoodsCategoryNotFoundException;
import cn.tedu.store.service.exception.GoodsNotFoundException;
import cn.tedu.store.service.exception.IdNotFoundException;
import cn.tedu.store.service.exception.InsertDataException;
import cn.tedu.store.service.exception.PassWordNotMatchException;
import cn.tedu.store.service.exception.ResourceNotFoundException;
import cn.tedu.store.service.exception.ServiceException;
import cn.tedu.store.service.exception.UpdateDataException;
import cn.tedu.store.service.exception.UserNotFoundException;
import cn.tedu.store.service.exception.UsernameConflictException;

public abstract class BaseController {
	@ExceptionHandler(ServiceException.class)
	@ResponseBody
	public ResponseResult<Void> handleException(ServiceException e) {
		
		if(e instanceof UsernameConflictException) {
			return new ResponseResult<Void>(401,e);
		}else if(e instanceof InsertDataException) {
			return new ResponseResult<Void>(501,e);
		}else if(e instanceof ServiceException){
			return new ResponseResult<Void>(505,e);
		}else if(e instanceof PassWordNotMatchException){
			return new ResponseResult<Void>(506,e);
		}else if(e instanceof UpdateDataException){
		}else if(e instanceof UserNotFoundException){
			return new ResponseResult<Void>(507,e);
		}else if(e instanceof IdNotFoundException) {
			System.out.println("aaaaaaaaaaaaaaa");
			return new ResponseResult<Void>(508,e);
		}else if(e instanceof AddressNotFoundException){
			return new ResponseResult<Void>(509,e);
		}else if(e instanceof ArgumentException){
			return new ResponseResult<Void>(600,e);
		}else if(e instanceof GoodsCategoryNotFoundException){
			return new ResponseResult<Void>(602,e);
		}else if(e instanceof GoodsNotFoundException){
			return new ResponseResult<Void>(603,e);
		}else if(e instanceof ResourceNotFoundException){
			return new ResponseResult<Void>(604,e);
		}else {
			return new ResponseResult<Void>(601,e);
		}
		return new ResponseResult<Void>(601,e);
		  
		}
		
	
	//获取uid的方法写在父类中
	protected final Integer getUidFromSession(HttpSession session) {//为了让子类使用，将访问权限设置为protected//设计final意为只能被调用，不让子类重写
		try {
			Integer id=Integer.valueOf(session.getAttribute("uid").toString());
			return id;
		}catch(NullPointerException e) {
			throw new IdNotFoundException("id找不到！");
		}
	}
	
	
	
	}

