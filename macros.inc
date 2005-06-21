#ifndef USUNIT_MACROS // just a failsafe
#define USUNIT_MACROS

#define CHECK(expr,msg) check(expr, msg$chr(3)$__FILE__$":"$string(__LINE__))
#define CHECK(expr) CHECK(expr, #expr)

#endif