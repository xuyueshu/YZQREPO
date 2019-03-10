package cn.tedu.store.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import cn.tedu.store.entity.Cart;

public interface CartMapper {
	/**
	 * 添加购物车
	 * @param cart
	 * @return
	 */
	Integer insert(Cart cart);
	/**
	 * 获取当前用户当前商品在购物车中的数量
	 * @param uid
	 * @param goodsId
	 * @return
	 */
	Integer getCountByUidAndGoodsId(@Param("uid")Integer uid,@Param("goodsId") Long goodsId);
	/**
	 * 修改购物车中该商品的数量
	 * @param num
	 * @param uid
	 * @param goodsId
	 * @return
	 */
	Integer changeGoodsNum(@Param("num")Integer num,@Param("uid")Integer uid,@Param("goodsId")Long goodsId);
	/**
	 * 查询当前用户购物车详情
	 * @param uid
	 * @param offset
	 * @param count
	 * @return
	 */
	List<Cart> getList(@Param("uid")Integer uid,@Param("offset")Integer offset,@Param("count")Integer count);
	/**
	 * 查询当前用户购物车列表的数量
	 * @param uid
	 * @return
	 */
	Integer getListCountByUid(Integer uid);
	/**
	 * 获取当前用户勾选购物列表对应的购物车信息
	 * @param uid
	 * @param ids
	 * @return
	 */
	List<Cart> getListByIds(@Param("uid")Integer uid,@Param("ids")Integer[] ids);
	
}
