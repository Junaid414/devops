# PowerShell Script to Deploy Apache on Remote Linux Server
# This script transfers the deployment files to a Linux server and executes the installation

param(
    [Parameter(Mandatory=$true)]
    [string]$LinuxHost,
    
    [Parameter(Mandatory=$true)]
    [string]$Username,
    
    [string]$PrivateKeyPath = "",
    
    [switch]$UsePassword
)

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Apache Deployment Script for Linux" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Check if required tools are available
function Test-Dependencies {
    Write-Host "Checking dependencies..." -ForegroundColor Yellow
    
    $scp = Get-Command scp -ErrorAction SilentlyContinue
    $ssh = Get-Command ssh -ErrorAction SilentlyContinue
    
    if (-not $scp -or -not $ssh) {
        Write-Host "❌ OpenSSH client is required but not found." -ForegroundColor Red
        Write-Host "Please install OpenSSH client:" -ForegroundColor Yellow
        Write-Host "  - Windows 10/11: Enable 'OpenSSH Client' optional feature" -ForegroundColor White
        Write-Host "  - Or download from: https://github.com/PowerShell/Win32-OpenSSH/releases" -ForegroundColor White
        exit 1
    }
    
    Write-Host "✅ Dependencies check passed" -ForegroundColor Green
}

# Transfer files to Linux server
function Copy-FilesToLinux {
    Write-Host "Transferring files to Linux server..." -ForegroundColor Yellow
    
    $currentPath = Split-Path -Parent $MyInvocation.MyCommand.Path
    $files = @(
        "$currentPath\deploy_apache.sh",
        "$currentPath\sample_index.html"
    )
    
    foreach ($file in $files) {
        if (Test-Path $file) {
            if ($PrivateKeyPath) {
                $scpCmd = "scp -i `"$PrivateKeyPath`" `"$file`" $Username@$LinuxHost`:~/"
            } else {
                $scpCmd = "scp `"$file`" $Username@$LinuxHost`:~/"
            }
            
            Write-Host "Copying $(Split-Path -Leaf $file)..." -ForegroundColor White
            Invoke-Expression $scpCmd
            
            if ($LASTEXITCODE -ne 0) {
                Write-Host "❌ Failed to copy $file" -ForegroundColor Red
                exit 1
            }
        } else {
            Write-Host "⚠️  File not found: $file" -ForegroundColor Yellow
        }
    }
    
    Write-Host "✅ Files transferred successfully" -ForegroundColor Green
}

# Execute deployment on Linux server
function Invoke-LinuxDeployment {
    Write-Host "Executing deployment on Linux server..." -ForegroundColor Yellow
    
    $commands = @(
        "chmod +x ~/deploy_apache.sh",
        "sudo ~/deploy_apache.sh"
    )
    
    foreach ($cmd in $commands) {
        Write-Host "Executing: $cmd" -ForegroundColor White
        
        if ($PrivateKeyPath) {
            $sshCmd = "ssh -i `"$PrivateKeyPath`" $Username@$LinuxHost `"$cmd`""
        } else {
            $sshCmd = "ssh $Username@$LinuxHost `"$cmd`""
        }
        
        Invoke-Expression $sshCmd
        
        if ($LASTEXITCODE -ne 0 -and $cmd -notlike "*sudo*") {
            Write-Host "❌ Command failed: $cmd" -ForegroundColor Red
            exit 1
        }
    }
}

# Test the deployment
function Test-Deployment {
    Write-Host "Testing deployment..." -ForegroundColor Yellow
    
    $testCommand = "curl -s -o /dev/null -w '%{http_code}' http://localhost"
    
    if ($PrivateKeyPath) {
        $sshCmd = "ssh -i `"$PrivateKeyPath`" $Username@$LinuxHost `"$testCommand`""
    } else {
        $sshCmd = "ssh $Username@$LinuxHost `"$testCommand`""
    }
    
    $httpCode = Invoke-Expression $sshCmd
    
    if ($httpCode -eq "200") {
        Write-Host "✅ Deployment test successful! HTTP 200 OK" -ForegroundColor Green
        Write-Host "🌐 Your website is accessible at: http://$LinuxHost" -ForegroundColor Cyan
    } else {
        Write-Host "⚠️  Deployment test returned HTTP code: $httpCode" -ForegroundColor Yellow
        Write-Host "The server might still be starting up. Try accessing http://$LinuxHost in a few minutes." -ForegroundColor White
    }
}

# Display final information
function Show-CompletionInfo {
    Write-Host ""
    Write-Host "=========================================" -ForegroundColor Green
    Write-Host "🎉 DEPLOYMENT COMPLETED!" -ForegroundColor Green
    Write-Host "=========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "🌐 Access your Apache web server at:" -ForegroundColor White
    Write-Host "   http://$LinuxHost" -ForegroundColor Cyan
    Write-Host "   http://$LinuxHost/about.html" -ForegroundColor Cyan
    Write-Host "   http://$LinuxHost/contact.html" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "🔧 To manage your server, SSH into it:" -ForegroundColor White
    if ($PrivateKeyPath) {
        Write-Host "   ssh -i `"$PrivateKeyPath`" $Username@$LinuxHost" -ForegroundColor Cyan
    } else {
        Write-Host "   ssh $Username@$LinuxHost" -ForegroundColor Cyan
    }
    Write-Host ""
    Write-Host "📁 Web files are located at: /var/www/html/" -ForegroundColor White
    Write-Host ""
    Write-Host "Happy coding! 🚀" -ForegroundColor Yellow
}

# Main execution
try {
    Test-Dependencies
    Copy-FilesToLinux
    Invoke-LinuxDeployment
    Start-Sleep -Seconds 5  # Give Apache time to start
    Test-Deployment
    Show-CompletionInfo
}
catch {
    Write-Host "❌ An error occurred: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Press any key to continue..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")