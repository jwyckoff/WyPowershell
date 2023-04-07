function Write-Line {
    param (
        $char = '-',
        $length = 80
    )
    Write-Host $( $char * $length)
}
function Write-Message {
    param (
        [string]$message)

    Write-Line
    echo $message
    
}
function Write-Done {
    echo "    ...done."
}

function Write-KeyValue {
    param (
        $key,
        $value
    )
    $keyMaxLength = 15

    $key = $key.PadRight($keyMaxLength)

    $length
    echo "$key :  '$value'"
}



function Clear-Directory {
    param ([string]$directory)
    Write-Message "Clearing Directory '${directory}'..."
    if (Test-Path $directory) {
 
        Remove-Item $directory -Recurse -Force
    }
    $result = New-Item -ItemType Directory -Force -Path $directory
    if (Test-Path $directory)
    { Write-Done }
    else {
        echo $result
    }

    
}

function ZipAndExit {

    Compress-Archive $OUTPUT_DIR $outputZip
    cd $startDir 
    exit
   
}



function Invoke-Gitsizer {
    param (
        [string]$gitUrl,
        [string]$gitName,
        [string]$repoRootFolder,
        [string]$outputFolder
    )
    
    $startDir = $PWD

    $gitSizerOutputDir = "$outputFolder\git-sizer"  # NOTE: using global constant defined outside of function.

    New-Item -ItemType Directory -Force -Path $gitSizerOutputDir

    # clone the repo in the $REPO_HOME directory.
    cd $repoRootFolder 
    git clone $gitUrl $gitName
    cd $gitName

    # runs 'git-sizer' and dumps output into repo-specific file in the centeralized $OUTPUT_DIR directory.
    $outputFile = "$gitSizerOutputDir\$gitName.gitsizer.txt"
    Write-Message -message "Running git-sizer to out    put '$outputFile'..."
    git-sizer > $outputFile



    # runs 'git-filter-repo'...
    Write-Message -message "Running git-filter-repo..."
    git filter-repo --analyze

    # copies/creates a repo-specific folder in $OUTPUT_DIR for the results.  The results are initially saved inside .git folder: .git\filter-repo\analysis\
    $targetFolder = "$rootFolder\filter-repo\$gitName"
    cp ".\.git\filter-repo\analysis\" $targetFolder -Recurse


    # to save space an not have all 20k+ repos cloned on your machine at the end, remove cloned repo when done.
    cd $rootFolder 
    Remove-Item $gitName -Recurse -Force

    cd $startDir
    
    
}


function Invoke-GetProjectInfo {
    param (
        [int]$projectId,
        [string]$projectName,
        [int]$i,
        [string]$apiUrl,
        [string]$keyword,
        [string]$outputCsv,
        [string]$outputDir
    )

    Write-Host $( "-" * 80)
    Write-Output "  Project # ${i} : $projectName"
    Write-Host $( "-" * 80)
    Write-Output " "

    Write-KeyValue -key "`$keyword" -value $keyword
    Write-KeyValue -key "`$projectId" -value $projectId
    Write-KeyValue -key "`$projectName" -value $projectName
    Write-KeyValue -key "`$apiUrl" -value $apiUrl


    if (!(Test-Path "$outputDir\$keyword\")) {
        New-Item -ItemType Directory -Force -Path "$outputDir\$keyword\"
    }
    Write-Output " "
    Write-Output "Calling API '$apiUrl'..."

    $t = "--UHzkEvbEa-wFbmQxdW" 
   # Write-Output " Token =$env:GITLAB_TOKEN"
    $headers = @{
        'PRIVATE-TOKEN' = $t
    }

    try {
        $projectResults = Invoke-RestMethod -Uri $apiUrl  -Headers $headers
    }
    catch {
        $statusCode = $_.Exception.Response.StatusCode.value__

        if($statusCode -in 401..404)
        {
            Write-Output "***** ERROR - $statusCode "
            "$projectId,$projectName,ERR,$statusCode" >> $outputCsv 
            return
        }
        else {
            $_.Exception | Format-List -Force
            exit
        }
    }

   
    Write-Done
    Write-Output " "

    $count = $projectResults.Length
    $outputJson = "$outputDir\$keyword\$keyword.$projectName.json"
    $outputDetailCsv = "$outputDir\$keyword\$keyword.$projectName.csv"
    Write-KeyValue -key "`$count" -value $count
    Write-KeyValue -key "`$outputJson" -value $outputJson



    "$projectId,$projectName,$count" >> $outputCsv 

    Write-Output "Savings Info to JSON '$outputJson'..."


    $projectResults |
    ConvertTo-Json |
    Set-Content $outputJson
      
    Write-Done
    Write-Output " "

    $projectResults | Export-CSV $outputDetailCsv -NoTypeInformation


}