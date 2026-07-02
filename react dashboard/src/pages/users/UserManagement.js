import React, { useState, useMemo } from 'react';
import { useSearch } from '../../context/SearchContext';
import {
  Mail, Phone, Calendar, User,
  ShieldOff, ShieldCheck, UserX, UserCheck,
} from 'lucide-react';

import PageHeader from '../../components/common/PageHeader';
import Badge from '../../components/common/Badge';
import { mockUsers as initialUsers } from '../../data/mockData';

import './UserManagement.css';

export default function UserManagement() {
  const [users, setUsers] = useState(initialUsers);
  const { search } = useSearch();
  const [filterRole, setFilterRole] = useState('All');
  const [filterStatus, setFilterStatus] = useState('All');

  const filteredUsers = useMemo(() => {
    return users.filter((u) => {
      const matchesSearch =
        u.name.toLowerCase().includes(search.toLowerCase()) ||
        u.email.toLowerCase().includes(search.toLowerCase()) ||
        u.phone.includes(search);
      const matchesRole = filterRole === 'All' || u.role === filterRole;
      const matchesStatus =
        filterStatus === 'All' ||
        (filterStatus === 'Active' && u.status === 'active') ||
        (filterStatus === 'Blocked' && u.status === 'blocked') ||
        (filterStatus === 'Suspended' && u.status === 'inactive');
      return matchesSearch && matchesRole && matchesStatus;
    });
  }, [users, search, filterRole, filterStatus]);

  const handleToggleBlock = (id) => {
    setUsers((prev) =>
      prev.map((u) =>
        u.id === id ? { ...u, status: u.status === 'blocked' ? 'active' : 'blocked' } : u
      )
    );
  };

  const handleSuspend = (id, action) => {
    setUsers((prev) =>
      prev.map((u) =>
        u.id === id ? { ...u, status: action === 'suspend' ? 'inactive' : 'active' } : u
      )
    );
  };

  const getStatusBadgeType = (status) => {
    switch (status) {
      case 'active':   return 'success';
      case 'blocked':  return 'danger';
      case 'inactive': return 'warning';
      default:         return 'default';
    }
  };

  const getStatusLabel = (status) => {
    switch (status) {
      case 'active':   return 'Active';
      case 'blocked':  return 'Blocked';
      case 'inactive': return 'Suspended';
      default:         return 'Unknown';
    }
  };

  return (
    <div className="user-management animate-fade">

      <PageHeader
        title="User Management"
        subtitle="Manage application users and technician profiles."
      />

      {/* Toolbar */}
      <div className="users-toolbar">
        <div className="users-toolbar__filters">

          {/* Role filter */}
          <span className="filter-group-label">Role</span>
          <div className="users-filter-pill-group">
            {['All', 'Customer', 'Electrician', 'Plumber'].map((option) => (
              <button
                key={option}
                type="button"
                className={`filter-pill ${filterRole === option ? 'filter-pill--active' : ''}`}
                onClick={() => setFilterRole(option)}
              >
                {option}
              </button>
            ))}
          </div>

          {/* Divider */}
          <div className="filter-group-divider" />

          {/* Status filter */}
          <span className="filter-group-label">Status</span>
          <div className="users-filter-pill-group">
            {['All', 'Active', 'Blocked', 'Suspended'].map((option) => (
              <button
                key={option}
                type="button"
                className={`filter-pill ${filterStatus === option ? 'filter-pill--active' : ''}`}
                onClick={() => setFilterStatus(option)}
              >
                {option}
              </button>
            ))}
          </div>

        </div>
      </div>

      {/* Table */}
      <div className="table-card">
        {filteredUsers.length === 0 ? (
          <div className="users-empty-state">
            <h3>No Users Found</h3>
            <p>Try another keyword or filter.</p>
          </div>
        ) : (
          <table className="data-table">
            <thead>
              <tr>
                <th>User Details</th>
                <th>Role</th>
                <th>Contact</th>
                <th>Joined</th>
                <th>Status</th>
                <th style={{ textAlign: 'right' }}>Actions</th>
              </tr>
            </thead>

            <tbody>
              {filteredUsers.map((u) => (
                <tr key={u.id}>

                  <td>
                    <div className="user-profile-cell">
                      <div className="user-avatar-frame">
                        {u.avatar ? (
                          <span className="user-avatar-initials">{u.avatar}</span>
                        ) : (
                          <User size={16} />
                        )}
                      </div>
                      <div>
                        <p className="user-name-text">
                          {u.name}
                          {u.isVerifiedWorker && (
                            <span className="verified-worker-tick">
                              <ShieldCheck size={13} />
                            </span>
                          )}
                        </p>
                        <span className="user-last-active">Active: {u.lastActive}</span>
                      </div>
                    </div>
                  </td>

                  <td>
                    <Badge
                      label={u.role}
                      type={
                        u.role === 'Customer'      ? 'primary'
                        : u.role === 'Electrician' ? 'info'
                        : 'success'
                      }
                    />
                  </td>

                  <td>
                    <div className="user-contact-info">
                      <p className="user-email-text"><Mail size={12} />{u.email}</p>
                      <p className="user-phone-text"><Phone size={12} />{u.phone}</p>
                    </div>
                  </td>

                  <td>
                    <span className="user-date-cell">
                      <Calendar size={13} />
                      {u.joined}
                    </span>
                  </td>

                  <td>
                    <Badge
                      label={getStatusLabel(u.status)}
                      type={getStatusBadgeType(u.status)}
                    />
                  </td>

                  <td>
                    <div className="user-table-actions">

                      {u.status === 'active' && (
                        <>
                          <button
                            className="u-act-btn u-act-btn--suspend"
                            title="Suspend User"
                            onClick={() => handleSuspend(u.id, 'suspend')}
                          >
                            <UserX size={12} />
                            <span>Suspend</span>
                          </button>
                          <div className="u-act-divider" />
                          <button
                            className="u-act-btn u-act-btn--block"
                            title="Block User"
                            onClick={() => handleToggleBlock(u.id)}
                          >
                            <ShieldOff size={12} />
                            <span>Block</span>
                          </button>
                        </>
                      )}

                      {u.status === 'inactive' && (
                        <>
                          <button
                            className="u-act-btn u-act-btn--reactivate"
                            title="Reactivate User"
                            onClick={() => handleSuspend(u.id, 'activate')}
                          >
                            <UserCheck size={12} />
                            <span>Reactivate</span>
                          </button>
                          <div className="u-act-divider" />
                          <button
                            className="u-act-btn u-act-btn--block"
                            title="Block User"
                            onClick={() => handleToggleBlock(u.id)}
                          >
                            <ShieldOff size={12} />
                            <span>Block</span>
                          </button>
                        </>
                      )}

                      {u.status === 'blocked' && (
                        <button
                          className="u-act-btn u-act-btn--unblock"
                          title="Unblock User"
                          onClick={() => handleToggleBlock(u.id)}
                        >
                          <ShieldCheck size={12} />
                          <span>Unblock</span>
                        </button>
                      )}

                    </div>
                  </td>

                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}
