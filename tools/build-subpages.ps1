# Builds subpages from _orig/*.html into themed HTML at repo root.
$ErrorActionPreference = "Stop"
$repoRoot = Split-Path $PSScriptRoot -Parent
$origDir = Join-Path $repoRoot "_orig"
$baseUrl = "https://khammett325995.github.io/Portfolio-Website-Kylie-Hammett/"
$shellTpl = Get-Content (Join-Path $PSScriptRoot "subpage-shell.html") -Raw -Encoding UTF8
$utf8NoBom = New-Object System.Text.UTF8Encoding $false

function Encode-PortfolioPath([string]$raw) {
  $p = $raw.Trim() -replace "\\", "/"
  if ($p -match "^https?://") { return $p }
  $p = $p -replace "^\./", ""
  $parts = $p -split "/" | Where-Object { $_ -ne "" }
  $enc = foreach ($s in $parts) { [Uri]::EscapeDataString($s) }
  return $baseUrl + ($enc -join "/")
}

function Extract-ContentInner([string]$html) {
  $patterns = @(
    '(?s)<div class="content-margin">\s*(.*)\s*</div>\s*</body>',
    '(?s)<div class="content-margin">\s*(.*)\s*</div>\s*</section>\s*</body>'
  )
  foreach ($p in $patterns) {
    if ($html -match $p) { return $matches[1].Trim() }
  }
  throw "content-margin / body pattern not found"
}

function Remove-LegacySiteNav([string]$inner) {
  $rx = '(?s)<h1>\s*<a\s+href="index\.html"\s*>Kylie Hammett</a>\s*</h1>\s*<!--\s*Navigation Bar\s*-->\s*<div class="Navigation"[^>]*id\s*=\s*["'']myNavigation["''][^>]*>.*?</div>\s*(?:<!--[\s\S]*?-->\s*)*'
  $out = [regex]::Replace($inner, $rx, "", [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
  $out = [regex]::Replace($out, '(?s)<section class="reveal">\s*</section>\s*', "")
  $out = [regex]::Replace($out, '(?s)<section class="reveal">\s*(?:<!--[\s\S]*?-->\s*)+\s*</section>\s*', "")
  return $out.Trim()
}

function Rewrite-MediaPaths([string]$html) {
  $rx = '(?<attr>src|data)="(?<path>website-images[^"]*)"'
  return [regex]::Replace($html, $rx, {
      param($m)
      $attr = $m.Groups["attr"].Value
      $path = $m.Groups["path"].Value
      $url = Encode-PortfolioPath $path
      return "$attr=""$url"""
    }, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
}

function Strip-InlineScripts([string]$html) {
  return [regex]::Replace($html, '(?s)<script(?![^>]*\bsrc=)[^>]*>.*?</script>', "")
}

function Get-NavPlaceholders([string]$fileName) {
  $n = @{
    NAV_ABOUT    = ""
    NAV_PROJECTS = ""
    NAV_WORK     = ""
    NAV_AWARDS   = ""
    NAV_CREDITS  = ""
  }
  switch -Wildcard ($fileName) {
    "about.html" { $n["NAV_ABOUT"] = 'aria-current="page"'; break }
    "projects.html" { $n["NAV_PROJECTS"] = 'aria-current="page"'; break }
    "work-and-volunteer-exp.html" { $n["NAV_WORK"] = 'aria-current="page"'; break }
    "awards.html" { $n["NAV_AWARDS"] = 'aria-current="page"'; break }
    "credits.html" { $n["NAV_CREDITS"] = 'aria-current="page"'; break }
    default {
      if ($fileName -match '^(coding-|design-|game-design|web-dev-|event-planning|additional-)') {
        $n["NAV_PROJECTS"] = 'aria-current="page"'
      }
    }
  }
  return $n
}

$files = @(
  @{ Name = "about.html"; Title = "About"; Meta = "About Kylie Hammett: education, goals, and detailed skills." },
  @{ Name = "projects.html"; Title = "Projects"; Meta = "Project portfolios by focus area: software, games, web, design, events, and more." },
  @{ Name = "work-and-volunteer-exp.html"; Title = "Work & volunteer"; Meta = "Work and volunteer experience." },
  @{ Name = "awards.html"; Title = "Awards"; Meta = "Awards and recognition." },
  @{ Name = "coding-projects.html"; Title = "Software development"; Meta = "Software and coding projects." },
  @{ Name = "design-and-marketing.html"; Title = "Design & marketing"; Meta = "Graphic design and marketing projects." },
  @{ Name = "game-design-and-development-projects.html"; Title = "Game design & development"; Meta = "Game design and development projects." },
  @{ Name = "web-dev-projects.html"; Title = "Web development"; Meta = "Web development projects." },
  @{ Name = "event-planning-projects.html"; Title = "Event planning"; Meta = "Event planning and leadership." },
  @{ Name = "additional-skills-projects.html"; Title = "Additional skills"; Meta = "Robotics, music, editing, and other projects." },
  @{ Name = "credits.html"; Title = "Credits"; Meta = "Credits for fonts, icons, and assets used on the portfolio." }
)

foreach ($item in $files) {
  $path = Join-Path $origDir $item.Name
  if (-not (Test-Path $path)) { Write-Warning "Missing $path"; continue }
  $raw = Get-Content -Path $path -Raw -Encoding UTF8
  $inner = Extract-ContentInner $raw
  $inner = Remove-LegacySiteNav $inner
  $inner = Rewrite-MediaPaths $inner
  $inner = $inner -replace '<script src="app.js"></script>\s*', ""
  $inner = Strip-InlineScripts $inner
  $inner = $inner -replace '<!--\s*Name as the Page Title\s*-->\s*', ""

  $nav = Get-NavPlaceholders $item.Name
  $page = $shellTpl
  $page = $page.Replace("{{TITLE}}", $item.Title)
  $page = $page.Replace("{{META_DESC}}", $item.Meta)
  $page = $page.Replace("{{BODY}}", $inner)
  $page = $page.Replace("{{NAV_ABOUT}}", $nav["NAV_ABOUT"])
  $page = $page.Replace("{{NAV_PROJECTS}}", $nav["NAV_PROJECTS"])
  $page = $page.Replace("{{NAV_WORK}}", $nav["NAV_WORK"])
  $page = $page.Replace("{{NAV_AWARDS}}", $nav["NAV_AWARDS"])
  $page = $page.Replace("{{NAV_CREDITS}}", $nav["NAV_CREDITS"])

  $finalPath = Join-Path $repoRoot $item.Name
  [System.IO.File]::WriteAllText($finalPath, $page, $utf8NoBom)
  Write-Output "Published $finalPath"
}
