package cn.tedu.store.entity;

import java.util.List;

public class OrderVO {
	private Integer id;
	private String recvName;
	private String recvPhone;
	private String recvAddress;
	private String totalPrice;
	private List<OrderItem> orderItems;
	
	public Integer getId() {
		return id;
	}
	public void setId(Integer id) {
		this.id = id;
	}
	public String getRecvName() {
		return recvName;
	}
	public void setRecvName(String recvName) {
		this.recvName = recvName;
	}
	public String getRecvPhone() {
		return recvPhone;
	}
	public void setRecvPhone(String recvPhone) {
		this.recvPhone = recvPhone;
	}
	public String getRecvAddress() {
		return recvAddress;
	}
	public void setRecvAddress(String recvAddress) {
		this.recvAddress = recvAddress;
	}
	public String getTotalPrice() {
		return totalPrice;
	}
	public void setTotalPrice(String totalPrice) {
		this.totalPrice = totalPrice;
	}
	public List<OrderItem> getOrderItems() {
		return orderItems;
	}
	public void setOrderItems(List<OrderItem> orderItems) {
		this.orderItems = orderItems;
	}
	@Override
	public String toString() {
		return "OrderVO [id=" + id + ", recvName=" + recvName + ", recvPhone=" + recvPhone + ", recvAddress="
				+ recvAddress + ", totalPrice=" + totalPrice + ", orderItems=" + orderItems + "]";
	}
	
	
	

}
