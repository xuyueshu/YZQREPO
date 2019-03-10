package cn.tedu.shoot;

import java.util.Random;
import java.awt.image.BufferedImage;

//大敌机，与小敌机一样
public class BigAirplane extends FlyingObject implements Enemy{
	public static BufferedImage[] images;
	static {    //静态块
		images=new BufferedImage[5];
 		for(int i=0;i<images.length;i++) {
 			images[i]=loadImage("bigplane"+i+".png");
 		}
		}
	
	private int speed;//移动速度
	 BigAirplane(){//参数写死
		 super(69,99);
    	 speed=2;
	 }
	 //重写方法
	 public void step() {
		y+=speed;//y向下
	 }
	//重写获取图片
	 int index=1;
	    public BufferedImage getImage() {//每10毫秒走一次
	    	if(isLife()) {
	    		return images[0];
	    	}else if(isDead()) {
	    		BufferedImage img=images[index++];
	    		if(index==images.length) {
	    			state=REMOVE;
	    		}
	    		return img;
	    	}
	    	return null;
			
	    	
	    }
	 //
	    public int getScore() {
	    	return 3;
	    }
}
