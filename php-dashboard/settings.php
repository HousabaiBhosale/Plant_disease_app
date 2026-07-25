<?php
require_once 'layout.php';
renderHeader("Settings & System Control", "Configure AI Model Parameters, Notifications & Admin Preferences");
?>

<div class="grid grid-cols-2">
    <!-- Left Column: Model Preferences & Notifications -->
    <div class="flex flex-col gap-6">
        <!-- AI Model Preferences Card -->
        <div class="glass-card">
            <div class="flex items-center gap-2 mb-6">
                <i class="fa-solid fa-sliders" style="color: var(--primary-main); font-size: 1.25rem;"></i>
                <h3 style="font-size: 1.25rem; font-weight: 800;" data-i18n="card_ai_prefs">AI Model Preferences</h3>
            </div>

            <div class="form-group mb-6">
                <div class="flex justify-between items-center mb-2">
                    <label class="form-label" style="margin: 0;" data-i18n="lbl_conf_thresh">Diagnostic Confidence Threshold</label>
                    <span class="badge badge-info" id="threshVal" style="font-size: 0.9rem;">75%</span>
                </div>
                <p style="color: var(--text-secondary); font-size: 0.85rem; margin-bottom: 12px;" data-i18n="desc_conf_thresh">Predictions below this threshold will be flagged for manual farmer verification.</p>
                <input type="range" class="form-control" id="confSlider" min="50" max="99" value="75" style="padding: 0; cursor: pointer; height: 6px; accent-color: var(--primary-main);" oninput="document.getElementById('threshVal').textContent = this.value + '%'">
            </div>

            <div class="form-group mb-6">
                <label class="form-label" data-i18n="lbl_infer_engine">Production Inference Engine</label>
                <select class="form-control">
                    <option value="hybrid" selected>Hybrid (TFLite Edge + Cloud API) [Recommended]</option>
                    <option value="cloud">Cloud API Only (High Precision, Requires Internet)</option>
                    <option value="edge">Edge Local Only (TFLite Offline Mode)</option>
                </select>
            </div>

            <button class="btn btn-primary" onclick="saveModelPrefs()"><i class="fa-solid fa-check"></i> <span data-i18n="btn_save_model">Save Model Preferences</span></button>
        </div>

        <!-- Notification Settings Card -->
        <div class="glass-card">
            <div class="flex items-center gap-2 mb-6">
                <i class="fa-solid fa-bell" style="color: var(--warning); font-size: 1.25rem;"></i>
                <h3 style="font-size: 1.25rem; font-weight: 800;" data-i18n="card_notif_rules">Notification & Alert Rules</h3>
            </div>

            <div class="flex flex-col gap-4 mb-6">
                <div class="flex justify-between items-center" style="padding-bottom: 12px; border-bottom: 1px solid rgba(255,255,255,0.08);">
                    <div>
                        <span style="font-weight: 700; display: block; color: var(--text-primary);" data-i18n="lbl_drift_alert">Model Drift Alert</span>
                        <span style="font-size: 0.8rem; color: var(--text-secondary);" data-i18n="desc_drift_alert">Notify when production accuracy drops below 85%</span>
                    </div>
                    <input type="checkbox" checked style="width: 22px; height: 22px;">
                </div>

                <div class="flex justify-between items-center" style="padding-bottom: 12px; border-bottom: 1px solid rgba(255,255,255,0.08);">
                    <div>
                        <span style="font-weight: 700; display: block; color: var(--text-primary);" data-i18n="lbl_outbreak_alert">Disease Outbreak Alert</span>
                        <span style="font-size: 0.8rem; color: var(--text-secondary);" data-i18n="desc_outbreak_alert">Trigger alert when single disease >50 scans in 24h</span>
                    </div>
                    <input type="checkbox" checked style="width: 22px; height: 22px;">
                </div>

                <div class="flex justify-between items-center">
                    <div>
                        <span style="font-weight: 700; display: block; color: var(--text-primary);" data-i18n="lbl_weekly_rep">Weekly Executive Report</span>
                        <span style="font-size: 0.8rem; color: var(--text-secondary);" data-i18n="desc_weekly_rep">Send automated analytical PDF report via email</span>
                    </div>
                    <input type="checkbox" checked style="width: 22px; height: 22px;">
                </div>
            </div>

            <button class="btn btn-secondary" onclick="alert('Notification rules updated successfully!')"><i class="fa-solid fa-bell"></i> <span data-i18n="btn_save_notif">Save Notification Rules</span></button>
        </div>
    </div>

    <!-- Right Column: Profile & Appearance -->
    <div class="flex flex-col gap-6">
        <!-- Admin Profile Card -->
        <div class="glass-card">
            <div class="flex items-center gap-2 mb-6">
                <i class="fa-solid fa-user-shield" style="color: var(--secondary-main); font-size: 1.25rem;"></i>
                <h3 style="font-size: 1.25rem; font-weight: 800;" data-i18n="card_admin_prof">Admin Profile & Security</h3>
            </div>

            <form onsubmit="handleProfileUpdate(event)" class="mb-6" style="padding-bottom: 24px; border-bottom: 1px dashed rgba(255,255,255,0.15);">
                <div class="form-group">
                    <label class="form-label" data-i18n="lbl_full_name">Full Name</label>
                    <input type="text" class="form-control" id="profileName" value="Admin User" required>
                </div>
                <div class="form-group">
                    <label class="form-label" data-i18n="lbl_email_addr">Email Address</label>
                    <input type="email" class="form-control" id="profileEmail" value="admin@plantsense.ai" required>
                </div>
                <button type="submit" class="btn btn-primary" id="saveProfileBtn"><i class="fa-solid fa-user-check"></i> <span data-i18n="btn_save_prof">Save Profile</span></button>
            </form>

            <h4 style="font-size: 1.1rem; font-weight: 800; margin-bottom: 16px; color: var(--text-primary);" data-i18n="lbl_change_pass">Change Password</h4>
            <form onsubmit="handlePasswordChange(event)">
                <div class="form-group">
                    <label class="form-label" data-i18n="lbl_curr_pass">Current Password</label>
                    <input type="password" class="form-control" id="oldPass" required placeholder="••••••••">
                </div>
                <div class="form-group">
                    <label class="form-label" data-i18n="lbl_new_pass">New Password</label>
                    <input type="password" class="form-control" id="newPass" required placeholder="••••••••">
                </div>
                <button type="submit" class="btn btn-secondary" id="savePassBtn"><i class="fa-solid fa-key"></i> <span data-i18n="btn_update_pass">Update Password</span></button>
            </form>
        </div>

        <!-- Appearance & Localization Card -->
        <div class="glass-card">
            <div class="flex items-center gap-2 mb-6">
                <i class="fa-solid fa-globe" style="color: var(--info); font-size: 1.25rem;"></i>
                <h3 style="font-size: 1.25rem; font-weight: 800;" data-i18n="card_app_local">Appearance & Localization</h3>
            </div>

            <div class="form-group mb-4">
                <label class="form-label" data-i18n="lbl_theme">Interface Theme</label>
                <select class="form-control" id="settingsTheme" onchange="toggleTheme(this.value)">
                    <option value="light">Light Mode (Glassmorphism Default)</option>
                    <option value="dark">Dark Mode (OLED Deep Night)</option>
                </select>
            </div>

            <div class="form-group mb-4">
                <label class="form-label" data-i18n="lbl_language">Language / Localization</label>
                <select class="form-control" id="settingsLang" onchange="setLanguage(this.value)">
                    <option value="en">English (US)</option>
                    <option value="hi">Hindi (हिन्दी)</option>
                    <option value="mr">Marathi (मराठी)</option>
                    <option value="es">Spanish (Español)</option>
                </select>
            </div>

            <div class="form-group mb-6">
                <label class="form-label" data-i18n="lbl_timezone">System Timezone</label>
                <select class="form-control">
                    <option value="ist" selected>(GMT+05:30) Indian Standard Time - Kolkata / Mumbai</option>
                    <option value="utc">(GMT+00:00) Universal Coordinated Time - UTC</option>
                    <option value="est">(GMT-05:00) Eastern Standard Time - New York</option>
                </select>
            </div>

            <button class="btn btn-secondary" onclick="alert('Localization preferences saved!')"><i class="fa-solid fa-globe"></i> <span data-i18n="btn_save_local">Save Localization</span></button>
        </div>
    </div>
</div>

<script>
async function loadProfile() {
    try {
        const user = await api.fetchApi('/auth/me');
        if (user) {
            if (user.name) document.getElementById('profileName').value = user.name;
            if (user.email) document.getElementById('profileEmail').value = user.email;
        }
        if (typeof setLanguage === 'function') setLanguage(localStorage.getItem('language') || 'en');
    } catch (e) {}
}

async function handleProfileUpdate(e) {
    e.preventDefault();
    const name = document.getElementById('profileName').value;
    const email = document.getElementById('profileEmail').value;
    const btn = document.getElementById('saveProfileBtn');
    
    try {
        btn.disabled = true;
        btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Saving...';
        await api.updateProfile(name, email);
        alert('Admin profile updated successfully!');
    } catch (err) {
        alert('Profile update failed: ' + err.message);
    } finally {
        btn.disabled = false;
        btn.innerHTML = '<i class="fa-solid fa-user-check"></i> <span data-i18n="btn_save_prof">Save Profile</span>';
        if (typeof setLanguage === 'function') setLanguage(localStorage.getItem('language') || 'en');
    }
}

async function handlePasswordChange(e) {
    e.preventDefault();
    const oldP = document.getElementById('oldPass').value;
    const newP = document.getElementById('newPass').value;
    const btn = document.getElementById('savePassBtn');

    try {
        btn.disabled = true;
        btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Updating...';
        await api.changePassword(oldP, newP);
        alert('Password changed successfully! Please use new password next time.');
        document.getElementById('oldPass').value = '';
        document.getElementById('newPass').value = '';
    } catch (err) {
        alert('Password update failed: ' + err.message);
    } finally {
        btn.disabled = false;
        btn.innerHTML = '<i class="fa-solid fa-key"></i> <span data-i18n="btn_update_pass">Update Password</span>';
        if (typeof setLanguage === 'function') setLanguage(localStorage.getItem('language') || 'en');
    }
}

function saveModelPrefs() {
    alert('Model preferences saved! Diagnostic confidence threshold updated to ' + document.getElementById('confSlider').value + '%.');
}

document.addEventListener('DOMContentLoaded', loadProfile);
</script>

<?php renderFooter(); ?>
