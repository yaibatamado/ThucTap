$ErrorActionPreference = "Stop"

$Flutter = "E:\flutter_windows_3.44.1-stable\flutter\bin\flutter.bat"
$Adb = "E:\Sdk\platform-tools\adb.exe"
$Package = "com.example.hospital_app_frontend"
$Activity = "com.example.hospital_app_frontend/.MainActivity"
$Apk = "build\app\outputs\flutter-apk\app-debug.apk"

Write-Host "Stopping old app..."
& $Adb shell am force-stop $Package 2>$null

Write-Host "Building APK..."
& $Flutter build apk --debug

Write-Host "Installing APK..."
& $Adb install -r $Apk

Write-Host "Starting app without debug attach..."
& $Adb shell am start -n $Activity

Write-Host "Done. The app should be open on the emulator."
