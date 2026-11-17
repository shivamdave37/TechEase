Add-Type -AssemblyName System.Drawing

function Create-CardImage {
    param (
        [string]$Path,
        [string]$Title,
        [string]$Subtitle,
        [System.Drawing.Color]$AccentColor
    )

    $width = 300
    $height = 200
    $bmp = New-Object System.Drawing.Bitmap($width, $height)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

    # Background
    $bgBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(248, 250, 252))
    $g.FillRectangle($bgBrush, 0, 0, $width, $height)

    # Accent circle
    $accentBrush = New-Object System.Drawing.SolidBrush($AccentColor)
    $g.FillEllipse($accentBrush, 110, 30, 80, 80)

    # Icon symbol
    $iconBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $iconFont = New-Object System.Drawing.Font("Arial", 28, [System.Drawing.FontStyle]::Bold)
    $format = New-Object System.Drawing.StringFormat
    $format.Alignment = [System.Drawing.StringAlignment]::Center
    $format.LineAlignment = [System.Drawing.StringAlignment]::Center
    $symbol = $Title.Substring(0, 1)
    $rect = New-Object System.Drawing.RectangleF(110, 30, 80, 80)
    $g.DrawString($symbol, $iconFont, $iconBrush, $rect, $format)

    # Title
    $titleFont = New-Object System.Drawing.Font("Arial", 16, [System.Drawing.FontStyle]::Bold)
    $titleBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(30, 41, 59))
    $tRect = New-Object System.Drawing.RectangleF(10, 125, 280, 30)
    $g.DrawString($Title, $titleFont, $titleBrush, $tRect, $format)

    # Subtitle
    $subFont = New-Object System.Drawing.Font("Arial", 11, [System.Drawing.FontStyle]::Regular)
    $subBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(100, 116, 139))
    $sRect = New-Object System.Drawing.RectangleF(10, 155, 280, 35)
    $g.DrawString($Subtitle, $subFont, $subBrush, $sRect, $format)

    $bmp.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
}

$base = "C:\Users\shiva\OneDrive\Desktop\elder people\elder_smartphone_learning_app\assets\images"
Create-CardImage "$base\basics.png" "Smartphone Basics" "Power, volume & buttons" ([System.Drawing.Color]::FromArgb(59, 130, 246))
Create-CardImage "$base\maps.png" "Google Maps" "Find places & directions" ([System.Drawing.Color]::FromArgb(239, 68, 68))
Create-CardImage "$base\qr.png" "QR Codes" "Scan menus & codes" ([System.Drawing.Color]::FromArgb(168, 85, 247))
Create-CardImage "$base\photos.png" "Photos & Gallery" "View & share photos" ([System.Drawing.Color]::FromArgb(234, 88, 12))
Create-CardImage "$base\internet.png" "Internet & Browsing" "Search and read news" ([System.Drawing.Color]::FromArgb(14, 165, 233))

Write-Output "Generated additional category images."
