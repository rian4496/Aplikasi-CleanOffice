# Admin Widgets Reorganization Script
# Run this to safely reorganize admin widgets

Write-Host "🔄 Starting Admin Widgets Reorganization..." -ForegroundColor Cyan

# Step 1: Backup current state
Write-Host "`n📦 Step 1: Creating backup..." -ForegroundColor Yellow
if (!(Test-Path "lib\widgets\admin_backup")) {
    Copy-Item -Path "lib\widgets\admin" -Destination "lib\widgets\admin_backup" -Recurse -Force
    Write-Host "✅ Backup created at lib\widgets\admin_backup" -ForegroundColor Green
}

# Step 2: Move existing old files to admin_old
Write-Host "`n📂 Step 2: Moving old files to admin_old..." -ForegroundColor Yellow

# Files to move to admin_old (existing old files)
$oldFiles = @(
    "admin_analytics_widget.dart",
    "admin_overview_widget.dart",
    "admin_sidebar.dart",
    "admin_stats_card.dart",
    "advanced_filter_dialog.dart",
    "batch_action_bar.dart",
    "export_dialog.dart",
    "filter_chips_widget.dart",
    "global_search_bar.dart",
    "info_card_widget.dart",
    "realtime_indicator_widget.dart",
    "recent_activities_widget.dart",
    "report_list_item_widget.dart",
    "selectable_report_card.dart"
)

# Create admin_old if not exists
if (!(Test-Path "lib\widgets\admin_old")) {
    New-Item -ItemType Directory -Path "lib\widgets\admin_old" -Force | Out-Null
}

foreach ($file in $oldFiles) {
    $sourcePath = "lib\widgets\admin\$file"
    if (Test-Path $sourcePath) {
        Move-Item -Path $sourcePath -Destination "lib\widgets\admin_old\$file" -Force
        Write-Host "  Moved: $file" -ForegroundColor Gray
    }
}

# Move old folders (charts, dashboard - old versions)
$oldFolders = @("charts", "dashboard")
foreach ($folder in $oldFolders) {
    $sourcePath = "lib\widgets\admin\$folder"
    if (Test-Path $sourcePath) {
        Move-Item -Path $sourcePath -Destination "lib\widgets\admin_old\$folder" -Force
        Write-Host "  Moved folder: $folder" -ForegroundColor Gray
    }
}

Write-Host "✅ Old files moved to admin_old/" -ForegroundColor Green

# Step 3: Create new folder structure
Write-Host "`n📁 Step 3: Creating new folder structure..." -ForegroundColor Yellow

$newFolders = @(
    "lib\widgets\admin\mobile\layout",
    "lib\widgets\admin\mobile\cards",
    "lib\widgets\admin\mobile\lists",
    "lib\widgets\admin\mobile\filters",
    "lib\widgets\admin\desktop\layout",
    "lib\widgets\admin\desktop\cards",
    "lib\widgets\admin\shared\verification",
    "lib\widgets\admin\shared\actions",
    "lib\widgets\admin\shared\common"
)

foreach ($folder in $newFolders) {
    if (!(Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder -Force | Out-Null
        Write-Host "  Created: $folder" -ForegroundColor Gray
    }
}

Write-Host "✅ New folder structure created" -ForegroundColor Green

# Step 4: Move MY new files to new structure
Write-Host "`n🔀 Step 4: Reorganizing new files..." -ForegroundColor Yellow

# Mobile - Layout
$moves = @(
    @{From="lib\widgets\admin\layout\mobile_admin_app_bar.dart"; To="lib\widgets\admin\mobile\layout\mobile_app_bar.dart"},
    @{From="lib\widgets\admin\layout\admin_bottom_nav.dart"; To="lib\widgets\admin\mobile\layout\mobile_bottom_nav.dart"},
    @{From="lib\widgets\admin\layout\quick_actions_fab.dart"; To="lib\widgets\admin\mobile\layout\mobile_fab.dart"},
    
    # Mobile - Cards
    @{From="lib\widgets\admin\cards\greeting_card.dart"; To="lib\widgets\admin\mobile\cards\mobile_greeting_card.dart"},
    @{From="lib\widgets\admin\cards\pastel_stat_card.dart"; To="lib\widgets\admin\mobile\cards\mobile_stat_card.dart"},
    @{From="lib\widgets\admin\cards\mobile_report_card.dart"; To="lib\widgets\admin\mobile\cards\mobile_report_card.dart"},
    @{From="lib\widgets\admin\cards\cleaner_card.dart"; To="lib\widgets\admin\mobile\cards\mobile_cleaner_card.dart"},
    
    # Mobile - Lists
    @{From="lib\widgets\admin\lists\activity_list_item.dart"; To="lib\widgets\admin\mobile\lists\mobile_activity_item.dart"},
    @{From="lib\widgets\admin\lists\activities_section.dart"; To="lib\widgets\admin\mobile\lists\mobile_activities_section.dart"},
    
    # Mobile - Filters
    @{From="lib\widgets\admin\filters\horizontal_filter_chips.dart"; To="lib\widgets\admin\mobile\filters\mobile_filter_chips.dart"},
    @{From="lib\widgets\admin\search\search_bar_widget.dart"; To="lib\widgets\admin\mobile\filters\mobile_search_bar.dart"},
    
    # Desktop - Layout
    @{From="lib\widgets\admin\layout\admin_sidebar.dart"; To="lib\widgets\admin\desktop\layout\desktop_sidebar.dart"},
    @{From="lib\widgets\admin\layout\desktop_admin_app_bar.dart"; To="lib\widgets\admin\desktop\layout\desktop_app_bar.dart"},
    @{From="lib\widgets\admin\layout\admin_layout_wrapper.dart"; To="lib\widgets\admin\desktop\layout\desktop_layout_wrapper.dart"},
    
    # Shared
    @{From="lib\widgets\admin\verification\image_comparison_widget.dart"; To="lib\widgets\admin\shared\verification\image_comparison.dart"},
    @{From="lib\widgets\admin\actions\batch_action_bar.dart"; To="lib\widgets\admin\shared\actions\batch_action_bar.dart"},
    @{From="lib\widgets\admin\layout\responsive_layout_builder.dart"; To="lib\widgets\admin\shared\common\responsive_builder.dart"}
)

foreach ($move in $moves) {
    if (Test-Path $move.From) {
        Copy-Item -Path $move.From -Destination $move.To -Force
        Write-Host "  Moved: $(Split-Path $move.From -Leaf) -> $(Split-Path $move.To -Leaf)" -ForegroundColor Gray
    } else {
        Write-Host "  ⚠️  Not found: $($move.From)" -ForegroundColor Yellow
    }
}

Write-Host "✅ Files reorganized" -ForegroundColor Green

# Step 5: Clean up empty old folders
Write-Host "`n🧹 Step 5: Cleaning up..." -ForegroundColor Yellow

$oldFoldersToRemove = @("layout", "cards", "lists", "filters", "search", "actions", "verification")
foreach ($folder in $oldFoldersToRemove) {
    $path = "lib\widgets\admin\$folder"
    if (Test-Path $path) {
        Remove-Item -Path $path -Recurse -Force
        Write-Host "  Removed: lib\widgets\admin\$folder" -ForegroundColor Gray
    }
}

Write-Host "`n✅ Reorganization complete!" -ForegroundColor Green
Write-Host "`n📝 Next steps:" -ForegroundColor Cyan
Write-Host "  1. Run: flutter pub run build_runner build --delete-conflicting-outputs" -ForegroundColor White
Write-Host "  2. Update imports in screens (see import_updates.txt)" -ForegroundColor White
Write-Host "  3. Test the app" -ForegroundColor White
Write-Host "  4. Delete lib\widgets\admin_backup if everything works" -ForegroundColor White
