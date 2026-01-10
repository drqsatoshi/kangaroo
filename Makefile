#---------------------------------------------------------------------
# Makefile for BSGS
#
# Author : Jean-Luc PONS

.DEFAULT_GOAL := all

ifdef gpu

SRC = SECPK1/IntGroup.cpp main.cpp SECPK1/Random.cpp \
      Timer.cpp SECPK1/Int.cpp SECPK1/IntMod.cpp \
      SECPK1/Point.cpp SECPK1/SECP256K1.cpp \
      GPU/GPUEngine.o Kangaroo.cpp HashTable.cpp \
      Backup.cpp Thread.cpp Check.cpp Network.cpp Merge.cpp PartMerge.cpp

OBJDIR = obj

OBJET = $(addprefix $(OBJDIR)/, \
      SECPK1/IntGroup.o main.o SECPK1/Random.o \
      Timer.o SECPK1/Int.o SECPK1/IntMod.o \
      SECPK1/Point.o SECPK1/SECP256K1.o \
      GPU/GPUEngine.o Kangaroo.o HashTable.o Thread.o \
      Backup.o Check.o Network.o Merge.o PartMerge.o)

else

SRC = SECPK1/IntGroup.cpp main.cpp SECPK1/Random.cpp \
      Timer.cpp SECPK1/Int.cpp SECPK1/IntMod.cpp \
      SECPK1/Point.cpp SECPK1/SECP256K1.cpp \
      Kangaroo.cpp HashTable.cpp Thread.cpp Check.cpp \
      Backup.cpp Network.cpp Merge.cpp PartMerge.cpp

OBJDIR = obj

OBJET = $(addprefix $(OBJDIR)/, \
      SECPK1/IntGroup.o main.o SECPK1/Random.o \
      Timer.o SECPK1/Int.o SECPK1/IntMod.o \
      SECPK1/Point.o SECPK1/SECP256K1.o \
      Kangaroo.o HashTable.o Thread.o Check.o Backup.o \
      Network.o Merge.o PartMerge.o)

endif

CXX        ?= g++

# CUDA configuration
#
# - On Ubuntu (e.g. via `apt install nvidia-cuda-toolkit`), `nvcc` is typically
#   installed in /usr/bin and headers in /usr/lib/cuda/include.
# - On NVIDIA's installer/toolkit, CUDA is often under /usr/local/cuda.
#
# Override as needed:
#   make gpu=1 CUDA=/usr/local/cuda NVCC=/usr/local/cuda/bin/nvcc CXXCUDA=/usr/bin/g++ ccap=80
CUDA       ?= /usr/lib/cuda

# Auto-fallback for environments where CUDA is under /usr/local/cuda (common in
# NVIDIA CUDA Docker images and NVIDIA's installer).
ifeq ($(wildcard $(CUDA)/include/cuda.h),)
      CUDA := /usr/local/cuda
endif

CUDA_INC   ?= $(CUDA)/include
CXXCUDA    ?= $(CXX)
NVCC       ?= nvcc

ifdef gpu

ifdef debug
CXXFLAGS   = -DWITHGPU -m64  -mssse3 -Wno-unused-result -Wno-write-strings -g -I. -I$(CUDA_INC)
else
CXXFLAGS   = -DWITHGPU -m64 -mssse3 -Wno-unused-result -Wno-write-strings -O2 -I. -I$(CUDA_INC)
endif
# libcudart is in standard lib paths on Ubuntu when installed via apt, but in
# NVIDIA CUDA Docker images it's typically under /usr/local/cuda/... which is
# not a default link search path.
LFLAGS     = -lpthread -L$(CUDA)/lib64 -L$(CUDA)/targets/x86_64-linux/lib -lcudart

else

ifdef debug
CXXFLAGS   = -m64 -mssse3 -Wno-unused-result -Wno-write-strings -g -I.
else
CXXFLAGS   =  -m64 -mssse3 -Wno-unused-result -Wno-write-strings -O2 -I.
endif
LFLAGS     = -lpthread

endif

#--------------------------------------------------------------------

NVCC_COMMON = -maxrregcount=0 --ptxas-options=-v --compile --compiler-options -fPIC -ccbin $(CXXCUDA) -m64 -I$(CUDA_INC) -gencode=arch=compute_$(ccap),code=sm_$(ccap)

ifdef gpu
ifdef debug
$(OBJDIR)/GPU/GPUEngine.o: GPU/GPUEngine.cu
	$(NVCC) -G -g $(NVCC_COMMON) -o $@ -c $<
else
$(OBJDIR)/GPU/GPUEngine.o: GPU/GPUEngine.cu
	$(NVCC) -O2 $(NVCC_COMMON) -o $@ -c $<
endif
endif

$(OBJDIR)/%.o : %.cpp
	$(CXX) $(CXXFLAGS) -o $@ -c $<

all: bsgs

bsgs: $(OBJET)
	@echo Making Kangaroo...
	$(CXX) $(OBJET) $(LFLAGS) -o kangaroo

$(OBJET): | $(OBJDIR) $(OBJDIR)/SECPK1 $(OBJDIR)/GPU

$(OBJDIR):
	mkdir -p $(OBJDIR)

$(OBJDIR)/GPU: $(OBJDIR)
	cd $(OBJDIR) && mkdir -p GPU

$(OBJDIR)/SECPK1: $(OBJDIR)
	cd $(OBJDIR) &&	mkdir -p SECPK1

clean:
	@echo Cleaning...
	@rm -f obj/*.o
	@rm -f obj/GPU/*.o
	@rm -f obj/SECPK1/*.o

