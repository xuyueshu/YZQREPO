package bean;

public class Demo {
    private String name;
    private String age;
    private Integer sex;
    public String getName() {
        return name;
    }
    public void setName(String name) {
        this.name = name;
    }
    public String getAge() {
        return age;
    }
    public void setAge(String age) {
        this.age = age;
    }
    public Integer getSex() {
        return sex;
    }
    public void setSex(Integer sex) {
        this.sex = sex;
    }
    public Demo(String age, Integer sex) {
        super();
        this.age = age;
        this.sex = sex;
    }
}
