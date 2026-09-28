// ═══════════════════════════════════════════════════════════════
//   KUKEM PERF — FPS METER + DEBLOAT EFFECTS
//   Chạy trên Kiwi console. Toggle bằng nút ▣ góc phải.
// ═══════════════════════════════════════════════════════════════

(function KukemPerf() {
    'use strict';

    if (window.__kukem_perf) { window.__kukem_perf.destroy(); }

    // ═══════════════ STYLE KILL ═══════════════
    const killCSS = `
        /* Tắt mọi animation + transition */
        *, *::before, *::after {
            animation: none !important;
            animation-duration: 0s !important;
            animation-delay: 0s !important;
            transition: none !important;
            transition-duration: 0s !important;
            transition-delay: 0s !important;
            scroll-behavior: auto !important;
        }
        /* Tắt hiệu ứng sáng / glow / blur / shadow */
        * {
            box-shadow: none !important;
            text-shadow: none !important;
            filter: none !important;
            backdrop-filter: none !important;
            -webkit-backdrop-filter: none !important;
            mix-blend-mode: normal !important;
            will-change: auto !important;
            transform-style: flat !important;
            perspective: none !important;
        }
        /* Tắt gradient phát sáng nền */
        *[style*="gradient"], *[class*="glow"], *[class*="shadow"],
        *[class*="blur"], *[class*="shine"], *[class*="sparkle"] {
            background-image: none !important;
        }
        /* Media không autoplay vòng lặp */
        video[autoplay], video[loop] { autoplay: false; }
        /* Smooth scroll off */
        html { scroll-behavior: auto !important; }
    `;

    const styleEl = document.createElement("style");
    styleEl.id = "__kukem_perf_css";
    styleEl.textContent = killCSS;
    document.head.appendChild(styleEl);

    // ═══════════════ HUD ═══════════════
    const hud = document.createElement("div");
    hud.id = "__kukem_perf_hud";
    hud.style.cssText = `
        position: fixed; top: 8px; right: 8px; z-index: 2147483647;
        background: rgba(6,4,12,0.9); color: #5adcff;
        font-family: monospace; font-size: 12px; line-height: 1.4;
        padding: 6px 10px; border-radius: 8px;
        border: 1px solid rgba(170,120,255,0.5);
        pointer-events: auto; cursor: move; user-select: none;
        box-shadow: 0 0 12px rgba(170,120,255,0.4);
        min-width: 130px;
    `;
    hud.innerHTML = `
        <div style="color:#aa78ff;font-weight:bold">▣ KUKEM PERF</div>
        <div>FPS: <span id="__kukem_fps" style="color:#0f0;font-weight:bold">--</span></div>
        <div>MS: <span id="__kukem_ms" style="color:#fc0">--</span></div>
        <div>MEM: <span id="__kukem_mem" style="color:#5adcff">--</span></div>
        <div style="margin-top:4px;font-size:10px;color:#888">
            <span id="__kukem_toggle" style="cursor:pointer;color:#aa78ff">[ toggle ]</span>
            <span id="__kukem_kill" style="cursor:pointer;color:#f44;margin-left:6px">[ off ]</span>
        </div>
    `;
    document.body.appendChild(hud);

    const fpsEl = hud.querySelector("#__kukem_fps");
    const msEl  = hud.querySelector("#__kukem_ms");
    const memEl = hud.querySelector("#__kukem_mem");

    // ═══════════════ FPS COUNTER ═══════════════
    let frames = 0;
    let lastT = performance.now();
    let rafId = null;
    let running = true;

    function tick(now) {
        if (!running) return;
        frames++;
        const dt = now - lastT;
        if (dt >= 500) {
            const fps = Math.round((frames * 1000) / dt);
            const ms = (dt / frames).toFixed(2);
            fpsEl.textContent = fps;
            fpsEl.style.color = fps >= 50 ? "#0f0" : fps >= 30 ? "#fc0" : "#f44";
            msEl.textContent = ms;

            // Memory (nếu hỗ trợ)
            if (performance.memory) {
                const mb = (performance.memory.usedJSHeapSize / 1048576).toFixed(1);
                memEl.textContent = mb + " MB";
            } else {
                memEl.textContent = "n/a";
            }

            frames = 0;
            lastT = now;
        }
        rafId = requestAnimationFrame(tick);
    }
    rafId = requestAnimationFrame(tick);

    // ═══════════════ REDUCE ANIMATIONS ═══════════════
    // Ép prefers-reduced-motion để nhiều site tự tắt anim
    function applyReduceMotion() {
        let meta = document.querySelector('meta[name="__kukem_reduce"]');
        if (!meta) {
            meta = document.createElement("meta");
            meta.name = "__kukem_reduce";
            meta.content = "reduce";
            document.head.appendChild(meta);
        }
    }
    applyReduceMotion();

    // ═══════════════ TOGGLE / KILL ═══════════════
    let cssOn = true;
    hud.querySelector("#__kukem_toggle").addEventListener("click", () => {
        cssOn = !cssOn;
        styleEl.disabled = !cssOn;
        hud.querySelector("#__kukem_toggle").textContent = cssOn ? "[ toggle ]" : "[ toggle:off ]";
        hud.querySelector("#__kukem_toggle").style.color = cssOn ? "#aa78ff" : "#666";
    });

    hud.querySelector("#__kukem_kill").addEventListener("click", () => {
        destroy();
    });

    // ═══════════════ DRAG HUD ═══════════════
    let dragging = false, sx, sy, ox, oy;
    hud.addEventListener("mousedown", e => {
        if (e.target.tagName === "SPAN") return;
        dragging = true; sx = e.clientX; sy = e.clientY;
        const r = hud.getBoundingClientRect();
        ox = r.left; oy = r.top;
    });
    document.addEventListener("mousemove", e => {
        if (!dragging) return;
        hud.style.left = (ox + e.clientX - sx) + "px";
        hud.style.top  = (oy + e.clientY - sy) + "px";
        hud.style.right = "auto";
    });
    document.addEventListener("mouseup", () => dragging = false);

    // Touch
    hud.addEventListener("touchstart", e => {
        if (e.target.tagName === "SPAN") return;
        const t = e.touches[0];
        dragging = true; sx = t.clientX; sy = t.clientY;
        const r = hud.getBoundingClientRect();
        ox = r.left; oy = r.top;
    }, { passive: true });
    document.addEventListener("touchmove", e => {
        if (!dragging) return;
        const t = e.touches[0];
        hud.style.left = (ox + t.clientX - sx) + "px";
        hud.style.top  = (oy + t.clientY - sy) + "px";
        hud.style.right = "auto";
    }, { passive: true });
    document.addEventListener("touchend", () => dragging = false);

    // ═══════════════ DESTROY ═══════════════
    function destroy() {
        running = false;
        if (rafId) cancelAnimationFrame(rafId);
        styleEl.remove();
        hud.remove();
        window.__kukem_perf = null;
        console.log("%c[KukemPerf] Đã tắt", "color:#f44");
    }

    window.__kukem_perf = { destroy };

    console.log("%c[KukemPerf] Đã bật — HUD góc phải", "color:#aa78ff;font-weight:bold");
    console.log("  FPS: số khung/giây | MS: ms mỗi khung | MEM: heap JS");
    console.log("  [ off ] để gỡ hoàn toàn");
})();
