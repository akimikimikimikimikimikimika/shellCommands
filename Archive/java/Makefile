src=$(shell echo *.java)
archive=../main.jar

${archive}: ${src}
	@javac *.java
	@jar cfe ${archive} core *.class
	@rm -f *.class