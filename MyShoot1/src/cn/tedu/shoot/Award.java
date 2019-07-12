package cn.tedu.shoot;
//奖励接口
public interface Award {
	//接口的使用
	/*
	 * 1.1、由于接口里面存在抽象方法，所以接口对象不能直接使用关键字new进行实例化。接口的使用原则如下： 
（1）接口必须要有子类，但此时一个子类可以使用implements关键字实现多个接口； 
（2）接口的子类（如果不是抽象类），那么必须要覆写接口中的全部抽象方法； 
（3）接口的对象可以利用子类对象的向上转型进行实例化。

---------------------

本文来自 志见 的CSDN 博客 ，全文地址请点击：https://blog.csdn.net/wei_zhi/article/details/52738471?utm_source=copy 
	 */
	
public int DOUBLE_FIRE=0;//火力值
public int LIFE=1;//命
//获取奖励类型（0或1）
public int getAwardType();

}
