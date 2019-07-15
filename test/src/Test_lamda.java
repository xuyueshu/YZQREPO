import bean.Student;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

public class Test_lamda {
    public void test(){
        List<Student>  list = new ArrayList<Student>();
        Student student1 = new Student();student1.setAge("12");student1.setSex(0);
        Student student2 = new Student();student2.setAge("13");student2.setSex(2);
        Student student3 = new Student();student3.setAge("11");student3.setSex(1);
        Student student4 = new Student();student4.setAge("18");student4.setSex(1);
        Student student5 = new Student();student5.setAge("18");student5.setSex(0);
        Student student6 = new Student();student6.setAge("18");student6.setSex(2);
        Student student7 = new Student();student7.setAge("18");student7.setSex(2);
        list.add(student1);
        list.add(student2);
        list.add(student3);
        list.add(student4);
        list.add(student5);
        list.add(student6);
        list.add(student7);

        list.forEach(student -> System.out.println(student.getAge()));
        /*int count=list.stream().filter(student -> student.getAge()="18").count();*/
        List<String>strings = Arrays.asList("abc", "", "bc", "efg", "abcd","", "jkl");
// 获取空字符串的数量
        Long count = strings.stream().filter(string -> string.isEmpty()).count();
        System.out.println(count);


        //生成流
        List<String> strings1 = Arrays.asList("abc", "", "bc", "efg", "abcd","", "jkl");
        List<String> filtered = strings1.stream().filter(string1 -> !string1.isEmpty()).collect(Collectors.toList());



    }
     public static void main(String[] args) {
      Test_lamda T=new Test_lamda();
         T.test();
         System.out.println();
         DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
         String st=LocalDate.now().format(formatter).toString();
         String st1=LocalDate.now().minusDays(1).format(formatter).toString();
         String st2=LocalDate.now().minusYears(1).format(formatter).toString();
         System.out.println("st="+st);
         System.out.println("st1="+st1);
         System.out.println("st2="+st2);

      }

}
