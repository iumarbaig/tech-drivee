import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { Mail, Lock, User, UserPlus } from 'lucide-react';
import { useAuth } from '../../context/AuthContext';
import './Signup.css';

const Signup = () => {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  
  const { signup } = useAuth();
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    
    if (!name || !email || !password) {
      setError('Please fill in all fields');
      return;
    }

    if (password.length < 6) {
      setError('Password must be at least 6 characters');
      return;
    }

    setIsLoading(true);
    
    const result = await signup(name, email, password);
    
    if (result.success) {
      navigate('/');
    } else {
      let errorMessage = result.error;
      if (errorMessage.includes('auth/email-already-in-use')) {
        errorMessage = 'An account with this email already exists.';
      } else if (errorMessage.includes('auth/weak-password')) {
        errorMessage = 'Password is too weak. Please use a stronger password.';
      }
      setError(errorMessage);
    }
    
    setIsLoading(false);
  };

  return (
    <div className="signup-container">
      <div className="signup-background">
        <div className="shape shape-1"></div>
        <div className="shape shape-2"></div>
        <div className="shape shape-3"></div>
      </div>
      
      <div className="signup-card">
        <div className="signup-header">
          <h2>Create Account</h2>
          <p>Register as a new TechDrive admin</p>
        </div>

        {error && <div className="signup-error">{error}</div>}

        <form onSubmit={handleSubmit} className="signup-form">
          <div className="input-group">
            <label htmlFor="name">Full Name</label>
            <div className="input-wrapper">
              <User className="input-icon" size={20} />
              <input
                id="name"
                type="text"
                placeholder="John Doe"
                value={name}
                onChange={(e) => setName(e.target.value)}
                autoComplete="name"
              />
            </div>
          </div>

          <div className="input-group">
            <label htmlFor="email">Email Address</label>
            <div className="input-wrapper">
              <Mail className="input-icon" size={20} />
              <input
                id="email"
                type="email"
                placeholder="admin@techdrive.com"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                autoComplete="email"
              />
            </div>
          </div>

          <div className="input-group">
            <label htmlFor="password">Password</label>
            <div className="input-wrapper">
              <Lock className="input-icon" size={20} />
              <input
                id="password"
                type="password"
                placeholder="••••••••"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                autoComplete="new-password"
              />
            </div>
          </div>

          <button 
            type="submit" 
            className={`signup-button ${isLoading ? 'loading' : ''}`}
            disabled={isLoading}
          >
            {isLoading ? (
              <span className="loader"></span>
            ) : (
              <>
                <span>Sign Up</span>
                <UserPlus size={20} />
              </>
            )}
          </button>
        </form>
        
        <div className="auth-links" style={{ marginTop: '20px', textAlign: 'center', fontSize: '14px', color: '#666' }}>
          Already have an account? <Link to="/login" style={{ color: '#007BFF', textDecoration: 'none', fontWeight: '500' }}>Sign in</Link>
        </div>
      </div>
    </div>
  );
};

export default Signup;
