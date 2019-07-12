package cn.tedu.store.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import cn.tedu.store.entity.GoodsCategory;
import cn.tedu.store.entity.ResponseResult;
import cn.tedu.store.service.IGoodsCategoryService;

@Controller
@RequestMapping("/goodsCategory")
public class GoodsCategoryController extends BaseController {
	@Autowired
	private IGoodsCategoryService service;
	
	/**
	 * 获取分类列表
	 * @return
	 */
	@RequestMapping(value="/list.do",method=RequestMethod.GET)
	@ResponseBody
	public ResponseResult<List<GoodsCategory>> getList(@RequestParam("parentId")Long parentId ){
		List<GoodsCategory> goodsCategories=service.getList(parentId);
		ResponseResult<List<GoodsCategory>> rr=new ResponseResult<List<GoodsCategory>>();
		rr.setData(goodsCategories);
		return rr;
	}

}
