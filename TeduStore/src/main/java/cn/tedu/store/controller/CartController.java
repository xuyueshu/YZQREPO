package cn.tedu.store.controller;

import java.util.List;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import cn.tedu.store.entity.Cart;
import cn.tedu.store.entity.ResponseResult;
import cn.tedu.store.service.ICartService;

@Controller
@RequestMapping("/cart")
public class CartController extends BaseController {
	@Autowired
	private ICartService service;
	
	
	@RequestMapping("/addCart.do")
	@ResponseBody
	public ResponseResult<Void> addToCart(HttpSession session,@RequestParam("goodsId")Long goodsId,@RequestParam("goodsNum")Integer goodsNum){
		Cart cart=new Cart();
		Integer uid=getUidFromSession(session);
		cart.setUid(uid);
		cart.setGoodsId(goodsId);
		cart.setGoodsNum(goodsNum);
		service.addToCart(cart);
		return new ResponseResult<Void>();
	}
	
	@RequestMapping("/getList.do")
	@ResponseBody
	public ResponseResult<List<Cart>> getList(HttpSession session,@RequestParam(value="page",required=false,defaultValue="1")Integer page){
		
		Integer uid=getUidFromSession(session);
		List<Cart> carts=service.getList(uid,page);
		ResponseResult<List<Cart>> rr=new ResponseResult<List<Cart>>();
		rr.setData(carts);
		return rr;
	}
	
	@RequestMapping("/getMaxPage.do")
	@ResponseBody
	public ResponseResult<Integer> getMaxPage(HttpSession session){
		
		Integer uid=getUidFromSession(session);
		Integer maxPage=service.getMaxPage(uid);
		ResponseResult<Integer> rr=new ResponseResult<Integer>();
		rr.setData(maxPage);
		return rr;
	}
	
	
	@RequestMapping("/get_list_by_ids.do")
	@ResponseBody
	public ResponseResult<List<Cart>> getListByIds(HttpSession session,@RequestParam("ids")Integer[] ids){
		for (Integer integer : ids) {
			System.out.println("id="+integer);
		}
		System.out.println();
		Integer uid=getUidFromSession(session);
		List<Cart> list=service.getListByIds(uid, ids);
		System.out.println("list="+list);
		ResponseResult<List<Cart>> rr=new ResponseResult<List<Cart>>();
		rr.setData(list);
		return rr;
	}
	
	
	
	

}
