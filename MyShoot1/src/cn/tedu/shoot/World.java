package cn.tedu.shoot;//变量私有，方法公开
//整个游戏世界
import javax.swing.JFrame;//(框)
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.awt.Graphics;////////world为窗口
import java.util.Timer;//定时器
import java.util.TimerTask;//导入定时任务
import javax.swing.JPanel;//（板）
import java.util.Random;
import java.util.Arrays;
public class World extends JPanel {//建立world类  测试
  public static final int WIDTH=400; 
  public static final int HEIGHT=700;
  private Sky sky=new Sky();                  //类 对象
  private Hero hero=new Hero();
  private FlyingObject[] enemies= {};//建议：成员类型为引用类型，要赋值，不然默认为null
  private Bullet[] bullets= {};//此时数组长度为0
  //world的宽高设定为常量不变，利用的几率很高
 
  /*敌人出现的机率设置*/
  public FlyingObject nextOne() {
	  Random rand =new Random();//new 一个随机对象
	  int type=rand.nextInt(20);//设定敌人出现的机率
	  if(type<4) {
		  return new Bee();
	  }else if(type<12) {
		  return new Airplane();
	  }else {
		  return new BigAirplane();
	  }
  }
  /*敌人入场*/
  int enterindex=0;
  public void enterAction() {//在run里面都是10毫秒
	  enterindex++;//每10秒走一次
	  if(enterindex%2==0) {//每400秒走一次
		  FlyingObject obj=nextOne();
		  enemies=Arrays.copyOf(enemies,enemies.length+1);//扩容
		  enemies[enemies.length-1]=obj;
	  }
  }
  /*子弹入场，即英雄机发射子弹*/
  int shootindex=0;
  public void shootAction() {//每10毫秒走一次
	  shootindex++;
	  if(shootindex%1==0) {//每300毫秒走一次
		  Bullet[] bs=hero.shoot();//获取子弹对象，shoot方法在hero对象类中，由hero来调
		  bullets=Arrays.copyOf(bullets, bullets.length+bs.length);//扩容。
		  System.arraycopy(bs, 0, bullets, bullets.length-bs.length, bs.length);
	  }//把bs追加到bullet数组里
  }
  /*敌人动起来*/
  public void stepAction() {
	  sky.step();
	  for(int i=0;i<enemies.length;i++) {
		  enemies[i].step();
	  }
	  for(int i=0;i<bullets.length;i++) {
		  bullets[i].step();
	  }
  }
    /*删除越界，每10毫秒走一次*/
  public void outOfBoundsAction() {
	  int index=0;//下标表示不越界敌人的个数
	  FlyingObject[] enemiesLives=new FlyingObject[enemies.length];//不越界敌人数组，长度与原数组相等
	  for(int i=0;i<enemies.length;i++) {
		  FlyingObject f=enemies[i];//获取敌人
		  if(!f.outOfBounds()) {//不越界，f是FlyingObject类型，能点出outOfBounds方法
			  enemiesLives[index]=f;//不越界的装在f中
			  index++;
		  }
	  }
	  enemies=Arrays.copyOf(enemiesLives, index);
	  index=0;
	  Bullet[] bulletsLives=new Bullet[bullets.length];
	  for(int i=0;i<bullets.length;i++) {
		  Bullet b=bullets[i];
		  if(!b.outOfBounds()) {
			  bulletsLives[index]=b;
			  index++;
		  }
	  }
	  bullets=Arrays.copyOf(bulletsLives, index);
  }
  /*子弹与敌人碰撞*/
  int score=0;
  public void bulletBangAction() {
	  for(int i=0;i<bullets.length;i++) {
		  Bullet b=bullets[i];//获取子弹
		  for(int j=0;j<enemies.length;j++) {
			  FlyingObject f=enemies[j];//获取敌人
			  if(b.isLife()&&f.isLife()&&f.hit(b)) {
				  b.goDead();//子弹去死
				  f.goDead();//敌人去死
			  
			  
		  if(f instanceof Enemy) {//若是敌人能得分
			  Enemy e=(Enemy)f;//强转为得分接口
			  score+=e.getScore();//累加得分
			  System.out.println(score);
		  }
		  
		  if(f instanceof Award) { //若是奖励
			  Award a=(Award)f;       //强转奖励接口
			  int type=a.getAwardType(); //获取奖励类型
			  switch(type){
				  case Award.DOUBLE_FIRE://奖励类型为火力
					  hero.adddoubleFire();//加火力值
					  break;
				  case Award.LIFE://奖励类型为获命
					  hero.addlife();//加命值
					  break; 
			    }
		     }
		  }	  
	  }
  }
  }
  
       /*启动程序的执行*/
    public void action() {//装测试代码
    	MouseAdapter l=new MouseAdapter() {//建立侦听器对象(触发事件)，匿名内部类没名字，l为派生类的对象
    		public void mouseMoved(MouseEvent e) {//在侦听器重写mouseMoved鼠标移动事件
    			int x=e.getX();//获取鼠标x坐标
    			int y=e.getY();
    			hero.moveTo(x, y);//英雄机随鼠标动	
    		}
    	};
    	this.addMouseListener(l);//鼠标操作事件
    	this.addMouseMotionListener(l);//鼠标滑动事件
	 Timer timer=new Timer();
	 int intervel=2;//定时间隔（毫秒）
	 timer.schedule(new TimerTask() {                
		 public void run() {//定时干的事，匿名内部类
			 enterAction();//敌人入场
			 shootAction();//子弹入场
			 stepAction();//对象移动
			 outOfBoundsAction();//删除越界方法
			 bulletBangAction();
			 repaint();//重新调paint方法
		 }
	 },intervel,intervel);//计划表，参数类型（timerTask类型，long，long）	  
	  }
	  
       /*在world中重写paint*/
	  public void paint(Graphics g) {
		  sky.paintObject(g);
		  hero.paintObject(g);
		  for(int i=0;i<enemies.length;i++) {
			  enemies[i].paintObject(g);
		  }
		  for(int i=0;i<bullets.length;i++) {
			  bullets[i].paintObject(g);
		  }	 
		  g.drawString("SCORE:"+score,10,25);//10为x坐标，25为y坐标
		  g.drawString("LIFE:"+hero.getlife(),10,45);
	  }
	  
	  
	  
	  
  public static void main(String[]args) {
	  JFrame frame = new JFrame();
		World world = new World();
		frame.add(world);
		frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		frame.setSize(world.WIDTH,world.HEIGHT);
		frame.setLocationRelativeTo(null); 
		frame.setVisible(true); //1)设置窗口可见  2)尽快调用paint()方法
		
		world.action(); //启动程序的执行,action是静态方法，所以需要world点来访问
  }
}

