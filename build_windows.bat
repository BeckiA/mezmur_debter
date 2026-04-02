@echo off
echo Setting environment variables...

REM Set CMAKE_TLS_VERIFY to bypass SSL certificate issues
set CMAKE_TLS_VERIFY=0

REM Add tools directory to PATH for nuget.exe
set PATH=%CD%\tools;%PATH%

REM Set FLUTTER_ROOT if not already set (helps with flutter_assemble)
if "%FLUTTER_ROOT%"=="" (
    for /f "tokens=*" %%i in ('where.exe flutter 2^>nul') do (
        set FLUTTER_PATH=%%i
        goto :found_flutter
    )
    :found_flutter
    if defined FLUTTER_PATH (
        set FLUTTER_ROOT=%FLUTTER_PATH:\bin\flutter.bat=%
        set FLUTTER_ROOT=%FLUTTER_ROOT:\bin\flutter=%
        echo FLUTTER_ROOT set to: %FLUTTER_ROOT%
    )
)

echo Cleaning build...
flutter clean

echo Pre-populating nuget.exe where CMake expects it...
if not exist "build\windows\x64\_deps\nuget-subbuild\nuget-populate-prefix\src" (
    mkdir "build\windows\x64\_deps\nuget-subbuild\nuget-populate-prefix\src"
)
copy /Y tools\nuget.exe "build\windows\x64\_deps\nuget-subbuild\nuget-populate-prefix\src\nuget.exe" >nul 2>&1

echo Building Windows application...
flutter build windows

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Build failed with error code %ERRORLEVEL%
    echo Check the output above for details.
) else (
    echo.
    echo Build completed successfully!
    echo Executable location: build\windows\x64\runner\Release\hymn_app.exe
)

pause

