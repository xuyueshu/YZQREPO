package cn.tedu.store.service;

import java.util.List;

import cn.tedu.store.entity.GoodsCategory;
import cn.tedu.store.service.exception.GoodsCategoryNotFoundException;

public interface IGoodsCategoryService {
	/**
	 * 
	 * @param parentId
	 * @return
	 */
	List<GoodsCategory> getList(Long parentId)throws GoodsCategoryNotFoundException;

}
