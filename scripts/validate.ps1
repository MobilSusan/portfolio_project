# Get Minikube IP
$minikubeIp = minikube ip

# Get NodePort
$nodePort = kubectl get service tdl-api-service -o jsonpath="{.spec.ports[0].nodePort}"

# Build URL
$serviceUrl = "http://$minikubeIp`:$nodePort"

Write-Host "Checking live version at $serviceUrl..."

try {
    $response = Invoke-RestMethod -Uri "$serviceUrl/health" -TimeoutSec 3
    Write-Host "Health: $($response.status)"
} catch {
    Write-Host "Health: FAILED"
}

try {
    $root = Invoke-RestMethod -Uri "$serviceUrl/" -TimeoutSec 3
    Write-Host "Version: $($root.message)"
} catch {
    Write-Host "Version: UNKNOWN (service unreachable)"
}