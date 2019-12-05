set -e

bundle exec fastlane hybrid_test

HYBRID_TEST_LOG=~/Library/Logs/scan/UnityAdsHybridTests-UnityAdsHybridTests.log

PASSING=$(grep -o -m 1 "[0-9]\+ passing \(.*\)" $HYBRID_TEST_LOG) || true
PENDING=$(grep -o -m 1 "[0-9]\+ pending" $HYBRID_TEST_LOG) || true
FAILING=$(grep -o -m 1 "[0-9]\+ failing" $HYBRID_TEST_LOG) || true

printf "${PASSING}\n${PENDING}\n${FAILING}\n"

if grep -q "[0-9]\+ failing" <<< $FAILING; then
    printf "Hybrid Tests Failed!\n${FAILING}\n"
    exit 1;
else
    echo "Finished Hybrid Testing Successfully"
    exit 0;
fi
