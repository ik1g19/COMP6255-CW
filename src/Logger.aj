import org.aspectj.lang.reflect.SourceLocation;

import java.io.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public aspect Logger {
    after(): execution(*.new(..)) && @within(logging) {
        String className = thisJoinPoint.getSignature().getDeclaringTypeName();
        String filename = className + ".csv";

        Object o = thisJoinPoint.getTarget();

        String objectId = Integer.toHexString(System.identityHashCode(o));
        LocalDateTime time = LocalDateTime.now();
        SourceLocation sourceLocation = thisJoinPoint.getSourceLocation();
        Object[] args = thisJoinPoint.getArgs();

        try (PrintWriter out = new PrintWriter(new FileWriter(filename, true))) {
            StringBuilder argString = new StringBuilder();

            for (Object arg : args) {
                if (arg != null && arg.getClass().isAnnotationPresent(logging.class)) {
                    argString.append(Integer.toHexString(System.identityHashCode(arg)));
                } else {
                    argString.append(arg);
                }
                argString.append(", ");
            }

            out.printf("%s, %s, %s, %s\n", objectId, time, sourceLocation, argString.toString());
        } catch (IOException e) {
            e.printStackTrace();
        }
    }


    // Inter-type declaration to add olderThan method
    public boolean Object.olderThan(Object x) {
        if (this.getClass().isAnnotationPresent(logging.class) &&
                x.getClass().isAnnotationPresent(logging.class)) {
            String className = this.getClass().getName();
            String filename = className + ".csv";
            String objectId = Integer.toHexString(System.identityHashCode(this));
            LocalDateTime timeOfCreation = null;

            try (BufferedReader reader = new BufferedReader(new FileReader(filename))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    String[] parts = line.split(", ");
                    if (parts.length >= 2 && parts[0].equals(objectId)) {
                        timeOfCreation = LocalDateTime.parse(parts[1], DateTimeFormatter.ISO_LOCAL_DATE_TIME);
                    }
                }
            } catch (IOException e) {
                e.printStackTrace();
            }



            String className2 = x.getClass().getName();
            String filename2 = className2 + ".csv";
            String objectId2 = Integer.toHexString(System.identityHashCode(x));
            LocalDateTime timeOfCreation2 = null;

            try (BufferedReader reader = new BufferedReader(new FileReader(filename2))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    String[] parts = line.split(", ");
                    if (parts.length >= 2 && parts[0].equals(objectId2)) {
                        timeOfCreation2 = LocalDateTime.parse(parts[1], DateTimeFormatter.ISO_LOCAL_DATE_TIME);
                    }
                }
            } catch (IOException e) {
                e.printStackTrace();
            }

            System.out.println(timeOfCreation);
            System.out.println(timeOfCreation2);


            return timeOfCreation != null && timeOfCreation2 != null && timeOfCreation.isBefore(timeOfCreation2);
        }
        return false;
    }
}
