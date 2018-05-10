#Script created by Gísli Guðmundsson
#Created for Aron Gauti Birgisson


#Create Objects to set info about the computers who user logged on to
function setPingUser($ComputerName, $IPAddress, $User){
    New-Object psobject -Property @{
        ComputerName=$ComputerName;
        IPAddress=$IPAddress;
        User=$User;
    }
}

#Ping the user
function pingUser($SamAccountName, $OSType){
    #Finds the user with samaccountname
    $FindUser = Get-ADUser -Filter "SamAccountName -eq '$SamAccountName'"

    #If the user exists enter the if statement
    if($FindUser){
        $Computers = Get-ADComputer -Filter "OperatingSystem -like '*$OSType*'" -Properties IPv4Address, OperatingSystem
        write-host "Pinging user $SamAccountName - Will take some time based on the network size" -ForegroundColor Yellow
        foreach($Computer in $Computers){
            
            #If computer responds to a network call enter the if statement
            if(Test-Connection -ComputerName $Computer.Name -ErrorAction SilentlyContinue){
                #Get last logged on user on remote computer
                $UserFound = Get-WinEvent -ComputerName $Computer.Name -FilterHashtable @{Logname='Security';ID=4672} -MaxEvents 1 -ErrorAction SilentlyContinue | select @{N='User';E={$_.Properties[1].Value}} | where { $_.User -eq $SamAccountName }
                #$UserFound
                #If the user is found on a specified computer enter the if statement
                if($UserFound){
                    setPingUser -ComputerName $Computer.Name -IPAddress $Computer.IPv4Address -User $UserFound.User
                }
            }
        }
    }else{
        write-host "User $SamAccountName does not exist, please type in the samaccount name" -ForegroundColor Red
    }
}

#Example for OSType are
# Server
# Windows Server 2016
# Windows 7
# Enterprise

pingUser -SamAccountName "gisli" -OSType "Server"