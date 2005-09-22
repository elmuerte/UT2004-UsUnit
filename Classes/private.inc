#if !(defined(UE2) || defined(UE25))
	#pragma ucpp error Neither UE2 or UE25 are defined
#endif

#ifdef UE25
	// has the UT2003\UT2004 style webadmin
	#define HAS_WEBADMIN
	// has the PlayInfo class
	#define HAS_PLAYINFO
	// the improved\less buggy UE25 playinfo
	#define HAS_PLAYINFO_UE25
#endif
