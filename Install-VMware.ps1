param($dir)

# 1. 安装到指定路径
$installer = Join-Path $dir "vmware_o.exe"
$installArgs = "/S /D=`"$dir`" ADDLOCAL=ALL ENABLE_AUTO_UPDATE=0 USER_SETTINGS_INSTALL=1"
Start-Process -FilePath $installer -ArgumentList $installArgs -Wait -Verb RunAs

# 2. 验证安装路径文件
$binFiles = @("vmware-vmx.exe", "vmrun.exe", "vmware-vmrc.exe", "vmware.exe")
$installSuccess = $true

foreach ($file in $binFiles) {
    $filePath = Join-Path $dir $file
    if (!(Test-Path $filePath)) {
        Write-Warning "文件未找到: $filePath"
        $installSuccess = $false
    }
}

# 3. 若文件在默认路径，创建符号链接
if (-not $installSuccess) {
    $defaultPath = "C:\Program Files\VMware\VMware Workstation Player"
    if (Test-Path $defaultPath) {
        Write-Host "检测到VMware安装在默认路径，创建符号链接..." -ForegroundColor Yellow
        
        foreach ($file in $binFiles) {
            $sourcePath = Join-Path $defaultPath $file
            $targetPath = Join-Path $dir $file
            
            if (Test-Path $sourcePath) {
                New-Item -ItemType SymbolicLink -Path $targetPath -Target $sourcePath -Force | Out-Null
                Write-Host "创建链接: $targetPath -> $sourcePath" -ForegroundColor Green
            }
        }
    } else {
        Write-Error "无法找到VMware安装文件，请手动安装后创建符号链接" -ForegroundColor Red
    }
}