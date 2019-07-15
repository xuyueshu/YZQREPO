package test1;

import bean.User;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

public class OptionalTest2 {
     public static void main(String[] args) {
         User u1=null;
         User u2=new User("张三","20");
         User u3=new User("李四","26");
         User u4=new User("王五","28");
         User u5=new User("赵柳","30");
         List<User> list = Arrays.asList(u1,u2,u3,u4,u5);
        /* List<Integer> length=list.stream().map(User ::getName).map(String::length).collect(Collectors.toList());
         length.forEach(integer -> {System.out.println(integer);
         });*/
        List<User> list2=new ArrayList();
        list.forEach(user -> {
            User u=Optional.ofNullable(user).orElse(new User("",""));
            list2.add(u);
        });

        Optional<Integer> total=list2.stream().map(User::getAge).map(String::length).reduce((a,b) -> a+b);
        System.out.println("total="+total.get());

        Optional<Integer> total1=list.stream().filter(user -> user !=null).map(User::getAge).map(String::length).reduce((a,b) -> a+b);
        System.out.println("total1="+total1.get());

     }


}
