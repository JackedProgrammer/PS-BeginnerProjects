Import-Module C:\Scripts\SendEmail\MailModule.psm1
$MailAccount=Import-Clixml -Path C:\Scripts\SendEmail\outlook.xml
$MailPort=587
$MailSMTPServer="smtp-mail.outlook.com"
$MailFrom=$MailAccount.Username
$MailTo="testjackedprogrammer@outlook.com"
$ServerListFilePath="C:\users\Administrator.HYPV2016L\Desktop\PS-BeginnerProjects\EnvCheckerList.csv"

$ServerList=Import-Csv -Path $ServerListFilePath -Delimiter ','

$Export=[System.Collections.ArrayList]@()

foreach($Server in $ServerList){
    $ServerName=$Server.ServerName
    $LastStatus=$Server.LastStatus
    $DownSince=$Server.DownSince
    $LastDownAlert=$Server.LastDownAlertTime
    $Alert=$false
    $Connection=Test-Connection $ServerName -Count 1
    $DateTime=Get-Date

    if($Connection.Status -eq "Success"){
        if($LastStatus -ne "Success"){
            $Server.DownSince=$null
            $Server.LastDownAlertTime=$null
            Write-Output "$ServerName is now online"
            $Alert=$true
            $Subject="$ServerName is now online!"
            $Body="<h2>$ServerName is now online!</h2>"
            $Body+="<p>$ServerName is now online at $DateTime</p>"
        }
    }else{
        if($LastStatus -eq "Success"){
            Write-Output "$ServerName is now offline"
            $Server.DownSince=$DateTime
            $Server.LastDownAlertTime=$DateTime
            $Alert=$true
            $Subject="$ServerName is now offline!"
            $Body="<h2>$ServerName is now offline!</h2>"
            $Body+="<p>$ServerName is now offline at $DateTime</p>"
        }else{
            $DownFor=$((Get-Date -Date $DateTime) - (Get-Date -Date $DownSince)).Days
            $SinceLastDownAlert=$((Get-Date -Date $DateTime) - (Get-Date -Date $LastDownAlert)).Days
            if(($DownFor -ge 1) -and ($SinceLastDownAlert -ge 1)){
                Write-Output "It has been $SinceLastDownAlert days since last alert"
                Write-Output "$ServerName is still offline for $DownFor days"
                $Server.LastDownAlertTime=$DateTime
                $Alert=$true
                $Subject="$ServerName is still offline for $DownFor days!"
                $Body="<h2>$ServerName has been offline for $DownFor days!</h2>"
                $Body+="<p>$ServerName is now offline since $DownSince</p>"
            }
        } 
    }

    if($Alert){
        Send-MailKitMessage -From $MailFrom -To $MailTo -SMTPServer $MailSMTPServer -Port $MailPort -Subject $Subject -Body $Body -BodyAsHtml -Credential $MailAccount
    }

    $Server.LastStatus=$Connection.Status
    $Server.LastCheckTime=$DateTime
    [void]$Export.add($Server)
}

$Export | Export-Csv -Path $ServerListFilePath -Delimiter ',' -NoTypeInformation

