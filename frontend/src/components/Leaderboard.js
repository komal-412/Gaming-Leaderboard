import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './Leaderboard.css';

const Leaderboard = () => {
  const [leaderboardData, setLeaderboardData] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:8000';

  const fetchLeaderboard = async () => {
    try {
      setLoading(true);
      const response = await axios.get(`${API_BASE_URL}/api/leaderboard/top/`);
      setLeaderboardData(response.data);
      setError(null);
    } catch (err) {
      console.error('Error fetching leaderboard:', err);
      setError('Failed to load leaderboard');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    // Initial fetch
    fetchLeaderboard();

    // Poll every 5 seconds
    const interval = setInterval(fetchLeaderboard, 5000);

    // Cleanup interval on component unmount
    return () => clearInterval(interval);
  }, []);

  if (loading && leaderboardData.length === 0) {
    return (
      <div className="leaderboard-container">
        <h2>🏆 Top Players</h2>
        <div className="loading">Loading leaderboard...</div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="leaderboard-container">
        <h2>🏆 Top Players</h2>
        <div className="error">{error}</div>
        <button onClick={fetchLeaderboard} className="retry-btn">
          Retry
        </button>
      </div>
    );
  }

  return (
    <div className="leaderboard-container">
      <h2>🏆 Top Players</h2>
      <div className="leaderboard-list">
        {leaderboardData.length === 0 ? (
          <div className="empty-state">No players yet!</div>
        ) : (
          leaderboardData.map((player, index) => (
            <div key={player.user} className={`leaderboard-item rank-${index + 1}`}>
              <div className="rank">#{player.rank}</div>
              <div className="username">{player.username}</div>
              <div className="score">{player.total_score.toLocaleString()}</div>
            </div>
          ))
        )}
      </div>
      <div className="last-updated">
        Last updated: {new Date().toLocaleTimeString()}
      </div>
    </div>
  );
};

export default Leaderboard;