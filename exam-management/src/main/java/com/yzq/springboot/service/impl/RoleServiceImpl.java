package com.yzq.springboot.service.impl;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.yzq.springboot.bean.Role;
import com.yzq.springboot.mapper.RoleMapper;
import com.yzq.springboot.service.IRoleService;
@Service
public class RoleServiceImpl implements IRoleService {
	@Autowired
	private RoleMapper roleMapper;
	@Override
	public Role getRoleByUid(Integer uid) {
		
		return roleMapper.getRoleByUid(uid);
	}

}
