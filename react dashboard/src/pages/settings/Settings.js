// ── Updated Settings.jsx ──

import React, { useState } from 'react';
import { 
  Save, Eye, EyeOff, Moon, Sun, RefreshCw, 
  Lock, Smartphone, ShieldCheck, CheckCircle, Clock, Bell
} from 'lucide-react';
import PageHeader from '../../components/common/PageHeader';
import './Settings.css';

export default function Settings() {
  const [showPassword, setShowPassword] = useState(false);
  const [darkMode, setDarkMode] = useState(localStorage.getItem('darkMode') === 'true');
  const [autoRefresh, setAutoRefresh] = useState(true);

  const [notifications, setNotifications] = useState({
    newProvider: true,
    complaint: true,
    bookings: false,
    blocked: true,
  });

  const [tfaEnabled, setTfaEnabled] = useState(false);
  const [tfaCode, setTfaCode] = useState('');
  const [tfaSuccess, setTfaSuccess] = useState(false);
  const [passwordSaved, setPasswordSaved] = useState(false);
  const [passwordError, setPasswordError] = useState('');

  const [passwords, setPasswords] = useState({
    current: '',
    newPass: '',
    confirm: '',
  });

  const [loginSessions, setLoginSessions] = useState([
    { id: 1, device: 'MacBook Pro · Chrome', location: 'Karachi, PK', status: 'Active Now', time: 'Current Session', current: true },
    { id: 2, device: 'iPhone 14 · Safari', location: 'Lahore, PK', status: 'Approved', time: '2 hours ago', current: false },
    { id: 3, device: 'Windows PC · Edge', location: 'Islamabad, PK', status: 'Approved', time: 'Yesterday at 4:15 PM', current: false }
  ]);

  const handleDarkModeToggle = (e) => {
    const enabled = e.target.checked;
    setDarkMode(enabled);
    localStorage.setItem('darkMode', enabled ? 'true' : 'false');

    if (enabled) {
      document.body.classList.add('dark-theme');
    } else {
      document.body.classList.remove('dark-theme');
    }
  };

  // Password Validation
  const validatePassword = (password) => {
    const regex =
      /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/;

    return regex.test(password);
  };

  const handleSavePassword = (e) => {
    e.preventDefault();

    setPasswordError('');

    if (!validatePassword(passwords.newPass)) {
      setPasswordError(
        'Password must contain uppercase, lowercase, number, special character and minimum 8 characters.'
      );
      return;
    }

    if (passwords.newPass !== passwords.confirm) {
      setPasswordError('Passwords do not match.');
      return;
    }

    setPasswordSaved(true);

    setTimeout(() => setPasswordSaved(false), 3000);

    setPasswords({
      current: '',
      newPass: '',
      confirm: '',
    });
  };

  const handleToggleTFA = () => {
    if (tfaEnabled) {
      setTfaEnabled(false);
      setTfaSuccess(false);
      setTfaCode('');
    } else {
      setTfaEnabled(true);
    }
  };

  const handleVerifyTFA = (e) => {
    e.preventDefault();

    if (tfaCode.length === 6) {
      setTfaSuccess(true);
    }
  };

  const handleRevokeSession = (id) => {
    setLoginSessions(prev => prev.filter(session => session.id !== id));
  };

  return (
    <div className="settings animate-fade">
      <PageHeader 
        title="Settings" 
        subtitle="Manage application configurations, security protocols, notification defaults, and design preferences." 
      />

      <div className="settings__grid">

        {/* LEFT COLUMN */}
        <div className="settings__col">

          {/* PASSWORD */}
          <div className="settings-card">
            <h3 className="settings-card__title">
              <Lock size={16} className="settings__title-icon" />
              Change Credentials
            </h3>

            <div className="settings-card__body">
              <form onSubmit={handleSavePassword} className="settings__form">

                <div className="form-grid form-grid--single">

                  <div className="form-field">
                    <label>Current Secure Password</label>

                    <div className="input-group">
                      <input
                        type={showPassword ? 'text' : 'password'}
                        className="form-input"
                        placeholder="••••••••••••"
                        required
                        value={passwords.current}
                        onChange={(e) =>
                          setPasswords({ ...passwords, current: e.target.value })
                        }
                      />

                      <button
                        type="button"
                        className="input-group__icon"
                        onClick={() => setShowPassword(p => !p)}
                      >
                        {showPassword ? <EyeOff size={16} /> : <Eye size={16} />}
                      </button>
                    </div>
                  </div>

                  <div className="form-field">
                    <label>New Secure Password</label>

                    <input
                      type={showPassword ? 'text' : 'password'}
                      className="form-input"
                      placeholder="Enter strong password"
                      required
                      value={passwords.newPass}
                      onChange={(e) =>
                        setPasswords({ ...passwords, newPass: e.target.value })
                      }
                    />

                    <span className="password-hint">
                      Must contain uppercase, lowercase, number & special character.
                    </span>
                  </div>

                  <div className="form-field">
                    <label>Confirm New Password</label>

                    <input
                      type={showPassword ? 'text' : 'password'}
                      className="form-input"
                      placeholder="Confirm new password"
                      required
                      value={passwords.confirm}
                      onChange={(e) =>
                        setPasswords({ ...passwords, confirm: e.target.value })
                      }
                    />
                  </div>
                </div>

                {passwordError && (
                  <div className="settings__error">
                    {passwordError}
                  </div>
                )}

                <div className="settings__card-footer">
                  <button type="submit" className="btn btn--primary">
                    <Save size={14} />
                    Update Password
                  </button>

                  {passwordSaved && (
                    <span className="settings__toast">
                      <CheckCircle size={14} />
                      Password updated successfully!
                    </span>
                  )}
                </div>
              </form>
            </div>
          </div>

          {/* 2FA */}
          <div className="settings-card">
            <h3 className="settings-card__title">
              <Smartphone size={16} className="settings__title-icon" />
              Two-Factor Authentication (2FA)
            </h3>

            <div className="settings-card__body">

              <div className="settings-toggle-row">
                <div>
                  <h4 className="settings__small-heading">
                    Secure with Authenticator App
                  </h4>

                  <p className="settings__small-text">
                    Require verification code during sign in.
                  </p>
                </div>

                <label className="toggle">
                  <input
                    type="checkbox"
                    checked={tfaEnabled}
                    onChange={handleToggleTFA}
                  />
                  <span className="toggle__slider" />
                </label>
              </div>

              {tfaEnabled && !tfaSuccess && (
                <div className="settings__tfa-box animate-fade">

                  <div className="settings__tfa-qr-section">

                    <div className="settings__tfa-qr-mock">
                      <div className="settings__tfa-qr-grid">
                        <div className="qr-corner top-left"></div>
                        <div className="qr-corner top-right"></div>
                        <div className="qr-corner bottom-left"></div>

                        <div className="qr-dot"></div>
                        <div className="qr-dot"></div>
                        <div className="qr-dot"></div>
                      </div>
                    </div>

                    <p className="settings__tfa-instructions">
                      Scan QR using Google Authenticator then enter 6 digit code.
                    </p>
                  </div>

                  <form
                    onSubmit={handleVerifyTFA}
                    className="settings__tfa-verify-form"
                  >
                    <input
                      type="text"
                      maxLength="6"
                      placeholder="000000"
                      value={tfaCode}
                      onChange={(e) =>
                        setTfaCode(e.target.value.replace(/\D/g, ''))
                      }
                      className="form-input settings__tfa-input"
                    />

                    <button
                      type="submit"
                      disabled={tfaCode.length !== 6}
                      className="btn btn--primary settings__tfa-btn"
                    >
                      Verify
                    </button>
                  </form>
                </div>
              )}

              {tfaSuccess && (
                <div className="settings__tfa-success animate-fade">
                  <ShieldCheck size={28} className="tfa-success-icon" />

                  <div>
                    <h4 className="settings__success-title">
                      2FA Enabled
                    </h4>

                    <p className="settings__small-text">
                      Your account is now protected.
                    </p>
                  </div>
                </div>
              )}
            </div>
          </div>

          {/* ACTIVE SESSIONS */}
          <div className="settings-card">
            <h3 className="settings-card__title">
              <Clock size={16} className="settings__title-icon" />
              Active System Sessions
            </h3>

            <div className="settings-card__body">

              <div className="settings__sessions-list">
                {loginSessions.map((session) => (
                  <div
                    key={session.id}
                    className={`settings__session-item ${
                      session.current ? 'current' : ''
                    }`}
                  >
                    <div className="settings__session-info">
                      <span className="settings__session-device">
                        {session.device}
                      </span>

                      <span className="settings__session-meta">
                        {session.location} · {session.time}
                      </span>
                    </div>

                    {session.current ? (
                      <span className="settings__session-badge active">
                        Active
                      </span>
                    ) : (
                      <button
                        onClick={() => handleRevokeSession(session.id)}
                        className="settings__session-revoke"
                      >
                        Revoke
                      </button>
                    )}
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>

        {/* RIGHT COLUMN */}
        <div className="settings__col">

          {/* APPEARANCE */}
          <div className="settings-card">
            <h3 className="settings-card__title">
              <Sun size={16} className="settings__title-icon" />
              Appearance Settings
            </h3>

            <div className="settings-card__body">

              <div className="settings-toggle-row">
                <div className="settings__row-left">
                  {darkMode ? (
                    <Moon size={16} className="settings__row-icon" />
                  ) : (
                    <Sun size={16} className="settings__row-icon" />
                  )}

                  <span>Dark Mode Theme</span>
                </div>

                <label className="toggle">
                  <input
                    type="checkbox"
                    checked={darkMode}
                    onChange={handleDarkModeToggle}
                  />
                  <span className="toggle__slider" />
                </label>
              </div>

              <div className="settings-toggle-row">
                <div className="settings__row-left">
                  <RefreshCw size={16} className="settings__row-icon" />
                  <span>Auto Refresh Dashboard</span>
                </div>

                <label className="toggle">
                  <input
                    type="checkbox"
                    checked={autoRefresh}
                    onChange={(e) => setAutoRefresh(e.target.checked)}
                  />
                  <span className="toggle__slider" />
                </label>
              </div>

            </div>
          </div>

          {/* NOTIFICATIONS */}
          <div className="settings-card">
            <h3 className="settings-card__title">
              <Bell size={16} className="settings__title-icon" />
              Notification Preferences
            </h3>

            <div className="settings-card__body">

              {Object.entries({
                newProvider: 'New provider registrations',
                complaint: 'New complaint submissions',
                bookings: 'All booking updates',
                blocked: 'Account auto-blocking events',
              }).map(([key, label]) => (
                <div key={key} className="settings-toggle-row">

                  <span>{label}</span>

                  <label className="toggle">
                    <input
                      type="checkbox"
                      checked={notifications[key]}
                      onChange={(e) =>
                        setNotifications(prev => ({
                          ...prev,
                          [key]: e.target.checked
                        }))
                      }
                    />

                    <span className="toggle__slider" />
                  </label>
                </div>
              ))}
            </div>
          </div>

        </div>
      </div>
    </div>
  );
}