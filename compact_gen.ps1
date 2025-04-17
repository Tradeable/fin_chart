# Define source directory and output file
$sourceDir = "." # Current directory, change if needed
$outputFile = "$sourceDir\compact_gen_code.txt"

# Define files relevant to crosshair
$relevantFiles = @(
	"lib/candle_stick_generator.dart"
	"lib/chart.dart"
	"lib/chart_painter.dart"
	"lib/models/i_candle.dart"
	"lib/utils/calculations.dart"
	"lib/utils/constants.dart"
	"lib/models/region/main_plot_region.dart"
	"lib/models/enums/candle_state.dart"
	"lib/models/region/region_prop.dart"
	"lib/models/recipe.dart"
)

# Create or clear the output file
"# Crosshair Generator Code" | Out-File -FilePath $outputFile

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