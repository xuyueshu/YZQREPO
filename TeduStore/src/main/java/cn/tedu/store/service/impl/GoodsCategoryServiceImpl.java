package cn.tedu.store.service.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import cn.tedu.store.entity.GoodsCategory;
import cn.tedu.store.mapper.GoodsCategoryMapper;
import cn.tedu.store.service.IGoodsCategoryService;
import cn.tedu.store.service.exception.GoodsCategoryNotFoundException;
@Service("goodsCategoryService")
public class GoodsCategoryServiceImpl implements IGoodsCategoryService {
	@Autowired
	GoodsCategoryMapper goodsCategoryMapper;
/**
 * 
 */
	public List<GoodsCategory> getList(Long parentId) throws GoodsCategoryNotFoundException {
		List<GoodsCategory> goodsCategories=goodsCategoryMapper.getCategoryByParent(parentId);
		if(goodsCategories!=null) {
			return goodsCategories;
		}else {
			throw new GoodsCategoryNotFoundException("该商品种类不存在！");
		}
		
	}

}
