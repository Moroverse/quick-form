SCHEME="QuickForm"
DOCC_BUNDLE_PATH="./Sources/Documentation.docc"

# Paths used in the script.
DERIVED_DATA_DIR=".deriveddata"
BUILD_DIR="${PWD}/.build"
SYMBOL_GRAPHS_DIR="${BUILD_DIR}/symbol-graphs"
SYMBOL_GRAPHS_DIR_IOS="${SYMBOL_GRAPHS_DIR}/ios"
SYMBOL_GRAPHS_DIR_MACOS="${SYMBOL_GRAPHS_DIR}/macos"
DOCCARCHIVE_PATH="${PWD}/${SCHEME}.doccarchive"
WEBSITE_OUTPUT_PATH="${PWD}/.docs"

build_for_platform() {
  local LOC_SYMBOL_GRAPHS_DIR=$1
  local LOC_DERIVED_DATA_DIR=$2
  local LOC_PLATFORM=$3

  echo "SYMBOL_GRAPHS_DIR: ${LOC_SYMBOL_GRAPHS_DIR}"
  echo "DERIVED_DATA_DIR: ${LOC_DERIVED_DATA_DIR}"
  echo "PLATFORM: ${LOC_PLATFORM}"

  mkdir -p "${LOC_SYMBOL_GRAPHS_DIR}"
  xcodebuild build \
    -scheme "${SCHEME}" \
    -destination "${LOC_PLATFORM}" \
    -derivedDataPath "${LOC_DERIVED_DATA_DIR}" \
    DOCC_EXTRACT_EXTENSION_SYMBOLS=YES \
    OTHER_SWIFT_FLAGS="-Xfrontend -emit-symbol-graph -Xfrontend -emit-symbol-graph-dir -Xfrontend ${LOC_SYMBOL_GRAPHS_DIR} -Xfrontend -emit-extension-block-symbols" | xcbeautify
}

platforms=(
    iOS,"📱","${SYMBOL_GRAPHS_DIR_IOS}"
    macOS,"💻","${SYMBOL_GRAPHS_DIR_MACOS}"
)

# Iterate over available platforms
for input in "${platforms[@]}"; do
    # Split elements
    IFS=","
    set -- $input

    echo "$2 Building for $1"
    build_for_platform "$3" ${DERIVED_DATA_DIR} "generic/platform=$1"
done

# Create a .doccarchive from the symbols.
$(xcrun --find docc) convert "${DOCC_BUNDLE_PATH}" \
  --fallback-display-name "${SCHEME}" \
  --fallback-bundle-identifier com.moroverse.quick-form \
  --fallback-bundle-version 1 \
  --output-dir "${DOCCARCHIVE_PATH}" \
  --additional-symbol-graph-dir "${SYMBOL_GRAPHS_DIR}" \


$(xcrun --find docc) process-archive \
transform-for-static-hosting "${DOCCARCHIVE_PATH}" \
--output-path "${WEBSITE_OUTPUT_PATH}" \
--hosting-base-path "/quick-form/"

# Clean up.
rm -rf "${DERIVED_DATA_DIR}"
rm -rf "${BUILD_DIR}"
