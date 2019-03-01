package com.yzq.springboot.mapper;

import com.yzq.springboot.bean.User;

public interface UserMapper {
	/**
	 * 通过账号名获取用户信息
	 * @return
	 */
	User getUserByCount(String account);
	/**
	 * 添加角色为学生的角色
	 * @param user
	 * @return
	 */
	Integer addStudentUser(User user);
}
