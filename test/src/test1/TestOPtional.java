package test1;

import bean.User;

import javax.swing.text.html.Option;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;
import java.util.logging.Logger;

public class TestOPtional {
     public static void main(String[] args) {
         User user1=new User("zhangsan","19");
         User user2=null;
         User op21=Optional.ofNullable(user2).orElse(user1);
         System.out.println("op21="+op21);
         System.out.println("----------------------------------------");

         User u11=Optional.ofNullable(user1).orElse(createUser("wangwu11","19"));
         User u12=Optional.ofNullable(user1).orElseGet(() ->createUser("wangwu12","19"));
         User u21=Optional.ofNullable(user2).orElse(createUser("wangwu21","19"));
         User u22=Optional.ofNullable(user2).orElseGet(() ->createUser("wangwu12","19"));
         List<User> u= Arrays.asList(u11,u12,u21,u22);
         u.forEach(user ->{System.out.println("user:"+user);
         });


     }

    private static User createUser(String name, String age) {
         User user=new User(name,age);
         System.out.println(user.getName()+"  用户已创建！");
         return user;
    }


}
