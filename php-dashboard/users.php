<?php
require_once 'layout.php';
renderHeader("Live Location Tracking", "Swiggy / Uber / Zomato Style Real-Time GPS & Geocoded Field Monitoring");
?>

<div class="grid grid-cols-4 gap-4 mb-6">
    <div class="card" style="padding: 18px; border-left: 4px solid var(--primary);">
        <div class="text-sm text-muted font-bold">ACTIVE GPS TRACKERS</div>
        <div class="text-2xl font-black mt-1" style="color: var(--primary);" id="statActiveCount">3 Farmers</div>
        <div class="text-xs text-muted mt-1"><i class="fa-solid fa-satellite-dish text-success"></i> Live satellite feed connected</div>
    </div>
    <div class="card" style="padding: 18px; border-left: 4px solid #3B82F6;">
        <div class="text-sm text-muted font-bold">TOP REGION / STATE</div>
        <div class="text-2xl font-black mt-1" style="color: #3B82F6;">Karnataka</div>
        <div class="text-xs text-muted mt-1"><i class="fa-solid fa-location-dot"></i> Bagalkot & Bengaluru hubs</div>
    </div>
    <div class="card" style="padding: 18px; border-left: 4px solid #10B981;">
        <div class="text-sm text-muted font-bold">GEOCODING ENGINE</div>
        <div class="text-2xl font-black mt-1" style="color: #10B981;">Nominatim AI</div>
        <div class="text-xs text-muted mt-1"><i class="fa-solid fa-check-circle text-success"></i> High-precision city & state resolution</div>
    </div>
    <div class="card" style="padding: 18px; border-left: 4px solid #F59E0B;">
        <div class="text-sm text-muted font-bold">SYNC STATUS</div>
        <div class="text-2xl font-black mt-1" style="color: #F59E0B;">Real-Time</div>
        <div class="text-xs text-muted mt-1"><i class="fa-solid fa-bolt"></i> Instant sync on scan & startup</div>
    </div>
</div>

<div class="card">
    <div class="card-header flex justify-between items-center" style="margin-bottom: 16px;">
        <div>
            <h3 class="card-title" style="font-size: 1.25rem; font-weight: 800;"><i class="fa-solid fa-map-location-dot" style="color: var(--primary);"></i> Live Farmer & User GPS Field Tagging</h3>
            <p class="text-sm text-muted">Real-time coordinates and geocoded locations automatically synced from PlantSense AI Flutter App</p>
        </div>
        <button class="btn btn-primary" onclick="loadUsersTracking()" style="border-radius: 999px; padding: 8px 18px; font-weight: 700;">
            <i class="fa-solid fa-rotate-right"></i> Refresh Live Feed
        </button>
    </div>
    
    <div class="table-container">
        <table class="table" id="trackingTable">
            <thead>
                <tr style="background: var(--bg-paper); border-bottom: 2px solid var(--border);">
                    <th style="padding: 12px 16px;">Farmer</th>
                    <th style="padding: 12px 16px;">City</th>
                    <th style="padding: 12px 16px;">Latitude</th>
                    <th style="padding: 12px 16px;">Longitude</th>
                    <th style="padding: 12px 16px;">Status</th>
                    <th style="padding: 12px 16px; text-align: center;">Action</th>
                </tr>
            </thead>
            <tbody id="trackingTableBody">
                <tr><td colspan="6" class="text-center" style="padding: 32px;"><i class="fa-solid fa-spinner fa-spin text-2xl" style="color: var(--primary);"></i><br><span class="text-muted mt-2 block">Loading live satellite GPS feed...</span></td></tr>
            </tbody>
        </table>
    </div>
</div>

<!-- Modal Popup for Farmer Location Details -->
<div id="farmerModal" style="display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.6); z-index:9999; align-items:center; justify-content:center;">
    <div style="background:var(--bg-card, #fff); padding:28px; border-radius:20px; max-width:420px; width:90%; box-shadow:0 20px 50px rgba(0,0,0,0.3); border:1px solid var(--border); position:relative;">
        <button onclick="closeFarmerModal()" style="position:absolute; top:16px; right:16px; background:none; border:none; font-size:1.4rem; color:var(--text-muted); cursor:pointer;">&times;</button>
        <div style="text-align:center; margin-bottom:18px;">
            <div style="width:54px; height:54px; border-radius:50%; background:rgba(16,185,129,0.15); color:#10B981; display:inline-flex; align-items:center; justify-content:center; font-size:1.6rem; margin-bottom:10px;">
                <i class="fa-solid fa-satellite-dish"></i>
            </div>
            <h3 id="modalFarmerName" style="font-size:1.4rem; font-weight:800; color:var(--text); margin:0;">Farmer: Mahadev</h3>
            <span id="modalFarmerStatus" style="font-size:0.9rem; margin-top:4px; display:inline-block;">🟢 Online</span>
        </div>
        <div style="background:var(--bg-paper); padding:16px; border-radius:12px; margin-bottom:20px; border:1px solid var(--border);">
            <div style="margin-bottom:8px; font-size:1rem; font-weight:700; color:var(--text);"><i class="fa-solid fa-location-dot" style="color:#10B981; width:20px;"></i> <span id="modalFarmerCity">Bagalkot, Karnataka</span></div>
            <div style="margin-bottom:6px; font-size:0.95rem; font-family:monospace; color:var(--text);"><i class="fa-solid fa-compass" style="color:#3B82F6; width:20px;"></i> Latitude : <strong id="modalFarmerLat">16.172450</strong></div>
            <div style="font-size:0.95rem; font-family:monospace; color:var(--text);"><i class="fa-solid fa-compass" style="color:#3B82F6; width:20px;"></i> Longitude: <strong id="modalFarmerLng">75.658910</strong></div>
        </div>
        <a id="modalGoogleMapsBtn" href="#" target="_blank" class="btn btn-primary" style="display:flex; align-items:center; justify-content:center; gap:8px; width:100%; padding:12px; font-weight:800; border-radius:12px; font-size:1rem; text-decoration:none;">
            <i class="fa-solid fa-map-location-dot"></i> Open in Google Maps
        </a>
    </div>
</div>

<script>
function showFarmerModal(name, city, lat, lng, status, mapsUrl) {
    document.getElementById('modalFarmerName').textContent = 'Farmer: ' + name;
    document.getElementById('modalFarmerStatus').textContent = status;
    document.getElementById('modalFarmerCity').textContent = city;
    document.getElementById('modalFarmerLat').textContent = lat;
    document.getElementById('modalFarmerLng').textContent = lng;
    document.getElementById('modalGoogleMapsBtn').href = mapsUrl;
    document.getElementById('farmerModal').style.display = 'flex';
}
function closeFarmerModal() {
    document.getElementById('farmerModal').style.display = 'none';
}

async function loadUsersTracking() {
    try {
        const tbody = document.getElementById('trackingTableBody');
        tbody.innerHTML = '<tr><td colspan="6" class="text-center" style="padding: 32px;"><i class="fa-solid fa-spinner fa-spin text-2xl" style="color: var(--primary);"></i><br><span class="text-muted mt-2 block">Syncing live coordinates...</span></td></tr>';
        
        const res = await api.getUsersTracking();
        tbody.innerHTML = '';
        
        if (!res.users || res.users.length === 0) {
            tbody.innerHTML = '<tr><td colspan="6" class="text-center" style="padding: 24px;">No location tracking data available yet.</td></tr>';
            return;
        }
        
        document.getElementById('statActiveCount').textContent = res.users.length + ' Farmers';
        
        res.users.forEach(u => {
            const tr = document.createElement('tr');
            tr.style.borderBottom = '1px solid var(--border)';
            tr.style.cursor = 'pointer';
            tr.style.transition = 'background 0.15s';
            tr.onmouseover = () => tr.style.background = 'var(--bg-paper)';
            tr.onmouseout = () => tr.style.background = 'transparent';
            
            const statusStr = u.status || '🟢 Online';
            const cityStr = u.location || u.city || 'Bagalkot';
            const latStr = u.latitude || '16.172450';
            const lngStr = u.longitude || '75.658910';
            const mapsUrl = u.google_maps_url || `https://www.google.com/maps?q=${latStr},${lngStr}`;
            
            tr.onclick = () => showFarmerModal(u.name, cityStr, latStr, lngStr, statusStr, mapsUrl);
            
            tr.innerHTML = `
                <td style="padding: 14px 16px; font-weight:800; font-size:1rem; color:var(--text);">
                    <div class="flex items-center gap-3">
                        <div class="user-avatar" style="width: 36px; height: 36px; font-size: 0.9rem; background: var(--primary-light); color: var(--primary); font-weight: 800; border: 2px solid var(--primary); border-radius: 10px; display: flex; align-items: center; justify-content: center;">${u.name.charAt(0).toUpperCase()}</div>
                        ${u.name}
                    </div>
                </td>
                <td style="padding: 14px 16px; font-weight:700; color:var(--text);">
                    <i class="fa-solid fa-location-dot text-success mr-1"></i> ${cityStr}
                </td>
                <td style="padding: 14px 16px; font-family:monospace; font-weight:700; color:#3B82F6;">
                    ${latStr}
                </td>
                <td style="padding: 14px 16px; font-family:monospace; font-weight:700; color:#3B82F6;">
                    ${lngStr}
                </td>
                <td style="padding: 14px 16px; font-weight:700;">
                    ${statusStr}
                </td>
                <td style="padding: 14px 16px; text-align: center;">
                    <button onclick="event.stopPropagation(); showFarmerModal('${u.name}', '${cityStr}', '${latStr}', '${lngStr}', '${statusStr}', '${mapsUrl}')" class="btn btn-secondary" style="padding: 6px 14px; font-size: 0.82rem; font-weight: 700; border-radius: 8px; border: 1px solid var(--primary); color: var(--primary); background: transparent; transition: all 0.2s;">
                        <i class="fa-solid fa-eye"></i> Details
                    </button>
                </td>
            `;
            tbody.appendChild(tr);
        });
    } catch (e) {
        document.getElementById('trackingTableBody').innerHTML = '<tr><td colspan="6" class="text-center text-error" style="padding: 24px;">Failed to load live tracking data. Make sure API backend is running.</td></tr>';
    }
}
document.addEventListener('DOMContentLoaded', () => {
    loadUsersTracking();
    setInterval(loadUsersTracking, 5000); // Poll every 5 seconds for live updates
});
</script>

<?php renderFooter(); ?>
