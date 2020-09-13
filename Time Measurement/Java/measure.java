public class measure {

	public static void main(String[] args) {
		lib.Data d=new lib.Data();

		analyze.argAnalyze(d,args);

		switch (d.mode) {
			case main:    execute.main(d); break;
			case help:    docs.help();    break;
			case version: docs.version(); break;
		}
	}

}