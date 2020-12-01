#include <CL/cl.h>
#include "err_code.h"

#include <iostream>
#include <fstream>
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>


//using namespace std;

cl_int buildFromSource(cl_context* context, cl_device_id* dev,
                        cl_program* prog, const char* source);

cl_int buildFromBinary(cl_context* context, cl_device_id* dev,
                         cl_program* prog, const char* source);

int ocl_get_device(cl_platform_id* plat, cl_device_id* dev);
