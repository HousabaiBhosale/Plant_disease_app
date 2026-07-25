<?php
function renderHeader($title = "Dashboard", $subtitle = "Real-Time Overview & AI Model Monitoring") {
    $activePage = basename($_SERVER['PHP_SELF'], '.php');
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?php echo htmlspecialchars($title); ?> - PlantSense AI</title>
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script src="assets/js/api.js"></script>
    <script src="assets/js/i18n.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script>
      // Apply dark theme immediately on load to prevent flash
      if (localStorage.getItem('theme') === 'dark') {
        document.documentElement.setAttribute('data-theme', 'dark');
      }
    </script>
</head>
<body>

<?php renderSidebar($activePage); ?>

<main class="main-content">
    <header class="header">
        <div class="header-title">
            <h1 class="mesh-gradient-text"><?php echo htmlspecialchars($title); ?></h1>
            <p><span class="status-dot"></span> <span data-i18n="header_active">System Active</span> &bull; <span id="headerSubtitle"><?php echo htmlspecialchars($subtitle); ?></span></p>
        </div>
        <div class="flex items-center gap-3">
            <!-- Language Selector Dropdown -->
            <select class="form-control" id="langSelector" onchange="setLanguage(this.value)" style="width: auto; padding: 6px 14px; font-size: 0.85rem; font-weight: 700; border-radius: 999px; cursor: pointer; background: var(--bg-paper);">
                <option value="en">🌐 English</option>
                <option value="hi">🇮🇳 हिन्दी</option>
                <option value="mr">🇮🇳 मराठी</option>
                <option value="es">🇪🇸 Español</option>
            </select>

            <!-- Theme Toggle Button -->
            <button class="btn btn-secondary" id="themeBtn" onclick="toggleTheme()" title="Toggle Dark/Light Mode" style="padding: 8px 14px; border-radius: 999px;">
                <i class="fa-solid fa-moon" style="color: #64748B;"></i>
            </button>

            <!-- User Profile Badge -->
            <div class="user-profile">
                <div class="user-avatar" id="headerAvatar">A</div>
                <div>
                    <span style="font-weight: 700; font-size: 0.9rem; display: block;" id="headerUserName">Admin User</span>
                    <span style="font-size: 0.75rem; color: var(--text-muted); display: block;" data-i18n="super_admin">Super Admin</span>
                </div>
            </div>
        </div>
    </header>
<?php
}

function renderSidebar($activePage) {
    $navItems = [
        'index' => ['icon' => 'fa-solid fa-chart-line', 'label' => 'Dashboard', 'i18n' => 'nav_dashboard'],
        'users' => ['icon' => 'fa-solid fa-location-dot', 'label' => 'Live Tracking', 'i18n' => 'nav_tracking'],
        'analytics' => ['icon' => 'fa-solid fa-chart-pie', 'label' => 'Analytics', 'i18n' => 'nav_analytics'],
        'datasets' => ['icon' => 'fa-solid fa-database', 'label' => 'Datasets', 'i18n' => 'nav_datasets'],
        'models' => ['icon' => 'fa-solid fa-brain', 'label' => 'AI Models', 'i18n' => 'nav_models'],
        'feedback' => ['icon' => 'fa-solid fa-comments', 'label' => 'Feedback', 'i18n' => 'nav_feedback'],
        'settings' => ['icon' => 'fa-solid fa-gear', 'label' => 'Settings', 'i18n' => 'nav_settings']
    ];
?>
<aside class="sidebar">
    <div class="sidebar-logo">
        <i class="fa-solid fa-leaf"></i>
        <h2>PlantSense AI</h2>
    </div>
    <nav class="nav-menu">
        <?php foreach ($navItems as $key => $item): ?>
        <a href="<?php echo $key; ?>.php" class="nav-item <?php echo $activePage === $key ? 'active' : ''; ?>">
            <i class="<?php echo $item['icon']; ?>"></i>
            <span data-i18n="<?php echo $item['i18n']; ?>"><?php echo $item['label']; ?></span>
        </a>
        <?php endforeach; ?>
    </nav>
    <div class="sidebar-footer">
        <a href="javascript:void(0)" onclick="api.logout()" class="nav-item" style="color: var(--error);">
            <i class="fa-solid fa-right-from-bracket"></i>
            <span data-i18n="nav_logout">Sign Out</span>
        </a>
    </div>
</aside>
<?php
}

function renderFooter() {
?>
</main>
<script>
// Fetch user profile name on load
document.addEventListener('DOMContentLoaded', async () => {
    try {
        const user = await api.fetchApi('/auth/me');
        if (user && user.name) {
            document.getElementById('headerUserName').textContent = user.name;
            document.getElementById('headerAvatar').textContent = user.name.charAt(0).toUpperCase();
        }
    } catch (e) {}
});
</script>
</body>
</html>
<?php
}
?>
