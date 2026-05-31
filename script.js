// ============ COPY LOADER BUTTON ============
const LOADER_CODE = `local SarXNight = loadstring(game:HttpGet("https://raw.githubusercontent.com/Styuai6/SarXNight-Ui-Library/refs/heads/main/Source.luau"))()

local Window = SarXNight:MakeWindow({
    Name = "My Hub",
    InterfaceId = "rbxassetid://11436111346",
    LoadingLogoId = "rbxassetid://11436111346",
    IntroText = "My Hub",
    SaveConfig = true,
    ConfigFolder = "MyHub"
})

local Main = Window:MakeTab({ Name = "Main" })
Main:AddToggle({ Name = "Toggle", Callback = function(v) print(v) end })
SarXNight:Init()`;

function copyToClipboard(text) {
    if (navigator.clipboard && window.isSecureContext) {
        return navigator.clipboard.writeText(text);
    }
    const ta = document.createElement('textarea');
    ta.value = text;
    ta.style.position = 'fixed';
    ta.style.opacity = '0';
    document.body.appendChild(ta);
    ta.select();
    document.execCommand('copy');
    document.body.removeChild(ta);
    return Promise.resolve();
}

const copyBtn = document.getElementById('copyLoader');
const copyText = document.getElementById('copyText');
if (copyBtn) {
    copyBtn.addEventListener('click', async () => {
        await copyToClipboard(LOADER_CODE);
        copyText.textContent = 'Copied!';
        copyBtn.style.borderColor = '#4ade80';
        setTimeout(() => {
            copyText.textContent = 'Copy Loader';
            copyBtn.style.borderColor = '';
        }, 2000);
    });
}

const copyCode = document.getElementById('copyCode');
if (copyCode) {
    copyCode.addEventListener('click', async () => {
        const codeEl = document.querySelector('.code-block pre code');
        await copyToClipboard(codeEl.innerText);
        copyCode.textContent = 'Copied!';
        copyCode.style.color = '#4ade80';
        setTimeout(() => {
            copyCode.textContent = 'Copy';
            copyCode.style.color = '';
        }, 2000);
    });
}

// ============ STATS COUNTER ANIMATION ============
function animateCounter(el, target, duration = 2000) {
    const start = 0;
    const startTime = performance.now();

    function step(now) {
        const elapsed = now - startTime;
        const progress = Math.min(elapsed / duration, 1);
        const eased = 1 - Math.pow(1 - progress, 3);
        const value = Math.floor(start + (target - start) * eased);
        el.textContent = value.toLocaleString() + (target === 99 ? '%' : (target >= 1000 ? '+' : ''));
        if (progress < 1) requestAnimationFrame(step);
        else el.textContent = target.toLocaleString() + (target === 99 ? '%' : (target >= 1000 ? '+' : ''));
    }
    requestAnimationFrame(step);
}

const statObserver = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
        if (entry.isIntersecting) {
            const target = parseInt(entry.target.dataset.target);
            animateCounter(entry.target, target);
            statObserver.unobserve(entry.target);
        }
    });
}, { threshold: 0.4 });

document.querySelectorAll('.stat-number').forEach(el => statObserver.observe(el));

// ============ TOGGLE INTERACTION (SHOWCASE) ============
document.querySelectorAll('[data-toggle]').forEach(toggle => {
    toggle.addEventListener('click', () => {
        toggle.classList.toggle('on');
    });
});

// ============ DROPDOWN INTERACTION ============
const dropdown = document.getElementById('mockDropdown');
if (dropdown) {
    const opts = dropdown.querySelectorAll('.dropdown-opt');
    const current = dropdown.querySelector('.dropdown-current');
    opts.forEach(opt => {
        opt.addEventListener('click', () => {
            opts.forEach(o => o.classList.remove('active'));
            opt.classList.add('active');
            current.textContent = opt.textContent + ' ▼';
        });
    });
}

// ============ SCROLL REVEAL ============
const revealObserver = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
        if (entry.isIntersecting) {
            entry.target.style.opacity = '1';
            entry.target.style.transform = 'translateY(0)';
            revealObserver.unobserve(entry.target);
        }
    });
}, { threshold: 0.1 });

document.querySelectorAll('.feature, .showcase-card, .stat-card').forEach(el => {
    el.style.opacity = '0';
    el.style.transform = 'translateY(20px)';
    el.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
    revealObserver.observe(el);
});

// ============ NAV SCROLL EFFECT ============
const nav = document.querySelector('.nav');
let lastY = 0;
window.addEventListener('scroll', () => {
    const y = window.scrollY;
    if (y > 20) {
        nav.style.background = 'rgba(10, 10, 18, 0.9)';
        nav.style.borderBottomColor = 'rgba(130,110,230,0.2)';
    } else {
        nav.style.background = 'rgba(10, 10, 18, 0.7)';
        nav.style.borderBottomColor = '';
    }
    lastY = y;
});
