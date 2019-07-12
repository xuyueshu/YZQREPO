package cn.tedu.shoot;
//hero 对象类
import java.awt.image.BufferedImage;
public  class Hero extends FlyingObject {
  public static BufferedImage[] images;
  static {    //静态块，将读取的图片保存在方法区里面，只执行一次。
		images=new BufferedImage[2];
		images[0]=loadImage("hero0.png");
		images[1]=loadImage("hero1.png");
	}
	private int life;
	private int doubleFire;


	public Hero(){//构造方法
    	super(97,124,140,400);
    	  life=3;
    	  doubleFire=0;	  
      }
	public void step() {}
	 //重写获取图片
	int index=0;
	public BufferedImage getImage() {//设置每10毫秒走一次
		
		if(isLife()) {
			return images[index++%2];
		}
		return null;
	}
	//  取余结果为image[0]image[1]切换


void moveTo(int x,int y) {//英雄机随鼠标移动
	this.x=x-this.width/2;//this.x代表英雄机的横坐标，this.x为鼠标的横坐标
	this.y=y-this.height/2;
	
	
}
//生成子弹对象（子弹由英雄机生成）
public Bullet[] shoot() {
	int xStep=this.width/4;
	int yStep=20;
	if(doubleFire>0) {
		Bullet[] bs=new Bullet[2];//两发子弹
		bs[0]=new Bullet(this.x+1*xStep,this.y-yStep);
		bs[1]=new Bullet(this.x+3*xStep,this.y-yStep);
		doubleFire-=2;//发射一次子弹火力-2
		return bs;
	}else {
		Bullet[] bs=new Bullet[1];//单发子弹
		bs[0]=new Bullet(this.x+2*xStep,this.y-yStep);
		return bs;
	}
}
//增命
public void addlife() {//1.先写行为2.页面调用
	life++;
}
//增火力
public void adddoubleFire() {
	doubleFire+=40;
}
/*获取英雄机的命*/
public int getlife() {
	return life;
}
	
	
	
}
