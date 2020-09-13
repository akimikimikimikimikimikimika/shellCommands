public class lib {

	public static enum CM { main,help,version }
	public static enum MM {
		none,
		serial,
		spawn,
		thread
	}

	public static class Data {
		public CM mode = CM.main;
		public String[] command = {};
		public String out = "inherit";
		public String err = "inherit";
		public String result = "stderr";
		public MM multiple = MM.none;
	}

	public static String lines(String ...l) {
		return String.join(System.lineSeparator(),l);
	}

	public static void error(String text) {
		System.err.println(text);
		System.exit(1);
	}

}