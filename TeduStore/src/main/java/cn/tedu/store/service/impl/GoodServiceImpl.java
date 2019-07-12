package cn.tedu.store.service.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import cn.tedu.store.entity.Goods;
import cn.tedu.store.mapper.GoodsMapper;
import cn.tedu.store.service.IGoodsService;
import cn.tedu.store.service.exception.GoodsNotFoundException;
@Service("goodsService")
public class GoodServiceImpl implements IGoodsService {
	@Autowired
	private GoodsMapper goodsMapper;
	/**
	 * 获取商品列表信息
	 */
	public List<Goods> getHotList(Long categoryId, Integer count) {
		List<Goods> list=goodsMapper.getListByCategory(categoryId, 0, count);
		
		return list;
	}
	/**
	 * 通过id查找商品信息
	 */
	public Goods getGoodsById(Long id) throws GoodsNotFoundException {
		Goods goods=goodsMapper.getGoodsById(id);
		if(goods!=null) {
			return goods;
		}else {
			throw new GoodsNotFoundException("该商品不存在！");
		}
		
	}

}
