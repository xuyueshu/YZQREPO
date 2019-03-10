package cn.tedu.store.service.impl;

import java.util.Date;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import cn.tedu.store.entity.Address;
import cn.tedu.store.entity.Cart;
import cn.tedu.store.entity.Goods;
import cn.tedu.store.entity.Order;
import cn.tedu.store.entity.OrderItem;
import cn.tedu.store.mapper.OrderMapper;
import cn.tedu.store.service.IAddressService;
import cn.tedu.store.service.ICartService;
import cn.tedu.store.service.IGoodsService;
import cn.tedu.store.service.IOrderService;
import cn.tedu.store.service.exception.InsertDataException;
@Service("orderService")
public class OrderServiceImpl implements IOrderService {
	@Autowired
	private OrderMapper orderMapper;
	@Autowired
	private IAddressService addressService;
	@Autowired
	private ICartService cartService;
	@Autowired
	private IGoodsService goodsService;
	
	@Transactional
	public Order createOrder(Integer uid, Integer addressId, Integer[] cartId) throws InsertDataException{
		Address address=addressService.getAddressById(addressId);
		List<Cart> carts=cartService.getListByIds(uid, cartId);
		
		Long  totalPrice=0L;
		for (Cart cart : carts) {
			totalPrice+=cart.getGoodsNum()*cart.getGoodsPrice();
		}
		Date now =new Date();
		//TODO
		Order order=new Order();
		order.setUid(uid);
		order.setRecvAddress(address.getRecvDistrict());
		order.setRecvName(address.getRecvName());
		order.setRecvPhone(address.getRecvPhone());
		order.setTotalPrice(totalPrice);
		order.setStatus(1);//1表示没支付，2表示已支付
		order.setPayTime(null);
		order.setCreateTime(now);
		insertOrder(order);
		
		for (Cart cart : carts) {
			Goods goods=goodsService.getGoodsById(cart.getGoodsId());
			OrderItem orderItem=new OrderItem();
			orderItem.setOrderId(order.getId());
			orderItem.setGoodsId(cart.getGoodsId());
			orderItem.setGoodsImage(goods.getImage());
			orderItem.setGoodsNum(cart.getGoodsNum());
			orderItem.setGoodsTitle(goods.getTitle());
			orderItem.setGoodsPrice(goods.getPrice());
			insertOrderItem(orderItem);
		}
		
		
		return order;
	}
	
	//////////////////////////////工具方法//////////////////////
	
	public Order insertOrder(Order order) throws InsertDataException{
		Integer rows=orderMapper.insertOrder(order);
		if(rows!=1) {
			throw new InsertDataException("订单提交错误！");
		}
		return order;
	}

	public OrderItem insertOrderItem(OrderItem orderItem)throws InsertDataException {
		Integer rows=orderMapper.insertOrderItem(orderItem);
		if(rows!=1) {
			throw new InsertDataException("订单提交错误！");
		}
		return orderItem;
	}



}
