# PowerShell equivalent of download-and-check.sh

# Read all releases from releases.txt into an array
$RELEASES = Get-Content releases.txt

# Create manifests directory and set permissions (Linux-specific, use sudo if needed)
if (-not (Test-Path "/mnt/manifests")) {
    sudo mkdir -p /mnt/manifests
}
sudo chown -R prabhakk /mnt/manifests

foreach ($RELEASE in $RELEASES) {
    Write-Host "Processing release: $RELEASE"
    $RELEASE_INSTALL_DIR = "/mnt/matlab/$RELEASE"
    $MANIFEST_FILE = "/mnt/manifests/${RELEASE}_Linux.enc.manifest"

    # Check if the release directory already exists
    if (Test-Path $RELEASE_INSTALL_DIR) {
        Write-Host "Release directory already exists: $RELEASE_INSTALL_DIR"
    } else {
        $base = $RELEASE -replace 'U.*$',''
        $productsFile = "$HOME/${base}.txt"
        $products = Get-Content $productsFile | ForEach-Object { $_ } | Join-String " "
        ./mpm download --release=$RELEASE --destination=$RELEASE_INSTALL_DIR --products=$products
        Write-Host "Downloaded release: $RELEASE to $RELEASE_INSTALL_DIR"
    }

    # Find all .enc files and write to manifest
    Get-ChildItem -Path $RELEASE_INSTALL_DIR -Recurse -Filter *.enc | Select-Object -ExpandProperty FullName | Set-Content $MANIFEST_FILE
    Write-Host "Created manifest file: $MANIFEST_FILE"

    # Run mwsign and check result
    ./mwsign -c 1.0.2 -v -m $MANIFEST_FILE | Set-Content "$MANIFEST_FILE.mwsign_result"
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Signature verification successful for $MANIFEST_FILE"
        Remove-Item -Recurse -Force $RELEASE_INSTALL_DIR
        Write-Host "Deleted folder: $RELEASE_INSTALL_DIR"
    } else {
        Write-Host "Signature verification failed for $MANIFEST_FILE"
    }
    Write-Host "----------------------------------------"
}