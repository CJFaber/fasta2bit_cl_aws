.PHONY: help

help::
	$(ECHO) "Makefile Usage:"
	$(ECHO) "  make all TARGET=<sw_emu/hw_emu/hw> DEVICE=<FPGA platform> HOST_ARCH=<aarch32/aarch64/x86> SYSROOT=<sysroot_path>"
	$(ECHO) "      Command to generate the design for specified Target and Shell."
	$(ECHO) "      By default, HOST_ARCH=x86. HOST_ARCH and SYSROOT is required for SoC shells"
	$(ECHO) ""
	$(ECHO) "  make clean "
	$(ECHO) "      Command to remove the generated non-hardware files."
	$(ECHO) ""
	$(ECHO) "  make cleanall"
	$(ECHO) "      Command to remove all the generated files."
	$(ECHO) ""
	$(ECHO) "  make sd_card TARGET=<sw_emu/hw_emu/hw> DEVICE=<FPGA platform> HOST_ARCH=<aarch32/aarch64/x86> SYSROOT=<sysroot_path>"
	$(ECHO) "      Command to prepare sd_card files."
	$(ECHO) "      By default, HOST_ARCH=x86. HOST_ARCH and SYSROOT is required for SoC shells"
	$(ECHO) ""
	$(ECHO) "  make check TARGET=<sw_emu/hw_emu/hw> DEVICE=<FPGA platform> HOST_ARCH=<aarch32/aarch64/x86> SYSROOT=<sysroot_path>"
	$(ECHO) "      Command to run application in emulation."
	$(ECHO) "      By default, HOST_ARCH=x86. HOST_ARCH and SYSROOT is required for SoC shells"
	$(ECHO) ""
	$(ECHO) "  make build TARGET=<sw_emu/hw_emu/hw> DEVICE=<FPGA platform> HOST_ARCH=<aarch32/aarch64/x86> SYSROOT=<sysroot_path>"
	$(ECHO) "      Command to build xclbin application."
	$(ECHO) "      By default, HOST_ARCH=x86. HOST_ARCH and SYSROOT is required for SoC shells"
	$(ECHO) ""

##########################################
#Change these depending on your app
DEVICE_DIR := ./device
HOST_DIR := ./host
INC_DIR := -I$(HOST_DIR)/inc
SRC_DIR := $(HOST_DIR)/src
LOG_DIR := $(DEVICE_DIR)/logs
HOST_HDRS += $(foreach D,$(INC_DIR),$(wildcard $D/*.h))
HOST_HDRS +=  $(foreach D,$(INC_DIR),$(wildcard $D/*.hpp))
HOST_SRCS += $(foreach D,$(SRC_DIR),$(wildcard $D/*.c))
HOST_SRCS += $(foreach D,$(SRC_DIR),$(wildcard $D/*.cpp))

EXECUTABLE := FastaTo2Bit.out
DEV_COMP_TRGT := cl 				#HLS target: cl / cpp / etc
#DEVICE_SRC = FastaTo2Bit-loop
#DEVICE_SRC = FastaTo2Bit-dataflow
DEVICE_SRC = FastaTo2Bit-dataflow
#KERNEL_NAME := FastaTo2Bit_loop
KERNEL_NAME := FastaTo2Bit_dataflow
###########################################

#$(info $(HOST_SRCS))

###########################################
# Specific to Stream cpp kernels
#DEVICE = xilinx_u200_qdma_201910_1
###########################################



# Points to top directory of Git repository
COMMON_REPO =/home/centos/src/project_data/aws-fpga/Vitis/examples/xilinx
PWD = $(shell readlink -f .)
ABS_COMMON_REPO = $(shell readlink -f $(COMMON_REPO))
$(info 	$(ABS_COMMON_REPO))
TARGET := hw
#CHECK FOR x64 at some point
HOST_ARCH := x86
SYSROOT := 

include ./utils.mk

XSA := $(call device2xsa, $(DEVICE))

VPP := v++
#VITIS_INC_DIR := /opt/Xilinx/Vitis/2019.2/include/



#Include Libraries
include $(ABS_COMMON_REPO)/common/includes/opencl/opencl.mk
include $(ABS_COMMON_REPO)/common/includes/xcl2/xcl2.mk

CXXFLAGS += $(xcl2_CXXFLAGS)
LDFLAGS += $(xcl2_LDFLAGS)
HOST_SRCS += $(xcl2_SRCS)
CXXFLAGS += $(opencl_CXXFLAGS) -Wall -O1 -g -std=c++11 -DTIMING -DACC_TIME -DPRINTOUT -DDEBUG -DDISABLE_SERV
LDFLAGS += $(opencl_LDFLAGS)


# Host compiler global settings
CXXFLAGS += -fmessage-length=0
#####################################################################################################Temp

##LD flags here
LDFLAGS += -L/home/centos/BoostLib/1_74/lib/ -I/home/centos/BoostLib/1_74/include/ 
LDFLAGS += -lrt -lstdc++ -Lboost_system -Lboost_thread 
LDFLAGS += -lpthread -lssl -lcrypto -lz -ldl -lzstd -fopenmp

ifneq ($(HOST_ARCH), x86)
	LDFLAGS += --sysroot=$(SYSROOT)
endif

# Kernel compiler global settings
CLFLAGS += -t $(TARGET) --platform $(DEVICE) --save-temps --config link.cfg
ifneq ($(TARGET), hw)
	CLFLAGS += -g
	CLFLAGS += --profile_kernel data:all:all:all:all
endif


##TESTING
#BUILD_DIR := $(DEVICE_DIR)/$(DEVICE_SRC)_build/build_dir.$(TARGET).$(XSA)
#TEMP_DIR := $(DEVICE_DIR)/$(DEVICE_SRC)_temp_dir/_x.$(TARGET).$(XSA)
TEMP_DIR := $(DEVICE_DIR)/$(DEVICE_SRC)temp_dir/_x.$(TARGET).$(XSA)
BUILD_DIR := $(DEVICE_DIR)/$(DEVICE_SRC)_build/build_dir.$(TARGET).$(XSA)

CMD_ARGS = $(BUILD_DIR)/$(DEVICE_SRC).xclbin
EMCONFIG_DIR = $(TEMP_DIR)
EMU_DIR = $(SDCARD)/data/emulation

BINARY_CONTAINERS += $(BUILD_DIR)/$(DEVICE_SRC).xclbin
BINARY_CONTAINER_OBJS += $(TEMP_DIR)/$(KERNEL_NAME).xo

CP = cp -rf

.PHONY: all clean cleanall docs emconfig
all: check-devices $(EXECUTABLE) $(BINARY_CONTAINERS)

.PHONY: exe
exe: $(EXECUTABLE)

.PHONY: build
build: $(BINARY_CONTAINERS)

# Building kernel
$(TEMP_DIR)/$(KERNEL_NAME).xo: $(DEVICE_DIR)/$(DEVICE_SRC).$(DEV_COMP_TRGT)
	mkdir -p $(TEMP_DIR)
	mkdir -p $(LOG_DIR)
	$(VPP) $(VPPFLAGS) $(CLFLAGS) --temp_dir $(TEMP_DIR) --log_dir $(LOG_DIR) -c -k $(KERNEL_NAME) -I'$(<D)' -o'$@' '$<'  
	#$(VPP) $(CLFLAGS) --temp_dir $(TEMP_DIR) -c -k $(KERNEL_NAME) -I'$(<D)' -o'$@' '$<'
$(BUILD_DIR)/$(DEVICE_SRC).xclbin: $(BINARY_CONTAINER_OBJS)
	mkdir -p $(BUILD_DIR)
	$(VPP) $(CLFLAGS) --temp_dir $(BUILD_DIR) --log_dir $(LOG_DIR) -l $(LDCLFLAGS) -o'$@' $(+)

# Building Host
$(EXECUTABLE): check-xrt $(HOST_SRCS) $(HOST_HDRS)
	$(CXX) $(CXXFLAGS) $(HOST_SRCS) $(HOST_HDRS) -o '$@' $(INC_DIR) $(LDFLAGS)

emconfig:$(EMCONFIG_DIR)/emconfig.json
$(EMCONFIG_DIR)/emconfig.json:
	emconfigutil --platform $(DEVICE) --od $(EMCONFIG_DIR)

check: all

#ifeq ($(TARGET),$(filter $(TARGET),sw_emu hw_emu))
#ifeq ($(HOST_ARCH), x86)
#	$(CP) $(EMCONFIG_DIR)/emconfig.json .
	#XCL_EMULATION_MODE=$(TARGET) ./$(EXECUTABLE) ./rand128.fasta $(BUILD_DIR)/$(DEVICE_SRC).xclbin
#endif
#else
#ifeq ($(HOST_ARCH), x86)
#	./$(EXECUTABLE) $(BUILD_DIR)/$(DEVICE_SRC).xclbin
#endif
#endif
#ifeq ($(HOST_ARCH), x86)
#	perf_analyze profile -i profile_summary.csv -f html
#endif



# Cleaning stuff
clean:
	-$(RMDIR) $(EXECUTABLE) $(XCLBIN)/{*sw_emu*,*hw_emu*} 
	-$(RMDIR) profile_* TempConfig system_estimate.xtxt *.rpt *.csv 
	-$(RMDIR) src/*.ll *v++* .Xil emconfig.json dltmp* xmltmp* *.log *.jou *.wcfg *.wdb

cleanall: clean
	-$(RMDIR) build_dir* sd_card*
	-$(RMDIR) _x.* *xclbin.run_summary qemu-memory-_* emulation/ _vimage/ pl* start_simulation.sh *.xclbin
	-$(RMDIR) $(DEVICE_DIR)/$(DEVICE_SRC)_build/ $(DEVICE_DIR)/$(DEVICE_SRC)_temp_dir/ $(LOG_DIR)

