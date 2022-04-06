function New-UserName{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [string]$FirstName,
        [Parameter(Mandatory)]
        [string]$LastName,
        [Parameter(Mandatory)]
        [string]$Server
    )

    try{
        [RegEx]$Pattern="\s|-|'"
        $Index=1

        do{
            $Username="$LastName$($FirstName.Substring(0,$Index))" -replace $Pattern,""
            $Index++
        }while((Get-ADUser -Filter "SamAccountName -like '$Username'" -Server $Server) -and ($Username -notlike "$LastName$FirstName"))

        if((Get-ADUser -Filter "SamAccountName -like '$Username'" -Server $Server)){
            throw "No usernames available for this account"
        }else{
            return $Username
        }
    }catch{
        Write-Error $_.Exception.Message
        throw $_.Exception.Message
    }
}
function New-OneOffADUser{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [string]$FirstName,
        [Parameter(Mandatory)]
        [string]$LastName,
        [Parameter()]
        [string]$Username,
        [Parameter(Mandatory)]
        [string]$Reason,
        [Parameter(Mandatory)]
        [string]$Server,
        [Parameter()]
        [datetime]$ExpirationDate,
        [Parameter()]
        [int]$PasswordLength=15,
        [Parameter()]
        $ChangePasswordAtNextLogon=$true
    )

    try{
        if(-not $Username){
            $Username=New-UserName -FirstName $FirstName -LastName $LastName -Server $Server
        }

        if($ExpirationDate){
            $Date=Get-Date -Date $ExpirationDate
        }

        $PlainTextPassword= -Join (@('0'..'9';'A'..'Z';'a'..'z';'!';'@';'#';'$','%','&') | Get-Random -Count $PasswordLength)
        $Password=ConvertTo-SecureString -String $PlainTextPassword -AsPlainText -Force

        $ADUserParams=@{
            Name=$Username
            GivenName=$FirstName
            SurName=$LastName
            SamAccountName=$Username
            UserPrincipalName="$Username@jacked.ca"
            Description=$Reason
            Title=$Reason
            Enabled=$true
            AccountPassword=$Password
            Server=$Server
            ChangePasswordAtLogon=$ChangePasswordAtNextLogon
        }

        if($Date){
            New-ADUser @ADUserParams -AccountExpirationDate $Date
        }else{
            New-ADUser @ADUserParams
        }

        Write-Output "User created for $FirstName $LastName with the username : $Username and password : $PlainTextPassword"

    }catch{
        Write-Error $_.Exception.Message
    }
}

New-OneOffADUser -FirstName "Test" -LastName "Test" -Username 'TestUser1' -Reason "YouTube" -Server "jacked.ca" -ExpirationDate "2022-4-30" -PasswordLength 15
