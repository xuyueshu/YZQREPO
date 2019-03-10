package cn.tedu.store.service.impl;

import java.util.Date;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import cn.tedu.store.entity.Address;
import cn.tedu.store.entity.District;
import cn.tedu.store.mapper.AddressMapper;
import cn.tedu.store.service.IAddressService;
import cn.tedu.store.service.IDistrictService;
import cn.tedu.store.service.exception.AddressNotFoundException;
import cn.tedu.store.service.exception.ArgumentException;
import cn.tedu.store.service.exception.InsertDataException;
import cn.tedu.store.service.exception.ServiceException;
import cn.tedu.store.service.exception.UpdateDataException;
@Service("addressService")
public class AddressServiceImpl implements IAddressService {
	@Autowired
	private AddressMapper addressMapper;
	@Autowired
	private IDistrictService districtService;
	/**
	 * 添加收货地址
	 */
	public Address addnew(String currentUser,Address address) throws InsertDataException{
		//TODO
		//
		String recvDistrict=getRecvDistrict(address);
		address.setRecvDistrict(recvDistrict);
		//设置默认收货地址
		Integer count=getCountByUid(address.getUid());
		System.out.println("count="+count);
		//判断并赋值
		address.setIsDefault(count==0?1:0);
		insert(currentUser, address);
		return address;
	}
	/**
	 * 获取用户地址列表
	 */
	public List<Address> getList(Integer uid) throws  AddressNotFoundException{
		List<Address> addresses=addressMapper.getList(uid);
		if(addresses.size()>0) {
			return addresses;
		}else {
			throw new AddressNotFoundException("你还没有添加收货地址！");
		}
		
	}
	/**
	 * @Transactional  表示该注解在该方法执行时，会有事务保护的，如果该方法的两个sql语句失败，会自动回滚
	 */
	@Transactional   
	public void setDefault(Integer uid, Integer id) throws UpdateDataException{
		Integer rows=addressMapper.setNonDefault(uid);
		/*try {
			Thread.sleep(6000);
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}*/
		Integer rows1=addressMapper.SetDefault(uid, id);
		if(rows==0) {
			throw new UpdateDataException("设置默认地址时发生异常！请联系系统管理员！");
		}
		if(rows1==0) {
			throw new UpdateDataException("设置默认地址时发生异常！请联系系统管理员！");
		}
	}
	
	
	
	/**
	 * 删除收货地址，管理员也能操作
	 */
	@Transactional
	public void deleteAddress(Integer id, Integer uid) throws AddressNotFoundException,ArgumentException {
		Address address=getAddressById(id);
		if(address!=null) {
			System.out.println("address="+address);
			if(uid.equals(address.getUid())) {
				
				//TODO 如果删除的是默认地址，应该设定一个默认地址
				if(address.getIsDefault()==1) {
					List<Address> addresses=getList(uid);
					if(addresses.size()>=2) {
						Integer nextId=addresses.get(1).getId();
						setDefault(uid,nextId );
					}
				}
				delete(id);
			}else {
				throw new ArgumentException("删除失败，参数错误!(这不是你的收货地址)");
			}
		}
		/*else if(uid==26){
			delete(id);
			System.out.println("管理员删除了用户id="+uid+"地址！");
		}*/else {
			
			throw new AddressNotFoundException("该收货地址不存在！");
		}
	}
	
	/**
	 * 修改地址信息
	 */
	public void updateAddress(Address address)throws UpdateDataException ,ArgumentException{
		Integer uid =getAddressById(address.getId()).getUid();
		System.out.println("服务层的address="+address);
		if(address.getUid().equals(uid)) {
			address.setRecvDistrict(getRecvDistrict(address));
			address.setModifiedTime(new Date());
			Integer rows=update(address);
			if(rows!=1) {
				throw new UpdateDataException("系统错误，修改失败！请联系管理员！");
			}
		}else {
			throw new ArgumentException("参数错误！（当前不是该用户的收货地址");
		}
	}
	
	
	/**
	 * 通过id查询地址信息
	 */
		public Address getAddressById(Integer id) throws AddressNotFoundException{
			Address address=addressMapper.getAddressById(id);
			if(address!=null){
				return address ;
			}else{
				throw new AddressNotFoundException("该地址不存在！");
			}
			
		}
	
	
	
	
	
	
	
	
	
	
	
	
	
///////////////////////////////工具方法////////////////////////////////
	/**
	 * 获取省市区的名称
	 * @param address
	 * @return 如 重庆市辖区大渡口区
	 */
	public String getRecvDistrict(Address address) {
		District province=districtService.getInfo(address.getRecvProvince());
		System.out.println("address.getRecvProvince()="+address.getRecvProvince());
		System.out.println("province="+province);
		District city=districtService.getInfo(address.getRecvCity());
		System.out.println("city="+city);
		District area=districtService.getInfo(address.getRecvArea());
		System.out.println("area="+area);
		String recvDistrict=province.getName()+city.getName()+area.getName()+address.getRecvAddress();
		return recvDistrict;
		
	}

	
	/**
	 * 插入地址
	 */
public void insert(String currentUser,Address address) throws InsertDataException {
		
		Date now=new Date();
		address.setCreatedUser(currentUser);
		address.setCreatedTime(now);
		address.setModifiedUser(currentUser);
		address.setModifiedTime(now);
		Integer rows=addressMapper.insert(address);
		if(rows!=1) {
			throw new InsertDataException("添加地址时，发生系统错误！请联系管理员！");
		}
	}
	/**
	 * 通过当前id获取用户的收货地址数量
	 */
	public Integer getCountByUid(Integer uid) {
		return addressMapper.getCountByUid(uid);
	}
	
		
	
	/**
	 * 删除用户收货地址
	 */
	public Integer delete(Integer id){
		return addressMapper.deleteById(id);
	}
	/**
	 * 修改地址
	 */
	public Integer update(Address address) {

		return addressMapper.update(address);
	}
	
	}
	
	
	
	
	




	
	

	


