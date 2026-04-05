Write-Host "=== BLUE Pods ==="
kubectl get pods -l version=blue -o wide

Write-Host "`n=== GREEN Pods ==="
kubectl get pods -l version=green -o wide

Write-Host "`n=== Service Routing ==="
$selector = kubectl get service tdl-api-service -o jsonpath="{.spec.selector.version}"
Write-Host "Service is routing traffic to: $selector"

Write-Host "`n=== Current Live Version ==="

# Build service URL
$minikubeIp = minikube ip
$nodePort = kubectl get service tdl-api-service -o jsonpath="{.spec.ports[0].nodePort}"
$serviceUrl = "http://$minikubeIp`:$nodePort"

try {
    $root = Invoke-RestMethod -Uri "$serviceUrl/" -TimeoutSec 3
    Write-Host "Live version response: $($root.message)"
} catch {
    Write-Host "Service unreachable"
}

Write-Host "`n=== Pod Restart Counts ==="
kubectl get pods -o custom-columns="NAME:.metadata.name,RESTARTS:.status.containerStatuses[*].restartCount"

Write-Host "`n=== Deployment Summary ==="
kubectl get deployments -o wide