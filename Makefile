OPT_LEVEL = -O3
OPT_FLAGS = $(OPT_LEVEL) -fno-vectorize -fno-slp-vectorize -Wno-override-module

export PATH := /opt/anydsl/artic/build/bin:/opt/llvm/bin:$(PATH)

RUNTIME_PATH = /opt/anydsl/runtime/build/lib
RUNTIME_LIB = $(RUNTIME_PATH)/libruntime.so
LD_FLAGS = '-Wl,-rpath,$(RUNTIME_PATH)'

cpu vec: *.impala
	artic utils.impala intrinsics_thorin.impala intrinsics_$@.impala mapping.impala gaussian.impala -o gaussian --emit-llvm $(OPT_LEVEL)
	clang++ -std=c++11 -march=native $(OPT_FLAGS) -c -o gaussian.o gaussian.ll
	clang++ -std=c++11 -march=native -fPIE gaussian.o -o gaussian_$@ $(RUNTIME_LIB) $(LD_FLAGS)
	ANYDSL_PROFILE=FULL ./gaussian_$@

amdgpu opencl cuda nvvm: *.impala
	artic utils.impala intrinsics_thorin.impala intrinsics_$@.impala mapping_gpu.impala gaussian.impala -o gaussian --emit-llvm $(OPT_LEVEL)
	clang++ -std=c++11 -march=native $(OPT_FLAGS) -c -o gaussian.o gaussian.ll
	clang++ -std=c++11 -march=native -fPIE gaussian.o -o gaussian_$@ $(RUNTIME_LIB) $(LD_FLAGS)
	ANYDSL_PROFILE=FULL ./gaussian_$@

help:
	@echo "make targets: cpu vec amdgpu opencl cuda nvvm"

clean:
	rm -f gaussian_* *.ll *.o *.cl *.cu *.nvvm *.amdgpu
	rm -rf cache
