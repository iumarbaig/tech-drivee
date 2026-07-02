import React from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Users,
  Briefcase,
  Clock,
  BookOpen,
  AlertCircle,
  ShieldOff
} from 'lucide-react';

import {
  BarChart,
  Bar,
  PieChart,
  Pie,
  Cell,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer
} from 'recharts';

import StatCard from '../../components/common/StatCard';
import PageHeader from '../../components/common/PageHeader';
import Badge from '../../components/common/Badge';

import {
  weeklyBookings,
  serviceCategories,
  mockBookings,
  mockComplaints,
  mockProviders
} from '../../data/mockData';

import './Dashboard.css';

const PIE_COLORS = ['#10B981', '#06B6D4', '#6366F1', '#F59E0B', '#EF4444'];

const recentApprovals = mockProviders
  .filter(p => p.status === 'approved')
  .slice(0, 4);

export default function Dashboard() {
  const navigate = useNavigate();

  return (
    <div className="dashboard animate-fade">
      <PageHeader
        title="Dashboard"
        subtitle="Welcome back! Here's what's happening on Tech Drive."
      />

      {/* Stats Grid */}
      <div className="dashboard__stats">

        <div onClick={() => navigate('/users')} className="dashboard__stat-click">
          <StatCard
            title="Total Users"
            value="1,248"
            icon={Users}
            color="blue"
            change={12}
            changeLabel="vs last month"
          />
        </div>

        <div onClick={() => navigate('/providers')} className="dashboard__stat-click">
          <StatCard
            title="Service Providers"
            value="186"
            icon={Briefcase}
            color="cyan"
            change={8}
            changeLabel="vs last month"
          />
        </div>

        <div onClick={() => navigate('/verification')} className="dashboard__stat-click">
          <StatCard
            title="Worker Verifications"
            value="24"
            icon={Clock}
            color="yellow"
            change={-3}
            changeLabel="vs last week"
          />
        </div>

        <div onClick={() => navigate('/bookings')} className="dashboard__stat-click">
          <StatCard
            title="Bookings"
            value="37"
            icon={BookOpen}
            color="green"
            change={18}
            changeLabel="vs yesterday"
          />
        </div>

        <div onClick={() => navigate('/complaints')} className="dashboard__stat-click">
          <StatCard
            title="Complaints"
            value="12"
            icon={AlertCircle}
            color="red"
            change={-8}
            changeLabel="vs last week"
          />
        </div>

        <div onClick={() => navigate('/blocked')} className="dashboard__stat-click">
          <StatCard
            title="Blocked Accounts"
            value="9"
            icon={ShieldOff}
            color="red"
            changeLabel="total blocked"
          />
        </div>

      </div>

      {/* Charts Row */}
      <div className="dashboard__charts">

        {/* Weekly Bookings */}
        <div className="chart-card">
          <div className="chart-card__header">
            <h3 className="chart-card__title">Weekly Bookings</h3>
            <span className="chart-card__badge">This Week</span>
          </div>

          <ResponsiveContainer width="100%" height={240}>
            <BarChart data={weeklyBookings} barGap={4}>
              <CartesianGrid strokeDasharray="3 3" stroke="var(--border)" />
              <XAxis
                dataKey="day"
                tick={{ fontSize: 12, fill: 'var(--text-secondary)' }}
                axisLine={false}
                tickLine={false}
              />
              <YAxis
                tick={{ fontSize: 12, fill: 'var(--text-secondary)' }}
                axisLine={false}
                tickLine={false}
              />
              <Tooltip
                contentStyle={{
                  backgroundColor: 'var(--card-bg)',
                  borderColor: 'var(--border)',
                  borderRadius: '12px',
                  boxShadow: 'var(--shadow-lg)',
                  color: 'var(--text-primary)'
                }}
                itemStyle={{ color: 'var(--text-primary)' }}
                labelStyle={{ color: 'var(--text-secondary)', fontWeight: 600 }}
              />
              <Legend wrapperStyle={{ paddingTop: '10px' }} />
              <Bar dataKey="completed" name="Completed" fill="var(--primary)" radius={[4, 4, 0, 0]} />
              <Bar dataKey="cancelled" name="Cancelled" fill="var(--danger)" radius={[4, 4, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>

        {/* Service Distribution */}
        <div className="chart-card">
          <div className="chart-card__header">
            <h3 className="chart-card__title">Service Distribution</h3>
          </div>

          <ResponsiveContainer width="100%" height={260}>
            <PieChart>
             <Pie
  data={serviceCategories}
  cx="50%"
  cy="50%"
  outerRadius={85}
  innerRadius={40}
  dataKey="value"
  nameKey="name"
  paddingAngle={3}
>
  {serviceCategories.map((_, i) => (
    <Cell key={i} fill={PIE_COLORS[i % PIE_COLORS.length]} />
  ))}
</Pie>

<Tooltip
  contentStyle={{
    backgroundColor: 'var(--card-bg)',
    borderColor: 'var(--border)',
    borderRadius: '12px',
    color: 'var(--text-primary)'
  }}
/>
<Legend />
            </PieChart>
          </ResponsiveContainer>
        </div>

      </div>

      {/* Live Activity */}
      <div className="dashboard__activity">

        {/* Recent Bookings */}
        <div className="activity-card">
          <div className="chart-card__header">
            <h3 className="chart-card__title">Recent Bookings</h3>
            <span
              className="chart-card__badge chart-card__badge--link"
              onClick={() => navigate('/bookings')}
            >
              View all
            </span>
          </div>

          <div className="activity-list">
            {mockBookings.slice(0, 4).map(b => (
              <div key={b.id} className="activity-item">
                <div className="activity-item__info">
                  <p className="activity-item__primary">{b.customer} → {b.provider}</p>
                  <p className="activity-item__secondary">{b.service} · {b.date}</p>
                </div>
                <Badge
                  label={b.status}
                  type={
                    b.status === 'completed' ? 'success'
                    : b.status === 'cancelled' ? 'danger'
                    : b.status === 'active' ? 'info'
                    : 'warning'
                  }
                />
              </div>
            ))}
          </div>
        </div>

        {/* Recent Complaints */}
        <div className="activity-card">
          <div className="chart-card__header">
            <h3 className="chart-card__title">Recent Complaints</h3>
            <span
              className="chart-card__badge chart-card__badge--link"
              onClick={() => navigate('/complaints')}
            >
              View all
            </span>
          </div>

          <div className="activity-list">
            {mockComplaints.slice(0, 4).map(c => (
              <div key={c.id} className="activity-item">
                <div className="activity-item__info">
                  <p className="activity-item__primary">{c.customer} vs {c.provider}</p>
                  <p className="activity-item__secondary">{c.type} · {c.date}</p>
                </div>
                <Badge
                  label={c.severity}
                  type={
                    c.severity === 'high' ? 'danger'
                    : c.severity === 'medium' ? 'warning'
                    : 'success'
                  }
                />
              </div>
            ))}
          </div>
        </div>

        {/* Recently Approved */}
        <div className="activity-card">
          <div className="chart-card__header">
            <h3 className="chart-card__title">Recently Approved</h3>
            <span
              className="chart-card__badge chart-card__badge--link"
              onClick={() => navigate('/verification')}
            >
              View all
            </span>
          </div>

          <div className="activity-list">
            {recentApprovals.map(p => (
              <div key={p.id} className="activity-item">
                <div className="activity-item__avatar">
                  {p.name.charAt(0)}
                </div>
                <div className="activity-item__info">
                  <p className="activity-item__primary">{p.name}</p>
                  <p className="activity-item__secondary">{p.type} · {p.city} · ⭐ {p.rating}</p>
                </div>
                <Badge label={p.type} type="primary" />
              </div>
            ))}
          </div>
        </div>

      </div>
    </div>
  );
}
