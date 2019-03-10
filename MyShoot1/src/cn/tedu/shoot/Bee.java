package cn.tedu.shoot;

import java.util.Random;
import java.awt.image.BufferedImage;
//小蜜蜂
public class Bee extends FlyingObject implements Award{
public static BufferedImage[] images;
	  static {    //静态块
		  images=new BufferedImage[5];
	 		for(int i=0;i<images.length;i++) {
	 			images[i]=loadImage("bee"+i+".png");
	 		}
		}
	private int xspeed;//x坐标移动速度
	private int yspeed;//y坐标移动速度
	private int awardType;//奖励类型(有两种)

	public Bee(){//写死不用传参//构造方法
    	
		 super(60,50); 
    	 xspeed=1;
    	 yspeed=2;
    	 Random rand=new Random();
    	 awardType=rand.nextInt(2);// 奖励类型，为0-1的随机数
    	
	 }
		//重写方法
	public void step() {
		 x+=xspeed;
		 y+=yspeed;
		 if(x<=0||x>=World.WIDTH-this.width) {//当走到两个端头时切换方向
			 xspeed*=-1;
		
		 }
		 System.out.println(x); 
	 }
	//重写获取图片
	int index=1;
    public BufferedImage getImage() {//每10毫秒走一次
    	if(isLife()) {
    		return images[0];
    	}else if(isDead()) {
    		BufferedImage img=images[index++];//注意index++
    		if(index==images.length) {
    			state=REMOVE;
    		}
    		return img;
    	}
    	return null;
		
    	
    }
    //重写奖励（接口）
    public int getAwardType() {
    	return awardType;
    }
	 
}
