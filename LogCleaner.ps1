
$DirectoryListFilePath="C:\Users\Administrator.HYPV2016L\Desktop\PS-BeginnerProjects\LogDirectories.csv"

$DirectoryList=Import-Csv -Path $DirectoryListFilePath

foreach($Directory in $DirectoryList){
    Get-ChildItem -Path $Directory.DirectoryPath -Filter "$($Directory.FileName)*" `
    | Where-Object LastWriteTime -lt $(Get-Date).AddDays(-$Directory.KeepForDays) `
    | Remove-Item -Confirm:$false -Force
}
