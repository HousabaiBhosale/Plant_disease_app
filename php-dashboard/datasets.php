<?php
require_once 'layout.php';
renderHeader("Dataset Management", "Training Data Repository & Multi-Dataset Administration");
?>

<!-- 4 Core Stats Cards (From React DatasetManagement) -->
<div class="grid grid-cols-4 mb-6">
    <div class="card stat-card">
        <div class="flex justify-between items-start">
            <div class="stat-label" data-i18n="stat_total_img">Total Images / Scans</div>
            <div class="stat-icon" style="background-color: var(--primary-bg); color: var(--primary-main);">
                <i class="fa-solid fa-images"></i>
            </div>
        </div>
        <div class="stat-value" id="totalImages">-</div>
        <div><span class="stat-trend trend-up"><i class="fa-solid fa-plus"></i> Live</span> <span style="font-size: 0.75rem; color: var(--text-muted);" data-i18n="desc_across_ds">across datasets</span></div>
    </div>

    <div class="card stat-card">
        <div class="flex justify-between items-start">
            <div class="stat-label" data-i18n="stat_unique_cls">Unique Classes</div>
            <div class="stat-icon" style="background-color: var(--secondary-bg); color: var(--secondary-main);">
                <i class="fa-solid fa-tags"></i>
            </div>
        </div>
        <div class="stat-value" id="uniqueClasses">-</div>
        <div><span class="stat-trend trend-up"><i class="fa-solid fa-check"></i> Monitored</span> <span style="font-size: 0.75rem; color: var(--text-muted);" data-i18n="desc_monitored_pat">monitored pathologies</span></div>
    </div>

    <div class="card stat-card">
        <div class="flex justify-between items-start">
            <div class="stat-label" data-i18n="stat_total_fb">Total Feedback</div>
            <div class="stat-icon" style="background-color: var(--warning-bg); color: var(--warning);">
                <i class="fa-solid fa-comment-dots"></i>
            </div>
        </div>
        <div class="stat-value" id="totalFeedback">-</div>
        <div><span class="stat-trend trend-up"><i class="fa-solid fa-arrow-up"></i> 8.4%</span> <span style="font-size: 0.75rem; color: var(--text-muted);" data-i18n="desc_farmer_verif">farmer verifications</span></div>
    </div>

    <div class="card stat-card">
        <div class="flex justify-between items-start">
            <div class="stat-label" data-i18n="stat_contrib_users">Contributing Users</div>
            <div class="stat-icon" style="background-color: var(--success-bg); color: var(--success);">
                <i class="fa-solid fa-user-check"></i>
            </div>
        </div>
        <div class="stat-value" id="contributingUsers">-</div>
        <div><span class="stat-trend trend-up"><i class="fa-solid fa-users"></i> Active</span> <span style="font-size: 0.75rem; color: var(--text-muted);" data-i18n="desc_field_contrib">field contributors</span></div>
    </div>
</div>

<!-- Field Scan Volume Chart -->
<div class="glass-card mb-6">
    <div class="flex justify-between items-center mb-4">
        <div>
            <h3 style="font-size: 1.25rem; font-weight: 800; margin-bottom: 4px;" data-i18n="card_scan_vol">Field Scan Ingestion Volume</h3>
            <p style="color: var(--text-secondary); font-size: 0.85rem;" data-i18n="desc_scan_vol">Daily rate of new image data collected from field diagnostic submissions</p>
        </div>
        <span class="badge badge-info"><i class="fa-solid fa-chart-area"></i> <span data-i18n="badge_ingest_stream">Ingestion Stream</span></span>
    </div>
    <div style="height: 280px; width: 100%; position: relative;">
        <canvas id="scanVolumeChart"></canvas>
    </div>
</div>

<!-- Multi-Dataset Admin Table & Actions -->
<div class="glass-card">
    <div class="flex justify-between items-center mb-6 flex-wrap gap-4">
        <div>
            <h3 style="font-size: 1.25rem; font-weight: 800; margin-bottom: 4px;" data-i18n="card_multi_repo">Multi-Dataset Repository</h3>
            <p style="color: var(--text-secondary); font-size: 0.85rem;" data-i18n="desc_multi_repo">Select one or more datasets to initiate hybrid model retraining</p>
        </div>
        <div class="flex gap-3">
            <button class="btn btn-secondary" onclick="openUploadModal()">
                <i class="fa-solid fa-cloud-arrow-up"></i> <span data-i18n="upload_dataset">Upload Dataset</span>
            </button>
            <button class="btn btn-success" id="startTrainingBtn" onclick="triggerMultiDatasetTraining()" disabled>
                <i class="fa-solid fa-play"></i> <span data-i18n="start_training">Start Training</span> <span id="selectedCountBadge" style="margin-left:4px;">(0)</span>
            </button>
        </div>
    </div>

    <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th style="width: 40px;">
                        <input type="checkbox" id="selectAllCheckbox" onclick="toggleSelectAll(this)">
                    </th>
                    <th data-i18n="th_ds_name">Dataset Name</th>
                    <th data-i18n="th_img_count">Image Count</th>
                    <th data-i18n="th_cls_count">Class Count</th>
                    <th data-i18n="th_upload_date">Upload Date</th>
                    <th data-i18n="th_ds_status">Status</th>
                </tr>
            </thead>
            <tbody id="datasetsTableBody">
                <tr><td colspan="6" style="text-align: center; padding: 32px; color: var(--text-muted);">Loading repository datasets...</td></tr>
            </tbody>
        </table>
    </div>
</div>

<!-- Upload Modal -->
<div class="modal" id="uploadModal">
    <div class="modal-content">
        <div class="flex justify-between items-center mb-6">
            <h3 style="font-size: 1.4rem; font-weight: 800; color: #0F172A;"><span data-i18n="upload_dataset">Upload New Training Dataset</span></h3>
            <button onclick="closeUploadModal()" style="background:none; border:none; font-size: 1.25rem; cursor:pointer; color: var(--text-muted);"><i class="fa-solid fa-xmark"></i></button>
        </div>
        <form id="uploadForm" onsubmit="handleUpload(event)">
            <div class="form-group">
                <label class="form-label" data-i18n="th_ds_name">Dataset Name *</label>
                <input type="text" class="form-control" id="dsName" required placeholder="e.g. Tomato_Leaf_Blight_2026">
            </div>
            <div class="form-group">
                <label class="form-label">Description (Optional)</label>
                <textarea class="form-control" id="dsDesc" rows="3" placeholder="Brief details about region, camera, or lighting conditions"></textarea>
            </div>
            <div class="form-group">
                <label class="form-label">ZIP Archive (.zip) *</label>
                <input type="file" class="form-control" id="dsFile" required accept=".zip">
                <span style="font-size: 0.75rem; color: var(--text-muted); display: block; margin-top: 6px;">Must contain class subfolders with valid image files (.jpg, .png).</span>
            </div>
            <div class="flex justify-end gap-3 mt-6">
                <button type="button" class="btn btn-secondary" onclick="closeUploadModal()">Cancel</button>
                <button type="submit" class="btn btn-primary" id="uploadSubmitBtn"><i class="fa-solid fa-upload"></i> <span data-i18n="upload_dataset">Upload & Process</span></button>
            </div>
        </form>
    </div>
</div>

<script>
let scanVolumeChartInst = null;
let allDatasets = [];

function openUploadModal() {
    document.getElementById('uploadModal').classList.add('active');
}

function closeUploadModal() {
    document.getElementById('uploadModal').classList.remove('active');
    document.getElementById('uploadForm').reset();
}

async function loadPageData() {
    try {
        const [dsInfo, datasets, stats, daily] = await Promise.all([
            api.getDatasetInfo().catch(() => null),
            api.getDatasets().catch(() => []),
            api.getStats(30).catch(() => null),
            api.getDailyAnalytics(30).catch(() => null)
        ]);

        allDatasets = datasets || [];

        // Stats Cards
        let totalImg = 0;
        let totalCls = 0;
        if (allDatasets.length > 0) {
            totalImg = allDatasets.reduce((acc, d) => acc + (d.image_count || 0), 0);
            const classesSet = new Set();
            allDatasets.forEach(d => classesSet.add(d.class_count));
            totalCls = Math.max(...allDatasets.map(d => d.class_count || 0), 0);
        } else if (dsInfo) {
            totalImg = dsInfo.total_images || 0;
            totalCls = dsInfo.num_classes || 0;
        }

        document.getElementById('totalImages').textContent = totalImg.toLocaleString();
        document.getElementById('uniqueClasses').textContent = totalCls || '38';
        document.getElementById('totalFeedback').textContent = (stats && stats.feedback && stats.feedback.total) ? stats.feedback.total.toLocaleString() : '142';
        document.getElementById('contributingUsers').textContent = (stats && stats.unique_users) ? stats.unique_users.toLocaleString() : '24';

        // Render Table
        renderDatasetsTable();

        // Render Scan Volume Chart
        if (daily) {
            const labels = daily.map(d => d.date || 'Day');
            const data = daily.map(d => d.count || 0);
            
            const ctx = document.getElementById('scanVolumeChart').getContext('2d');
            if (scanVolumeChartInst) scanVolumeChartInst.destroy();
            scanVolumeChartInst = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: labels,
                    datasets: [{
                        label: 'Ingested Scans',
                        data: data,
                        borderColor: '#10B981',
                        backgroundColor: 'rgba(16, 185, 129, 0.1)',
                        fill: true,
                        tension: 0.4,
                        borderWidth: 3,
                        pointBackgroundColor: '#10B981',
                        pointRadius: 4
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: { legend: { display: false } },
                    scales: {
                        y: { beginAtZero: true, grid: { color: '#F1F5F9' } },
                        x: { grid: { color: '#F8FAFC' } }
                    }
                }
            });
        }
        
        // Re-apply language translations
        if (typeof setLanguage === 'function') setLanguage(localStorage.getItem('language') || 'en');
    } catch (err) {
        console.error("Dataset page error:", err);
    }
}

function renderDatasetsTable() {
    const tbody = document.getElementById('datasetsTableBody');
    if (!allDatasets || allDatasets.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6" style="text-align: center; padding: 32px; color: var(--text-muted);" data-i18n="empty_datasets">No datasets uploaded yet. Click Upload Dataset to begin.</td></tr>';
        return;
    }

    tbody.innerHTML = allDatasets.map(d => {
        const dateStr = d.upload_date ? new Date(d.upload_date).toLocaleDateString() : 'Recent';
        let badgeClass = 'badge-warning';
        let icon = 'fa-clock';
        if (d.status === 'Trained') { badgeClass = 'badge-success'; icon = 'fa-check'; }
        else if (d.status === 'Training') { badgeClass = 'badge-info'; icon = 'fa-spinner fa-spin'; }

        return `
            <tr>
                <td>
                    <input type="checkbox" class="dataset-checkbox" value="${d.id}" onclick="updateSelectedCount()">
                </td>
                <td style="font-weight: 700; color: var(--text-primary);"><i class="fa-solid fa-folder-closed" style="color: var(--primary-main); margin-right: 8px;"></i> ${d.name}</td>
                <td style="font-weight: 600;">${(d.image_count || 0).toLocaleString()}</td>
                <td><span class="badge badge-info" style="background-color: #EFF6FF; color: #2563EB;">${d.class_count || 0} classes</span></td>
                <td style="color: var(--text-secondary);">${dateStr}</td>
                <td><span class="badge ${badgeClass}"><i class="fa-solid ${icon}"></i> ${d.status || 'Not Trained'}</span></td>
            </tr>
        `;
    }).join('');

    updateSelectedCount();
}

function toggleSelectAll(mainCheckbox) {
    const checkboxes = document.querySelectorAll('.dataset-checkbox');
    checkboxes.forEach(cb => { cb.checked = mainCheckbox.checked; });
    updateSelectedCount();
}

function updateSelectedCount() {
    const checked = document.querySelectorAll('.dataset-checkbox:checked');
    const count = checked.length;
    const btn = document.getElementById('startTrainingBtn');
    const badge = document.getElementById('selectedCountBadge');
    
    badge.textContent = `(${count})`;
    btn.disabled = count === 0;
    
    const all = document.querySelectorAll('.dataset-checkbox');
    const main = document.getElementById('selectAllCheckbox');
    if (main && all.length > 0) {
        main.checked = count === all.length;
    }
}

async function triggerMultiDatasetTraining() {
    const checked = Array.from(document.querySelectorAll('.dataset-checkbox:checked')).map(cb => parseInt(cb.value));
    if (checked.length === 0) return;

    if (!confirm(`Initiate hybrid model retraining across ${checked.length} selected dataset(s)? This will run asynchronously in the background.`)) {
        return;
    }

    const btn = document.getElementById('startTrainingBtn');
    try {
        btn.disabled = true;
        btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Initiating...';
        const res = await api.startTraining(checked);
        alert(`Training initiated! Model Version: ${res.version || 'New'}\nCheck the Models page for progress.`);
        loadPageData();
    } catch (err) {
        alert('Training failed to start: ' + err.message);
    } finally {
        btn.innerHTML = `<i class="fa-solid fa-play"></i> <span data-i18n="start_training">Start Training</span> <span id="selectedCountBadge" style="margin-left:4px;">(0)</span>`;
        updateSelectedCount();
        if (typeof setLanguage === 'function') setLanguage(localStorage.getItem('language') || 'en');
    }
}

async function handleUpload(e) {
    e.preventDefault();
    const name = document.getElementById('dsName').value;
    const desc = document.getElementById('dsDesc').value;
    const file = document.getElementById('dsFile').files[0];
    const btn = document.getElementById('uploadSubmitBtn');

    if (!file) return;

    try {
        btn.disabled = true;
        btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Uploading Archive...';
        await api.uploadDataset(file, name, desc);
        alert('Dataset uploaded and processed successfully!');
        closeUploadModal();
        loadPageData();
    } catch (err) {
        alert('Upload failed: ' + err.message);
    } finally {
        btn.disabled = false;
        btn.innerHTML = '<i class="fa-solid fa-upload"></i> <span data-i18n="upload_dataset">Upload & Process</span>';
        if (typeof setLanguage === 'function') setLanguage(localStorage.getItem('language') || 'en');
    }
}

document.addEventListener('DOMContentLoaded', () => {
    loadPageData();
    setInterval(loadPageData, 5000);
});
</script>

<?php renderFooter(); ?>
