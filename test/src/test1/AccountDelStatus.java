package test1;

public enum AccountDelStatus {
    IS_DELETE("已删除",1),IS_NOT_DELETE("未删除",1);

    private AccountDelStatus(String name,int index){
        this.name=name;
        this.index=index;
    }
    private String name;
    private int index;

    public String getName() {
        return name;
    }

    public int getIndex() {
        return index;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setIndex(int index) {
        this.index = index;
    }

    @Override
    public String toString() {
        return "AccountDelStatus{" +
                "name='" + name + '\'' +
                ", index=" + index +
                '}';
    }

     public static void main(String[] args) {
        for(AccountDelStatus a : AccountDelStatus.values()){
            System.out.println(a);

        }


     }

}
