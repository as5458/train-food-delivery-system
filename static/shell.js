/* ════════════════════════════════
   SHELL — injects sidebar + topbar
════════════════════════════════ */

const NAV_ITEMS = [
  { key: 'dashboard',        icon: '📊', label: 'Dashboard', href: '/dashboard' },
  { key: 'orders',           icon: '📋', label: 'Orders', href: '/orders' },
  { key: 'stations',         icon: '🖥️', label: 'Station Counter', href: '/stations' },
  { key: 'delivery',         icon: '🚴', label: 'Delivery Assignment', href: '/delivery' },

  // 🔥 DELIVERY PARTNER (IMPORTANT)
  { key: 'deliverypartner',  icon: '🚚', label: 'Delivery Partner', href: '/delivery-partner' },

  { key: 'train',            icon: '🚆', label: 'Train Delay', href: '/train' },
  { key: 'cancelled',        icon: '❌', label: 'Cancelled Orders', href: '/cancelled' },
  { key: 'discount',         icon: '🏷️', label: 'Discount Sale', href: '/discount' },
  { key: 'analytics',        icon: '📈', label: 'Analytics', href: '/analytics' },
];


const TOPBAR_META = {
  dashboard: {
    icon: '📊',
    title: 'Nagpur Station Dashboard',
    badge: 'ACTIVE',
    badgeClass: 'badge-active'
  },

  orders: {
    icon: '📋',
    title: 'All Orders',
    badge: 'LIVE',
    badgeClass: 'badge-ready'
  },

  stations: {
    icon: '🖥️',
    title: 'Nagpur Station Drop Counter',
    badge: 'ACTIVE',
    badgeClass: 'badge-active'
  },

  delivery: {
    icon: '🚴',
    title: 'Delivery Assignment',
    badge: '',
    badgeClass: ''
  },

  // 🔥 DELIVERY PARTNER META
  deliverypartner: {
    icon: '🚚',
    title: 'Delivery Partner',
    badge: '',
    badgeClass: ''
  },

  train: {
    icon: '🚆',
    title: 'Train Delay Tracker',
    badge: '',
    badgeClass: ''
  },

  cancelled: {
    icon: '❌',
    title: 'Cancelled Orders',
    badge: '',
    badgeClass: ''
  },

  discount: {
    icon: '🏷️',
    title: 'Discount Sale',
    badge: '',
    badgeClass: ''
  },

  analytics: {
    icon: '📈',
    title: 'Analytics',
    badge: '',
    badgeClass: ''
  },
};


function renderShell(activeKey) {

  // ===== SIDEBAR =====
  const navHTML = NAV_ITEMS.map(item => `
    <a class="nav-item ${item.key === activeKey ? 'active' : ''}" href="${item.href}">
      <span style="margin-right:8px">${item.icon}</span>
      ${item.label}
    </a>
  `).join('');

  const sidebar = `
    <div class="sidebar">
      <div class="brand">
        <div class="brand-icon">🚆</div>
        <div>
          <div class="brand-name">Right Time</div>
          <div class="brand-sub">Food Delivery Platform</div>
        </div>
      </div>

      <nav>${navHTML}</nav>

      <div class="sidebar-bottom">
        <a class="profile-link" href="#">👤 Profile</a>

        <div class="support-box">
          <div class="support-label">Support Status</div>
          <div class="support-status">🟢 Operational (24/7)</div>
        </div>
      </div>
    </div>
  `;


  // ===== TOPBAR =====
  const m = TOPBAR_META[activeKey] || {};

  const badgeHTML = m.badge
    ? `<span class="status-badge ${m.badgeClass}">${m.badge}</span>`
    : '';

  const topbar = `
    <div class="topbar">
      <div class="topbar-left">
        <div class="topbar-icon">${m.icon || ''}</div>
        <div class="topbar-title">${m.title || ''}</div>
        ${badgeHTML}
      </div>

      <div class="topbar-right">
        <button class="bell-btn">🔔<span class="bell-dot"></span></button>

        <div class="user-info">
          <div class="user-name">Rakesh Kumar</div>
          <div class="user-role">Station Master</div>
        </div>

        <div class="avatar">RK</div>
      </div>
    </div>
  `;


  // ===== INJECT INTO PAGE =====
  document.getElementById('sidebar-slot').innerHTML = sidebar;
  document.getElementById('topbar-slot').innerHTML = topbar;
}