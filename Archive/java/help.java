public class help {

    public static void main(String arg) {
        if (util.eq(arg,"","general","help")) genericHelp();
        else if (util.eq(arg,"create","compress")) create.help();
        else if (util.eq(arg,"expand","extract","decompress")) expand.help();
        else if (util.eq(arg,"paths","list")) paths.help();
        else util.error("指定したヘルプテキストはありません: "+arg);
    }

    public static void genericHelp() {
        util.helpText(
            "",
            "使い方:",
            "arc [command] [options]...",
            "",
            "アーカイブを取り扱います",
            "それぞれのコマンドの使い方は arc help [command] を参照",
            "",
            "arc create [archive path] [options] [input file paths]...",
            "arc compress [input file paths] [options]",
            " アーカイブを生成します",
            "",
            "arc expand [archive path] [options]",
            "arc extract [archive path] [options]",
            "arc decompress [archive path] [options]",
            " アーカイブを展開します",
            "",
            "arc paths [archive path] [options]",
            "arc list [archive path] [options]",
            " アーカイブに含まれるファイルの一覧を表示します",
            ""
        );
    }

}