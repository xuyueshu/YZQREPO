package com.yzq.springboot.bean;

import java.util.List;

public class EasyUIDatagrid {
	//easyui中显示的数据
	private List<?> rows;
	//总个数，数据条数
	private Integer total;
	public List<?> getRows() {
		return rows;
	}
	public void setRows(List<?> rows) {
		this.rows = rows;
	}
	public Integer getTotal() {
		return total;
	}
	public void setTotal(Integer total) {
		this.total = total;
	}
	@Override
	public String toString() {
		return "EsayUIDatagrid [rows=" + rows + ", total=" + total + "]";
	}
	
}
