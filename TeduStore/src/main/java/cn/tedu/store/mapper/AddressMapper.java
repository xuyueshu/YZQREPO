package cn.tedu.store.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import cn.tedu.store.entity.Address;

public interface AddressMapper {
	/**
	 * 
	 * @param address
	 * @return
	 */
	Integer insert(Address address);
	/**
	 * 根据当前的用户id，查询用户收获地址数量
	 * @param uid
	 * @return
	 */
	Integer getCountByUid(Integer uid);
	/**
	 * 获取当前用户收货地址列表
	 * @param uid
	 * @return
	 */
	List<Address> getList(Integer uid);
	
	/**
	 * 将当前用户全部的收货地址设为非默认
	 * @param uid
	 * @return
	 */
	Integer setNonDefault(Integer uid);
	/**
	 * 对指定的地址设为默认
	 * @param id
	 * @return
	 */
	Integer SetDefault(@Param("uid") Integer uid,@Param("id")Integer id);
	/**
	 * 通过id查询收货地址信息
	 * @param id
	 * @return
	 */
	Address getAddressById(Integer id);
	/**
	 * 删除id的客户的收货地址(不限制是当前用户能操作，管理员也能操作，在业务层判断uid)
	 * @param id
	 * @return
	 */
	Integer deleteById(Integer id);
	/**
	 * 修改id的地址信息
	 * @param uid
	 * @param id
	 * @return
	 */
	Integer update(Address address);
}
