(() => {
  'use strict';
  if (!/(^|\.)instagram\.com$/.test(location.hostname)) return;
  const original = new Map();
  const properties = ['width', 'min-width', 'max-width', 'box-sizing', 'overflow-x'];
  const visible = el => el && el.getClientRects().length && getComputedStyle(el).visibility !== 'hidden';
  const text = el => (el.textContent || '').trim().replace(/\s+/g, ' ').toLowerCase();
  const restore = () => {
    for (const [el, values] of original) {
      for (const [name, value, priority] of values) {
        if (value) el.style.setProperty(name, value, priority);
        else el.style.removeProperty(name);
      }
    }
    original.clear();
  };
  const apply = () => {
    // Restore natural geometry first, including when a sidebar disappears on resize.
    restore();
    if (location.pathname !== '/') return {state: 'not-home'};
    const nodes = [...document.querySelectorAll('span,a,button,div,[role="tab"],h2,h3')]
      .filter(el => !el.children.length && visible(el));
    const first = nodes.find(el => ['for you', 'per te'].includes(text(el)));
    const second = nodes.find(el => ['following', 'seguiti'].includes(text(el)));
    const suggested = nodes.filter(el => ['suggested for you', 'suggeriti per te'].includes(text(el)));
    if (!first || !second || !suggested.length) return {state: 'no-layout-match'};
    const firstRect = first.getBoundingClientRect();
    const secondRect = second.getBoundingClientRect();
    // Match the compact feed tab strip by structure and geometry, never generated classes.
    let header = null;
    let ancestor = first.parentElement;
    for (let depth = 0; ancestor && depth < 10; depth++, ancestor = ancestor.parentElement) {
      if (!ancestor.contains(second)) continue;
      const r = ancestor.getBoundingClientRect();
      if (r.height > 180) break;
      if (r.width >= 300 && r.height >= 24 && r.top >= -180 && r.top <= 140 &&
          r.bottom >= firstRect.bottom && r.bottom >= secondRect.bottom) header = ancestor;
    }
    if (!header) return {state: 'no-header'};
    const bounds = header.getBoundingClientRect();
    const sidebar = suggested.map(el => el.getBoundingClientRect()).find(r =>
      r.left > bounds.left + 360 && r.left < bounds.right &&
      r.top >= bounds.top && r.top < bounds.bottom + 260);
    if (!sidebar) return {state: 'no-overlap'};
    const width = Math.floor(sidebar.left - bounds.left - 24);
    if (width < 360 || width >= bounds.width || !Number.isFinite(width)) return {state: 'no-overlap'};
    original.set(header, properties.map(name =>
      [name, header.style.getPropertyValue(name), header.style.getPropertyPriority(name)]));
    header.style.setProperty('box-sizing', 'border-box', 'important');
    header.style.setProperty('width', width + 'px', 'important');
    header.style.setProperty('min-width', '0', 'important');
    header.style.setProperty('max-width', width + 'px', 'important');
    header.style.setProperty('overflow-x', 'clip', 'important');
    return {state: 'adjusted', width};
  };
  // Exposed only for local regression fixtures; no profile data is collected.
  window.__instagramDockAdjustLayout = apply;
  let pending = false;
  const schedule = () => {
    if (pending) return;
    pending = true;
    setTimeout(() => { pending = false; apply(); }, 500);
  };
  new MutationObserver(schedule).observe(document.documentElement, {
    subtree: true, childList: true, characterData: true
  });
  window.addEventListener('resize', schedule);
  window.addEventListener('popstate', schedule);
  schedule();
})();
