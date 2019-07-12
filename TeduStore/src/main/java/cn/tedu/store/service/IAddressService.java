package cn.tedu.store.service;

import java.util.List;

import cn.tedu.store.entity.Address;
import cn.tedu.store.service.exception.AddressNotFoundException;
import cn.tedu.store.service.exception.ArgumentException;
import cn.tedu.store.service.exception.InsertDataException;
import cn.tedu.store.service.exception.UpdateDataException;

public interface IAddressService {
	/**
	 * 添加新地址
	 * @param address
	 * @return
	 */
	Address addnew(String currentUser,Address address);
	/**
	 * 插入地址
	 * @param address
	 * @throws InsertDataException
	 */
	void insert(String currentUser,Address address)throws InsertDataException;
	/**
	 * 通过当前id获取用户的收获地址
	 * @param uid
	 * @return
	 */
	Integer getCountByUid(Integer uid);
	/**
	 * 通过id查询地址信息
	 * @param id
	 * @return
	 */
	Address getAddressById(Integer id);
	/**
	 * 查询当前用户的收货地址
	 * @param uid
	 * @return
	 */
	List<Address> getList(Integer uid) throws  AddressNotFoundException;
	/**
	 * 设置当前用户的地址为默认
	 * @param uid
	 * @param id
	 */
	void setDefault(Integer uid,Integer id);
	/**
	 * 作为工具方法
	 * @param id
	 * @return
	 */
	Integer delete(Integer id);
	/**
	 * 作为业务方法
	 * @param id
	 * @param uid
	 * @return
	 */
	void deleteAddress(Integer id,Integer uid)throws AddressNotFoundException,ArgumentException;
	/**
	 * 修改地址信息
	 * @param address
	 */
	void updateAddress(Address address)throws UpdateDataException ,ArgumentException;
	/**
	 * 工具方法修改地址信息
	 * @param address
	 * @return
	 */
	Integer update(Address address);

}
