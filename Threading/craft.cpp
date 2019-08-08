#include <regex>
#include "structure.hpp"

void iter(VI*,O&);
void insert(VS,O&);

class Regex {
	public:
		const regex brace = regex("\\{{1}\\}{1}");
		regex icon(int icon) {
			if (iconList.size()<icon) for (int n=iconList.size();n<icon;n++) iconList.push_back(regex("\\{{1}"+std::to_string(n+1)+"\\}{1}"));
			return iconList[icon-1];
		}
		S one2two(S unsafe) {
			S temp = regex_replace(unsafe,slash1,"\\\\");
			temp = regex_replace(temp,openBrace1,"\\{");
			temp = regex_replace(temp,closeBrace1,"\\}");
			return temp;
		}
		S two2one(S unsafe) {
			S temp = regex_replace(unsafe,slash2,"\\");
			temp = regex_replace(temp,openBrace2,"{");
			temp = regex_replace(temp,closeBrace2,"}");
			return temp;
		}
	private:
		vector<regex> iconList;
		const regex openBrace1 = regex("\\{");
		const regex closeBrace1 = regex("\\}");
		const regex openBrace2 = regex("\\\\\\{");
		const regex closeBrace2 = regex("\\\\\\}");
		const regex slash1 = regex("\\\\");
		const regex slash2 = regex("\\\\\\\\");
};

static Regex re;

void craft(O& o) {
	iter(new VI(),o);
}

void iter(VI* cur,O& o) {
	int s=cur->size();
	if (s<o.list.size()) for (int n=0;n<o.list[s]->size();n++) {
		cur->push_back(n);
		iter(cur,o);
		cur->pop_back();
	}
	else if (s==o.list.size()) {
		VS v;
		for (int m=0;m<(cur->size());m++) v.push_back(re.one2two((*o.list[m])[(*cur)[m]]));
		insert(v,o);
	}
}

void insert(VS c,O& o) {
	auto pro=*(new VS());
	for (int n=0;n<o.format.size();n++) {
		S p=o.format[n];
		int iconIndex=1;
		int realIndex=0;
		while (regex_search(p,re.icon(iconIndex))) {
			if (realIndex>=c.size()) break;
			p=regex_replace(p,re.icon(iconIndex),c[realIndex]);
			iconIndex++;
			realIndex++;
		}
		while (regex_search(p,re.brace)) {
			if (realIndex>=c.size()) break;
			p=regex_replace(p,re.brace,c[realIndex],regex_constants::format_first_only);
			realIndex++;
		}
		p=re.two2one(p);
		pro.push_back(p);
	}
	o.process.push_back(move(pro));
}