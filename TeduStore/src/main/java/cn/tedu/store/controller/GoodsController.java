package cn.tedu.store.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import cn.tedu.store.entity.Goods;
import cn.tedu.store.entity.ResponseResult;
import cn.tedu.store.service.IGoodsService;

@Controller
@RequestMapping("/goods")
public class GoodsController extends BaseController {
	@Autowired
	private IGoodsService service;
	
	/**
	 * 获取热门商品列表
	 * @return
	 */
	@RequestMapping(value="/list.do",method=RequestMethod.GET)
	@ResponseBody
	public ResponseResult<List<Goods>> getList(@RequestParam("categoryId")Long categoryId,@RequestParam("count")Integer count){
		System.out.println("categoryId="+categoryId+",count="+count);
		List<Goods> list=service.getHotList(categoryId, count);
		ResponseResult<List<Goods>> rr=new ResponseResult<List<Goods>>(); 
		System.out.println("list="+list);
		rr.setData(list);
	
		return rr;
	}
	/**
	 * 获取指定商品信息
	 * @param id
	 * @return
	 */
	@RequestMapping(value="/getGoods.do",method=RequestMethod.GET)
	@ResponseBody
	public ResponseResult<Goods> getGoods(@RequestParam("id")Long id){
		ResponseResult<Goods> rr=new  ResponseResult<Goods>();
		Goods goods=service.getGoodsById(id);
		rr.setData(goods);
		return rr;
		
	}

}
