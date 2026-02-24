Write-Host "updateCsv.ps1"
Write-Host "Zach Pepsin"
Write-Host "22 September 2020"
Write-Host "`nThis script should be located in folder 
above the agency folders to function properly."
Write-Host "`nThis script will make updates to CSVs to format/add
missing data for select GTFS static feeds.`n"
Write-Host "`nRemember: NEVER run in current production
folder! ALWAYS make a new folder first and
test in dev mode!`n"

#Names of GTFS .txt files in CSV format. Any missing files in folder will be ignored.
$fileNames = @("agency", "stops", "routes", "trips", "stop_times", "calendar", "calendar_dates", 
	"fare_attributes", "fare_rules", "shapes", "frequencies", "transfers", "feed_info")

#Get root folder
$rootFolder = Read-Host 'Root Folder'
if( ($rootFolder -contains '*') -or ($rootFolder -eq '') ){
	Write-Host "Don't leave folder name empty or use an '*' in folder name."
	Read-Host -Prompt 'Press Enter to exit'
	Exit
}
while(-not (Test-Path .\$rootFolder) ) {  #if path isn't found, try again/exit
	Write-Host 'Root folder not found'
	$rootFolder = Read-Host 'Try again or press Enter to exit'
	if( $rootFolder -eq ''){
		Exit
	}
}

##Get sub folder (version folder)
$subFolder = Read-Host 'Sub Folder'
if( ($subFolder -contains '*') -or ($subFolder -eq '') ){
	Write-Host "Don't leave sub folder name empty or use an '*' in folder name."
	Read-Host -Prompt 'Press Enter to exit'
	Exit
}
while(-not (Test-Path .\$rootFolder\$subFolder) ) {  #if path isn't found, try again/exit
	Write-Host 'Subfolder not found'
	$subFolder = Read-Host 'Try again or press Enter to exit'
	if( $subFolder -eq ''){
		Exit
	}
}

#check that .txt files exist in the folder
if (-not (Test-Path .\$rootFolder\$subFolder\*.txt) ) {
	Write-Host 'No .txt files in this folder'
	Read-Host -Prompt 'Press Enter to exit'
	Exit
}

function Export-Updated-Csv
{
    Param
    (
         [Parameter(Mandatory=$true, Position=0)]
         $csv,
         [Parameter(Mandatory=$true, Position=1)]
         $feedFileName,
         [Parameter(Mandatory=$true, Position=2)]
         $rootFolder
    )
	
	$csv | Export-Csv .\$rootFolder\$subFolder\$feedFileName.txt -Delimiter ',' -NoType
	Write-Host "Updated "$feedFileName
	
}

# NJT Customization
if($rootFolder -eq 'njt') {
	Write-Host "Updating "$rootFolder
	foreach($feedFileName in $fileNames) {
	
		# Change the agency_name from NJ TRANSIT RAIL to "NJ Transit Rail"
		if($feedFileName -eq "agency") {
			#$csvfile = Import-csv .\$rootFolder\$subFolder\$feedFileName.txt
			
			#($csv = Import-Csv .\$rootFolder\$subFolder\$feedFileName.txt -Delimiter ',') | ? agency_id -ne 'NJB' | ForEach { 
			
			# skip (delete) the NJB row in agency
			$csv = Import-Csv -Path .\$rootFolder\$subFolder\$feedFileName.txt -Delimiter ',' | ? agency_id -ne 'NJB'
			foreach($rows in $csv) {
				if ($rows.agency_id -match "NJT") {
					$rows.agency_name = "NJ Transit Rail"
					$rows.agency_phone = "973-275-5555"
				}
			}
	
			Export-Updated-Csv $csv $feedFileName $rootFolder
			#$csv | Export-Csv .\$rootFolder\$subFolder\$feedFileName.txt -Delimiter ',' -NoType
		} elseif ($feedFileName -eq "stops") {
			# Set the wheelchair_boarding for accessible stops
			#Need to add the new column first
			$csv = Import-Csv .\$rootFolder\$subFolder\$feedFileName.txt -Delimiter ',' | Select-Object *,"wheelchair_boarding" 
			$csv | Export-Csv .\$rootFolder\$subFolder\$feedFileName.txt -Delimiter ',' -NoType
			
			($csv = Import-Csv .\$rootFolder\$subFolder\$feedFileName.txt -Delimiter ',') | ForEach { 
				if ($_.stop_id -in ('1', '43298', '28', '71', '9', '55', '39', '2', '10')) {
					# Set the wheelchair_boarding for ACL stops
					$_.wheelchair_boarding = "1"
				} elseif ($_.stop_id -in ('38291', '38292', '38293', '38294', '38295', '38296', '38297', '38298', '38299', '38300', '38301', '38302', '38303', '38304', '38305', '43288', '38306', '38307', '38308', '38309', '38310')) {
					# Set the wheelchair_boarding for River Line stops
					$_.wheelchair_boarding = "1"
				} elseif ($_.stop_id -in ('148', '32905', '125', '103', '38', '84', '83', '127', '70', '41', '109', '37953', '107', '38187', '105')) {
					# Set the wheelchair_boarding for NEC accessible stops
					$_.wheelchair_boarding = "1"
				} elseif ($_.stop_id -in ('32906')) {
					# Set the wheelchair_boarding for NEC non-accessible stops
					$_.wheelchair_boarding = "2"
				}
			}
			
			Export-Updated-Csv $csv $feedFileName $rootFolder
		
		} elseif ($feedFileName -eq "trips") {
			#Add the wheelchair_accessible and bikes_allowed
			#Need to add the new columns first
			$csv = Import-Csv .\$rootFolder\$subFolder\$feedFileName.txt -Delimiter ',' | Select-Object *,"wheelchair_accessible","bikes_allowed" 
			$csv | Export-Csv .\$rootFolder\$subFolder\$feedFileName.txt -Delimiter ',' -NoType
			
			($csv = Import-Csv .\$rootFolder\$subFolder\$feedFileName.txt -Delimiter ',') | ForEach { 
				#All NJT trains can accomidate wheelchairs
				$_.wheelchair_accessible = "1"
				
				#Bikes are allowed on RiverLine at all times.  Other routes depends on time of day
				if ($_.route_id -in ('16')) {
					# Set the wheelchair_boarding for ACL stops
					$_.bikes_allowed = "1"
				}
			}
			
			Export-Updated-Csv $csv $feedFileName $rootFolder
		
		}
	}
	
} elseif($rootFolder -eq 'septa') {
	Write-Host "Updating "$rootFolder
	foreach($feedFileName in $fileNames) {
		if($feedFileName -eq "agency") {
			#Add the agency_phone and agency_fare_url columns
			#Need to add the new columns first
			
			# Update: SEPTA added this info to the agency in 2026
			#$csv = Import-Csv .\$rootFolder\$subFolder\$feedFileName.txt -Delimiter ',' | Select-Object *,"agency_phone","agency_fare_url"
			#$csv | Export-Csv .\$rootFolder\$subFolder\$feedFileName.txt -Delimiter ',' -NoType

			($csv = Import-Csv .\$rootFolder\$subFolder\$feedFileName.txt -Delimiter ',') | ForEach {
				if ($_.agency_id -match "SEPTA") {
					# Change the agency_name from SEPTA to "SEPTA Regional Rail"
					
					$_.agency_name = "SEPTA Regional Rail"
					
					# Update: SEPTA added this info to the agency in 2026
					#$_.agency_phone = "215-580-7800"
					#$_.agency_fare_url = "https://wwww.septa.org/fares/regional-rail-zones/"
				}
				
				# Do not use noreply@septa.org for agency_email
				# Update: SEPTA has since removed the unnecessary email
				#if ($_.agency_email -match "noreply@septa.org") {
				#	$_.agency_email = ""
				#}
			}
	
			Export-Updated-Csv $csv $feedFileName $rootFolder
			
		} elseif ($feedFileName -eq "stops") {
			# Set the wheelchair_boarding
			#Need to add the new column first
			$csv = Import-Csv .\$rootFolder\$subFolder\$feedFileName.txt -Delimiter ',' | Select-Object *,"wheelchair_boarding" 
			$csv | Export-Csv .\$rootFolder\$subFolder\$feedFileName.txt -Delimiter ',' -NoType
			
			($csv = Import-Csv .\$rootFolder\$subFolder\$feedFileName.txt -Delimiter ',') | ForEach { 
				if ($_.stop_id -in ('90001', '90002', '90003', '90004', '90005', '90006', '90007', '90008', '90009', '90201', '90202', '90203', '90204', '90207', '90224', '90228', '90300', '90301', '90302', '90305', '90306', '90307', '90308', '90314', '90318', '90319', '90320', '90321', '90322', '90323', '90326', '90401', '90402', '90403', '90404', '90405', '90406', '90407', '90408', '90412', '90413', '90414', '90417', '90501', '90504', '90506', '90508', '90510', '90511', '90513', '90522', '90525', '90526', '90529', '90530', '90531', '90532', '90533', '90534', '90535', '90536', '90537', '90538', '90539', '90701', '90702', '90704', '90706', '90801', '90804', '90809', '90811', '90812', '90813', '90814', '90815', '91004')) {
					# Set the wheelchair_boarding for accessible stops
					$_.wheelchair_boarding = "1"
				} elseif ($_.stop_id -in ('90205', '90206', '90208', '90209', '90210', '90211', '90212', '90213', '90214', '90215', '90216', '90217', '90218', '90219', '90220', '90221', '90222', '90223', '90225', '90226', '90227', '90303', '90304', '90309', '90310', '90311', '90312', '90313', '90315', '90316', '90317', '90324', '90325', '90327', '90409', '90410', '90411', '90415', '90416', '90502', '90503', '90505', '90507', '90509', '90512', '90514', '90515', '90516', '90517', '90518', '90519', '90520', '90521', '90523', '90524', '90527', '90528', '90703', '90705', '90707', '90708', '90709', '90710', '90711', '90712', '90713', '90714', '90715', '90716', '90717', '90718', '90719', '90720', '90802', '90803', '90805', '90806', '90807', '90808', '90810')) {
					# Set the wheelchair_boarding for non-accessible stops
					$_.wheelchair_boarding = "2"
				}
			}
			
			Export-Updated-Csv $csv $feedFileName $rootFolder
		
		} #elseif ($feedFileName -eq "trips") { #UPDATE v202602010 added "wheelchair_accessible" to all trips
			#Add the wheelchair_accessible
			#Need to add the new columns first
		#	$csv = Import-Csv .\$rootFolder\$subFolder\$feedFileName.txt -Delimiter ',' | Select-Object *,"wheelchair_accessible"
		#	$csv | Export-Csv .\$rootFolder\$subFolder\$feedFileName.txt -Delimiter ',' -NoType
		#	
		#	($csv = Import-Csv .\$rootFolder\$subFolder\$feedFileName.txt -Delimiter ',') | ForEach { 
		#		#All SEPTA regional trains can accomidate wheelchairs
		#		$_.wheelchair_accessible = "1"
		#	}
		#	
		#	Export-Updated-Csv $csv $feedFileName $rootFolder
		#}
		
	}
} elseif($rootFolder -eq 'septa_bus') {
	Write-Host "Updating "$rootFolder
	foreach($feedFileName in $fileNames) {
		if($feedFileName -eq "agency") {
			#Add the agency_phone column
			#Need to add the new columns first
			$csv = Import-Csv .\$rootFolder\$subFolder\$feedFileName.txt -Delimiter ',' | Select-Object *,"agency_phone","agency_fare_url"
			$csv | Export-Csv .\$rootFolder\$subFolder\$feedFileName.txt -Delimiter ',' -NoType

			($csv = Import-Csv .\$rootFolder\$subFolder\$feedFileName.txt -Delimiter ',') | ForEach {
				if ($_.agency_id -match "SEPTA") {
					# Change the agency_name from SEPTA to "SEPTA Bus/Light Rail"
					$_.agency_name = "SEPTA Bus/Light Rail"
					$_.agency_phone = "215-580-7800"
					$_.agency_fare_url = "https://wwww.septa.org/fares/"
				}
			}
	
			Export-Updated-Csv $csv $feedFileName $rootFolder
		}
	}
}

Read-Host "`nFinished!  Press Enter to exit"
