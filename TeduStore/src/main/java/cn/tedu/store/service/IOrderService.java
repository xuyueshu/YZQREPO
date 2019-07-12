package cn.tedu.store.service;

import cn.tedu.store.entity.Cart;
import cn.tedu.store.entity.Order;
import cn.tedu.store.service.exception.InsertDataException;

public interface IOrderService {
	/**
	 * 
	 * @param uid
	 * @param addressId
	 * @param cartId
	 * @return
	 * @throws InsertDataException
	 */
	Order createOrder(Integer uid,Integer addressId,Integer[] cartId)throws InsertDataException;

}
