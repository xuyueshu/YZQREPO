package cn.tedu.store.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import cn.tedu.store.entity.District;
import cn.tedu.store.entity.ResponseResult;
import cn.tedu.store.service.IDistrictService;

@Controller
@RequestMapping("/district")
public class DistrictController extends BaseController {
	@Autowired
	private IDistrictService service;
	@RequestMapping("/list.do")
	@ResponseBody
	public ResponseResult<List<District>> getList(String parent){
		List<District> districts=service.getList(parent);
		ResponseResult<List<District>> rr=new ResponseResult<List<District>>();
		rr.setData(districts);
		System.out.println("rr="+rr);
		return rr;
	}
	
	/**
	 * 获取指定编号的地区对象
	 * @param code
	 * @return
	 */
	@RequestMapping("/info.do")
	@ResponseBody
	public ResponseResult<District> getInfo(String code){
		District district=service.getInfo(code);
		ResponseResult<District> rr=new ResponseResult<District>();
		rr.setData(district);
		return rr;
	}

	

}
