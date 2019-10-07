set -e -o xtrace

mkdir build || true
touch build/analyze-output.txt
bundle exec fastlane analyze 2>&1 | tee build/analyze-output.txt

ANALYSIS=$(awk '/Analyzing/{y=1}y' build/analyze-output.txt)
if grep -q "⚠️" <<< $ANALYSIS; then
    echo "Please fix the warnings found during static analysis!"
    exit 1;
fi
