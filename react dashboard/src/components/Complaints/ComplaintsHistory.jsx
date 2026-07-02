import React, { useState, useMemo } from 'react';
import './ComplaintsHistory.css';

const MOCK_COMPLAINTS = [
  { email: 'user1@gmail.com', title: 'Payment failed but amount deducted', category: 'Billing & Payments', priority: 'Urgent', status: 'Open', date: '2026-05-17' },
  { email: 'ahmad.khan@gmail.com', title: 'App crashes on checkout screen', category: 'Technical Issue', priority: 'High', status: 'In Progress', date: '2026-05-16' },
  { email: 'sara.ali@gmail.com', title: 'Rude behavior by delivery executive', category: 'Service Quality', priority: 'Medium', status: 'Resolved', date: '2026-05-15' },
  { email: 'test.user@gmail.com', title: 'Cannot reset password via email', category: 'Account Access', priority: 'High', status: 'Closed', date: '2026-05-14' },
  { email: 'feedback@gmail.com', title: 'Feature request: Dark mode', category: 'Product Feedback', priority: 'Low', status: 'Resolved', date: '2026-05-12' },
];

const FILTERS = ['All', 'Open', 'In Progress', 'Resolved', 'Closed'];

const ComplaintsHistory = () => {
  const [searchTerm, setSearchTerm] = useState('');
  const [activeFilter, setActiveFilter] = useState('All');

  const filteredData = useMemo(() => {
    return MOCK_COMPLAINTS.filter(item => {
      const matchesFilter = activeFilter === 'All' || item.status === activeFilter;
      const searchLower = searchTerm.toLowerCase();
      const matchesSearch =
        item.title.toLowerCase().includes(searchLower) ||
        item.category.toLowerCase().includes(searchLower) ||
        item.email.toLowerCase().includes(searchLower);
      return matchesFilter && matchesSearch;
    });
  }, [searchTerm, activeFilter]);

  const getCount = (filter) => {
    if (filter === 'All') return MOCK_COMPLAINTS.length;
    return MOCK_COMPLAINTS.filter(item => item.status === filter).length;
  };

  const getStatusIcon = (status) => {
    switch(status) {
      case 'Open': return 'ti-circle-dotted';
      case 'In Progress': return 'ti-loader';
      case 'Resolved': return 'ti-circle-check';
      case 'Closed': return 'ti-lock';
      default: return 'ti-circle';
    }
  };

  return (
    <div className="ch-card">

      {/* Filters + Search on one line */}
      <div className="ch-filters-bar">
        <div className="ch-filters">
          {FILTERS.map(filter => (
            <button
              key={filter}
              className={`ch-filter-btn ${activeFilter === filter ? 'active' : ''}`}
              onClick={() => setActiveFilter(filter)}
            >
              {filter} <span className="ch-badge">{getCount(filter)}</span>
            </button>
          ))}
        </div>

        <div className="ch-search">
          <i className="ti ti-search"></i>
          <input
            type="text"
            placeholder="Search by title, category or email..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
        </div>
      </div>

      <div className="ch-table-container">
        {filteredData.length > 0 ? (
          <table className="ch-table animate-fade">
            <thead>
              <tr>
                <th>Email</th>
                <th>Title</th>
                <th>Category</th>
                <th>Priority</th>
                <th>Status</th>
                <th>Date</th>
                <th>Action</th>
              </tr>
            </thead>
            <tbody>
              {filteredData.map((item, index) => (
                <tr key={index}>
                  <td className="ch-col-id">{item.email}</td>
                  <td className="ch-col-title">{item.title}</td>
                  <td>
                    <span className="ch-category-pill">{item.category}</span>
                  </td>
                  <td>
                    <span className={`ch-priority-pill ch-priority-${item.priority.toLowerCase()}`}>
                      {item.priority}
                    </span>
                  </td>
                  <td>
                    <span className={`ch-status-badge ch-status-${item.status.toLowerCase().replace(' ', '-')}`}>
                      <i className={`ti ${getStatusIcon(item.status)}`}></i>
                      {item.status}
                    </span>
                  </td>
                  <td className="ch-col-date">{item.date}</td>
                  <td>
                    <button className="ch-btn-view">
                      View <i className="ti ti-arrow-right"></i>
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        ) : (
          <div className="ch-empty-state animate-fade">
            <div className="ch-empty-icon">
              <i className="ti ti-file-search"></i>
            </div>
            <h3>No complaints found</h3>
            <p>We couldn't find any complaints matching your current filters and search term.</p>
            <button
              className="ch-btn-clear-filters"
              onClick={() => { setSearchTerm(''); setActiveFilter('All'); }}
            >
              Clear Filters
            </button>
          </div>
        )}
      </div>
    </div>
  );
};

export default ComplaintsHistory;