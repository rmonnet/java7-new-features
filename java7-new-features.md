
# What's new in Java 7?

<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/5/5d/Duke_%28Java_mascot%29_waving.svg/133px-Duke_%28Java_mascot%29_waving.svg.png" width="100">

&copy; 2016 Robert Monnet

###### licensed under the [Creative Commons Attribution 4.0 Int. License](http://creativecommons.org/licenses/by/4.0/)
###### ![license](https://i.creativecommons.org/l/by/4.0/80x15.png)

---

## Improvements in Java 7

Syntax Improvements that help write cleaner code.

- Diamond <> operator
- `try` with resources
- Multi-exceptions `catch` blocks
- `String` arguments in `switch` statements

Java library new features for concurrency and IO.

- `LinkedTransferQueue` concurrent queue
- `java.nio.file` package
- `fork/join` framework


---

## Diamond Operator <>

- Use <> to avoid type repetition when constructing objects.

##### Before Java 7

```java
// new needs to fully specify the Generic Parameters.

public TreeMap<String, LinkedList<String>> map = 
        new TreeMap<String, LinkedList<String>>();
```

##### Java 7

```java
// new can use the <> operator for shorter declaration.

public TreeMap<String, LinkedList<String>> map = 
        new TreeMap<>();
```

---

## try-with-resources

##### Before Java 7, use `finally` block to insure resources are released.

```java
BufferedReader in = null; // declare resource before try block
try {
    in = new BufferedReader(new FileReader(filename));
    for (String line = in.readLine(); line != null; 
                                      line = in.readLine()) {
        process(line);
    }
    in.close();
    in = null;
} catch (IOException ex) {
    System.err.println("error: " + ex.getMessage());
} finally {
    if (in != null) { // resource allocation may have failed
        try {
            in.close();
        } catch (IOException ex) { // releasing resource may fail
            System.err.println("error: " + ex.getMessage());
        }
    }
}
```

---

## try-with-resources

##### With Java 7, resource defined with `try()` are automatically released.

```java
// declare resources with try(...)

try (BufferedReader in = 
                new BufferedReader(new FileReader(filename))) {
    for (String line = in.readLine(); line != null; 
                                      line = in.readLine()) {
        process(line);
    }
} catch (IOException ex) {
    System.err.println("error: " + ex.getMessage());
}

// resources are automatically released when try block is exited.
```

---

## try-with-resources

- Exceptions raised when releasing resources are suppressed
    - Typically what you want since released exceptions are ignored.

- If an Exception is allowed to escape the try-with-resource block, it will suppress any exception thrown during the auto-release.
    - Rationale: the exception thrown in the block is more important
    - The suppressed exception can be retrieved via `ex.getSuppressed()`

---

## try-with-resources

##### `IOException` thrown in the `try` block masks any released exception.

```java
// block auto-releases Reader but let IOException bubble up.
try (BufferedReader
    in = new BufferedReader(new FileReader(filename))) {
    for (String line = in.readLine(); line != null;
                                      line = in.readLine()) {
        process(line);
    }
}
```

##### Suppressed exception can be examined in the caller.

```java
} catch (IOException ex) {
    System.out.println("error when reading: " + ex.getMessage());
    for (Throwable se : ex.getSuppressed()) {
        System.out.println("suppressed error: " + se.getMessage());
    }
}
```

---

## try-with-resources

- Resources must implements `AutoCloseable` (compile error otherwise).
- Java library resource classes implement `AutoCloseable`
- Implement `AutoCloseable` in your Class to benefit from the try-with-resource idiom

```java
public interface AutoCloseable {
    void close() throws Exception;
}
```

---

## catching multiple exceptions

##### Before Java 7, different exception types have separate catch blocks.

```java
try (BufferedReader in =
        Files.newBufferedReader(Paths.get(new URI(filename)),
                                Charset.defaultCharset())) {
    for (String line = in.readLine(); line != null;
                                      line = in.readLine()) {
        process(line);
    }
} catch (URISyntaxException ex) {
    System.err.println("error: " + ex.getMessage());
} catch (IOException ex) {
    System.err.println("error: " + ex.getMessage());
}
```

---

## catching multiple exceptions

##### With Java 7, exceptions can be caught within one catch block.

```java
try (BufferedReader in =
        Files.newBufferedReader(Paths.get(new URI(filename)),
                                Charset.defaultCharset())) {
    for (String line = in.readLine(); line != null;
                                      line = in.readLine()) {
        process(line);
    }
} catch (URISyntaxException | IOException ex) {
    System.err.println("error: " + ex.getMessage());
}
```

---

## String arguments in switch

##### Before Java7, only integer and enum arguments were allowed in switch statements.

```java
for (String arg : args) {
    if ("-help".equals(arg)) {
        displayHelp();
    } else if ("-verbose".equals(arg)) {
        setVerbose(true);
    } else if ("-recursive".equals(arg)) {
        setRecursive(true);
    } else {
        setFilename(arg);
    }
}
```

---

## String arguments in switch

##### With Java 7, strings can also be used.

```java
for (String arg : args) {
    switch (arg) {
        case "-help":
            displayHelp();
            break;
        case "-verbose":
            setVerbose(true);
            break;
        case "-recursive":
            setRecursive(true);
            break;
        default:
            setFilename(arg);
    }
```

---

## LinkedTransferQueue

- Class [`LinkedTransferQueue`] [1] is a thread safe queue useful to communicate between threads.
- Important: to be thread safe, messages passed between the threads should be either:
    - read only
    - deep copy
    - such that sender doesn't keep handles on object 

```java
// Create queue and pass to both Producer and Consumer
LinkedTransferQueue<Message> queue = new LinkedTransferQueue<>();
Producer prod = new Producer(queue, 10);
Consumer cons = new Consumer(queue);
```
[1]: https://docs.oracle.com/javase/7/docs/api/java/util/concurrent/LinkedTransferQueue.html
---

## LinkedTransferQueue

##### Producer uses `put()` for a FIFO queue.
```java
// producer adds messages to the LinkedTransferQueue
public void run() {
    while (running) {
        for (int i = 1; i <= nmsgs; i++) {
            Message msg = createMessage(i);
            queue.put(msg);
            sleep(10);
        }
        running = false;
    }
}
```

---

## LinkedTransferQueue


##### Consumer can use `take()` to read (blocking) from the FIFO queue.
```java
// consumer reads messages from the LinkedTransferQueue                           
public void run() {                                       
    while (running) {                                     
        try {                   
            // thread is blocked until an element is available.                          
            Message msg = queue.take();                   
            processMessage(msg);                          
        } catch (InterruptedException _) {                
            // thread blocked on take() can be interrupted.
            // interrupting the thread is useful for the thread to
            // be able to check if running flag has changed.
        }                                                 
    }                                                     
}                                                         
```

---

## LinkedTransferQueue

##### Consumer can use `poll()` to read (non-blocking) from FIFO queues.
```java
// consumer reads messages from multiple LinkedTransferQueue
// using the polling interface.
public void run() {
    while (running) {
        try {
            Command cmd;
            Message msg;
            if ((cmd = cmdQueue.poll()) != null) {
                processCommand(cmd);
            } else if ((msg = msgQueue.poll()) != null) {
                processMessage(msg);
            } else {
                Thread.sleep(50);
            }
        } catch (InterruptedException _) {
            // just ignore the interruption for this case.
        }
    }
}
```

---

## Fork/Join Framework

- New concurrency framework to take advantage of multiple cores/CPUs
- Designed for Divide-and-Conquer (recursive) problems
    - Use Class [`ForkJoinTask`] [2] instances
    - Split a task with `fork()`
    - Wait for a forked task to complete with `join()`
    - Support tasks returning results with [`RecursiveTask<E>`] [3]
    - Support resultless tasks with [`RecursiveAction`] [4] 

---

[2]: https://docs.oracle.com/javase/7/docs/api/java/util/concurrent/ForkJoinTask.html
[3]: https://docs.oracle.com/javase/7/docs/api/java/util/concurrent/RecursiveTask.html
[4]: https://docs.oracle.com/javase/7/docs/api/java/util/concurrent/RecursiveAction.html

## Fork/Join Framework

##### Example using Fork/Join with Tasks returning a result

```java
public class ParMaximum extends RecursiveTask<Double> {
...
public Double compute() {

    // if problem is small enough then solve sequentially
    if ((high - low) < THRESHOLD) {
        return computeDirectly();
    }
    
    // else (recursively) fork half the problem
    int split = low + (high - low) / 2;
    ParMaximum left = new ParMaximum(values, low, split, origin);
    left.fork();
    ParMaximum right = new ParMaximum(values, split, high, origin);

    return Math.max(right.compute(), left.join());
}

```

---

## Fork/Join Framework

##### Example using Fork/Join with result-less Tasks
```java
public class ParQuicksort extends RecursiveAction {
...
public void compute() {
...
    // if the problem is big enough, and we have two branches
    // then solve in parallel.
    if (((high - low) > THRESHOLD) && (low < j) && (i < high)) {
        ParQuicksort sort = new ParQuicksort(numbers, low, j);
        sort.fork();
        new ParQuicksort(numbers, i, high).compute();
        sort.join();
    
    // else solve sequentially
    } else {
        if (low < j) {
            new ParQuicksort(numbers, low, j).compute();
        }
        if (i < high) {
            new ParQuicksort(numbers, i, high).compute();
        }
    }
```

---

## Fork/Join Framework

- Fork/Join uses a special [`ExecutorService`] [5] : [`ForkJoinPool`] [6]

```java
// use a single ForkJoinPool per VM
static final ForkJoinPool pool = new ForkJoinPool();
...
ParQuicksort qs = new ParQuicksort(values, 0, values.length - 1);
pool.invoke(qs);
```
[5]: https://docs.oracle.com/javase/7/docs/api/java/util/concurrent/ExecutorService.html
[6]: https://docs.oracle.com/javase/7/docs/api/java/util/concurrent/ForkJoinPool.html

---

## java.nio.file

- Package [`java.nio.file`] [7]

Class                | Usage
-----                | -----
[`Files`] [8]        | Provides a set of static methods that operate on files, directories, or other types of files
[`Paths`] [9]        | Provides a set of static methods that return a Path by converting a path string or URI
[`FileSystem`] [10]  | Provides an interface to the file system and a factory for objects accessing files and other filesystem objects
[`FileSystems`] [11] | Provides factory methods for file systems. This class defines the `getDefault()` method to access the default file system and factory methods to construct other types of file systems.

[7]: https://docs.oracle.com/javase/7/docs/api/java/nio/file/package-summary.html
[8]: https://docs.oracle.com/javase/7/docs/api/java/nio/file/Files.html
[9]: https://docs.oracle.com/javase/7/docs/api/java/nio/file/Paths.html
[10]: https://docs.oracle.com/javase/7/docs/api/java/nio/file/FileSystem.html
[11]: https://docs.oracle.com/javase/7/docs/api/java/nio/file/FileSystems.html
---

# References

- Java 7 new features
    - [O'Reilly, a look at Java7 new features](http://radar.oreilly.com/2011/09/java7-features.html)
    - [Oracle, Java SE Features and Enhancements](http://www.oracle.com/technetwork/java/javase/jdk7-relnotes-418459.html)
    - [10 JDK 7 Features to revisit before you welcome Java8](http://javarevisited.blogspot.com/2014/04/10-jdk-7-features-to-revisit-before-you.html)
- Concurrency
    - [When to use ForkJoinPool vs. ExecutorService](http://www.javaworld.com/article/2078440/enterprise-java/java-tip-when-to-use-forkjoinpool-vs-executorservice.html)
    - [A java Fork/Join Calamity](http://coopsoft.com/ar/CalamityArticle.html)
    - [Java Fork and Join using ForkJoinPool](http://tutorials.jenkov.com/java-util-concurrent/java-fork-and-join-forkjoinpool.html)
    - [Doug Lea's Workstation](http://g.oswego.edu)

---

# Attributions

- Duke's image is from Wikimedia ["Duke: Java Mascot"](https://commons.wikimedia.org/wiki/File:Duke_java_maskot.png).
- This presentation is using the excellent [remark](https://remarkjs.com) framework.


