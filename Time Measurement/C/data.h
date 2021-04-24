#include <stdlib.h> // for size_t

enum CommandMode {
	CMMain,
	CMHelp,
	CMVersion
};
typedef enum CommandMode CM;

enum COType {
	COInherit,
	CODiscard,
	COFile
};
struct ChildOutput {
	enum COType type;
	const char* file;
};
typedef struct ChildOutput CO;

enum ROType {
	ROStdout,
	ROStderr,
	ROFile
};
struct ResultOutput {
	enum ROType type;
	const char* file;
};
typedef struct ResultOutput RO;

enum MultipleMode {
	MMSerial,
	MMSpawn,
	MMThread,
	MMNone
};
typedef enum MultipleMode MM;

struct data {
	CM mode;
	CO out;
	CO err;
	RO result;
	MM multiple;
	char** commands;
	size_t count;
};
typedef struct data D;
D initData();

CO s2co(const char*);
RO s2ro(const char*);