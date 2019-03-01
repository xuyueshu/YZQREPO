package com.yzq.springboot.service.impl;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.yzq.springboot.bean.Clazz;
import com.yzq.springboot.bean.Student;
import com.yzq.springboot.bean.User;
import com.yzq.springboot.mapper.ClazzMapper;
import com.yzq.springboot.mapper.StudentMapper;
import com.yzq.springboot.mapper.UserMapper;
import com.yzq.springboot.service.IUserService;
import com.yzq.springboot.service.exception.ResourceNotFoundException;
import com.yzq.springboot.service.exception.ResourceNotInsertException;
import com.yzq.springboot.service.exception.ResourceNotMatchException;
@Service("userService")
public class UserServiceImpl implements IUserService {
	@Autowired
	private UserMapper userMapper;
	@Autowired
	private ClazzMapper clazzMapper;
	@Autowired
	private StudentMapper studentMapper;
	
	@Override
	public User login(String account, String password)throws ResourceNotMatchException ,ResourceNotFoundException{
		User user=getUserByAccount(account);
		String pwd=user.getPassword();
		if(!password.equals(pwd)) {
			throw new ResourceNotMatchException("密码不正确");
		}
		return user;
	}
	/**
	 * 添加角色为学生的用户
	 */
	@Override
	@Transactional
	public Integer addStudentUser(User user, Integer leaderTeacherId) {
		Clazz clazz=clazzMapper.getClazzByleaderTeacherId(leaderTeacherId);
		String name=user.getName();
		Student<Void> student=new Student<Void>();
		student.setName(name);
		student.setClazzId(clazz.getId());
		student.setGradeId(clazz.getGradeId());
		Integer addStudentRows=studentMapper.addStudent(student);
		if(addStudentRows!=1) {
			throw new ResourceNotInsertException("学生列表添加失败！");
		}
		Integer studentId=student.getId();
		user.setStudentId(studentId);
		if(user.getPassword()==null) {
		  user.setPassword("111111");
		}
		
		Integer addUserRows=userMapper.addStudentUser(user);
		if(addUserRows!=1) {
			throw new ResourceNotInsertException("学生用户添加失败！");
		}
		return addUserRows;
	}
	
	
	////////////////工具方法//////////////
	
	private User getUserByAccount(String account) throws ResourceNotFoundException{
		
		User user=userMapper.getUserByCount(account);
		if(user==null) {
			throw new ResourceNotFoundException("该用户不存在！");
		}
		return user;
	}


	

}
