package test1;


import java.util.Arrays;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

public class TestListStreamFilter {
     public static void main(String[] args) {
         List<String> lines= Arrays.asList("zhangsan","lisi","wangwu");
         List<String> result=getFilterOutPut(lines);
         for (String r:result){
             System.out.println(r);
         }
         Optional<String> result1=getFirstFilterOutPut(lines);
         System.out.println("result1="+result1.get());

     }


    private static Optional<String> getFirstFilterOutPut(List<String> lines) {
         Optional<String> result1=lines.stream().filter(line -> "wangwu".equals(line)).findFirst();
         return result1;
    }

    private static List<String> getFilterOutPut(List<String> lines) {
         List<String> result=lines.stream().filter(line -> !"lisi".equals(line)).collect(Collectors.toList());
         return result;
    }



}
