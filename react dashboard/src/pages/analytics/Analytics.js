import React from 'react';
import {
  BarChart, Bar, LineChart, Line,
  XAxis, YAxis, CartesianGrid, Tooltip, Legend,
  ResponsiveContainer, AreaChart, Area
} from 'recharts';
import PageHeader from '../../components/common/PageHeader';
import StatCard from '../../components/common/StatCard';
import { TrendingUp, Users, Star } from 'lucide-react';
import { weeklyBookings, providerGrowth, complaintTrend } from '../../data/mockData';
import '../dashboard/Dashboard.css';

export default function Analytics() {
  return (
    <div className="dashboard animate-fade">
      <PageHeader
        title="Reports & Analytics"
        subtitle="Platform-wide insights and performance metrics."
      />

      <div className="dashboard__stats">
        <StatCard title="Total Bookings"  value="1,842" icon={TrendingUp} color="blue"   change={14} changeLabel="vs last month" />
        <StatCard title="Total Providers" value="186"   icon={Users}      color="cyan"   change={8}  changeLabel="vs last month" />
        <StatCard title="Avg. Rating"     value="4.6"   icon={Star}       color="yellow" change={2}  changeLabel="avg rating" />
      </div>

      <div className="dashboard__charts">

        {/* Booking Volume Weekly */}
        <div className="chart-card">
          <div className="chart-card__header">
            <h3 className="chart-card__title">Booking Volume (Weekly)</h3>
            <span className="chart-card__badge">Real-time</span>
          </div>
          <ResponsiveContainer width="100%" height={250}>
            <AreaChart data={weeklyBookings}>
              <defs>
                <linearGradient id="bookGrad" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%"  stopColor="var(--primary)" stopOpacity={0.2} />
                  <stop offset="95%" stopColor="var(--primary)" stopOpacity={0} />
                </linearGradient>
              </defs>
              <CartesianGrid strokeDasharray="3 3" stroke="var(--border)" />
              <XAxis dataKey="day" tick={{ fontSize: 12, fill: 'var(--text-secondary)' }} axisLine={false} tickLine={false} />
              <YAxis tick={{ fontSize: 12, fill: 'var(--text-secondary)' }} axisLine={false} tickLine={false} />
              <Tooltip
                contentStyle={{ backgroundColor: 'var(--card-bg)', borderColor: 'var(--border)', borderRadius: '12px', boxShadow: 'var(--shadow-lg)', color: 'var(--text-primary)' }}
                itemStyle={{ color: 'var(--text-primary)' }}
                labelStyle={{ color: 'var(--text-secondary)', fontWeight: 600 }}
              />
              <Area type="monotone" dataKey="bookings" fill="url(#bookGrad)" stroke="var(--primary)" strokeWidth={3} dot={false} />
            </AreaChart>
          </ResponsiveContainer>
        </div>

        {/* Provider Growth */}
        <div className="chart-card">
          <div className="chart-card__header">
            <h3 className="chart-card__title">Provider Growth (6 Months)</h3>
            <span className="chart-card__badge">By Category</span>
          </div>
          <ResponsiveContainer width="100%" height={250}>
            <LineChart data={providerGrowth}>
              <CartesianGrid strokeDasharray="3 3" stroke="var(--border)" />
              <XAxis dataKey="month" tick={{ fontSize: 12, fill: 'var(--text-secondary)' }} axisLine={false} tickLine={false} />
              <YAxis tick={{ fontSize: 12, fill: 'var(--text-secondary)' }} axisLine={false} tickLine={false} />
              <Tooltip
                contentStyle={{ backgroundColor: 'var(--card-bg)', borderColor: 'var(--border)', borderRadius: '12px', boxShadow: 'var(--shadow-lg)', color: 'var(--text-primary)' }}
                itemStyle={{ color: 'var(--text-primary)' }}
                labelStyle={{ color: 'var(--text-secondary)', fontWeight: 600 }}
              />
              <Legend wrapperStyle={{ paddingTop: '10px' }} />
              <Line type="monotone" dataKey="electricians" stroke="var(--primary)" strokeWidth={3} dot={false} activeDot={{ r: 5 }} />
              <Line type="monotone" dataKey="plumbers"     stroke="var(--cyan)"    strokeWidth={3} dot={false} activeDot={{ r: 5 }} />
            </LineChart>
          </ResponsiveContainer>
        </div>

      </div>

      {/* Complaints vs Resolutions */}
      <div className="chart-card" style={{ marginTop: '24px' }}>
        <div className="chart-card__header">
          <h3 className="chart-card__title">Complaints vs Resolutions</h3>
          <span className="chart-card__badge">Trend Analysis</span>
        </div>
        <ResponsiveContainer width="100%" height={260}>
          <BarChart data={complaintTrend}>
            <CartesianGrid strokeDasharray="3 3" stroke="var(--border)" />
            <XAxis dataKey="month" tick={{ fontSize: 12, fill: 'var(--text-secondary)' }} axisLine={false} tickLine={false} />
            <YAxis tick={{ fontSize: 12, fill: 'var(--text-secondary)' }} axisLine={false} tickLine={false} />
            <Tooltip
              contentStyle={{ backgroundColor: 'var(--card-bg)', borderColor: 'var(--border)', borderRadius: '12px', boxShadow: 'var(--shadow-lg)', color: 'var(--text-primary)' }}
              itemStyle={{ color: 'var(--text-primary)' }}
              labelStyle={{ color: 'var(--text-secondary)', fontWeight: 600 }}
            />
            <Legend wrapperStyle={{ paddingTop: '10px' }} />
            <Bar dataKey="complaints" name="Complaints" fill="#8B5CF6" radius={[4,4,0,0]} />
            <Bar dataKey="resolved"   name="Resolved"   fill="#4F46E5" radius={[4,4,0,0]} />
          </BarChart>
        </ResponsiveContainer>
      </div>

    </div>
  );
}