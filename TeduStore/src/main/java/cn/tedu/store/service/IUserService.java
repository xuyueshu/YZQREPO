package cn.tedu.store.service;

import cn.tedu.store.entity.User;
import cn.tedu.store.service.exception.InsertDataException;
import cn.tedu.store.service.exception.PassWordNotMatchException;
import cn.tedu.store.service.exception.UpdateDataException;
import cn.tedu.store.service.exception.UsernameConflictException;
import cn.tedu.store.service.exception.UserNotFoundException;

public interface IUserService {
	/**
	 * 注册
	 * @param user
	 * @return
	 * @throws UsernameConflictException 
	 * @throws InsertDataException
	 */
	User reg(User user)throws UsernameConflictException, InsertDataException;
	/**
	 * 添加信息
	 * @param user
	 * @throws InsertDataException
	 */
	void insert(User user)throws InsertDataException;
	/**
	 * 通过用户名查询用户信息
	 * @param username
	 * @return
	 */
	User getUserByUsername(String username);
	/**
	 * 登录
	 * @param username
	 * @param password
	 * @return
	 * @throws PassWordNotMatchException
	 * @throws UserNotFoundException
	 */
	User login(String username,String password) throws PassWordNotMatchException,UserNotFoundException;
	/**
	 * 通过id查询用户信息
	 * @param id
	 * @return
	 */
	User getUserById(Integer id);
	/**
	 * 修改密码
	 * @param id
	 * @param oldPassword
	 * @param newPassword
	 * @throws PassWordNotMatchException
	 * @throws UserNotFoundException
	 */
	void changePasswordByOldPassword(Integer id,String oldPassword,String newPassword)throws PassWordNotMatchException,
	UserNotFoundException;
	/**
	 * 修改个人信息
	 * @param user
	 * @throws UpdateDataException
	 * @throws UserNotFoundException
	 */
	void changeInfo(User user)throws UpdateDataException ,UserNotFoundException;
	
}
