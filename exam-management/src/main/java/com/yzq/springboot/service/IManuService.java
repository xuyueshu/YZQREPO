package com.yzq.springboot.service;

import java.util.List;

import com.yzq.springboot.bean.Manu;

public interface IManuService {
	/**
	 * 通过用户id获取菜单列表
	 * @return
	 */
	List<Manu> getManuList(Integer userId);

}
