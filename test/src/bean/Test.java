package bean;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public class Test {
    @org.junit.Test
    public void test() {
        List<Student> list = new ArrayList<>();
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
        List<Demo> demos = new ArrayList<Demo>();
        demos = printData(demos, list);
//         printSexequal0(demos);
//         filterAge(demos);
//         sort(demos);
//         pour(demos);
//         pour2(demos);
//         moreSort(demos);
//         morePour(demos);
        groupByAge(demos);

    }

    /**
     * 数据打印
     * @param demos
     * @param list
     */
    public List<Demo> printData(List<Demo> demos ,List<Student> list) {
        demos = list.stream().map(student -> new Demo(student.getAge(),student.getSex())).collect(Collectors.toList());
        /*demos.forEach(demo ->{
            System.out.println(demo.getAge());
        });*/
        return demos;
    }

    /**
     * 打印性别为0的数据
     * @param demos
     */
    public void printSexequal0(List<Demo> demos) {
        List<Demo> collect = demos.stream().filter(demo -> demo.getSex() == 0).distinct().collect(Collectors.toList());
        collect.forEach(item ->{
            System.out.println("\n"+item.getAge()+":"+item.getSex());
        });
    }

    /**
     * 过滤年龄大于12的信息
     * @param demos
     */
    public void filterAge(List<Demo> demos) {
        List<Demo> collect = demos.stream().filter(demo -> Integer.valueOf(demo.getAge())>12).collect(Collectors.toList());
        collect.forEach(demo ->{
            System.out.println(demo.getAge()+":"+demo.getSex());
        });
    }

    /**
     * 数据排序
     * @param demos
     */
    public void sort(List<Demo> demos) {
        List<Demo> collect = demos.stream().sorted((s1,s2) -> s1.getAge().compareTo(s2.getAge())).collect(Collectors.toList());
        collect.forEach(demo -> {
            System.out.println(demo.getAge());
        });
    }

    /**
     * 倒叙
     * @param demos
     */
    public void pour(List<Demo> demos) {
        ArrayList<Demo> demoArray = (ArrayList<Demo>)demos;
        demoArray.sort(Comparator.comparing(Demo::getAge).reversed());
        demoArray.forEach(demo -> {
            System.out.println(demo.getAge());
        });
    }

    /**
     * 倒叙2
     * @param demos
     */
    public void pour2(List<Demo> demos) {
        ArrayList<Demo> demoArray = (ArrayList<Demo>)demos;
        Comparator<Demo> comparator = (h1,h2) -> h1.getAge().compareTo(h2.getAge());
        demoArray.sort(comparator.reversed());
        demoArray.forEach(demo -> {
            System.out.println(demo.getAge());
        });
    }

    /**
     * 多条件排序--正序
     * @param demos
     */
    public void moreSort(List<Demo> demos) {
        demos.sort(Comparator.comparing(Demo::getSex).thenComparing(Demo::getAge));
        demos.forEach(demo ->{
            System.out.println(demo.getSex()+":"+demo.getAge());
        });
    }

    /**
     * 多条件倒叙
     * @param demos
     */
    public void morePour(List<Demo> demos) {
        demos.sort(Comparator.comparing(Demo::getSex).reversed().thenComparing(Demo::getAge));
        demos.forEach(demo ->{
            System.out.println(demo.getSex()+":"+demo.getAge());
        });
    }

    /**
     * 分组
     * @param demos
     */
    public void groupByAge(List<Demo> demos) {
        Map<String, List<Demo>> collect = demos.stream().collect(Collectors.groupingBy(Demo::getAge));
        collect.forEach((key,value)->{
            value.forEach(demo ->{
                System.out.println(key+":"+demo.getSex());
            });
        });
    }
}
