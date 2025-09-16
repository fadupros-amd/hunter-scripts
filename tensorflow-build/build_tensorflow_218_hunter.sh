#!/bin/bash


########################
#	Hunter - Build  Tensorflow v218
#	Validated with rocm 6.2.2 + cray-python/3.11.7
#	Adjust all Input Variables


#	Sept 1st : Some minor modification to be done : portability / error-checking
#	
#####################

#	Input Variables
export BUILD_DIR="/localscratch/89880.hunter-pbs01/tensorflow-build"
export PROXY_HOST="127.0.0.1"
export PROXY_PORT="12345"



#### CLEAN
rm -rf  bazel bazelisk tensorflow-upstream patchelf 




####	Setup
export PROXY="http://${PROXY_HOST}:${PROXY_PORT}"
module load cray-python/3.11.7

export ALL_PROXY="$PROXY"
export HTTP_PROXY="$PROXY"
export HTTPS_PROXY="$PROXY"
export http_proxy="$PROXY"
export https_proxy="$PROXY"

git config --global --unset-all http.proxy
git config --global --unset-all https.proxy
git config --global  http.proxy "$PROXY"
git config --global  https.proxy "$PROXY"

export DIR_CACHE=${BUILD_DIR}/tensorflow-upstream
export PATH=$PATH:${DIR_CACHE}:${DIR_CACHE}/tools/hostbin




#### Dependencies
python  -m pip install /sw/general/x86_64/development/python/share/PySocks-1.7.1-py3-none-any.whl
python  -m pip install patchelf





###### git clone
git clone https://github.com/ROCm/tensorflow-upstream
cd tensorflow-upstream
git checkout r2.18-rocm-enhanced-hipblaslt-and-fp8-fixes



####### Bazel
cat .bazelversion | head -n 1
curl -x "$PROXY" -Lo bazelisk https://github.com/bazelbuild/bazelisk/releases/latest/download/bazelisk-$(uname -s | tr '[:upper:]' '[:lower:]')-amd64
chmod +x bazelisk 
mv bazelisk bazel
export USE_BAZEL_VERSION=`cat .bazelversion | head -n 1`
bazel --version



#####	patchelf in the WORKDIR
mkdir -p tools/hostbin
cp ~/.local/bin/patchelf tools/hostbin

##### patch tensorflow to support non-standard patchelf location
PATCHELF_ABS="${DIR_CACHE}/tools/hostbin/patchelf"
sed -i "s#\"patchelf\"#\"$PATCHELF_ABS\"#g" tensorflow/tools/pip_package/build_pip_package.py



####  Configure
yes "" | TF_NEED_CLANG=1 CLANG_COMPILER_PATH=${ROCM_PATH}/llvm/bin/clang ROCM_PATH=$ROCM_PATH TF_NEED_ROCM=1 PYTHON_BIN_PATH=${PYTHON_PATH}/bin/python  ./configure


####  Build
bazel  --output_base=${DIR_CACHE}/repo_workdir_bazel_download build  --repository_cache=${DIR_CACHE}/fetched --repo_env=${PROXY} --action_env=http_proxy --action_env=https_proxy    --action_env=PATH=${DIR_CACHE}/tools/hostbin:$PATH  --config=opt --config=rocm   --repo_env=WHEEL_NAME=tensorflow_rocm --action_env=project_name=tensorflow_rocm/ //tensorflow/tools/pip_package:wheel  --verbose_failures --repo_env=CC=${ROCM_PATH}/llvm/bin/clang --repo_env=BAZEL_COMPILER=${ROCM_PATH}/llvm/bin/clang --repo_env=CLANG_COMPILER_PATH=${ROCM_PATH}/llvm/bin/clang 
