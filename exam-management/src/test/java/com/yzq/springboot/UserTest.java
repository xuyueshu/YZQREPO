package com.yzq.springboot;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import com.yzq.springboot.bean.Role;
import com.yzq.springboot.bean.User;
import com.yzq.springboot.mapper.UserMapper;
import com.yzq.springboot.service.IRoleService;
import com.yzq.springboot.service.IUserService;
import com.yzq.springboot.service.exception.ServiceException;

@RunWith(SpringJUnit4ClassRunner.class)
@SpringBootTest(classes=ExamManagementApplication.class)
public class UserTest {
	@Autowired
	private UserMapper userMapper;
	@Autowired
	private IUserService userService;
	@Autowired
	private IRoleService roleService;
	
	@Test
	public void getUser() {
		User user=userMapper.getUserByCount("虚约束");
		System.out.println("user="+user);
	}
	
	@Test
	public void login() {
		try {
			User user=userService.login("虚约束", "111111");
			System.out.println(user);
		} catch (ServiceException e) {
			// TODO: handle exception
			System.out.println(e.getMessage());
		}
		
	}
	@Test
	public void getRole() {
		Role role=roleService.getRoleByUid(96);
		System.out.println("role="+role);
	}
	
}




