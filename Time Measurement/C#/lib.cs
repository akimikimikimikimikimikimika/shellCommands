using System;
using System.Text.RegularExpressions;

public class lib {

	public enum CM { main,help,version };
	public enum MM {
		none,
		serial,
		spawn,
		thread
	};

	public class Data {
		public CM mode = CM.main;
		public string[] command = new string[0];
		public string stdout = "inherit";
		public string stderr = "inherit";
		public string result = "stderr";
		public MM multiple = MM.none;
	}

	public static object error(string text) {
		Console.Error.WriteLine(text);
		Environment.Exit(1);
		return null;
	}

	public static string clean(string text) {
		var t=text;
		t=new Regex(@"^\n").Replace(t,"");
		t=new Regex(@"\n$").Replace(t,"");
		t=new Regex(@"(?m)^\t+").Replace(t,"");
		return t;
	}

}