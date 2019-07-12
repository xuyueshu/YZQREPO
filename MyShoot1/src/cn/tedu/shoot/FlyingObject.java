package cn.tedu.shoot;
import java.util.Random;
import java.awt.image.BufferedImage;
import javax.imageio.ImageIO;//图片录入输出
import java.awt.Graphics;
public abstract class FlyingObject {//建一个超类，同样的成员变量和方法，构造方法
	public static final int LIFE=0;//设计状态为常量必赋值
	public static final int DEAD=1;
	public static final int REMOVE=2;
	protected int state=LIFE;///给state变量赋初值
	protected int width;//protected后的变量在同类，同包，派生类可以用，超类变量用protected
	protected int height;//protected权限大于默认，继承可以跨包
	protected int x;
	protected int y;
	
	//建第一个超类构造，针对小敌机、大敌机、小蜜蜂
	public FlyingObject(int width,int height){//因为宽度高度不能写死，所以要设置参数，当超类构造带有参数，所以派生类
		 this.width=width;                  //构造第一行不默认调无参超类构造，自己写
		 this.height=height;
		 Random rand=new Random();
		 x=rand.nextInt(World.WIDTH-this.width);//x为这个区间的随机数
    	 y=-this.height;
		 
	 }
	 //建第二个超类构造，针对英雄机、天空、子弹
	public FlyingObject(int width,int height,int x,int y){
		 this.width=width;
		 this.height=height;//因为宽度、高度不能写死，所以加参数
		 this.x=x;
		 this.y=y;
	 }
	 //读取图片，每个对象都要读取图片这个行为,一次只能获取一张
	public static BufferedImage loadImage(String fileName) {//读取图片只与参数有关
		try {
			BufferedImage img=ImageIO.read(FlyingObject.class.getResource(fileName));//同包中读图片
			return img;
		}catch(Exception e) {           //try ...catch 是异常处理，做文件处理时，一定要加
			e.printStackTrace();
			throw new RuntimeException();
		}
	}
	/*飞行物移动*/
	public abstract void step(); //飞行物移动方式不一样，所以改成抽象方法，报错后，将类也改成抽象类
	/*获取图片*/
	public abstract BufferedImage getImage();//每个对象获取方式不同，所以抽象,派生类方法要重写
	/*判断是否活着*/
	public boolean isLife() {
		return state==LIFE;//当前状态为LIFE则返回true
	}	
	public boolean isDead() {
		return state==DEAD;
	}
	public boolean isRemove() {
		return state==REMOVE;
		
	}
	/*画对象（图片），g：画笔*/
	public void paintObject(Graphics g) {//每个对象都能画，所以将画对象的行为设计在超类中，
		g.drawImage(getImage(),x,y,null);//每个对象画的方式都一样，所以设计为普通方法	
	}
	
	/*越界检查*/
	public boolean outOfBounds() {
		return this.y>=World.HEIGHT;	
	}
	
	/*撞击判断*/
	public boolean hit(FlyingObject other) {//other代表子弹和英雄机
		int x1=this.x-other.width;
		int x2=this.x+this.width;
		int y1=this.y-other.height;
		int y2=this.y+this.height;
		int x=other.x;
		int y=other.y;
		return x>=x1&&x<=x2	&& y>=y1&&y<=y2;	
	}
	
	/*飞行物去死*/
	public void goDead() {
		state=DEAD;	
	}
	
	
		
	
	
}
