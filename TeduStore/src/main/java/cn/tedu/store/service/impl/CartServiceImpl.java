package cn.tedu.store.service.impl;

import java.util.Date;
import java.util.List;

import org.apache.ibatis.annotations.Param;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import cn.tedu.store.entity.Cart;
import cn.tedu.store.entity.Goods;
import cn.tedu.store.entity.User;
import cn.tedu.store.mapper.CartMapper;
import cn.tedu.store.service.ICartService;
import cn.tedu.store.service.IGoodsService;
import cn.tedu.store.service.IUserService;
import cn.tedu.store.service.exception.InsertDataException;
import cn.tedu.store.service.exception.ResourceNotFoundException;
import cn.tedu.store.service.exception.UpdateDataException;
@Service("cartService")
public class CartServiceImpl implements ICartService {
	@Autowired
	private CartMapper cartMapper;
	@Autowired
	private IUserService userService;
	@Autowired
	private IGoodsService goodsService;
 
	/**
	 * 添加购物车业务
	 */
	//不需要@Transactional，两条sql在不同的分支里面
	public void addToCart(Cart cart)throws InsertDataException,UpdateDataException{
		//TODO 到底是增加还是修改数量？
	Long goodsId=cart.getGoodsId();
	Integer uid=cart.getUid();
	Integer count=getCountByUidAndGoodsId(uid, goodsId);
	if(count==0) {
		insert(cart);
	}else {
		changeGoodsNum(cart.getGoodsNum(), uid, goodsId);
	}
		
	}
	
	
	/**
	 * 获取当前用户当前商品在购物车中的数量
	 * @return
	 */
	public Integer getCountByUidAndGoodsId(Integer uid,Long goodsId) {
		
		return cartMapper.getCountByUidAndGoodsId(uid, goodsId);
	}
	/**
	 * 修改购物车中该商品的数量
	 * @param num
	 * @param uid
	 * @param goodsId
	 * @return
	 */
	public void changeGoodsNum(Integer num,Integer uid,Long goodsId)throws UpdateDataException{
		Integer rows=cartMapper.changeGoodsNum(num, uid, goodsId);
		if(rows!=1) {
			throw new UpdateDataException("商品数量更新失败！");
		}
		
	}
	/**
	 * 
	 * 获取当前用户的购物车详情
	 */
	public List<Cart> getList(Integer uid,Integer page) {
		//如果page无效，视为1
		//如page超出上线，视为最后一页
		Integer maxPage=getMaxPage(uid);
		System.out.println("maxPage="+maxPage);
		if(page==0) {
			page=1;
		}else if(page>maxPage) {
			page=maxPage;
		}
		System.out.println("page="+page);
		Integer offset=(page-1)*COUNT_PER_PAGE;
		List<Cart> carts=cartMapper.getList(uid,offset,COUNT_PER_PAGE);
		if(carts!=null) {
			return carts;
		}else {
			throw new ResourceNotFoundException("用户购物车为空！");
		}
	}
	
	
	
	public List<Cart> getListByIds(Integer uid, Integer[] ids){
		List<Cart> carts=cartMapper.getListByIds(uid, ids);
		
		
			return carts;
		
		
	}
	
	
	
	
	/////////////////////////////////////工具方法//////////////////////////////
	
	/**
	 * 
	 * @param cart
	 * @return 新增购物车数据
	 */
	private Cart insert(Cart cart)throws InsertDataException {
		User currentUser=userService.getUserById(cart.getUid());
		Goods goods=goodsService.getGoodsById(cart.getGoodsId());
		System.out.println("cart中的goods="+goods);
		String username=currentUser.getUsername();
		System.out.println("image//"+goods.getImage());
		cart.setGoodsImage(goods.getImage());
		cart.setGoodsPrice(goods.getPrice());
		cart.setGoodsTitle(goods.getTitle());
		Date now =new Date();
		cart.setCreatedTime(now);
		cart.setCreatedUser(username);
		cart.setModifiedTime(now);
		cart.setModifiedUser(username);
		Integer rows=cartMapper.insert(cart);
		if(rows!=1) {
			throw new InsertDataException("系统错误，添加购物车失败,请联系管理员！");
	}
		return cart;
	}
	
	/**
	 * 获取当前用户购物车列表数据的条数
	 * @param uid
	 * @return
	 */
	private Integer getListCountByUid(Integer uid) {
		
		return cartMapper.getListCountByUid(uid);
		
	}

	/**
	 * 获取最大页数
	 */
	public Integer getMaxPage(Integer uid) {
		
		return (int)Math.ceil(1.0*getListCountByUid(uid)/COUNT_PER_PAGE);
	}

	


	


	
	
	
	
	
}
