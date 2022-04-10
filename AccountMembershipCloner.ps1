function Copy-ADPrincipalGroupMembership{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [string]$OriginalUserName,
        [Parameter(Mandatory)]
        [string]$ReceivingUserName,
        [Parameter(Mandatory)]
        [string]$Server,
        [Parameter()]
        [switch]$Replace
    )

    try{
        $OriginalUser=Get-ADPrincipalGroupMembership -Identity $OriginalUserName -Server $Server
        $ReceivingUser=Get-ADPrincipalGroupMembership -Identity $ReceivingUserName -Server $Server
        
        if($OriginalUser -and $ReceivingUser){
            $CompareResults=Compare-Object -ReferenceObject $OriginalUser -DifferenceObject $ReceivingUser -Property SamAccountName
            $Adds=$CompareResults | Where-Object SideIndicator -eq "<="
            $Removes=$CompareResults | Where-Object SideIndicator -eq "=>"
        }elseif($OriginalUser){
            $Adds=$OriginalUser
            $Removes=$null
        }elseif($ReceivingUser){
            $Removes=$ReceivingUser
            $Adds=$null
        }
        
        if($Adds){
            Foreach($Add in $Adds){
                Write-Debug "Adding $ReceivingUserName to group $($Add.SamAccountName)"
                Add-ADGroupMember -Identity $add.samAccountName -Members $ReceivingUserName -Server $Server
            }
        }
        
        if($Replace){
            if($Removes){
                Foreach($Remove in $Removes){
                    Write-Debug "Removing $ReceivingUserName from group $($Add.SamAccountName)"
                    Remove-ADGroupMember -Identity $Remove.samAccountName -Members $ReceivingUserName -Server $Server -Confirm:$false
                }
            }
        }
        
    }catch{
        Write-Error $_.Exception.Message
    }

}

Copy-ADPrincipalGroupMembership -OriginalUserName "testuser1" -ReceivingUserName "testuser2" -Server "jacked.ca" -Replace -Debug



