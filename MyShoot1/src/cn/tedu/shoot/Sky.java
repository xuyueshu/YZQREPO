package cn.tedu.shoot;
import java.awt.Graphics;
//天空

import java.awt.image.BufferedImage;
public class  Sky extends FlyingObject {
	private static BufferedImage image;      //静态放第一行
	static {    //静态块
		image=loadImage("background.png");
	}
	private int speed;//移动速度
	private int y1;//第二章图的y坐标
	 
		//构造方法
	 Sky(){
		 super(World.WIDTH,World.HEIGHT,0,0);
	   speed=1;
	   y1=-700;  //可以写死
	   
	 }
	 //重写方法
	 public void step() {
		 y+=speed;
		 y1+=speed;
		 if(y>=World.HEIGHT) {//当y大于等于窗口高时，意味图片出窗口
			 y=-World.HEIGHT;//重新走//
		 }
		 if(y1>=World.HEIGHT) {
			 y1=-World.HEIGHT;
		 }
	 }
	 //重写天空获取图片
	 public BufferedImage getImage() {
		 return image;//天空只有一种状态，直接return
		 
	 }
	//   重写天空画图片      画对象，g：画笔
		public void paintObject(Graphics g) {
			g.drawImage(getImage(),x,y,null);
			g.drawImage(getImage(),x,y1,null);//画两张图，天空为两张图
		}
	 
}
