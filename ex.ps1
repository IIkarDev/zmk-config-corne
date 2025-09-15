# Script to extract content of all files in current directory and subdirectories
# Result is saved to output.txt

# Get current directory
$currentPath = Get-Location
$outputFile = Join-Path $currentPath "output.txt"

# Clear output file if it exists
if (Test-Path $outputFile) {
    Clear-Content $outputFile
}

Write-Host "Starting file extraction from directory: $currentPath"
Write-Host "Result will be saved to: $outputFile"

# Get all files recursively
$files = Get-ChildItem -Path $currentPath -File -Recurse

# Counter for progress display
$totalFiles = $files.Count
$processedFiles = 0

foreach ($file in $files) {
    $processedFiles++
    
    # Show progress
    Write-Progress -Activity "Processing files" -Status "Processing: $($file.Name)" -PercentComplete (($processedFiles / $totalFiles) * 100)
    
    # Skip output.txt to avoid recursion
    if ($file.Name -eq "output.txt") {
        continue
    }
    
    try {
        # Write separator and file path
        Add-Content -Path $outputFile -Value "`n" -Encoding UTF8
        Add-Content -Path $outputFile -Value ("=" * 80) -Encoding UTF8
        Add-Content -Path $outputFile -Value "FILE: $($file.FullName)" -Encoding UTF8
        Add-Content -Path $outputFile -Value "SIZE: $($file.Length) bytes" -Encoding UTF8
        Add-Content -Path $outputFile -Value "MODIFIED: $($file.LastWriteTime)" -Encoding UTF8
        Add-Content -Path $outputFile -Value ("=" * 80) -Encoding UTF8
        Add-Content -Path $outputFile -Value "`n" -Encoding UTF8
        
        # Try to read file content as text
        $content = Get-Content -Path $file.FullName -Raw -ErrorAction SilentlyContinue
        
        if ($content) {
            Add-Content -Path $outputFile -Value $content -Encoding UTF8
        } else {
            Add-Content -Path $outputFile -Value "[FILE IS EMPTY OR CANNOT BE READ AS TEXT]" -Encoding UTF8
        }
        
    } catch {
        # Handle file reading errors
        Add-Content -Path $outputFile -Value "[ERROR READING FILE: $($_.Exception.Message)]" -Encoding UTF8
        Write-Warning "Could not read file: $($file.FullName). Error: $($_.Exception.Message)"
    }
}

# Complete progress indicator
Write-Progress -Activity "Processing files" -Completed

Write-Host "`nProcessing completed!"
Write-Host "Files processed: $processedFiles"
Write-Host "Result saved to: $outputFile"

# Show output file size
if (Test-Path $outputFile) {
    $outputSize = (Get-Item $outputFile).Length
    $sizeKB = [math]::Round($outputSize/1KB, 2)
    Write-Host "Output file size: $sizeKB KB"
}