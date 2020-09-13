using CM = lib.CM;

public class Measure {

	public static void Main (string[] args) {
		var d=new lib.Data();

		analyze.argAnalyze(ref d,args);

		switch (d.mode) {
			case CM.main:    execute.exec(ref d); break;
			case CM.help:    docs.help();         break;
			case CM.version: docs.version();      break;
		}
	}

}