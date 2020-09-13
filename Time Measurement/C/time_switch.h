#include <time.h>

#ifndef TIMESWITCH
#define TIMESWITCH

#define SEC(T) (double)T.tv_sec
#if defined(CLOCK_MONOTONIC_RAW)
	#define TIMETYPE struct timespec
	#define GETTIME(T) clock_gettime(CLOCK_MONOTONIC_RAW,&T)
	#define NSEC(T) (double)T.tv_nsec
#elif defined(CLOCK_MONOTONIC)
	#define TIMETYPE struct timespec
	#define GETTIME(PT) clock_gettime(CLOCK_MONOTONIC,&PT)
	#define NSEC(T) (double)T.tv_nsec
#elif defined(TIME_UTC)
	#define TIMETYPE struct timespec
	#define GETTIME(PT) timespec_get(&PT,TIME_UTC)
	#define NSEC(T) (double)T.tv_nsec
#else
	#include <sys/time.h>
	#define TIMETYPE struct timeval
	#define GETTIME(PT) gettimeofday(&PT,NULL)
	#define NSEC(T) ((double)T.tv_usec)*1000
#endif

#endif