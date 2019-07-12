package cn.tedu.store.service;

import java.util.List;

import cn.tedu.store.entity.Goods;
import cn.tedu.store.service.exception.GoodsNotFoundException;

public interface IGoodsService {
	/**
	 * 获取商品列表
	 * @param categoryId 商品分类id
	 * @param offset 偏移量
	 * @param count 需要获取的数据数量
	 * @return 商品列表,如果没有数据，则返回一个空集合
	 */
	List<Goods> getHotList(Long categoryId,Integer count);
	/**
	 * 通过id查找商品信息
	 * @param id
	 * @return
	 */
	Goods getGoodsById(Long id)throws GoodsNotFoundException;


}
