S/* ════════════════════════════════
   SHARED DATA & RENDERERS
   Loaded by every page via <script src="data.js">
════════════════════════════════ */

const orders = [
  { id: '#ORD-8921', train: '12290 (Duronto)',     coach: 'S4', seat: '22', rest: "Haldiram's Express", status: 'PENDING',    dropTime: '12:15 PM', outlet: 'Station Outlet A1' },
  { id: '#ORD-8922', train: '12834 (Howrah Exp)',  coach: 'B2', seat: '45', rest: 'Nagpur Kitchen',     status: 'READY',      dropTime: '12:30 PM', outlet: 'Platform 2'        },
  { id: '#ORD-8923', train: '22692 (Rajdhani)',    coach: 'A1', seat: '12', rest: 'Biryani House',      status: 'ASSIGNED',   dropTime: '12:45 PM', outlet: 'West Wing Exit'    },
  { id: '#ORD-8924', train: '12106 (Vidarbha)',    coach: 'S1', seat: '05', rest: 'Rail Dhaba',         status: 'PENDING',    dropTime: '01:05 PM', outlet: 'Main Concourse'    },
  { id: '#ORD-8925', train: '12140 (Sewagram)',    coach: 'B3', seat: '30', rest: 'Spice Route',        status: 'READY',      dropTime: '01:15 PM', outlet: 'Gate 3'            },
  { id: '#ORD-8926', train: '12290 (Duronto)',     coach: 'H1', seat: '04', rest: 'Nagpur Kitchen',     status: 'DISPATCHED', dropTime: '11:50 AM', outlet: 'Platform 1'        },
  { id: '#ORD-8927', train: '12291 (Chennai Exp)', coach: 'S3', seat: '18', rest: 'Rail Dhaba',         status: 'PENDING',    dropTime: '01:35 PM', outlet: 'South Exit'        },
  { id: '#ORD-8928', train: '12293 (Pune Exp)',    coach: 'B4', seat: '33', rest: 'Biryani House',      status: 'READY',      dropTime: '01:50 PM', outlet: 'Gate 1'            },
];

const STATUS_CLASS = {
  PENDING:    'badge-pending',
  READY:      'badge-ready',
  ASSIGNED:   'badge-assigned',
  DISPATCHED: 'badge-dispatched',
  CANCELLED:  'badge-cancelled',
};

/**
 * Standard order row — used in Dashboard + Orders pages.
 */
function renderOrderRow(o) {
  return `
    <tr>
      <td class="order-id">${o.id}</td>
      <td>${o.train}</td>
      <td>${o.coach}</td>
      <td>${o.seat}</td>
      <td>${o.rest}</td>
      <td><span class="status-badge ${STATUS_CLASS[o.status]}">${o.status}</span></td>
    </tr>`;
}
