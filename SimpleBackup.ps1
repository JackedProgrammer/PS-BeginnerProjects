$BackupLocationsFilePath="C:\Users\Administrator.HYPV2016L\Desktop\PS-BeginnerProjects\Directories.txt"
$BackupLocations=Get-Content -Path $BackupLocationsFilePath

$StorageLocation="C:\Users\Administrator.HYPV2016L\Desktop\BackUpStorage"
$BackupName="Backup $(Get-Date -Format "yyyy-MM-dd hh-mm")"

foreach($Location in $BackupLocations){
    Write-Output "Backing up $($Location)"
    $LeadingPath="$($Location.Replace(':',''))"
    if(-not (Test-Path "$StorageLocation\$BackupName\$LeadingPath")){
        New-Item -Path "$StorageLocation\$BackupName\$LeadingPath" -ItemType Directory
    }
    Get-ChildItem -Path $Location | Copy-Item -Destination "$StorageLocation\$BackupName\$LeadingPath" -Recurse -Container
}

Compress-Archive -Path "$StorageLocation\$BackupName" -DestinationPath "$StorageLocation\$BackupName.zip" -CompressionLevel Fastest
