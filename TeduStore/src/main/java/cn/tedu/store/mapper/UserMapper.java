package cn.tedu.store.mapper;

import org.apache.ibatis.annotations.Param;

import cn.tedu.store.entity.User;

public interface UserMapper {
	/**
	 * 添加用户
	 * @param user
	 * @return
	 */
	Integer insert(User user);
	/**
	 * 根据用户名查询用户信息
	 * @param username
	 * @return
	 */
	User getUserByUsername(String username);
	/**
	 * 通过id查找用户信息
	 * @param id
	 * @return  
	 */
	User getUserById(Integer id);
	/**
	 * 修改密码
	 * @param id
	 * @param newPassword
	 * @return
	 */
	Integer changePassword(@Param("id")Integer id,@Param("newPassword")String newPassword);
	/**
	 * 修改用户信息
	 * @param user
	 * @return
	 */
	Integer changeInfo(User user);

}
