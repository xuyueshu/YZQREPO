package cn.tedu.store.mapper;

import java.util.List;

import cn.tedu.store.entity.GoodsCategory;

public interface GoodsCategoryMapper {
	/**
	 * 通过父级id获取分类
	 * @param parentId
	 * @return
	 */
	List<GoodsCategory> getCategoryByParent(Long parentId);

}
