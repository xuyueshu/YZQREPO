package cn.tedu.store.mapper;

import java.util.List;

import cn.tedu.store.entity.District;

public interface DistrictMapper {
	/**
	 * 
	 * @param parent
	 * @return
	 */
	List<District> getList(String parent);
	/**
	 * 
	 * @param code
	 * @return
	 */
	District getInfo(String code);

}
