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
# Returns:
#     exit status
#############################################################
function build_frameworks {
    if [ $# -ne 1 ];then
        echo "FUNC '$FUNCNAME': Invalid amount of arguments passed"
        echo "PASSED ARGS: $*"
        exit 1
    fi

    local configuration_target_type="$1"
	
    echo "FUNC '$FUNCNAME': configuration_target_type: '$configuration_target_type'"

    # Do the build
    xcodebuild -project UnityAdsStaticLibrary.xcodeproj -configuration "$configuration_target_type"
}



echo "Generating XCODE project file"
./generate-project.rb
if [ $? -ne 0 ]; then
    echo -e "\n\nGenerating XCODE project file errored\n\n"
    exit 1
fi

rm -rf build
rm -rf ~/Library/Developer/Xcode/DerivedData/UnityAds*


if $BUILD_BOTH_TARGETS; then
    echo "Building both targets DEBUG and RELEASE"
    CONFIGURATION_TARGET_TYPE="Release"
    build_frameworks $CONFIGURATION_TARGET_TYPE

    CONFIGURATION_TARGET_TYPE="Debug"
    build_frameworks $CONFIGURATION_TARGET_TYPE
else
    echo "Building Single Target $CONFIGURATION_TARGET_TYPE"
    build_frameworks $CONFIGURATION_TARGET_TYPE
fi