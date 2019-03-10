package cn.tedu.store.service.impl;

import java.util.Date;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.DigestUtils;

import cn.tedu.store.entity.User;
import cn.tedu.store.mapper.UserMapper;
import cn.tedu.store.service.IUserService;
import cn.tedu.store.service.exception.InsertDataException;
import cn.tedu.store.service.exception.PassWordNotMatchException;
import cn.tedu.store.service.exception.UpdateDataException;
import cn.tedu.store.service.exception.UserNotFoundException;
import cn.tedu.store.service.exception.UsernameConflictException;

@Service("userService")
public class UserServiceImpl implements IUserService {
	@Autowired
	private UserMapper userMapper;
	
	/**
  * 注册
  */
	public User reg(User user) throws UsernameConflictException, InsertDataException{
		User result=getUserByUsername(user.getUsername());
		if(result==null) {
			insert(user);
			return user;
		}else {
			throw new UsernameConflictException("该用户名("+user.getUsername()+")已经被注册过");
		}
		
	}
	
	/**
	 * 登录
	 */
	public User login(String username, String password) throws PassWordNotMatchException,UserNotFoundException{
		User result=getUserByUsername(username);
		if(result!=null) {
			String md5Password=getEncrpytedPassword(password, result.getSalt());
			if(md5Password.equals(result.getPassword())) {
				result.setPassword(null);
				result.setSalt(null);//返回的user不能带有密码和盐
				return result;
			}else {
				throw new PassWordNotMatchException("密码错误！");
			}
			
		}else {
			throw new UserNotFoundException("用户不存在！");
		}
	}
	
	/**
	 * 修改密码
	 */
	public void changePasswordByOldPassword(Integer id, String oldPassword, String newPassword) throws PassWordNotMatchException,
	UserNotFoundException{
		User user=getUserById(id);
		if(user!=null) {
			String salt=user.getSalt();
			String mdPassword=getEncrpytedPassword(oldPassword, salt);
			if(mdPassword.equals(user.getPassword())) {
				 userMapper.changePassword(id, getEncrpytedPassword(salt, newPassword));
			}else {
				throw new PassWordNotMatchException("原密码不匹配！");
			}
		}else {
			throw new UserNotFoundException("id为"+id+"的用户不存在！");
		}
		
	}
	/**
	 * 修改个人信息
	 */
	public void changeInfo(User user) throws UpdateDataException ,UserNotFoundException{
		Integer id=user.getId();
		User result=getUserById(id);
		if(result!=null) {
			Date date=new Date();
			user.setModifiedTime(date);
			user.setCreatedUser(user.getUsername()==null?result.getUsername():user.getUsername());
			Integer rows=userMapper.changeInfo(user);
			if(rows!=1) {
			throw new UpdateDataException("修改用户信息时出现未知错误！请联系系统管理员！");	
			}
		}else {
			throw new UserNotFoundException("id为"+id+"的用户不存在！");
		}
	}
	
	
	
	
	
	
	/////////////////////////////////////////工具方法////////////////////////////
	
	/**
	 * 添加用户信息
	 */
	public void insert(User user) throws InsertDataException{
		//TODO 加密密码
		user.getPassword();
		//为用户没有提交的属性设置值
		user.setStatus(1);
		user.setIsDelete(0);
		//设置数据的日志
	
		String salt= getRandomSalt();//通过UUID来加随机盐
		String mdPassword=getEncrpytedPassword(user.getPassword(), salt);
		user.setPassword(mdPassword);
		user.setSalt(salt);
		user.setCreatedUser(user.getUsername());
		Date now=new Date();
		user.setCreatedTime(now);////
		user.setModifiedUser(user.getUsername());
		user.setModifiedTime(now);
		Integer rows=userMapper.insert(user);
		if(rows!=1) {
			throw new InsertDataException("注册时发生未知错误，请联系系统管理员！");
		}
		
	}

	/**
	 * 通过用户名获得用户信息
	 */
	
	public User getUserByUsername(String username) {
		return userMapper.getUserByUsername(username);
	}
	
	
	/**
	 * 获取加密后的密码
	 */
	private String getEncrpytedPassword(String src,String salt) {////

		
		
		//将原密码加密
		String s1=md5(src);
		//将盐加密
		String s2=md5(salt);
		//将原密码和盐拼在一起，五次加密
		String result=s1+s2;
		for(int i=0;i<6;i++) {
			result=md5(result);
		}
		return result;
		
	}
	/**
	 * //密钥（同“密钥”）
	 * 加密
	 * @param src原文
	 * @return  密文
	 */
	private String md5(String src) {
		return DigestUtils.md5DigestAsHex(src.getBytes()).toUpperCase();
		
	}
	
	/**
	 * 获取随机盐
	 * @return
	 */
	private String getRandomSalt() {
		return UUID.randomUUID().toString();
		
	}
/**
 * 通过id查找用户信息
 */
	public User getUserById(Integer id) {
		
		return userMapper.getUserById(id);
	}

	

	

}
