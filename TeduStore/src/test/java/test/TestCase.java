package test;

import java.util.Date;
import java.util.List;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.springframework.context.support.AbstractApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;

import cn.tedu.store.entity.Address;
import cn.tedu.store.entity.Cart;
import cn.tedu.store.entity.District;
import cn.tedu.store.entity.Goods;
import cn.tedu.store.entity.GoodsCategory;
import cn.tedu.store.entity.OrderVO;
import cn.tedu.store.entity.User;
import cn.tedu.store.mapper.AddressMapper;
import cn.tedu.store.mapper.CartMapper;
import cn.tedu.store.mapper.DistrictMapper;
import cn.tedu.store.mapper.GoodsCategoryMapper;
import cn.tedu.store.mapper.GoodsMapper;
import cn.tedu.store.mapper.OrderMapper;
import cn.tedu.store.mapper.UserMapper;
import cn.tedu.store.service.IAddressService;
import cn.tedu.store.service.ICartService;
import cn.tedu.store.service.IDistrictService;
import cn.tedu.store.service.IGoodsCategoryService;
import cn.tedu.store.service.IGoodsService;
import cn.tedu.store.service.IOrderService;
import cn.tedu.store.service.IUserService;
import cn.tedu.store.service.exception.ServiceException;

public class TestCase {
		AbstractApplicationContext ac;
		IUserService userService;
		IAddressService addressService;
		DistrictMapper districtMapper;
		IDistrictService districtService;
		AddressMapper addressMapper;
	  GoodsCategoryMapper goodsCategoryMapper;
	  IGoodsCategoryService goodsCategoryService;
	  GoodsMapper goodsMapper;
	  IGoodsService goodsService;
	  CartMapper cartMapper;
	  ICartService cartService;
	  IOrderService orderService;
	  OrderMapper orderMapper;
	@Before
	public void doBefore() {//在测试方法前执行
		ac=new ClassPathXmlApplicationContext("spring-dao.xml","spring-service.xml");
	 userService=ac.getBean("userService", IUserService.class);
	 addressService=ac.getBean("addressService", IAddressService.class);
	 districtMapper=ac.getBean("districtMapper", DistrictMapper.class);
	 districtService=ac.getBean("districtService", IDistrictService.class);
	 addressMapper=ac.getBean("addressMapper", AddressMapper.class);
	 goodsCategoryMapper=ac.getBean("goodsCategoryMapper", GoodsCategoryMapper.class);
	 goodsCategoryService=ac.getBean("goodsCategoryService", IGoodsCategoryService.class);
	 goodsMapper=ac.getBean("goodsMapper", GoodsMapper.class);
	 goodsService=ac.getBean("goodsService", IGoodsService.class);
	 cartMapper=ac.getBean("cartMapper", CartMapper.class);
	 cartService=ac.getBean("cartService", ICartService.class);
	 orderService=ac.getBean("orderService", IOrderService.class);
	 orderMapper=ac.getBean("orderMapper", OrderMapper.class);
	}
	@After
	public void doAfter() {//在测试方法后执行
		ac.close();
	}
	
	@Test
	public void test() {
		AbstractApplicationContext ac=new ClassPathXmlApplicationContext("spring-dao.xml");
		UserMapper userMapper=ac.getBean("userMapper", UserMapper.class);
		User user=new User();
		user.setUsername("黄尚");
		user.setPassword("00000");
		user.setIsDelete(0);
		Integer rows=userMapper.insert(user);
		Integer id=user.getId();
		System.out.println("rows="+rows);
		System.out.println("id="+id);
	}
	
	@Test
	public void test1() {
		AbstractApplicationContext ac=new ClassPathXmlApplicationContext("spring-dao.xml");
		UserMapper userMapper=ac.getBean("userMapper", UserMapper.class);
		
		User user=userMapper.getUserByUsername("游");
		System.out.println("user="+user);
	}
	
	@Test
	public void test2() {
		AbstractApplicationContext ac=new ClassPathXmlApplicationContext("spring-dao.xml","spring-service.xml");
		IUserService userService=ac.getBean("userService", IUserService.class);
		User u=new User();
		u.setUsername("黄忠");
		u.setPassword("00000");
		u.setIsDelete(0);
		try {
			User user=userService.reg(u);
			System.out.println("user="+user);
		}catch(ServiceException e) {
			System.out.println(e.getMessage());
		}
	}
	
	@Test
	public void test3() {
		try {
		userService.changePasswordByOldPassword(14, "000000", "111111");
		}catch(ServiceException e) {
			System.out.println(e.getMessage());
		}
	}
	
	@Test
	public void test4() {
		
		UserMapper userMapper=ac.getBean("userMapper", UserMapper.class);
		User user=new User();
		/*user.setAvatar("asjhbcsh");
		user.setUsername("小龙女1");
		user.setPhone("654648498");
		user.setEmail("sudhcsbhbc");*/
		user.setGender(0);
		user.setId(19);
		Integer rows=userMapper.changeInfo(user);
		System.out.println(rows);
	}
	
	@Test
	public void test5() {
		try {
			User user=new User();
			user.setId(18);
			user.setUsername("杨过1");
		userService.changeInfo(user);
		}catch(ServiceException e) {
			System.out.println(e.getMessage());
		}
	}
	
	@Test
	public void test6() {
		Address address=new Address();
		address.setUid(24);
		address.setCreatedUser("城市");
		address.setIsDefault(1);
		address.setRecvCity("重庆");
		try {
			addressService.insert(address.getCreatedUser(), address);
		}catch(ServiceException e) {
			System.out.println(e.getMessage());
		}
		
	}
	
	@Test
	public void test7() {
		Address address=new Address();
		address.setUid(24);
		address.setCreatedUser("城市");
		address.setIsDefault(1);
		address.setRecvCity("重庆1");
		try {
			addressService.addnew(address.getCreatedUser(), address);
		}catch(ServiceException e) {
			System.out.println(e.getMessage());
		}
		
	}
	
	@Test
	public void test8() {
		List<District> districts=districtMapper.getList("500000");
		System.out.println(districts);
		
	}
	

	@Test
	public void test9() {
		District district=districtMapper.getInfo("500000");
		System.out.println(district);
		
	}
	@Test
	public void test10() {
		List<District> list=districtService.getList("86");
		System.out.println(list);
		
	}
	
	@Test
	public void test11() {
		District district=districtService.getInfo("500000");
		System.out.println(district);
		
	}
	
	@Test
	public void test12() {
		try {
			List<Address> addresses=addressService.getList(25);
			for (Address address : addresses) {
				System.out.println(address);
			}
			
		}catch(ServiceException e) {
			System.out.println(e.getMessage());
		}
		
		
	}
	
	@Test
	public void test13() {
		
		Integer rows=addressMapper.setNonDefault(26);
		System.out.println("rows="+rows);
		
	}
	
	@Test
	public void test14() {
		
		Integer rows=addressMapper.SetDefault(26, 2);
		System.out.println("rows="+rows);
		
	}
	
	@Test
	public void test15() throws InterruptedException {
		try {
			addressService.setDefault(25, 4);
			System.out.println("设置成功！");
		}catch(ServiceException e) {
			System.out.println(e.getMessage());
		}
		
		
	}
	
	@Test
	public void test16(){
		try {
			addressService.deleteAddress(11, 25);
			System.out.println("删除成功！");
		}catch(ServiceException e) {
			System.out.println(e.getMessage());
		}
		
		
	}
	
	@Test
	public void test17(){
		try {
			Address address =new Address();
			address.setUid(24);
			address.setId(13);
			address.setRecvName("美女");
			address.setRecvProvince("重庆");
			address.setModifiedTime(new Date());
			addressMapper.update(address);
			System.out.println("修改成功！");
		}catch(ServiceException e) {
			System.out.println(e.getMessage());
		}
		
		
	}
	
	@Test
	public void test18(){
		try {
			Address address =new Address();
			address.setUid(24);
			address.setId(13);
			address.setRecvName("美女");
			address.setRecvProvince("重庆");
			address.setModifiedTime(new Date());
			addressService.update(address);
			System.out.println("修改成功！");
		}catch(ServiceException e) {
			System.out.println(e.getMessage());
		}
		
		
	}
	
	@Test
	public void test19(){
		try {
			Address address=addressService.getAddressById(14);
			System.out.println("address="+address);
		}catch(ServiceException e) {
			System.out.println(e.getMessage());
		}
		
		
	}
	/////////////////////////////////////商品类测试///////////////////////
	
	
	
	
	
	
	@Test
	public void test20(){
		List<GoodsCategory> goodsCategories=goodsCategoryMapper.getCategoryByParent((162L));
		for (GoodsCategory goodsCategory : goodsCategories) {
			System.out.println(goodsCategory);
		}
		
		
	}
	
	
	@Test
	public void test21(){
		List<GoodsCategory> goodsCategories=goodsCategoryService.getList(162L);
		System.out.println("List:");
		for (GoodsCategory goodsCategory : goodsCategories) {
			System.out.println(goodsCategory);
		}
		
		
	}
	//////////////////////////测试goods/////////////////////////
	
	@Test
	public void test22(){
		List<Goods> goodses=goodsService.getHotList(166L,3);
		System.out.println("List:");
		for (Goods goods : goodses) {
			System.out.println(goods);
		}
		
		
	}
	
	@Test
	public void test23(){
		List<Goods> goodses=goodsMapper.getListByCategory(163L, 0, 3);
		System.out.println("List:");
		for (Goods goods : goodses) {
			System.out.println(goods);
		}
		
		
	}
	
	@Test
	public void test24(){
		Goods goods=goodsMapper.getGoodsById(10000017L);
		System.out.println("Goods:");
		System.out.println(goods);
		
	}
	
	@Test
	public void test25(){
		try {
			Goods goods=goodsService.getGoodsById(10000017L);
			System.out.println("Goods:");
			System.out.println(goods);
		}catch(ServiceException e) {
			System.out.println(e.getMessage());
		}
		
		
	}
	/////////////////////////////////////////////////购物车测试////////////////////////////////////////
	@Test
	public void test26(){
		Cart cart=new Cart();
		cart.setUid(25);
		cart.setCreatedTime(new Date());
		cart.setGoodsId(10000017L);
		cart.setGoodsNum(2);
		Integer rows=cartMapper.insert(cart);
	}
	
	
	@Test
	public void test27(){
		Cart cart=new Cart();
		cart.setUid(23);
		cart.setCreatedTime(new Date());
		cart.setGoodsId(10000017L);
		cart.setGoodsNum(5);
		try {
			cartService.addToCart(cart);
			System.out.println("执行成功！");
		}catch(ServiceException e) {
			System.out.println(e.getMessage());
		}
		
	}
	
	@Test
	public void test28(){
		
			Integer count=cartMapper.getCountByUidAndGoodsId(26, 10000017L);
			System.out.println(count);
	}
	
	@Test
	public void test29(){
		
			Integer rows=cartMapper.changeGoodsNum(3, 26, 10000017L);
			System.out.println(rows);
	}
	
	@Test
	public void getList(){
		try {
			List<Cart> carts=cartService.getList(28,5);
			for (Cart cart : carts) {
				System.out.println(cart);
			}
		
		}catch(ServiceException e) {
			System.out.println(e.getMessage());
		}
			
	}
	
	@Test
	public void getCount(){
		Integer count=cartMapper.getListCountByUid(28);
		System.out.println("count="+count);
	}
	
	@Test
	public void getCartListByids(){
		Integer[] ids={7,8,9,10,11,12};
		try {
			List<Cart> carts=cartService.getListByIds(25, ids);
			System.out.println(carts);
			for (Cart cart : carts) {
				System.out.println("cart="+cart);
			}
		}catch(ServiceException e) {
			System.out.println(e.getMessage());
		}
		
		
	}

	///////////////////////测试订单//////////////
	@Test
	public void createOrder(){
		Integer uid=22;
		Integer addressId=14;
		Integer[] cartId={6,5};
		try{
			orderService.createOrder(uid, addressId, cartId);
			System.out.println("订单创建成功！");
		}catch(ServiceException e){
			System.out.println(e.getMessage());
		}
		
	}
	
	//////////////////////测试VO类///////////
	@Test
	public void testVO(){
		/*List<OrderVO>*/ OrderVO ordervos=orderMapper.getOrderByUid(22);
		System.out.println(ordervos);
		/*for (OrderVO orderVO2 : ordervos) {
			System.out.println(orderVO2);
		}*/
			
		
		
	}
	
	
}
