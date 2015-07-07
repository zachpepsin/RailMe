Write-Host "csvToJson.ps1"
Write-Host "Zach Pepsin"
Write-Host "07 July 2015"
Write-Host "`nThis script should be located in folder 
above the agency folders to function properly"
Write-Host "`nRemember: NEVER run in current production
folder! ALWAYS make a new folder first and
test in dev mode!`n"

#Names of GTFS .txt files in CSV format to be converted to JSON.  Any missing files in folder will be ignored.
$fileNames = @("agency", "stops", "routes", "trips", "stop_times", "calendar", "calendar_dates", 
	"fare_attributes", "fare_rules", "shapes", "frequencies", "transfers", "feed_info")

#get root agency folder
$agency = Read-Host 'Root (agency)'
if( ($agency -contains '*') -or ($agency -eq '') ){
	Write-Host "Don't leave folder name empty or use an '*' in folder name."
	Read-Host -Prompt 'Press Enter to exit'
	Exit
}
while(-not (Test-Path .\$agency) ) {  #if path isn't found, try again/exit
	Write-Host 'Root folder not found'
	$agency = Read-Host 'Try again or press Enter to exit'
	if( $agency -eq ''){
		Exit
	}
}

#get subfolder (version folder)
$folder = Read-Host 'Folder'
if( ($folder -contains '*') -or ($folder -eq '') ){
	Write-Host "Don't leave folder name empty or use an '*' in folder name."
	Read-Host -Prompt 'Press Enter to exit'
	Exit
}
while(-not (Test-Path .\$agency\$folder) ) {  #if path isn't found, try again/exit
	Write-Host 'Subfolder not found'
	$folder = Read-Host 'Try again or press Enter to exit'
	if( $folder -eq ''){
		Exit
	}
}

#check that .txt files exist in the folder
if (-not (Test-Path .\$agency\$folder\*.txt) ) {
	Write-Host 'No .txt files in this folder'
	Read-Host -Prompt 'Press Enter to exit'
	Exit
}

#if .json files are in the folder, they may be overwritten by new files.  confirm this.
if ( Test-Path .\$agency\$folder\*.json ) {
	$input = ''
	while( $input -eq '' ){
		$input = Read-Host 'Existing .json files found in this folder.  Continue? (Y/N)'
		if( $input -ieq 'N' ){
			Exit
		}elseif( $input -ieq 'Y'){
			Continue  #don't change $input value, loop will break
		}else{
			$input = ''  #reset input to '' so loop continues
		}
	}
}	

#for use with ConvertTo-JSON function
function Escape-JSONString($str){
	if ($str -eq $null) {return ""}
	$str = $str.ToString().Replace('"','\"').Replace('\','\\').Replace("`n",'\n').Replace("`r",'\r').Replace("`t",'\t')
	return $str;
}

#converts object to JSON format
function ConvertTo-JSON($maxDepth = 4,$forceArray = $false) {
	begin {
		$data = @()
	}
	process{
		$data += $_
	}
	
	end{
	
		if ($data.length -eq 1 -and $forceArray -eq $false) {
			$value = $data[0]
		} else {	
			$value = $data
		}
 
		if ($value -eq $null) {
			return "null"
		}
 
		
 
		$dataType = $value.GetType().Name
		
		switch -regex ($dataType) {
	            'String'  {
					return  "`"{0}`"" -f (Escape-JSONString $value )
				}
	            '(System\.)?DateTime'  {return  "`"{0:yyyy-MM-dd}T{0:HH:mm:ss}`"" -f $value}
	            'Int32|Double' {return  "$value"}
				'Boolean' {return  "$value".ToLower()}
	            '(System\.)?Object\[\]' { # array
					
					if ($maxDepth -le 0){return "`"$value`""}
					
					$jsonResult = ''
					foreach($elem in $value){
						#if ($elem -eq $null) {continue}
						if ($jsonResult.Length -gt 0) {$jsonResult +=', '}				
						$jsonResult += ($elem | ConvertTo-JSON -maxDepth ($maxDepth -1))
					}
					return "[" + $jsonResult + "]"
	            }
				'(System\.)?Hashtable' { # hashtable
					$jsonResult = ''
					foreach($key in $value.Keys){
						if ($jsonResult.Length -gt 0) {$jsonResult +=', '}
						$jsonResult += 
@"
	"{0}": {1}
"@ -f $key , ($value[$key] | ConvertTo-JSON -maxDepth ($maxDepth -1) )
					}
					return "{" + $jsonResult + "}"
				}
	            default { #object
					if ($maxDepth -le 0){return  "`"{0}`"" -f (Escape-JSONString $value)}
					
					return "{" +
						(($value | Get-Member -MemberType *property | % { 
@"
	"{0}": {1}
"@ -f $_.Name , ($value.($_.Name) | ConvertTo-JSON -maxDepth ($maxDepth -1) )			
					
					}) -join ', ') + "}"
	    		}
		}
	}
}
	
#loop through each GTFS file name
foreach ($file in $fileNames){
	Write-Host "`n$file" #subheader
	Write-Host "----------"
	if(-not (Test-Path .\$agency\$folder\$file.txt) ){  #skip file if .txt isn't found
		Write-Host "file not found (skipped)"
		Continue
	}
	Write-Host "Importing CSV..."
	$fin = Import-Csv .\$agency\$folder\$file.txt -delimiter "," #import from file to object
	Write-Host "Converting to JSON..."
	<# $fout = $fin | ConvertTo-Json #> #only works in PowerShell v3+, have to use function
	$fout = $fin | ConvertTo-JSON  #convert object to JSON format
	Write-Host 'Writing to .\$agency\$folder\$file.json...'
	$fout > ".\$agency\$folder\$file.json"
	Write-Host "Done!`n"
}

Read-Host '`nFinished!  Press Enter to exit'
