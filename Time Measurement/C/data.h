#include <stdbool.h>

enum COType {
	COInherit,
	CODiscard,
	COFile
};
struct ChildOutput {
	enum COType type;
	const char* file;
};

enum ROType {
	ROStdout,
	ROStderr,
	ROFile
};
struct ResultOutput {
	enum ROType type;
	const char* file;
};

struct data {
	struct ChildOutput out;
	struct ChildOutput err;
	struct ResultOutput result;
	bool multiple;
	int count;
};
struct data initData();

struct ChildOutput s2co(const char*);
struct ResultOutput s2ro(const char*);