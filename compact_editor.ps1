# Define source directory and output file
$sourceDir = "." # Current directory, change if needed
$outputFile = "$sourceDir\compact_editor_code.txt"

# Define files relevant to crosshair
$relevantFiles = @(
	"lib/chart.dart"
	"lib/chart_painter.dart"
	"lib/utils/calculations.dart"
	"lib/utils/constants.dart"
	"lib/models/i_candle.dart"
	"example/lib/home.dart"
	"example/lib/main.dart"
	"example/lib/editor/ui/pages/editor_page.dart"
	"example/lib/editor/ui/pages/chart_demo.dart"
	"lib/models/recipe.dart"
)

# Create or clear the output file
"# Editor Relevant Code" | Out-File -FilePath $outputFile

# Process each relevant file
foreach ($file in $relevantFiles) {
    $filePath = Join-Path -Path $sourceDir -ChildPath $file
    
    if (Test-Path $filePath) {
        # Add file header to the output
        "`n`n# FILE: $file`n" | Out-File -FilePath $outputFile -Append
        
        # Read the file content and append to the output
        Get-Content -Path $filePath | Out-File -FilePath $outputFile -Append
        
        Write-Host "Added: $file"
    } else {
        Write-Host "Warning: File not found - $filePath"
    }
}

Write-Host "All relevant code has been collated into $outputFile"