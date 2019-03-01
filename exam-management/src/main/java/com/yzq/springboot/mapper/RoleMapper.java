package com.yzq.springboot.mapper;

import com.yzq.springboot.bean.Role;

public interface RoleMapper {
	/**
	 * 通过uid获取对应的role
	 * @param uid
	 * @return
	 */
	Role getRoleByUid(Integer uid);

}
