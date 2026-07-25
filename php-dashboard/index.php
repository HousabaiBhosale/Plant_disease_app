<?php
require_once 'layout.php';
renderHeader("System Command", "Real-Time Overview & AI Model Monitoring");
?>

<!-- Header Actions -->
<div class="flex justify-between items-center mb-6">
    <div class="flex items-center gap-2">
        <span class="badge badge-info"><i class="fa-solid fa-rotate"></i> <span data-i18n="badge_live_polling">Live Polling Active (5s)</span></span>
    </div>
    <div class="flex gap-4">
        <button class="btn btn-secondary" onclick="exportReport()">
            <i class="fa-solid fa-download"></i> <span data-i18n="btn_export">Export Report</span>
        </button>
        <button class="btn btn-primary" id="retrainBtn" onclick="triggerRetrain()">
            <i class="fa-solid fa-play"></i> <span data-i18n="btn_retrain">Retrain Model</span>
        </button>
    </div>
</div>

<!-- 5 Core Stats Cards -->
<div class="grid grid-cols-4 mb-6" style="grid-template-columns: repeat(5, minmax(0, 1fr));">
    <div class="card stat-card">
        <div class="flex justify-between items-start">
            <div class="stat-label" data-i18n="stat_total_scans">Total Scans</div>
            <div class="stat-icon" style="background-color: var(--primary-bg); color: var(--primary-main);">
                <i class="fa-solid fa-chart-pie"></i>
            </div>
        </div>
        <div class="stat-value" id="totalScans">-</div>
        <div><span class="stat-trend trend-up"><i class="fa-solid fa-arrow-up"></i> 12.5%</span> <span style="font-size: 0.75rem; color: var(--text-muted);" data-i18n="desc_live_edge">vs last month</span></div>
    </div>
    
    <div class="card stat-card">
        <div class="flex justify-between items-start">
            <div class="stat-label" data-i18n="stat_model_acc">Accuracy</div>
            <div class="stat-icon" style="background-color: var(--success-bg); color: var(--success);">
                <i class="fa-solid fa-gauge-high"></i>
            </div>
        </div>
        <div class="stat-value" id="accuracyRate">-</div>
        <div><span class="stat-trend trend-up"><i class="fa-solid fa-check"></i> Live</span> <span style="font-size: 0.75rem; color: var(--text-muted);" data-i18n="desc_prod_val">production model</span></div>
    </div>
    
    <div class="card stat-card">
        <div class="flex justify-between items-start">
            <div class="stat-label" data-i18n="stat_avg_conf">Confidence</div>
            <div class="stat-icon" style="background-color: var(--warning-bg); color: var(--warning);">
                <i class="fa-solid fa-brain"></i>
            </div>
        </div>
        <div class="stat-value" id="avgConfidence">-</div>
        <div><span class="stat-trend trend-up"><i class="fa-solid fa-minus"></i> Stable</span> <span style="font-size: 0.75rem; color: var(--text-muted);" data-i18n="desc_diag_cert">average score</span></div>
    </div>
    
    <div class="card stat-card">
        <div class="flex justify-between items-start">
            <div class="stat-label" data-i18n="stat_edge_inf">Edge Inference</div>
            <div class="stat-icon" style="background-color: var(--secondary-bg); color: var(--secondary-main);">
                <i class="fa-solid fa-mobile-screen-button"></i>
            </div>
        </div>
        <div class="stat-value" id="edgeInference">-</div>
        <div><span class="stat-trend trend-down"><i class="fa-solid fa-arrow-down"></i> 1.1%</span> <span style="font-size: 0.75rem; color: var(--text-muted);" data-i18n="desc_tflite_edge">local TFLite mode</span></div>
    </div>

    <div class="card stat-card">
        <div class="flex justify-between items-start">
            <div class="stat-label" data-i18n="stat_active_users">Active Users</div>
            <div class="stat-icon" style="background-color: var(--info-bg); color: var(--info);">
                <i class="fa-solid fa-users"></i>
            </div>
        </div>
        <div class="stat-value" id="activeUsers">-</div>
        <div><span class="stat-trend trend-up"><i class="fa-solid fa-arrow-up"></i> 5.8%</span> <span style="font-size: 0.75rem; color: var(--text-muted);" data-i18n="desc_contrib">contributing farmers</span></div>
    </div>
</div>

<!-- Disease Distribution & Model Intelligence -->
<div class="grid grid-cols-3 mb-6" style="grid-template-columns: 3fr 2fr;">
    <!-- Disease Distribution Chart -->
    <div class="glass-card flex flex-col justify-between">
        <div>
            <h3 style="font-size: 1.25rem; font-weight: 800; margin-bottom: 4px;" data-i18n="card_disease_dist">Disease Distribution & Volume</h3>
            <p style="color: var(--text-secondary); font-size: 0.85rem; margin-bottom: 20px;" data-i18n="desc_disease_dist">Top detected pathologies across monitored agricultural regions</p>
        </div>
        <div style="height: 300px; width: 100%; position: relative;">
            <canvas id="diseaseChart"></canvas>
        </div>
    </div>

    <!-- Model Intelligence Card -->
    <div class="glass-card flex flex-col justify-between">
        <div>
            <div class="flex items-center gap-2 mb-4">
                <i class="fa-solid fa-brain" style="color: var(--primary-main); font-size: 1.25rem;"></i>
                <h3 style="font-size: 1.25rem; font-weight: 800;" data-i18n="card_model_intel">Model Intelligence & Performance</h3>
            </div>
            
            <div class="flex flex-col gap-4">
                <div>
                    <div class="flex justify-between mb-1">
                        <span style="font-size: 0.9rem; font-weight: 600; color: var(--text-secondary);" data-i18n="acc_label">Production Model Accuracy</span>
                        <span style="font-size: 0.9rem; font-weight: 800; color: var(--text-primary);" id="modelAccText">-</span>
                    </div>
                    <div class="progress-bar-container">
                        <div class="progress-bar-fill" id="modelAccBar" style="width: 0%; background-color: var(--primary-main);"></div>
                    </div>
                </div>
                
                <div>
                    <div class="flex justify-between mb-1">
                        <span style="font-size: 0.9rem; font-weight: 600; color: var(--text-secondary);" data-i18n="conf_label">Average Diagnostic Confidence</span>
                        <span style="font-size: 0.9rem; font-weight: 800; color: var(--text-primary);" id="modelConfText">-</span>
                    </div>
                    <div class="progress-bar-container">
                        <div class="progress-bar-fill" id="modelConfBar" style="width: 0%; background-color: var(--success);"></div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Version Comparison Table -->
        <div style="background-color: var(--bg-paper); padding: 16px; border-radius: var(--radius-lg); border: 1px solid rgba(255,255,255,0.08); margin-top: 24px;">
            <span style="font-size: 0.75rem; font-weight: 700; color: var(--text-secondary); text-transform: uppercase; letter-spacing: 0.05em; display: block; margin-bottom: 8px;" data-i18n="desc_model_intel">Hybrid TFLite & Cloud API v2.4</span>
            <div class="flex justify-between items-center">
                <span style="font-weight: 800; font-size: 0.95rem;">Current Production Model</span>
                <div class="flex items-center gap-1">
                    <span style="font-weight: 800; color: var(--success); font-size: 0.95rem;" id="versionAccText">-</span>
                    <i class="fa-solid fa-arrow-trend-up" style="color: var(--success); font-size: 0.85rem;"></i>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Recent Scans Table & System Status -->
<div class="grid grid-cols-3" style="grid-template-columns: 3fr 1fr;">
    <!-- Recent Scans -->
    <div class="glass-card">
        <h3 style="font-size: 1.25rem; font-weight: 800; margin-bottom: 4px;" data-i18n="card_recent_scans">Recent Field Scans & Diagnostics</h3>
        <p style="color: var(--text-secondary); font-size: 0.85rem; margin-bottom: 20px;" data-i18n="desc_recent_scans">Real-time stream of farmer image submissions from mobile edge devices</p>
        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th data-i18n="th_timestamp">Date</th>
                        <th data-i18n="th_crop_label">Disease Detected</th>
                        <th data-i18n="th_confidence">Confidence</th>
                        <th data-i18n="th_engine">Mode</th>
                        <th data-i18n="th_location">Location</th>
                        <th>User</th>
                    </tr>
                </thead>
                <tbody id="recentScansBody">
                    <tr><td colspan="6" style="text-align: center; padding: 32px; color: var(--text-muted);">Loading recent scans...</td></tr>
                </tbody>
            </table>
        </div>
    </div>

    <!-- System Status Card -->
    <div class="glass-card flex flex-col justify-between">
        <div>
            <div class="flex items-center gap-2 mb-4">
                <i class="fa-solid fa-server" style="color: var(--success); font-size: 1.25rem;"></i>
                <h3 style="font-size: 1.25rem; font-weight: 800;" data-i18n="card_sys_status">System Status & Edge Diagnostics</h3>
            </div>
            
            <div class="flex flex-col gap-4">
                <div class="flex justify-between items-center" style="padding-bottom: 12px; border-bottom: 1px dashed rgba(255,255,255,0.1);">
                    <span style="font-weight: 600; font-size: 0.9rem; color: var(--text-secondary);">API Server</span>
                    <span class="badge badge-success"><i class="fa-solid fa-check"></i> Online</span>
                </div>
                
                <div class="flex justify-between items-center" style="padding-bottom: 12px; border-bottom: 1px dashed rgba(255,255,255,0.1);">
                    <span style="font-weight: 600; font-size: 0.9rem; color: var(--text-secondary);">MySQL Database</span>
                    <span class="badge badge-success" id="dbStatusBadge"><i class="fa-solid fa-check"></i> Connected</span>
                </div>
                
                <div class="flex justify-between items-center" style="padding-bottom: 12px; border-bottom: 1px dashed rgba(255,255,255,0.1);">
                    <span style="font-weight: 600; font-size: 0.9rem; color: var(--text-secondary);">AI Model Engine</span>
                    <span class="badge badge-info" id="modelStatusBadge"><i class="fa-solid fa-brain"></i> Loaded</span>
                </div>

                <div class="flex justify-between items-center">
                    <span style="font-weight: 600; font-size: 0.9rem; color: var(--text-secondary);">Storage Pool</span>
                    <span style="font-weight: 700; font-size: 0.9rem; color: var(--text-primary);">68% Free</span>
                </div>
            </div>
        </div>

        <div style="background-color: var(--success-bg); padding: 12px 16px; border-radius: var(--radius-md); border: 1px solid rgba(16, 185, 129, 0.3); margin-top: 24px;">
            <div class="flex items-center gap-2">
                <span class="status-dot"></span>
                <span style="font-size: 0.85rem; font-weight: 700; color: var(--success);" data-i18n="desc_sys_status">Live connection health across cloud servers and edge devices</span>
            </div>
        </div>
    </div>
</div>

<script>
let diseaseChartInstance = null;

async function loadDashboardData() {
    try {
        const [stats, modelMetrics, predictions, health] = await Promise.all([
            api.getStats(30).catch(() => null),
            api.getModelMetrics().catch(() => null),
            api.getPredictions(1, 10).catch(() => null),
            api.getSystemHealth().catch(() => null)
        ]);
        
        if (stats) {
            document.getElementById('totalScans').textContent = stats.total_predictions ? stats.total_predictions.toLocaleString() : '0';
            document.getElementById('accuracyRate').textContent = stats.feedback && stats.feedback.accuracy ? stats.feedback.accuracy : '0.0%';
            document.getElementById('avgConfidence').textContent = stats.avg_confidence || '0.0%';
            document.getElementById('edgeInference').textContent = stats.local_predictions ? stats.local_predictions.toLocaleString() : '0';
            document.getElementById('activeUsers').textContent = stats.unique_users ? stats.unique_users.toLocaleString() : '0';
            
            // Model Intelligence bars
            const confVal = parseFloat(stats.avg_confidence) || 0;
            document.getElementById('modelConfText').textContent = stats.avg_confidence || '0.0%';
            document.getElementById('modelConfBar').style.width = Math.min(100, confVal) + '%';
            
            // Disease Distribution Chart
            if (stats.top_diseases && stats.top_diseases.length > 0) {
                const labels = stats.top_diseases.map(d => {
                    const parts = d.disease.split('___');
                    return (parts[1] || d.disease).replace(/_/g, ' ');
                });
                const data = stats.top_diseases.map(d => d.count);
                
                const ctx = document.getElementById('diseaseChart').getContext('2d');
                if (diseaseChartInstance) diseaseChartInstance.destroy();
                
                diseaseChartInstance = new Chart(ctx, {
                    type: 'bar',
                    data: {
                        labels: labels,
                        datasets: [{
                            label: 'Detections',
                            data: data,
                            backgroundColor: '#2563EB',
                            hoverBackgroundColor: '#1D4ED8',
                            borderRadius: 6
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: { display: false }
                        },
                        scales: {
                            y: { beginAtZero: true, grid: { color: '#F1F5F9' } },
                            x: { grid: { display: false } }
                        }
                    }
                });
            }
        }
        
        if (modelMetrics) {
            const accVal = parseFloat(modelMetrics.accuracy) || 0;
            document.getElementById('modelAccText').textContent = modelMetrics.accuracy || '0.0%';
            document.getElementById('modelAccBar').style.width = Math.min(100, accVal) + '%';
            document.getElementById('versionAccText').textContent = modelMetrics.accuracy || '0.0%';
        }
        
        if (predictions && predictions.data) {
            const tbody = document.getElementById('recentScansBody');
            if (predictions.data.length === 0) {
                tbody.innerHTML = '<tr><td colspan="6" style="text-align: center; padding: 24px; color: var(--text-muted);" data-i18n="empty_scans">No field scans recorded yet.</td></tr>';
            } else {
                tbody.innerHTML = predictions.data.map(p => {
                    const dateStr = p.created_at ? new Date(p.created_at).toLocaleDateString() : 'N/A';
                    const diseaseName = (p.predicted_disease?.split('___').pop() || p.predicted_disease || 'Unknown').replace(/_/g, ' ');
                    const confPercent = p.confidence ? (p.confidence * 100).toFixed(1) + '%' : '0.0%';
                    const mode = p.inference_mode || 'local';
                    const modeClass = mode === 'cloud' ? 'badge-warning' : 'badge-success';
                    const user = p.user_id || 'Anonymous';
                    
                    let locStr = '<span style="color: var(--text-muted);" data-i18n="unknown_location">Unknown</span>';
                    if (p.device_info) {
                        if (p.device_info.location) {
                            locStr = `<span style="font-size: 0.85rem;">📍 ${p.device_info.location}</span>`;
                        } else if (p.device_info.latitude && p.device_info.longitude) {
                            const lat = Number(p.device_info.latitude).toFixed(2);
                            const lng = Number(p.device_info.longitude).toFixed(2);
                            locStr = `<span style="font-size: 0.85rem;">📍 ${lat}° N, ${lng}° E</span>`;
                        }
                    }
                    
                    return `
                        <tr>
                            <td style="font-weight: 600;">${dateStr}</td>
                            <td style="font-weight: 700; color: var(--text-primary);">${diseaseName}</td>
                            <td><span class="badge badge-info" style="background-color: #EFF6FF; color: #2563EB;">${confPercent}</span></td>
                            <td><span class="badge ${modeClass}" style="text-transform: capitalize;">${mode}</span></td>
                            <td>${locStr}</td>
                            <td style="color: var(--text-secondary);">${user}</td>
                        </tr>
                    `;
                }).join('');
            }
        }
        
        if (health) {
            if (health.database !== 'connected') {
                const dbBadge = document.getElementById('dbStatusBadge');
                dbBadge.className = 'badge badge-error';
                dbBadge.innerHTML = '<i class="fa-solid fa-xmark"></i> Disconnected';
            }
        }
        
        // Re-apply current language translations to ensure newly rendered elements or refreshed texts get translated!
        if (typeof setLanguage === 'function') {
            setLanguage(localStorage.getItem('language') || 'en');
        }
    } catch (err) {
        console.error("Dashboard error:", err);
    }
}

async function triggerRetrain() {
    const btn = document.getElementById('retrainBtn');
    try {
        btn.disabled = true;
        btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Retraining...';
        await api.retrainModel();
        alert('Model retraining triggered successfully!');
    } catch (err) {
        alert('Failed to trigger retraining: ' + err.message);
    } finally {
        btn.disabled = false;
        btn.innerHTML = '<i class="fa-solid fa-play"></i> <span data-i18n="btn_retrain">Retrain Model</span>';
        if (typeof setLanguage === 'function') setLanguage(localStorage.getItem('language') || 'en');
    }
}

function exportReport() {
    alert("Generating System Summary Report (PDF)... Download will begin shortly.");
}

document.addEventListener('DOMContentLoaded', () => {
    loadDashboardData();
    setInterval(loadDashboardData, 5000); // 5s live polling exactly like React
});
</script>

<?php renderFooter(); ?>
