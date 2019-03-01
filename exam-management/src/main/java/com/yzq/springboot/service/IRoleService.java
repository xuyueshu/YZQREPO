package com.yzq.springboot.service;

import com.yzq.springboot.bean.Role;

public interface IRoleService {
	
	/**
	 * 通过uid获取对应的role
	 * @param uid
	 * @return
	 */
	Role getRoleByUid(Integer uid);

}
