#Requires -Version 5.1
<#
.SYNOPSIS
  Onboarding script — dev mới vào chạy 1 trong 3 lệnh.

.EXAMPLE
  .\scripts\dev.ps1 web          # Chạy app web tại http://localhost:8080
  .\scripts\dev.ps1 apk          # Build APK → docker-output/app-release.apk
  .\scripts\dev.ps1 setup-fvm    # Cài FVM + Flutter pin version (dev local)
#>

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet("web", "apk", "setup-fvm")]
    [string]$Command
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $Root

function Assert-Docker {
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        Write-Host "Docker chua duoc cai. Tai Docker Desktop: https://www.docker.com/products/docker-desktop/" -ForegroundColor Red
        exit 1
    }
}

switch ($Command) {
    "web" {
        Assert-Docker
        Write-Host "==> Chay app web tai http://localhost:8080" -ForegroundColor Cyan
        docker compose up --build web
    }
    "apk" {
        Assert-Docker
        New-Item -ItemType Directory -Force -Path "docker-output" | Out-Null
        Write-Host "==> Build APK (lan dau co the mat 10-20 phut)..." -ForegroundColor Cyan
        docker compose --profile build run --rm apk
        if (Test-Path "docker-output/app-release.apk") {
            Write-Host "==> APK: docker-output/app-release.apk" -ForegroundColor Green
        }
    }
    "setup-fvm" {
        if (-not (Get-Command dart -ErrorAction SilentlyContinue)) {
            Write-Host "Can cai Dart/Flutter truoc: https://docs.flutter.dev/get-started/install" -ForegroundColor Red
            exit 1
        }
        Write-Host "==> Cai FVM..." -ForegroundColor Cyan
        dart pub global activate fvm
        $env:Path += ";$env:LOCALAPPDATA\Pub\Cache\bin"
        Write-Host "==> Cai Flutter 3.29.3 (pin version)..." -ForegroundColor Cyan
        fvm install
        fvm flutter pub get
        Write-Host "==> Xong. Chay local: fvm flutter run -d chrome" -ForegroundColor Green
    }
}
