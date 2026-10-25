(() => {
  'use strict';
  const visible = el => !!(el && el.getClientRects().length && getComputedStyle(el).visibility !== 'hidden');
  const number = text => {
    const match = String(text || '').trim().match(/^(\d{1,4})(\+)?$/);
    return match ? { count: Math.min(9999, Number(match[1])), minimum: !!match[2] } : null;
  };
  // Recognize both English and Italian website labels; app output is English.
  const unread = /non lett[oi e]|unread|nuov[oi e] messagg|new messages?/i;
  const actionableUnread = label => unread.test(label) && !/segna.*non lett|mark.*unread/i.test(label);
  const inspectPage = () => {
    if (!/(^|\.)instagram\.com$/.test(location.hostname)) return {state:'outside'};
    if (document.querySelector('input[type="password"]')) return {state:'login'};
    const inbox = location.pathname.startsWith('/direct/');
    const links = [...document.querySelectorAll('a[href]')].filter(el => {
      try { const u = new URL(el.href, location.href); return u.origin === location.origin && /^\/direct\/(inbox\/?)?$/.test(u.pathname) && visible(el); } catch { return false; }
    });
    for (const link of links) {
      for (const el of [link, ...link.querySelectorAll('[aria-label]')]) {
        const label = el.getAttribute('aria-label') || '';
        if (!visible(el) || !actionableUnread(label)) continue;
        const m = label.match(/\b(\d{1,4})\b/);
        if (m) return {state:'known',count:Math.min(9999,Number(m[1])),minimum:false,source:'Unread-message accessibility label'};
      }
      for (const el of link.querySelectorAll('span,div')) {
        if (!visible(el) || el.children.length) continue;
        const n = number(el.textContent);
        if (n) return {state:'known',...n,source:'Counter next to Messages'};
      }
      if (actionableUnread(link.getAttribute('aria-label') || '') || [...link.querySelectorAll('[aria-label]')].some(el => visible(el) && actionableUnread(el.getAttribute('aria-label') || ''))) {
        return {state:'indicator',source:'Unread indicator without a number'};
      }
    }
    if (inbox) {
      const rows = new Set();
      for (const el of document.querySelectorAll('[aria-label]')) {
        if (!visible(el) || !actionableUnread(el.getAttribute('aria-label') || '')) continue;
        const row = el.closest('a[href*="/direct/t/"], [role="listitem"], [role="row"]');
        if (row) rows.add(row);
      }
      if (rows.size) return {state:'known',count:rows.size,minimum:true,source:'Visible unread conversations (lower bound)'};
    }
    // Instagram removes the badge element after the final message is read.
    // Only treat that absence as zero when the Messages link is present and
    // stable for 8 seconds. Unrelated feed/reel progress indicators must not
    // suppress resetting the badge. Interactive pages already have a parsed DOM;
    // waiting for every external resource to finish can also stall indefinitely.
    const loadingSelector = '[aria-busy="true"], [role="progressbar"]';
    const pageBusy = [...document.querySelectorAll(loadingSelector)].filter(visible).length;
    const messagesBusy = links.some(link => link.getAttribute('aria-busy') === 'true' || [...link.querySelectorAll(loadingSelector)].some(visible));
    const readiness = {links:links.length,inbox,pageState:document.readyState,pageLoadingIndicators:pageBusy,messagesBusy};
    if (links.length && document.readyState !== 'loading' && !messagesBusy) {
      return {state:'emptyCandidate',...readiness,source:'Messages link present, counter absent'};
    }
    return {state:'unknown',...readiness,source:'No readable counter; count unavailable'};
  };
  let emptySince = null;
  let emptyPath = '';
  const inspect = () => {
    const result = inspectPage();
    if (result.state !== 'emptyCandidate') { emptySince = null; emptyPath = ''; return result; }
    const now = Date.now();
    if (emptySince === null || emptyPath !== location.pathname) { emptySince = now; emptyPath = location.pathname; }
    if (now - emptySince >= 8000) return {...result,state:'known',count:0,minimum:false,source:'Messages link without unread activity for at least 8 seconds'};
    return {...result,state:'settling',source:'Checking whether to clear the badge'};
  };
  window.__instagramDockInspect = inspect;
  let pending = false;
  const send = () => {
    pending = false;
    try { window.webkit.messageHandlers.badge.postMessage(inspect()); } catch (_) {}
  };
  const observer = new MutationObserver(() => {
    if (!pending) { pending = true; setTimeout(send, 600); }
  });
  observer.observe(document.documentElement, {subtree:true,childList:true,characterData:true,attributes:true,attributeFilter:['aria-label']});
  setInterval(send, 5000);
  send();
})();
