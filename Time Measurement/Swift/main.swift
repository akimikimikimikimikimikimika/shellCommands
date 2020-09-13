switch argAnalyze() {
	case let .main(d): execute(d)
	case .help:        help()
	case .version:     version()
}