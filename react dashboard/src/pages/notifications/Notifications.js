import React, { useState } from 'react';
import { Bell, CheckCheck, Trash2 } from 'lucide-react';
import PageHeader from '../../components/common/PageHeader';
import Badge from '../../components/common/Badge';
import './Notifications.css';

const allNotifications = [
  { id: 1, title: 'New Provider Registration',      body: 'Hassan Qureshi registered as a Plumber and is awaiting verification.',  time: '2 min ago',  type: 'info',    read: false },
  { id: 2, title: 'Complaint Submitted',             body: 'Customer Ayesha Khan submitted a complaint against Nadeem Shah.',        time: '15 min ago', type: 'warning', read: false },
  { id: 3, title: 'Provider Approved',               body: 'Ali Raza has been verified and approved as an Electrician.',              time: '1 hour ago', type: 'success', read: false },
  { id: 4, title: 'Account Auto-Blocked',            body: 'Nadeem Shah was auto-blocked after 3 failed quiz attempts.',             time: '3 hours ago',type: 'danger',  read: true },
  { id: 5, title: 'Booking Completed',               body: 'Booking BK001 between Ayesha Khan and Ali Raza marked as completed.',   time: '5 hours ago',type: 'success', read: true },
  { id: 6, title: 'New Booking Request',             body: 'Bilal Ahmed booked Imran Butt for Fan Installation service.',            time: 'Yesterday',  type: 'info',    read: true },
];

export default function Notifications() {
  const [notifications, setNotifications] = useState(allNotifications);
  const [filter, setFilter] = useState('all');

  const filtered = notifications.filter(n =>
    filter === 'all' ? true : filter === 'unread' ? !n.read : n.read
  );

  const markAllRead = () => {
    setNotifications(prev => prev.map(n => ({ ...n, read: true })));
  };

  const deleteNotif = (id) => {
    setNotifications(prev => prev.filter(n => n.id !== id));
  };

  const unreadCount = notifications.filter(n => !n.read).length;

  return (
    <div className="notif-page animate-fade">
      <PageHeader
        title="Notifications"
        subtitle={`You have ${unreadCount} unread notification${unreadCount !== 1 ? 's' : ''}.`}
        actions={
          <button className="btn btn--outline" onClick={markAllRead}>
            <CheckCheck size={14} /> Mark all as read
          </button>
        }
      />

      <div className="notif-page__toolbar">
        {['all', 'unread', 'read'].map(f => (
          <button
            key={f}
            className={`filter-btn ${filter === f ? 'filter-btn--active' : ''}`}
            onClick={() => setFilter(f)}
          >
            {f.charAt(0).toUpperCase() + f.slice(1)}
          </button>
        ))}
      </div>

      <div className="notif-page__list">
        {filtered.map(n => (
          <div key={n.id} className={`notif-row ${n.read ? 'notif-row--read' : ''}`}>
            <div className={`notif-row__icon notif-row__icon--${n.type}`}>
              <Bell size={16} />
            </div>
            <div className="notif-row__body">
              <div className="notif-row__top">
                <h4 className="notif-row__title">{n.title}</h4>
                <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <Badge label={n.type} type={n.type} />
                  <span className="notif-row__time">{n.time}</span>
                </div>
              </div>
              <p className="notif-row__text">{n.body}</p>
            </div>
            {!n.read && <div className="notif-row__dot" />}
            <button className="icon-btn icon-btn--danger" onClick={() => deleteNotif(n.id)}>
              <Trash2 size={13} />
            </button>
          </div>
        ))}
        {filtered.length === 0 && (
          <div style={{ textAlign: 'center', padding: '60px', color: 'var(--text-muted)' }}>
            No notifications here.
          </div>
        )}
      </div>
    </div>
  );
}