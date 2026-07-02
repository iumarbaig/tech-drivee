import React, { useState } from "react";
import PageHeader from '../../components/common/PageHeader';
import "./Verification.css";

const workers = [
  {
    id: 1,
    name: "Ali Khan",
    role: "Electrician",
    bestScore: 62,
    status: "Pending",
    attemptsData: [
      { score: 45, result: "Failed" },
      { score: 62, result: "Passed" },
      { score: null, result: "Not Taken" },
    ],
    documents: {
      cnic: "CNIC_FRONT.jpg",
      certificate: "Electrician_CERT.pdf",
    },
  },
  {
    id: 2,
    name: "Sara Ahmed",
    role: "Plumber",
    bestScore: 78,
    status: "Pending",
    attemptsData: [
      { score: 78, result: "Passed" },
      { score: null, result: "Not Taken" },
      { score: null, result: "Not Taken" },
    ],
    documents: {
      cnic: "CNIC_BACK.jpg",
      certificate: "Plumbing_CERT.pdf",
    },
  },
];

export default function Verification() {
  const [data, setData] = useState(workers);
  const [openId, setOpenId] = useState(null);

  const handleAction = (id, action) => {
    setData(data.map((w) => w.id === id ? { ...w, status: action } : w));
  };

  return (
    <div className="verification-page animate-fade">
      <PageHeader
        title="Worker Verifications"
        subtitle="Review applicant verification requests and documents."
      />

      <div className="cards-grid">
        {data.map((w) => (
          <div key={w.id} className={`card ${openId === w.id ? 'card--expanded' : ''}`}>

            {/* TOP */}
            <div className="top">
              <div className="user-info">
                <div className="avatar">{w.name.charAt(0)}</div>
                <div>
                  <h3>{w.name}</h3>
                  <div className="role">{w.role}</div>
                </div>
              </div>
              <span className={`badge ${w.status.toLowerCase()}`}>{w.status}</span>
            </div>

            {/* MIDDLE */}
            <div className="middle">
              <div className="attempts">
                <span className="label">Attempts</span>
                <div className="dots">
                  {w.attemptsData.map((a, i) => (
                    <div
                      key={i}
                      className={`dot ${
                        a.result === "Passed" ? "pass"
                        : a.result === "Failed" ? "fail"
                        : "empty"
                      }`}
                    />
                  ))}
                </div>
              </div>

              <div className="score-box">
                <div className="score">{w.bestScore}%</div>
                <div className="score-text">Best Score</div>
              </div>
            </div>

            {/* ACTIONS */}
            <div className="actions">
              <button className="approve-btn" onClick={() => handleAction(w.id, "Approved")}>
                Approve
              </button>
              <button className="reject-btn" onClick={() => handleAction(w.id, "Rejected")}>
                Reject
              </button>
              <button className="view-btn" onClick={() => setOpenId(openId === w.id ? null : w.id)}>
                {openId === w.id ? "Hide Docs" : "View Docs"}
              </button>
            </div>

            {/* EXPANDED */}
            {openId === w.id && (
              <div className="expand">
                <div className="docs">
                  <div className="doc-card">
                    <h5>CNIC</h5>
                    <p>{w.documents.cnic}</p>
                  </div>
                  <div className="doc-card">
                    <h5>Certificate</h5>
                    <p>{w.documents.certificate}</p>
                  </div>
                </div>
              </div>
            )}

          </div>
        ))}
      </div>
    </div>
  );
}
