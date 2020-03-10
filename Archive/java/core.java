public class core {
	public static void main(String[] a) {
		util.registerArgs(a);
		if (a.length==1) {
			if (util.eq(a[0],"help","-help","--help")) help.main("");
			else util.error("引数が不足しています");
		}
		else if (a.length==0) util.error("引数が不足しています");
		else if (util.eq(a[0],"create","compress")) create.main(a[0]);
		else if (util.eq(a[0],"expand","extract","decompress")) expand.main();
		else if (util.eq(a[0],"paths","list")) paths.main();
		else if (util.eq(a[0],"help")) help.main(a[1]);
		else util.error("コマンドが無効です: "+a[0]);
		if (util.verbose>1) util.println("正常に終了しました");
	}
}