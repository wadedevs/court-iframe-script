(() => {
    const panel = document.getElementById('panel');
    const frame = document.getElementById('frame');
    const title = document.getElementById('title');
    const loading = document.getElementById('loading');
    const failed = document.getElementById('failed');
    const resource = typeof GetParentResourceName === 'function' ? GetParentResourceName() : 'fivem-iframe';

    let current = null;
    let timer = null;

    function load(url) {
        clearTimeout(timer);
        failed.hidden = true;
        loading.hidden = false;
        frame.src = url;
        const seconds = Number(current && current.timeout) || 10;
        timer = setTimeout(() => {
            loading.hidden = true;
            failed.hidden = false;
        }, seconds * 1000);
    }

    frame.addEventListener('load', () => {
        if (frame.src === 'about:blank') return;
        clearTimeout(timer);
        loading.hidden = true;
        failed.hidden = true;
    });

    function open(site) {
        const sameSite = current && current.id === site.id && current.id !== 'custom';
        current = site;
        title.textContent = site.title || '';
        panel.classList.toggle('fullscreen', Boolean(site.fullscreen));
        panel.style.width = site.width || '';
        panel.style.height = site.height || '';
        panel.hidden = false;
        // Reopening the same site keeps its page; a new site (or a fresh token) loads its URL.
        if (!sameSite || frame.src === 'about:blank') load(site.url);
    }

    function hide() {
        clearTimeout(timer);
        panel.hidden = true;
    }

    function requestClose() {
        fetch(`https://${resource}/close`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=UTF-8' },
            body: '{}',
        }).catch(() => {});
    }

    window.addEventListener('message', (event) => {
        const data = event.data;
        if (!data || typeof data !== 'object') return;
        if (data.type === 'open' && data.site && typeof data.site.url === 'string') open(data.site);
        else if (data.type === 'close') hide();
    });

    document.getElementById('close').addEventListener('click', requestClose);
    document.getElementById('reload').addEventListener('click', () => current && load(current.url));
    document.getElementById('retry').addEventListener('click', () => current && load(current.url));
    window.addEventListener('keydown', (e) => { if (e.key === 'Escape') requestClose(); });
})();
