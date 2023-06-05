@logging
public class TestObj {

    public TestObj() {
        System.out.println("Constructed");
    }

    public void sayHi() {
        System.out.println("Hi");
    }

    public static void main(String[] args) {
        TestObj o = new TestObj();
        o.sayHi();

        TestObj o2 = new TestObj();
        o2.sayHi();

        System.out.println(o.olderThan(o2));
    }
}
