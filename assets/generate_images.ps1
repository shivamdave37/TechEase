Add-Type -AssemblyName System.Drawing

function Create-StepImage {
    param (
        [string]$Path,
        [string]$Title,
        [string]$Subtitle,
        [string]$HighlightAction,
        [System.Drawing.Color]$BgColor,
        [System.Drawing.Color]$AccentColor
    )

    $width = 400
    $height = 300
    $bmp = New-Object System.Drawing.Bitmap($width, $height)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

    # Background
    $bgBrush = New-Object System.Drawing.SolidBrush($BgColor)
    $g.FillRectangle($bgBrush, 0, 0, $width, $height)

    # Phone outline / Card
    $cardPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(210, 215, 225), 3)
    $cardBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $g.FillRectangle($cardBrush, 30, 20, 340, 260)
    $g.DrawRectangle($cardPen, 30, 20, 340, 260)

    # Header bar
    $accentBrush = New-Object System.Drawing.SolidBrush($AccentColor)
    $g.FillRectangle($accentBrush, 30, 20, 340, 48)

    # Header Text
    $headFont = New-Object System.Drawing.Font("Arial", 16, [System.Drawing.FontStyle]::Bold)
    $whiteBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $g.DrawString($Title, $headFont, $whiteBrush, 45, 32)

    # Content Area - Subtitle
    $subFont = New-Object System.Drawing.Font("Arial", 12, [System.Drawing.FontStyle]::Regular)
    $darkBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(40, 45, 55))
    $g.DrawString($Subtitle, $subFont, $darkBrush, 50, 85)

    # Action / Button highlight
    $actBg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(235, 248, 240))
    $actPen = New-Object System.Drawing.Pen($AccentColor, 3)
    $g.FillRectangle($actBg, 50, 130, 300, 75)
    $g.DrawRectangle($actPen, 50, 130, 300, 75)

    # Action Text
    $actFont = New-Object System.Drawing.Font("Arial", 13, [System.Drawing.FontStyle]::Bold)
    $g.DrawString($HighlightAction, $actFont, $accentBrush, 65, 155)

    # Touch indicator (Hand pointer circle)
    $touchBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(220, 255, 75, 75))
    $g.FillEllipse($touchBrush, 280, 175, 40, 40)
    $tapFont = New-Object System.Drawing.Font("Arial", 9, [System.Drawing.FontStyle]::Bold)
    $g.DrawString("TAP", $tapFont, $whiteBrush, 288, 187)

    # Clean up and save
    $bmp.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
}

$base = "C:\Users\shiva\OneDrive\Desktop\elder people\elder_smartphone_learning_app\assets\images"
$green = [System.Drawing.Color]::FromArgb(37, 162, 90)
$blue = [System.Drawing.Color]::FromArgb(24, 119, 242)
$bg = [System.Drawing.Color]::FromArgb(245, 247, 250)

Create-StepImage "$base\whatsapp.png" "WhatsApp" "Free Messaging App" "WhatsApp Icon" $bg $green
Create-StepImage "$base\whatsapp_step1.png" "Step 1: Home Screen" "Look for the green WhatsApp icon" "👉 Tap WhatsApp Icon" $bg $green
Create-StepImage "$base\whatsapp_step2.png" "Step 2: Chats Screen" "Look at the bottom right corner" "👉 Tap Green Chat Button" $bg $green
Create-StepImage "$base\whatsapp_step3.png" "Step 3: Select Contact" "Choose the person to message" "👉 Tap Contact Name" $bg $green
Create-StepImage "$base\whatsapp_step4.png" "Step 4: Type Message" "Type your message in the box" "👉 Tap Message Box" $bg $green
Create-StepImage "$base\whatsapp_step5.png" "Step 5: Send Message" "Send using the green paper plane" "👉 Tap Send Arrow" $bg $green

Write-Output "Generated 6 illustrations."
