package cn.tedu.store.service;

import java.util.List;

import cn.tedu.store.entity.Cart;
import cn.tedu.store.service.exception.InsertDataException;
import cn.tedu.store.service.exception.ResourceNotFoundException;
import cn.tedu.store.service.exception.UpdateDataException;

public interface ICartService {
	//每页显示3条
	Integer COUNT_PER_PAGE=3;
	/**
	 * 添加购物车
	 * @param cart
	 */
	void addToCart(Cart cart)throws InsertDataException,UpdateDataException;
	/**
	 * 获取当前用户当前商品在购物车中的数量
	 * @param uid
	 * @param goodsId
	 * @return
	 */
	Integer getCountByUidAndGoodsId(Integer uid,Long goodsId);
	/**
	 * 修改购物车中该商品的数量
	 * @param num
	 * @param uid
	 * @param goodsId
	 * @return
	 */
	void changeGoodsNum(Integer num,Integer uid,Long goodsId);
	/**
	 * 
	 * @param uid
	 * @param page
	 * @return
	 */
	List<Cart> getList(Integer uid,Integer page);
	/**
	 * 获取最大页数
	 * @param uid
	 * @return
	 */
	Integer getMaxPage(Integer uid);
	/**
	 * 获取当前用户勾选购物列表对应的购物车信息
	 * @param uid
	 * @param ids
	 * @return
	 */
	List<Cart> getListByIds(Integer uid,Integer[] ids);

}
