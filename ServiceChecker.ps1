Import-Module C:\Scripts\SendEmail\MailModule.psm1
$MailAccount=Import-Clixml -Path C:\Scripts\SendEmail\outlook.xml
$MailPort=587
$MailSMTPServer="smtp-mail.outlook.com"
$MailFrom=$MailAccount.Username
$MailTo="testjackedprogrammer@outlook.com"

$ServicesFilePath="C:\users\Administrator.HYPV2016L\Desktop\PS-BeginnerProjects\Services.csv"
$LogPath="C:\users\Administrator.HYPV2016L\Desktop\PS-BeginnerProjects\Logs"
$LogFile="Services-$(Get-Date -Format "yyyy-MM-dd hh-mm").txt"
$ServicesList=Import-Csv -Path $ServicesFilePath -Delimiter ','

foreach($Service in $ServicesList){
    $CurrentServiceStatus=(Get-Service -Name $Service.Name).status

    if($Service.Status -ne $CurrentServiceStatus){
        $Log="Service : $($Service.Name) is currently $CurrentServiceStatus, should be $($Service.Status)"
        Write-Output $Log
        Out-File -FilePath "$LogPath\$LogFile" -Append -InputObject $Log

        $Log="Setting $($Service.Name) to $($Service.Status)"
        Write-Output $Log
        Out-File -FilePath "$LogPath\$LogFile" -Append -InputObject $Log
        Set-Service -Name $Service.Name -Status $Service.Status

        $AfterServiceStatus=(Get-Service -Name $Service.Name).Status
        if($Service.Status -eq $AfterServiceStatus){
            $Log="Action was succesful Service $($Service.Name) is now $AfterServiceStatus"
            Write-Output $Log
            Out-File -FilePath "$LogPath\$LogFile" -Append -InputObject $Log    
        }else{
            $Log="Action failed Service $($Service.Name) is still $AfterServiceStatus, should be $($Service.Status)"
            Write-Output $Log
            Out-File -FilePath "$LogPath\$LogFile" -Append -InputObject $Log
        }
    }
}

if(Test-Path -Path "$LogPath\$LogFile"){
    $Subject="$($env:COMPUTERNAME) is having issues with services"
    $Body="Here is the log file"
    $Attachment="$LogPath\$LogFile"
    Send-MailKitMessage -From $MailFrom -To $MailTo -SMTPServer $MailSMTPServer -Port $MailPort -Credential $MailAccount -Subject $Subject -Body $Body -Attachments $Attachment
}
