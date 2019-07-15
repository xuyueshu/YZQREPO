package test1;

import bean.User;

import java.util.Optional;
import java.util.function.Consumer;

public class TestOptional3 {
     public static void main(String[] args) {
      TestOptional3 test=new TestOptional3();
      test.test();
     }
//ifPresent(Consumer consumer)：如果option对象保存的值不是null，则调用consumer对象，否则不调用
     private void test(){
         User u=null;
         Optional<User> opt=Optional.ofNullable(u);
         opt.ifPresent(new Consumer<User>() {
             @Override
             public void accept(User user) {
                 System.out.println("开始调用consumer对象");
                 System.out.println(opt.get());
             }
         });
     }

}
