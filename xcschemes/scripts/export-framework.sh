HEADERS_ROOT=$SRCROOT/$PRODUCT_NAME
FRAMEWORK_HEADERS_DIR="$BUILT_PRODUCTS_DIR/$WRAPPER_NAME/Versions/$FRAMEWORK_VERSION/Headers"

## only header files expected at this point
PUBLIC_HEADERS=$(find $FRAMEWORK_HEADERS_DIR/. -not -type d 2> /dev/null | sed -e "s@.*/@@g")

FIND_OPTS=""
for PUBLIC_HEADER in $PUBLIC_HEADERS; do
if [ -n "$FIND_OPTS" ]; then
FIND_OPTS="$FIND_OPTS -o"
fi
FIND_OPTS="$FIND_OPTS -name '$PUBLIC_HEADER'"
done

if [ -n "$FIND_OPTS" ]; then
for ORIG_HEADER in $(eval "find $HEADERS_ROOT/. $FIND_OPTS" 2> /dev/null | sed -e "s@^$HEADERS_ROOT/./@@g"); do
PUBLIC_HEADER=$(basename $ORIG_HEADER)
RELATIVE_PATH=$(dirname $ORIG_HEADER)
if [ -e $FRAMEWORK_HEADERS_DIR/$PUBLIC_HEADER ]; then
mkdir -p "$FRAMEWORK_HEADERS_DIR/$RELATIVE_PATH"
mv "$FRAMEWORK_HEADERS_DIR/$PUBLIC_HEADER" "$FRAMEWORK_HEADERS_DIR/$RELATIVE_PATH/$PUBLIC_HEADER"
fi
done
fi


set -e

set +u
if [[ $UFW_MASTER_SCRIPT_RUNNING ]]
then
# Nothing for the slave script to do
exit 0
fi
set -u
export UFW_MASTER_SCRIPT_RUNNING=1

# Functions

## List files in the specified directory, storing to the specified array.
#
# @param $1 The path to list
# @param $2 The name of the array to fill
#
##
list_files ()
{
    filelist=$(ls "$1")
    while read line
    do
    eval "$2[\${#$2[*]}]=\"\$line\""
    done <<< "$filelist"
}

EXECUTABLE_PATH_ORIG=${EXECUTABLE_PATH}
EXECUTABLE_PATH="${WRAPPER_NAME}/${EXECUTABLE_NAME}"
UNLOCALIZED_RESOURCES_FOLDER_PATH_ORIG="${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
UNLOCALIZED_RESOURCES_FOLDER_PATH="${WRAPPER_NAME}/Resources"

# Sanity check

if [[ ! -f "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_PATH_ORIG}" ]]
then
echo "Framework target \"${TARGET_NAME}\" had no source files to build from. Make sure your source files have the correct target membership"
exit 1
fi

# Gather information

if [[ "$SDK_NAME" =~ ([A-Za-z]+) ]]
then
UFW_SDK_PLATFORM=${BASH_REMATCH[1]}
else
echo "Could not find platform name from SDK_NAME: $SDK_NAME"
exit 1
fi

if [[ "$SDK_NAME" =~ ([0-9]+.*$) ]]
then
UFW_SDK_VERSION=${BASH_REMATCH[1]}
else
echo "Could not find sdk version from SDK_NAME: $SDK_NAME"
exit 1
fi

if [[ "$UFW_SDK_PLATFORM" = "iphoneos" ]]
then
UFW_OTHER_PLATFORM=iphonesimulator
else
UFW_OTHER_PLATFORM=iphoneos
fi

if [[ "$BUILT_PRODUCTS_DIR" =~ (.*)$UFW_SDK_PLATFORM$ ]]
then
UFW_OTHER_BUILT_PRODUCTS_DIR="${BASH_REMATCH[1]}${UFW_OTHER_PLATFORM}"
else
echo "Could not find $UFW_SDK_PLATFORM in $BUILT_PRODUCTS_DIR"
exit 1
fi

# Short-circuit if all binaries are up to date.
# We already checked the other platform in the prerun script.

if [[ -f "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_PATH_ORIG}" ]] && [[ -f "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.embeddedframework/${EXECUTABLE_PATH}" ]] && [[ ! "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_PATH_ORIG}" -nt "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.embeddedframework/${EXECUTABLE_PATH}" ]]
then
exit 0
fi

vrun() {
    echo $@
    $@
}

# Make sure the other platform gets built

echo "Build other platform"

vrun xcodebuild -project "${PROJECT_FILE_PATH}" -target "${TARGET_NAME}" -configuration "${CONFIGURATION}" -sdk ${UFW_OTHER_PLATFORM}${UFW_SDK_VERSION} BUILD_DIR="${BUILD_DIR}" INSTALL_ROOT="/" CONFIGURATION_TEMP_DIR="${PROJECT_TEMP_DIR}/${CONFIGURATION}-${UFW_OTHER_PLATFORM}" $ACTION -UseNewBuildSystem=NO

# Build the fat static library binary

echo "Create universal static library"

vrun "$DT_TOOLCHAIN_DIR/usr/bin/libtool" -static "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_PATH_ORIG}" "${UFW_OTHER_BUILT_PRODUCTS_DIR}/${EXECUTABLE_PATH_ORIG}" -o "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_PATH_ORIG}.temp"

if [[ "$COPY_PHASE_STRIP" = "YES" ]]
then
vrun "$DT_TOOLCHAIN_DIR/usr/bin/strip" -S "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_PATH_ORIG}.temp"
fi

vrun mv "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_PATH_ORIG}.temp" "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_PATH_ORIG}"

cp -R ./Modules "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.framework"


# Replace other platform's framework with a copy of this one (so that both have the same universal binary)

echo "Copy from $UFW_SDK_PLATFORM to $UFW_OTHER_PLATFORM"

echo rm -rf "${BUILD_DIR}/${CONFIGURATION}-${UFW_OTHER_PLATFORM}"
rm -rf "${BUILD_DIR}/${CONFIGURATION}-${UFW_OTHER_PLATFORM}"
echo cp -a "${BUILD_DIR}/${CONFIGURATION}-${UFW_SDK_PLATFORM}" "${BUILD_DIR}/${CONFIGURATION}-${UFW_OTHER_PLATFORM}"
cp -a "${BUILD_DIR}/${CONFIGURATION}-${UFW_SDK_PLATFORM}" "${BUILD_DIR}/${CONFIGURATION}-${UFW_OTHER_PLATFORM}"
