package com.yzq.springboot.service;

import com.yzq.springboot.bean.User;

public interface IUserService {
	/**
	 * 登录
	 * @param account
	 * @param password
	 * @return 
	 */
	User login(String account,String password);
	/**
	 * 添加角色为学生的角色
	 * @param user
	 * @return
	 */
	Integer addStudentUser(User user,Integer leaderTeacherId);

}
