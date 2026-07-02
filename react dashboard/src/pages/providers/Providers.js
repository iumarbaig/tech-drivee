import React, { useState, useMemo } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Eye,
  ShieldOff,
  Zap,
  Droplets,
  Briefcase,
  ChevronRight,
  UserCheck,
  Check,
  RotateCcw,
} from 'lucide-react';

import PageHeader from '../../components/common/PageHeader';
import { useSearch } from '../../context/SearchContext';
import Badge from '../../components/common/Badge';
import EmptyState from '../../components/common/EmptyState';
import { mockProviders } from '../../data/mockData';

import './Providers.css';

const statusMap = {
  approved: 'success',
  pending: 'warning',
  blocked: 'danger',
};

export default function Providers() {
  const { search, setSearch } = useSearch();

  const [filter, setFilter] = useState('all');
  const [selectedCategory, setSelectedCategory] = useState('All');

  const navigate = useNavigate();

  const electricianStats = useMemo(() => {
    const list = mockProviders.filter((p) => p.type === 'Electrician');

    return {
      total: list.length,
      active: list.filter((p) => p.status === 'approved').length,
      pending: list.filter((p) => p.status === 'pending').length,
      blocked: list.filter((p) => p.status === 'blocked').length,
    };
  }, []);

  const plumberStats = useMemo(() => {
    const list = mockProviders.filter((p) => p.type === 'Plumber');

    return {
      total: list.length,
      active: list.filter((p) => p.status === 'approved').length,
      pending: list.filter((p) => p.status === 'pending').length,
      blocked: list.filter((p) => p.status === 'blocked').length,
    };
  }, []);

  const handleCategorySelect = (category) => {
    if (selectedCategory === category) {
      setSelectedCategory('All');
    } else {
      setSelectedCategory(category);
    }
  };

  const filteredProviders = useMemo(() => {
    return mockProviders.filter((p) => {
      const matchSearch =
        p.name.toLowerCase().includes(search.toLowerCase()) ||
        p.type.toLowerCase().includes(search.toLowerCase()) ||
        p.city.toLowerCase().includes(search.toLowerCase());

      const matchStatus = filter === 'all' || p.status === filter;

      const matchCategory =
        selectedCategory === 'All' || p.type === selectedCategory;

      return matchSearch && matchStatus && matchCategory;
    });
  }, [search, filter, selectedCategory]);

  return (
    <div className="providers animate-fade">
      <PageHeader
        title="Service Providers"
        subtitle="Consolidated administration panel to filter electricians and plumbers, verify credentials, and manage platform service coverage."
      />

      <div className="providers-category-hub">
        <div
          className={`providers-cat-card providers-cat-card--electrician ${
            selectedCategory === 'Electrician' ? 'active' : ''
          }`}
          onClick={() => handleCategorySelect('Electrician')}
        >
          {selectedCategory === 'Electrician' && (
            <div className="providers-cat-card__badge-check">
              <Check size={14} />
            </div>
          )}

          <div className="providers-cat-card__header">
            <div className="providers-cat-card__icon-box">
              <Zap size={24} />
            </div>

            <div className="providers-cat-card__title-area">
              <div className="title-row">
                <h3>Electricians</h3>

                <span className="profession-tag tag--electrician">
                  Power & Wiring
                </span>
              </div>

              <p className="providers-cat-card__desc">
                Certified electricians for home wiring, repairs, and appliance
                installations.
              </p>
            </div>
          </div>

          <div className="providers-cat-card__stats">
            <div className="cat-stat-pill">
              <span className="pill-val">{electricianStats.total}</span>
              <span className="pill-lbl">Total</span>
            </div>

            <div className="cat-stat-pill">
              <div className="lbl-row">
                <span className="dot dot--success"></span>
                <span className="pill-lbl">Active</span>
              </div>

              <span className="pill-val val--success">
                {electricianStats.active}
              </span>
            </div>

            <div className="cat-stat-pill">
              <div className="lbl-row">
                <span className="dot dot--warning"></span>
                <span className="pill-lbl">Pending</span>
              </div>

              <span className="pill-val val--warning">
                {electricianStats.pending}
              </span>
            </div>

            <div className="cat-stat-pill">
              <div className="lbl-row">
                <span className="dot dot--danger"></span>
                <span className="pill-lbl">Blocked</span>
              </div>

              <span className="pill-val val--danger">
                {electricianStats.blocked}
              </span>
            </div>
          </div>
        </div>

        <div
          className={`providers-cat-card providers-cat-card--plumber ${
            selectedCategory === 'Plumber' ? 'active' : ''
          }`}
          onClick={() => handleCategorySelect('Plumber')}
        >
          {selectedCategory === 'Plumber' && (
            <div className="providers-cat-card__badge-check">
              <Check size={14} />
            </div>
          )}

          <div className="providers-cat-card__header">
            <div className="providers-cat-card__icon-box">
              <Droplets size={24} />
            </div>

            <div className="providers-cat-card__title-area">
              <div className="title-row">
                <h3>Plumbers</h3>

                <span className="profession-tag tag--plumber">
                  Water & Pipes
                </span>
              </div>

              <p className="providers-cat-card__desc">
                Licensed plumbers for leakage repair, pipe installations, and
                fittings.
              </p>
            </div>
          </div>

          <div className="providers-cat-card__stats">
            <div className="cat-stat-pill">
              <span className="pill-val">{plumberStats.total}</span>
              <span className="pill-lbl">Total</span>
            </div>

            <div className="cat-stat-pill">
              <div className="lbl-row">
                <span className="dot dot--success"></span>
                <span className="pill-lbl">Active</span>
              </div>

              <span className="pill-val val--success">
                {plumberStats.active}
              </span>
            </div>

            <div className="cat-stat-pill">
              <div className="lbl-row">
                <span className="dot dot--warning"></span>
                <span className="pill-lbl">Pending</span>
              </div>

              <span className="pill-val val--warning">
                {plumberStats.pending}
              </span>
            </div>

            <div className="cat-stat-pill">
              <div className="lbl-row">
                <span className="dot dot--danger"></span>
                <span className="pill-lbl">Blocked</span>
              </div>

              <span className="pill-val val--danger">
                {plumberStats.blocked}
              </span>
            </div>
          </div>
        </div>
      </div>

      <div className="providers-summary-strip">
        <div className="summary-info">
          <Briefcase size={16} className="summary-icon" />

          <span>
            Showing <strong>{filteredProviders.length}</strong> providers
          </span>
        </div>

        {(selectedCategory !== 'All' ||
          filter !== 'all' ||
          search !== '') && (
          <button
            className="providers-reset-strip-btn"
            onClick={() => {
              setSelectedCategory('All');
              setFilter('all');
              setSearch('');
            }}
          >
            <RotateCcw size={13} />
            <span>Reset All Filters</span>
          </button>
        )}
      </div>

      <div className="providers__toolbar">
        <div className="providers__filters">
          {['all', 'approved', 'pending', 'blocked'].map((f) => (
            <button
              key={f}
              className={`filter-btn ${
                filter === f ? 'filter-btn--active' : ''
              }`}
              onClick={() => setFilter(f)}
            >
              {f.charAt(0).toUpperCase() + f.slice(1)}
            </button>
          ))}
        </div>
      </div>

      <div className="table-card table-card--premium animate-fade">
        {filteredProviders.length === 0 ? (
          <EmptyState
            title="No Providers Match Selected Filters"
            subtitle="Try resetting the categories or clearing search keywords."
          />
        ) : (
          <table className="data-table data-table--premium">
            <thead>
              <tr>
                <th style={{ width: '36%' }}>Provider Profile</th>
                <th style={{ width: '18%' }}>Service Category</th>
                <th style={{ width: '18%' }}>City Coverage</th>
                <th style={{ width: '12%' }}>Status</th>
                <th style={{ width: '16%', textAlign: 'right' }}>
                  Actions
                </th>
              </tr>
            </thead>

            <tbody>
              {filteredProviders.map((p) => (
                <tr
                  key={p.id}
                  onClick={() => navigate(`/reviews/${p.id}`)}
                  className="table-row-premium"
                >
                  <td>
                    <div className="provider-profile-cell">
                      <div
                        className={`provider-squircle-avatar avatar--${p.type.toLowerCase()}`}
                      >
                        {p.name.charAt(0)}
                      </div>

                      <div className="provider-profile-details">
                        <span className="profile-fullname">{p.name}</span>
                        <span className="profile-contact">{p.phone}</span>
                      </div>
                    </div>
                  </td>

                  <td>
                    <span
                      className={`category-tag-premium category-tag-premium--${p.type.toLowerCase()}`}
                    >
                      {p.type === 'Electrician' ? (
                        <Zap size={10} />
                      ) : (
                        <Droplets size={10} />
                      )}

                      {p.type}
                    </span>
                  </td>

                  <td>
                    <span className="city-cell-text">{p.city}</span>
                  </td>

                  <td>
                    <Badge
                      label={
                        p.status === 'approved' ? 'Active' : p.status
                      }
                      type={statusMap[p.status]}
                    />
                  </td>

                  <td>
                    <div
                      className="table-actions"
                      style={{ justifyContent: 'flex-end' }}
                      onClick={(e) => e.stopPropagation()}
                    >
                      <button
                        className="act-btn act-btn--view"
                        title="View Profile"
                        onClick={() => navigate(`/reviews/${p.id}`)}
                      >
                        <Eye size={12} />
                        <span>View</span>
                      </button>

                      <div className="act-btn-divider" />

                      {p.status !== 'blocked' ? (
                        <button
                          className="act-btn act-btn--block"
                          title="Block Provider"
                        >
                          <ShieldOff size={12} />
                          <span>Block</span>
                        </button>
                      ) : (
                        <button
                          className="act-btn act-btn--unblock"
                          title="Unblock Provider"
                        >
                          <UserCheck size={12} />
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