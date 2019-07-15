package test1;

public class ColorTest {
    Color c =Color.BLANK;
    public void change(){
        switch (c){
            case RED:
                c= Color.GREEN;
                System.out.println("变成了绿色");
            case GREEN:
                c=Color.BLANK;
                System.out.println("变成了黑色");
            case BLANK:
                c=Color.YELLOW;
                System.out.println("变成了黄色");

        }
    }

     public static void main(String[] args) {
         ColorTest t1=new ColorTest();
         t1.change();

      }
}
