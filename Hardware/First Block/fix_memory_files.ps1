# Fix memory file formats for SystemVerilog simulation

# Create backup of original files
Copy-Item .\memory\test_image.mem .\memory\test_image.mem.bak
Copy-Item .\memory\conv1.mem .\memory\conv1.mem.bak
Copy-Item .\memory\bn1.mem .\memory\bn1.mem.bak

Write-Host "Processing test_image.mem..."
$lines = Get-Content .\memory\test_image.mem
$newLines = @()
foreach ($line in $lines) {
    # Break long binary strings into 16-bit chunks
    for ($i = 0; $i -lt $line.Length; $i += 16) {
        $chunk = ""
        if ($i + 16 -le $line.Length) {
            $chunk = $line.Substring($i, 16)
        } else {
            $chunk = $line.Substring($i, $line.Length - $i)
            # Pad with zeros if needed
            $chunk = $chunk.PadRight(16, '0')
        }
        $newLines += $chunk
    }
}
$newLines | Out-File -FilePath .\memory\test_image.mem -Encoding ASCII

Write-Host "Processing conv1.mem..."
$lines = Get-Content .\memory\conv1.mem
$newLines = @()
foreach ($line in $lines) {
    # Break long binary strings into 16-bit chunks
    for ($i = 0; $i -lt $line.Length; $i += 16) {
        $chunk = ""
        if ($i + 16 -le $line.Length) {
            $chunk = $line.Substring($i, 16)
        } else {
            $chunk = $line.Substring($i, $line.Length - $i)
            # Pad with zeros if needed
            $chunk = $chunk.PadRight(16, '0')
        }
        $newLines += $chunk
    }
}
$newLines | Out-File -FilePath .\memory\conv1.mem -Encoding ASCII

Write-Host "Processing bn1.mem..."
$lines = Get-Content .\memory\bn1.mem
$newLines = @()
foreach ($line in $lines) {
    # Break long binary strings into 16-bit chunks
    for ($i = 0; $i -lt $line.Length; $i += 16) {
        $chunk = ""
        if ($i + 16 -le $line.Length) {
            $chunk = $line.Substring($i, 16)
        } else {
            $chunk = $line.Substring($i, $line.Length - $i)
            # Pad with zeros if needed
            $chunk = $chunk.PadRight(16, '0')
        }
        $newLines += $chunk
    }
}
$newLines | Out-File -FilePath .\memory\bn1.mem -Encoding ASCII

Write-Host "Memory files processed successfully!" 