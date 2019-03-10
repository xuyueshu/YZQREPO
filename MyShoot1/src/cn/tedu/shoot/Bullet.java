package cn.tedu.shoot;
//子弹
import java.awt.image.BufferedImage;

public class Bullet extends FlyingObject{
	 private static BufferedImage image; 
	 static {    //静态块
		 image=loadImage("bullet.png");
		}
	private int speed;//移动速度
	 Bullet(int x,int y){//子弹的位置不能写死，所以要传参
		 super(8,14,x,y);
          speed=3;
		 
	 }//重写方法
	 public void step() {
		 y-=speed;
	 }
	 //重写获取图片
	 public BufferedImage getImage() {
		 if(isLife()) {
			 return image;
		 }else if(isDead()) {
			 state=REMOVE;
		 }
		 return null;//return只执行一次
		 
	 }
	 //重写子弹越界
	 public boolean outOfBounds() {
			return this.y<=-this.height;
			
		}
		
	 
}
