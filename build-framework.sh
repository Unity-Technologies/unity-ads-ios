unset TOOLCHAINS

CONFIGURATION_TARGET_TYPE="Release"
BUILD_BOTH_TARGETS=true

USAGE="$(basename $0) is program that compiles the iOS DEBUG or RELEASE frameworks
USAGE
    ./build-framework                Build both DEBUG and RELEASE versions of the framework
    ./build-framework -c DEBUG       Builds the DEBUG version of the framework
    ./build-framework -c RELEASE     Builds the RELEASE version of the framework
"

while getopts hc: OPTIONS; do
    case $OPTIONS in
        h )
            echo "$USAGE"
            exit ;;
        c )
            echo "got options: $OPTARG"

            CONFIGURATION_TARGET_TYPE=$(echo "$OPTARG" | tr '[:upper:]' '[:lower:]')
            CONFIGURATION_TARGET_TYPE="$(tr '[:lower:]' '[:upper:]' <<< ${CONFIGURATION_TARGET_TYPE:0:1})${CONFIGURATION_TARGET_TYPE:1}"

            if [ "$CONFIGURATION_TARGET_TYPE" != "Release" ] && [ "$CONFIGURATION_TARGET_TYPE" != "Debug" ]; then
                echo "Invalid Target type defined '$CONFIGURATION_TARGET_TYPE'"
                echo "$USAGE"
                exit 1
            fi
            echo "building $CONFIGURATION_TARGET_TYPE Framework"
            BUILD_BOTH_TARGETS=false
            ;;
        * )
            echo "Invalid args passed"
            echo
            echo "$USAGE"
            exit ;;
    esac
done

    

#############################################################
# Build the Framework with xcodebuild
# Globals:
#    None
# Arguments:
#     CONFIGURATION_TARGET_TYPE
#     FRAMEWORK
#     BUILD_PATH
# Returns:
#     exit status
#############################################################
function build_frameworks {
    if [ $# -ne 3 ];then
        echo "FUNC '$FUNCNAME': Invalid amount of arguments passed"
        echo "PASSED ARGS: $*"
        exit 1
    fi
    
    local configuration_target_type="$1"
    local framework="$2"
    local build="$3"

    echo "FUNC '$FUNCNAME': configuration_target_type: '$configuration_target_type' framework: '$framework' build: '$build'"
    
    # Do the build
    xcodebuild -configuration "$configuration_target_type" ENABLE_BITCODE=NO -target "${framework}" -sdk iphoneos SYMROOT=$build VALID_ARCHS="armv7 armv7s arm64" ONLY_ACTIVE_ARCH=NO
    xcodebuild -configuration "$configuration_target_type" ENABLE_BITCODE=NO -target "${framework}" -sdk iphonesimulator SYMROOT=$build VALID_ARCHS="i386 x86_64" ONLY_ACTIVE_ARCH=NO
    xcodebuild -configuration "$configuration_target_type" ENABLE_BITCODE=YES -target "${framework}" -sdk iphonesimulator SYMROOT=$build VALID_ARCHS="i386 x86_64" ONLY_ACTIVE_ARCH=NO OTHER_CFLAGS='-fembed-bitcode'
    xcodebuild -configuration "$configuration_target_type" ENABLE_BITCODE=YES -target "${framework}" -sdk iphoneos SYMROOT=$build VALID_ARCHS="armv7 armv7s arm64" ONLY_ACTIVE_ARCH=NO OTHER_CFLAGS='-fembed-bitcode'    
}


#############################################################
# Wrap the built Framework
# Globals:
#    None
# Arguments:
#     CONFIGURATION_TARGET_TYPE
#     FRAMEWORK
#     FRAMEWORK_PATH
#     BUILD_PATH
# Returns:
#     exit status
#############################################################
function wrap_frameworks {
    if [ $# -ne 4 ];then
        echo "FUNC '$FUNCNAME': Invalid amount of arguments passed"
        echo "PASSED ARGS: $*"
        exit 1
    fi
    
    local configuration_target_type=$1
    local framework=$2
    local framework_path=$3
    local build=$4

    echo "FUNC '$FUNCNAME': configuration_target_type: '$configuration_target_type' framework: '$framework' framework_path '$framework_path' build: $build"
    
    cp -RL $build/$CONFIGURATION_TARGET_TYPE-iphoneos $build/$CONFIGURATION_TARGET_TYPE-universal
    lipo -create $build/$CONFIGURATION_TARGET_TYPE-iphoneos/$FRAMEWORK_PATH/$FRAMEWORK $build/$CONFIGURATION_TARGET_TYPE-iphonesimulator/$FRAMEWORK_PATH/$FRAMEWORK -output $build/$CONFIGURATION_TARGET_TYPE-universal/$FRAMEWORK_PATH/$FRAMEWORK
    mv $build/$CONFIGURATION_TARGET_TYPE-universal/$FRAMEWORK_PATH $build/$FRAMEWORK_PATH
    file $build/$FRAMEWORK_PATH/$FRAMEWORK
}



cd "$(dirname "$0")"

FRAMEWORK=UnityAds
BUILD=build
FRAMEWORK_PATH=$FRAMEWORK.framework

if [ -e $BUILD ]; then
	rm -Rf ${BUILD:?}
fi

echo "Generating XCODE project file"
./generate-project.rb
if [ $? -ne 0 ]; then
    echo -e "\n\nGenerating XCODE project file errored\n\n"
    exit 1    
fi


if $BUILD_BOTH_TARGETS; then
    echo "Building both targets DEBUG and RELEASE"
    CONFIGURATION_TARGET_TYPE="Release"
    build_frameworks $CONFIGURATION_TARGET_TYPE $FRAMEWORK $BUILD/$CONFIGURATION_TARGET_TYPE
    wrap_frameworks $CONFIGURATION_TARGET_TYPE $FRAMEWORK $FRAMEWORK_PATH $BUILD/$CONFIGURATION_TARGET_TYPE

    CONFIGURATION_TARGET_TYPE="Debug"
    build_frameworks $CONFIGURATION_TARGET_TYPE $FRAMEWORK $BUILD/$CONFIGURATION_TARGET_TYPE
    wrap_frameworks $CONFIGURATION_TARGET_TYPE $FRAMEWORK $FRAMEWORK_PATH $BUILD/$CONFIGURATION_TARGET_TYPE 
else
    echo "Building Single Target $CONFIGURATION_TARGET_TYPE"
    build_frameworks $CONFIGURATION_TARGET_TYPE $FRAMEWORK $BUILD/$CONFIGURATION_TARGET_TYPE
    wrap_frameworks $CONFIGURATION_TARGET_TYPE $FRAMEWORK $FRAMEWORK_PATH $BUILD/$CONFIGURATION_TARGET_TYPE
fi

