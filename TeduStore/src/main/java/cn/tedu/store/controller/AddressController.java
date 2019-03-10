package cn.tedu.store.controller;

import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import cn.tedu.store.entity.Address;
import cn.tedu.store.entity.District;
import cn.tedu.store.entity.ResponseResult;
import cn.tedu.store.service.IAddressService;
import cn.tedu.store.service.IDistrictService;

@Controller
@RequestMapping("/address")
public class AddressController extends BaseController {
	@Autowired
	private IAddressService service;
	@Autowired
	private IDistrictService disService;
	/**
	 * 添加地址
	 * @param session
	 * @param address
	 * @return
	 */
	@RequestMapping(value="/handle_addnew.do",method=RequestMethod.POST)
	@ResponseBody
	public ResponseResult<Void> handleAddnew(HttpSession session,Address address){
		Integer uid=getUidFromSession(session);
		address.setUid(uid);
		String currentUser=session.getAttribute("username").toString();
		service.addnew(currentUser, address);
		return new ResponseResult<Void>();
		
	}
	/**
	 * 获取当前用户的收货地址列表
	 * @param session
	 * @return
	 */
	@RequestMapping(value="/list.do",method=RequestMethod.GET)
	@ResponseBody
	public ResponseResult<List<Address>> getList(HttpSession session){
		Integer uid=getUidFromSession(session);
		System.out.println("xxxxxxxxxxxxxxx");
		List<Address> addresses=service.getList(uid);
		 System.out.println("addresses="+addresses);
		 ResponseResult<List<Address>> rr=new  ResponseResult<List<Address>>();
		
		 rr.setData(addresses);
		return rr;
		
	}
	/**
	 * 设置默认收货地址
	 * @param session
	 * @param id
	 * @return
	 */
	@RequestMapping(value="/setDefault.do",method=RequestMethod.POST)
	@ResponseBody
	public ResponseResult<Void> setDefault(HttpSession session,@RequestParam("id")Integer id){
		service.setDefault(getUidFromSession(session), id);
		return new ResponseResult<Void>();
		
	}
	/**
	 * 删除收货地址
	 * @param session
	 * @param id
	 * @return
	 */
	@RequestMapping(value="/delete.do",method=RequestMethod.POST)
	@ResponseBody
	public ResponseResult<Void> delete(HttpSession session,Integer id){
		service.deleteAddress(id, getUidFromSession(session));
		
		return new ResponseResult<Void>();
	}
	/**
	 * 更新地址
	 * @param address
	 * @param session
	 * @return
	 */
	@RequestMapping("/update.do")
	@ResponseBody
	public ResponseResult<Void> update(Address address,HttpSession session){
		Integer uid=getUidFromSession(session);
		System.out.println("请求uid="+uid);
		address.setUid(uid);
		service.updateAddress(address);
		return new ResponseResult<Void>();
	}
	
	/**
	 * 通过id获取地址信息,
	 * @param id
	 * @return
	 */
	@RequestMapping("/getAddress.do")
	@ResponseBody
	public ResponseResult<List<Object>> getAddress(Integer id){
		Address address=service.getAddressById(id);
		/*District district=new District();*/
		String provinceName=disService.getInfo(address.getRecvProvince()).getName(); 
		String cityName=disService.getInfo(address.getRecvCity()).getName();
		String areaName=disService.getInfo(address.getRecvArea()).getName();
		List<String> names=new ArrayList<String>();
		names.add(provinceName);
		names.add(cityName);
		names.add(areaName);
		List results=new ArrayList();
		results.add(address);
		results.add(names);
		ResponseResult<List<Object>> rr=new ResponseResult<List<Object>>();
		rr.setData(results);
		return rr;
	}
	
	
	
}