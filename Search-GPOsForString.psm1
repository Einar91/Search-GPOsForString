<#
.SYNOPSIS
Search-GPOsForString will search through all group policyes in a domain for a specific string.
.DESCRIPTION
Search-GPOsForString uses GroupPolicy module to query for all GPO's and then creating a GPOReport in Xml format to search for a match to the specified string.
.PARAMETER DOMAINNAME
The DomainName to query for GPO's.
.PARAMETER STRING
The string to search through the policyes to find.
.EXAMPLE
Search-GPOsForString -DomainName CORP.local -String "String to search for"
#>

function Search-GPOsForString {
    [CmdletBinding()]
    #^ Optional ..Binding(SupportShouldProcess=$True,ConfirmImpact='Low')
    param (
    [string]$DomainName = $env:USERDNSDOMAIN,

    [Parameter(Mandatory=$True)]
    [string]$String
    )

BEGIN {
    #Load GrouPolicy module
    Import-Module GroupPolicy -ErrorAction Stop
}

PROCESS {
    #Query for all GPO's in domain
    $AllGPOsInDomain = Get-GPO -All -Domain $DomainName
    
    #Search through each GPO for the specified string
    Write-Verbose "Starting search.."
    foreach($gpo in $AllGPOsInDomain){
        $Report = Get-GPOReport -GUID $gpo.id -ReportType Xml
        if($Report -match $String){
            $Result_Prop = @{'Status'="Match Found"
                            'PolicyName'=$gpo.DisplayName}
            New-Object psobject -Property $Result_Prop
            Write-Verbose "****** Match found in: $($gpo.DisplayName) ******"
        } else {
            Write-Verbose "No match in: $($gpo.DisplayName)"
        } # Else

    } #Foreach
} #Process


END {
    # Intentionaly left empty.
    # This block is used to provide one-time post-processing for the function.
}

} #Function