package cn.tedu.store.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import cn.tedu.store.entity.Goods;

public interface GoodsMapper {
	/**
	 * 获取商品列表
	 * @param categoryId
	 * @param offset
	 * @param count
	 * @return
	 */
	List<Goods> getListByCategory(@Param("categoryId")Long categoryId,@Param("offset")Integer offset,@Param("count")Integer count);
	/**
	 * 通过id查询商品信息
	 * @param id
	 * @return
	 */
	Goods getGoodsById(Long id);
}
