# Validation Script for Kubernetes Deployment
# Exit Code: 0 = Healthy | 1 = Unhealthy

Write-Host "Starting deployment validation..." -ForegroundColor Cyan

$exitCode = 0

# -----------------------------
# 1. POD STATUS CHECK
# -----------------------------
Write-Host "`nChecking pod status..." -ForegroundColor Yellow
kubectl get pods

$badPods = kubectl get pods --no-headers | Select-String -Pattern "CrashLoopBackOff|Error"

if ($badPods) {
    Write-Host "`nUnhealthy pods detected:" -ForegroundColor Red
    $badPods | ForEach-Object { Write-Host $_ }
    $exitCode = 1
}

# -----------------------------
# 2. POD READINESS CHECK
# -----------------------------
$notReadyPods = kubectl get pods --no-headers | Where-Object {
    ($_ -split "\s+")[1].Split('/')[0] -ne ($_ -split "\s+")[1].Split('/')[1]
}

if ($notReadyPods) {
    Write-Host "`nSome pods are not fully ready:" -ForegroundColor Red
    $notReadyPods | ForEach-Object { Write-Host $_ }
    $exitCode = 1
} else {
    Write-Host "`nAll pods are Ready" -ForegroundColor Green
}

# -----------------------------
# 3. SERVICE ROUTING CHECK
# -----------------------------
Write-Host "`nChecking service routing..." -ForegroundColor Yellow

$serviceName = "tdl-api-service"

$svcExists = kubectl get svc $serviceName --no-headers 2>$null

if (-not $svcExists) {
    Write-Host "Service '$serviceName' not found!" -ForegroundColor Red
    exit 1
}

$versionSelector = kubectl get svc $serviceName -o jsonpath='{.spec.selector.version}'

Write-Host "Service is routing to version: $versionSelector" -ForegroundColor Cyan

# -----------------------------
# 4. LIVE SERVICE HEALTH CHECK
# -----------------------------
Write-Host "`nChecking live service health..." -ForegroundColor Yellow

$minikubeIp = minikube ip
$nodePort = kubectl get svc $serviceName -o jsonpath='{.spec.ports[0].nodePort}'
$baseUrl = "http://localhost:8080"

# Check /health
try {
    $health = Invoke-RestMethod -Uri "$baseUrl/health" -TimeoutSec 3
    if ($health.status -eq "ok") {
        Write-Host "Health endpoint OK" -ForegroundColor Green
    } else {
        Write-Host "Health endpoint returned unexpected response" -ForegroundColor Red
        $exitCode = 1
    }
}
catch {
    Write-Host "Health endpoint unreachable" -ForegroundColor Red
    $exitCode = 1
}

# Check root endpoint
try {
    $root = Invoke-RestMethod -Uri "$baseUrl/" -TimeoutSec 3
    Write-Host "Live version response: $($root.message)" -ForegroundColor Green
}
catch {
    Write-Host "Root endpoint unreachable" -ForegroundColor Red
    $exitCode = 1
}

# -----------------------------
# 5. FINAL RESULT
# -----------------------------
Write-Host "`nValidation Summary:" -ForegroundColor Cyan

if ($exitCode -eq 0) {
    Write-Host "Deployment is HEALTHY" -ForegroundColor Green
} else {
    Write-Host "Deployment is UNHEALTHY" -ForegroundColor Red
}

exit $exitCode
