#!/bin/bash

# Documentation:
# This script builds DocC for a <TARGET> and certain <PLATFORMS>.
# This script targets iOS, macOS, tvOS, watchOS, and xrOS by default.
# You can pass in a list of <PLATFORMS> if you want to customize the build.
# The documentation ends up in to .build/docs-<PLATFORM>.

# Usage:
# docc.sh <TARGET> [<PLATFORMS> default:iOS macOS tvOS watchOS xrOS]
# e.g. `bash scripts/docc.sh MyTarget iOS macOS`
# If the TARGET name differs from the archive name, use:
# docc.sh <TARGET> --archive <ARCHIVE_NAME> [<PLATFORMS>]

# Exit immediately if a command exits with a non-zero status
set -e

# Fail if any command in a pipeline fails
set -o pipefail

# Verify that all required arguments are provided
if [ $# -eq 0 ]; then
    echo "Error: This script requires at least one argument"
    echo "Usage: $0 <TARGET> [<PLATFORMS> default:iOS macOS tvOS watchOS xrOS]"
    echo "       $0 <TARGET> --archive <ARCHIVE_NAME> [<PLATFORMS>]"
    echo "For instance: $0 MyTarget iOS macOS"
    exit 1
fi

# Define argument variables
TARGET=$1
ARCHIVE_NAME=$TARGET
TARGET_LOWERCASED=$(echo "$1" | tr '[:upper:]' '[:lower:]')

# Remove TARGET from arguments list
shift

# Check if archive name is specified
if [ "$1" = "--archive" ]; then
    if [ $# -lt 2 ]; then
        echo "Error: --archive option requires an archive name"
        exit 1
    fi
    ARCHIVE_NAME=$2
    shift 2
fi

# Define platforms variable
if [ $# -eq 0 ]; then
    set -- iOS macOS tvOS watchOS xrOS
fi
PLATFORMS=$@

# Prepare the package for DocC
swift package resolve;

# A function that builds $TARGET for a specific platform
build_platform() {

    # Define a local $PLATFORM variable and set an exit code
    local PLATFORM=$1
    local EXIT_CODE=0

    # Define the build folder name, based on the $PLATFORM
    case $PLATFORM in
        "iOS")
            DEBUG_PATH="Debug-iphoneos"
            ;;
        "macOS")
            DEBUG_PATH="Debug"
            ;;
        "tvOS")
            DEBUG_PATH="Debug-appletvos"
            ;;
        "watchOS")
            DEBUG_PATH="Debug-watchos"
            ;;
        "xrOS")
            DEBUG_PATH="Debug-xros"
            ;;
        *)
            echo "Error: Unsupported platform '$PLATFORM'"
            exit 1
            ;;
    esac

    # Build $TARGET docs for the $PLATFORM
    WEBSITE_OUTPUT_PATH="${PWD}/docs/${PLATFORM}"
    echo "Building $TARGET docs for $PLATFORM..."
    if ! xcodebuild docbuild -scheme $TARGET -derivedDataPath .build/docbuild -destination "generic/platform=$PLATFORM"; then
        echo "Error: Failed to build documentation for $PLATFORM" >&2
        return 1
    fi

    # Transform docs for static hosting
    echo "Transforming docs in $WEBSITE_OUTPUT_PATH"
    mkdir -p "${WEBSITE_OUTPUT_PATH}"
    if ! $(xcrun --find docc) process-archive \
      transform-for-static-hosting .build/docbuild/Build/Products/$DEBUG_PATH/$ARCHIVE_NAME.doccarchive \
      --output-path "${WEBSITE_OUTPUT_PATH}" \
      --hosting-base-path "$TARGET"; then
        echo "Error: Failed to transform documentation for $PLATFORM" >&2
        return 1
    fi

    # Inject a root redirect script on the root page
    echo "<script>window.location.href += \"/documentation/$TARGET_LOWERCASED\"</script>" > ${WEBSITE_OUTPUT_PATH}/index.html;

    # Complete successfully
    echo "Successfully built $TARGET docs for $PLATFORM"
    return 0
}

# Start script
echo ""
echo "Building $TARGET docs for [$PLATFORMS]..."
echo ""

# Loop through all platforms and call the build function
for PLATFORM in $PLATFORMS; do
    if ! build_platform "$PLATFORM"; then
        exit 1
    fi
done

# Complete successfully
echo ""
echo "Building $TARGET docs completed successfully!"
echo ""
