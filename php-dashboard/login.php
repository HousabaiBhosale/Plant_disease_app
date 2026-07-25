<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Login - PlantSense AI</title>
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script src="assets/js/api.js"></script>
    <style>
        body {
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            background: linear-gradient(135deg, #0F172A 0%, #1E293B 50%, #0F172A 100%);
            margin: 0;
            padding: 20px;
        }
        .login-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(24px);
            -webkit-backdrop-filter: blur(24px);
            border-radius: var(--radius-xl);
            padding: 48px 40px;
            width: 100%;
            max-width: 440px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
            border: 1px solid rgba(255, 255, 255, 0.2);
            text-align: center;
        }
        .logo-wrapper {
            width: 64px;
            height: 64px;
            border-radius: var(--radius-xl);
            background: linear-gradient(135deg, #2563EB 0%, #10B981 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 32px;
            margin: 0 auto 24px;
            box-shadow: 0 10px 25px -5px rgba(37, 99, 235, 0.4);
        }
    </style>
</head>
<body>

<div class="login-card">
    <div class="logo-wrapper">
        <i class="fa-solid fa-leaf"></i>
    </div>
    <h2 style="font-size: 1.75rem; font-weight: 800; color: #0F172A; margin-bottom: 8px;">PlantSense AI</h2>
    <p style="color: var(--text-secondary); font-size: 0.95rem; margin-bottom: 32px;">Admin Command Portal</p>

    <div id="errorBox" style="display: none; background-color: var(--error-bg); color: var(--error); padding: 12px; border-radius: var(--radius-md); border: 1px solid #FECACA; margin-bottom: 20px; font-size: 0.9rem; text-align: left;">
        <i class="fa-solid fa-circle-exclamation" style="margin-right: 6px;"></i> <span id="errorText"></span>
    </div>

    <form id="loginForm" onsubmit="handleLogin(event)" style="text-align: left;">
        <div class="form-group mb-4">
            <label class="form-label">Email Address</label>
            <input type="email" class="form-control" id="email" required placeholder="admin@gmail.com" value="admin@gmail.com">
        </div>

        <div class="form-group mb-6">
            <label class="form-label">Password</label>
            <input type="password" class="form-control" id="password" required placeholder="••••••••" value="admin123">
        </div>

        <button type="submit" class="btn btn-primary w-full" id="loginBtn" style="padding: 14px; font-size: 1rem;">
            <i class="fa-solid fa-right-to-bracket"></i> Sign In to Portal
        </button>
    </form>

    <div style="margin-top: 28px; padding-top: 20px; border-top: 1px solid #E2E8F0; font-size: 0.8rem; color: var(--text-muted);">
        Hybrid TFLite & Cloud Diagnostic Engine v2.4
    </div>
</div>

<script>
async function handleLogin(e) {
    e.preventDefault();
    const email = document.getElementById('email').value;
    const password = document.getElementById('password').value;
    const btn = document.getElementById('loginBtn');
    const errBox = document.getElementById('errorBox');
    const errText = document.getElementById('errorText');

    errBox.style.display = 'none';
    btn.disabled = true;
    btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Authenticating...';

    try {
        await api.login(email, password);
        window.location.href = 'index.php';
    } catch (err) {
        errText.textContent = err.message || 'Invalid email or password';
        errBox.style.display = 'block';
        btn.disabled = false;
        btn.innerHTML = '<i class="fa-solid fa-right-to-bracket"></i> Sign In to Portal';
    }
}
</script>

</body>
</html>
