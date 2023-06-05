import org.aspectj.lang.reflect.SourceLocation;
import java.io.*;
import java.time.LocalDateTime;
import java.util.UUID;

public aspect Logger {
    private UUID _id;
    private LocalDateTime _time;
    private SourceLocation _source;
    private Object[] _args;
    private String _classname;


    /*
     * Before the call to constructor to object instantiated from
     * anything annotated with @logging
     * Assign ID and record time of creation
     */
    before(): call(*.new(..)) && @within(logging) {
        _id = UUID.randomUUID();
        _time = LocalDateTime.now();
        _source = thisJoinPoint.getSourceLocation();
        _args = thisJoinPoint.getArgs();
        _classname = thisJoinPoint.getSignature().getDeclaringTypeName();
    }

    /*
     * After execution of constructor from object instantiated from
     * anything annotated with @logging
     * Log information to CSV
     */
    after(): execution(*.new(..)) && @within(logging) {
        String filename = _classname + ".csv";

        Object obj = thisJoinPoint.getTarget();
        ((Log)obj).setId(_id);
        ((Log)obj).setToc(_time);

        try (PrintWriter out = new PrintWriter(new FileWriter(filename, true))) {
            StringBuilder argString = new StringBuilder();

            for (Object arg : _args) {
                if (arg != null && arg.getClass().isAnnotationPresent(logging.class)) {
                    argString.append(Integer.toHexString(System.identityHashCode(arg)));
                } else {
                    argString.append(arg);
                }
                argString.append(", ");
            }

            out.printf("%s, %s, %s, %s\n", _id, _time, _source, argString.toString());
        } catch (IOException e) {
            e.printStackTrace();
        }
    }


    /*
     * Interface for annotations of @logging to implement
     */
    interface Log {}



    private UUID Log.id;
    private LocalDateTime Log.toc;

    public UUID Log.getId() {return id;}
    public void Log.setId(UUID n) {id = n;}
    public LocalDateTime Log.getToc() {return toc;}
    public void Log.setToc(LocalDateTime t) {toc = t;}



    /*
     * Inter-type declaration
     * Return true if time of creation of object x is later
     * than this time of creation
     */
    public boolean Log.olderThan(Object x) {
        if (x.getClass().isAnnotationPresent(logging.class)) {
            LocalDateTime timeOfCreation = this.getToc();

            LocalDateTime timeOfCreation2 = ((Log)x).getToc();

            return timeOfCreation != null && timeOfCreation2 != null && timeOfCreation.isBefore(timeOfCreation2);
        }
        return false;
    }



    /*
     * Annotations of @logging implement Log
     */
    declare parents : @logging * implements Log;
}
