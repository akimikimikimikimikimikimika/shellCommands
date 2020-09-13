const
process=require("process"),
EOL=require("os").EOL,
e=exports;

e.CMMain   =0;
e.CMHelp   =1;
e.CMVersion=2;

e.MMNone  =0;
e.MMSerial=1;
e.MMSpawn =2;

class data {
	mode=e.CMMain;
	command=[];
	out="inherit";
	err="inherit";
	result="stderr";
	multiple=e.MMNone;
};
e.data=data;

e.error=(message)=>{
	process.stderr.write(message+EOL);
	process.exit(1);
};

e.clean=(text)=>{
	return text.replace(/\t+/mg,"").replace(/^\n/,"");
};