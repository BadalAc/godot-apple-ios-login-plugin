#!/bin/zsh

# MARK: Help
echo "iOS-only build script"
echo "Syntax: ./build.sh <config?>"
echo "Valid configurations: debug & release (Default: release)"

# MARK: Settings
BINARY_PATH_IOS="Bin/ios"
BUILD_PATH_IOS=".build/arm64-apple-ios"

# MARK: Inputs
CONFIG=$1
if [[ ! $CONFIG ]]; then
    CONFIG="release"
fi

COPY_COMMANDS=()

# MARK: Build iOS
build_ios() {
    xcodebuild \
        -scheme "MyLibrary" \
        -destination 'generic/platform=iOS' \
        -derivedDataPath "$BUILD_PATH_IOS" \
        -clonedSourcePackagesDirPath ".build" \
        -configuration "$1" \
        -skipPackagePluginValidation \
        -skipMacroValidation \
        -quiet

    if [[ $? -gt 0 ]]; then
        echo "${BOLD}${RED}Failed to build iOS library${RESET_FORMATTING}"
        return 1
    fi

    echo "${BOLD}${GREEN}iOS build succeeded${RESET_FORMATTING}"

    product_path="$BUILD_PATH_IOS/Build/Products/$1-iphoneos/PackageFrameworks"
    source_path="Sources"
    for source in $source_path/*; do
        COPY_COMMANDS+=("cp -af ""$product_path/$source:t:r.framework ""$BINARY_PATH_IOS")
    done
    
    COPY_COMMANDS+=("cp -af ""$product_path/SwiftGodot.framework ""$BINARY_PATH_IOS")

    return 0
}

# MARK: Pre & Post process
build_libs() {
    echo "${BOLD}${CYAN}Building iOS libraries ($1)...${RESET_FORMATTING}"
    
    build_ios "$1"
    
    if [[ ${#COPY_COMMANDS[@]} -gt 0 ]]; then
        echo "${BOLD}${CYAN}Copying iOS frameworks...${RESET_FORMATTING}"
        for instruction in ${COPY_COMMANDS[@]}
        do
            target=${instruction##* }
            mkdir -p "$target"
            eval $instruction
        done
    fi

    echo "${BOLD}${GREEN}Finished building $1 libraries for iOS${RESET_FORMATTING}"
}

# MARK: Formatting
BOLD="$(tput bold)"
GREEN="$(tput setaf 2)"
CYAN="$(tput setaf 6)"
RED="$(tput setaf 1)"
RESET_FORMATTING="$(tput sgr0)"

# MARK: Run
build_libs "$CONFIG"
