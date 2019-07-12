package cn.tedu.shoot;//域名反写，避免公司冲突
//小敌机
import java.util.Random; //不同包里面的类利用，要声明。import 包.类（java.util 为包，Random为类）
import java.awt.image.BufferedImage;

public class Airplane extends FlyingObject implements Enemy{
	 public static BufferedImage[] images;
	 static {    //静态块,放在第一行
		 
	 		images=new BufferedImage[5];
	 		for(int i=0;i<images.length;i++) {
	 			images[i]=loadImage("airplane"+i+".png");
	 		}
	 		
	 	}
    
    private int speed;//移动速度
    public Airplane(){//构造方法没有返回值类型，方法名与类名相同
    	 
    	 super(49,36);
    	 speed=2;
    	 
     }
     //重写，当超类的方法不好用了，就要在派生类里重写方法
    public void step() {
		 y+=speed;
	 }
    //重写获取图片，每个获取图片的方式不一样
    int index=1;
    public BufferedImage getImage() {//每10毫秒走一次
    	if(isLife()) {
    		return images[0];
    	}else if(isDead()) {
    		BufferedImage img=images[index++];
    		if(index==images.length) {//image[1]到image[4]轮转
    			state=REMOVE;
    		}
    		return img;
    	}
    	return null;//删除状态时，返回null
		
    	
    }
 //重写接口得分
 public int getScore() {
	 return 1;//打掉小敌机得一分
 }
 
 
	
 
 
}
