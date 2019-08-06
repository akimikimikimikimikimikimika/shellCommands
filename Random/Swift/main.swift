var c = Customize()

if argAnalyze(&c) {
	generator(&c)
	execute(c)
}