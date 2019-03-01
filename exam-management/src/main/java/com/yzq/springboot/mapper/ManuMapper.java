package com.yzq.springboot.mapper;

import java.util.List;

import com.yzq.springboot.bean.Manu;

public interface ManuMapper {
	/**
	 * 通过uid获取父级菜单
	 * @return
	 */
	List<Manu> getParentManu(Integer userId);
	/**
	 * 通过父级id获取子菜单
	 * @param parentId
	 * @return
	 */
	List<Manu>getChildrenManueByPid(Integer parentId);

}
