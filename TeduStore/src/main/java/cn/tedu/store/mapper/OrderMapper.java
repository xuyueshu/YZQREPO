package cn.tedu.store.mapper;

import java.util.List;

import cn.tedu.store.entity.Order;
import cn.tedu.store.entity.OrderItem;
import cn.tedu.store.entity.OrderVO;

public interface OrderMapper {
	/**
	 * 插入订单数据
	 * @param order 订单数据
	 * @return 受影响的行数
	 */
	Integer insertOrder(Order order);
	
	/**
	 * 插入订单商品数据
	 * @param orderItem 订单商品数据
	 * @return 受影响的行数
	 */
	Integer insertOrderItem(OrderItem orderItem);
	/**
	 * 查询当前用户的订单信息
	 * @param uid
	 * @return
	 */
	/*List<OrderVO>*/OrderVO getOrderByUid(Integer uid);

}
