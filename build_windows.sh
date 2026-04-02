#!/bin/bash

# Set environment variable to bypass SSL certificate verification
export CMAKE_TLS_VERIFY=0

# Add tools directory to PATH
export PATH="$(pwd)/tools:$PATH"

echo "Cleaning build..."
flutter clean

echo "Pre-populating nuget.exe where CMake expects it..."
mkdir -p "build/windows/x64/_deps/nuget-subbuild/nuget-populate-prefix/src"
cp -f tools/nuget.exe "build/windows/x64/_deps/nuget-subbuild/nuget-populate-prefix/src/nuget.exe" 2>/dev/null || true

echo "Building Windows application..."
flutter build windows

if [ $? -eq 0 ]; then
    echo ""
    echo "Build completed successfully!"
    echo "Executable location: build/windows/x64/runner/Release/hymn_app.exe"
else
    echo ""
    echo "Build failed with error code $?"
    echo "Check the output above for details."
fi

