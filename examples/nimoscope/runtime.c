// gcc -shared -fPIC -o libruntime.so runtime.c
#include <stdio.h>
double print(double x) { printf("%f\n", x); return 0.0 / 0.0; }