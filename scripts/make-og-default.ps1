<#
.SYNOPSIS
  Renders public\images\og\og-default.png (1200x675 social preview card).

.DESCRIPTION
  The default Open Graph image carries the brand: the deep-green gradient and dot
  grid are drawn with GDI+, while the FinanceQuizApp logo is read straight from
  public\images\brand\financequizapp-logo.png (the single source of truth for the
  mark, also used by the header, the footer and the loading splash), so the card
  can never drift away from the logo shown on the site.

  Run it again whenever the brand name, tagline, palette or logo changes:

      powershell -ExecutionPolicy Bypass -File ./scripts/make-og-default.ps1
#>

Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = 'Stop'

$root = Resolve-Path (Join-Path $PSScriptRoot '..')
$outFile = Join-Path $root 'public\images\og\og-default.png'
$logoPng = Join-Path $root 'public\images\brand\financequizapp-logo.png'

if (-not (Test-Path $logoPng)) {
  throw "Brand mark not found at $logoPng - restore it before rendering the OG card."
}

$brandName  = 'Finance'
$brandTail  = 'QuizApp'
$tagline    = 'Clear, practical money education'

$w = 1200
$h = 675

$bmp = New-Object System.Drawing.Bitmap($w, $h)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

# Background: brand gradient + dot grid + soft light circles.
$bgBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  (New-Object System.Drawing.Rectangle(0, 0, $w, $h)),
  [System.Drawing.Color]::FromArgb(46, 125, 91),
  [System.Drawing.Color]::FromArgb(11, 31, 26),
  [System.Drawing.Drawing2D.LinearGradientMode]::ForwardDiagonal
)
$g.FillRectangle($bgBrush, 0, 0, $w, $h)

$dotBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(46, 255, 255, 255))
for ($dy = 0; $dy -lt $h; $dy += 28) {
  for ($dx = 0; $dx -lt $w; $dx += 28) {
    $g.FillEllipse($dotBrush, $dx, $dy, 3.2, 3.2)
  }
}

$g.FillEllipse((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(18, 255, 255, 255))), 820, -110, 440, 440)
$g.FillEllipse((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(15, 255, 255, 255))), -120, 340, 520, 520)

# Logo: the brand mark is full-bleed (the forest tile fills the canvas), so the
# box is the visible tile.
$markSize = 168
$markX = ($w - $markSize) / 2
$markY = 139
$logo = [System.Drawing.Image]::FromFile($logoPng)
$g.DrawImage($logo, [single]$markX, [single]$markY, [single]$markSize, [single]$markSize)
$logo.Dispose()

# Wordmark: "Finance" in white, "QuizApp" in the accent mint — joined, no space.
$titleFont = New-Object System.Drawing.Font('Segoe UI', 92, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$nameSize = $g.MeasureString($brandName, $titleFont)
$tailSize = $g.MeasureString($brandTail, $titleFont)
$fullNameSize = $g.MeasureString($brandName + $brandTail, $titleFont)
# MeasureString adds one trailing-space advance; removing it keeps the wordmark joined.
$trailing = $nameSize.Width + $tailSize.Width - $fullNameSize.Width
$titleY = 340
$titleX = ($w - ($fullNameSize.Width - $trailing)) / 2

$g.DrawString($brandName, $titleFont, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)), [single]$titleX, [single]$titleY)
$g.DrawString($brandTail, $titleFont, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(131, 212, 171))), [single]($titleX + $fullNameSize.Width - $tailSize.Width), [single]$titleY)

$tagFont = New-Object System.Drawing.Font('Segoe UI', 34, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$tagBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(214, 180, 194, 188))
$tagSize = $g.MeasureString($tagline, $tagFont)
$g.DrawString($tagline, $tagFont, $tagBrush, [single](($w - $tagSize.Width) / 2 + 8), [single]($titleY + $nameSize.Height + 6))

$g.Dispose()
$bmp.Save($outFile, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()

Write-Host "Wrote $((Resolve-Path $outFile))" -ForegroundColor Green
