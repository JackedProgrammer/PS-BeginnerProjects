Import-Module C:\Scripts\SendEmail\MailModule.psm1
$MailAccount=Import-Clixml -Path C:\Scripts\SendEmail\outlook.xml
$MailPort=587
$MailSMTPServer="smtp-mail.outlook.com"
$MailFrom=$MailAccount.UserName
$MailTo="testjackedprogrammer@outlook.com"

$HowManyDaysBeforeNotify=14

$Users=Get-ADUser -Filter * -Properties * -Server Jacked.ca | Where-Object {($_.Enabled -eq $true) -and ($_.PasswordNeverExpires -eq $false) -and ($_.PasswordExpired -eq $false)}

foreach($User in $Users){
    $Name = "$($User.givenname) $($user.Surname)"
    $Email =$user.EmailAddress
    $PasswordSetOn=$user.PasswordLastSet
    $PasswordPolicy=(Get-ADUserResultantPasswordPolicy -Identity $User.SamAccountName -Server jacked.ca)
    if($PasswordPolicy){
        $MaxPasswordAge=$PasswordPolicy.maxPasswordAge
    }else{
        $MaxPasswordAge=(Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge
    }

    $ExpiryDate=$PasswordSetOn+$MaxPasswordAge
    $Today=Get-Date
    $DaysLeft=(New-TimeSpan -Start $Today -End $ExpiryDate).Days

    if($DaysLeft -le $HowManyDaysBeforeNotify){
        if($DaysLeft -ge 1){
            $CustomMessage="in $DaysLeft days"
        }else{
            $CustomMessage="today"
        }

        $Subject = "Your password expires $CustomMessage"
        $Body="<p>Hi $Name,</p><p>Your password expires $CustomMessage</p><p>Thanks,</p><p>JackedProgrammer</p>"
        Send-MailKitMessage -From $MailFrom -To $MailTo -SMTPServer $MailSMTPServer -Port $MailPort -Credential $MailAccount -Subject $Subject -Body $Body -BodyAsHtml
    }
    
}
