package main

func main() {
	var d = initData()

	argAnalyze(&d)

	switch (d.mode) {
		case cmMain:    ex(&d)
		case cmHelp:    help()
		case cmVersion: version()
	}
}