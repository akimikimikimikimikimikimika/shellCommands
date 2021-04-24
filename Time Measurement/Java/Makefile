build:
	@javac *.java -Xlint:unchecked
	@jar cfe ../binaries/measure-java.jar measure *.class
	@rm -f *.class

clean:
	@rm -f *.class