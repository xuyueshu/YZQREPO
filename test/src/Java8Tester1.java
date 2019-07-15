import jdk.internal.org.objectweb.asm.tree.analysis.Value;

import java.util.Optional;

public class Java8Tester1 {
     public static void main(String[] args) {
         Java8Tester1 java8 =new Java8Tester1();
         Integer value1=null;
         Integer value2=10;
         Optional<Integer> a=Optional.ofNullable(value1);
         Optional<Integer> b=Optional.of(value2);
         System.out.println(java8.sum(a,b));



     }

    private static Integer  sum(Optional<Integer> a, Optional<Integer> b) {
          System.out.println("第一个参数存在:"+a.isPresent());
          System.out.println("第一个参数存在:"+b.isPresent());
          Integer value1=a.orElse(10);
          Integer value2=b.get();
        return value1+value2;
    }
}
