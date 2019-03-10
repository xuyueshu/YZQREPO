package cn.tedu.store.controller;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import cn.tedu.store.service.IOrderService;

@Controller
@RequestMapping("/order")
public class OrderController extends BaseController {
	@Autowired
	private IOrderService service;
	
	
	/**
	 * 创建订单
	 * @param session
	 * @param addressId
	 * @param cartsId
	 * @return
	 */
	@RequestMapping("/createOrder.do")//执行转发，不用ajax，所以不用json
	public String createOrder(HttpSession session,@RequestParam("addressId")Integer addressId,@RequestParam("cartsId")Integer[] cartsId) {
		
		
		return null;
	}

}
