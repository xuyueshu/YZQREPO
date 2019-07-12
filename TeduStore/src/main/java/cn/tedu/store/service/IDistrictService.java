package cn.tedu.store.service;

import java.util.List;

import cn.tedu.store.entity.District;

public interface IDistrictService {
	String PROVINCE_PARENT="86";
	/**
	 * 获取地区字典列表
	 * @param parent
	 * @return
	 */
	List<District> getList(String parent);
	/**
	 * 通过编号获取地区信息
	 * @param code
	 * @return
	 */
	District getInfo(String code);
}
