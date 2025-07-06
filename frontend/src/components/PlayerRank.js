import React, { useState } from 'react';
import axios from 'axios';
import './PlayerRank.css';

const PlayerRank = () => {
  const [userId, setUserId] = useState('');
  const [rankData, setRankData] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:8000';

  const fetchPlayerRank = async () => {
    if (!userId || userId.trim() === '') {
      setError('Please enter a valid user ID');
      return;
    }

    try {
      setLoading(true);
      setError(null);
      const response = await axios.get(`${API_BASE_URL}/api/leaderboard/rank/${userId}/`);
      setRankData(response.data);
    } catch (err) {
      console.error('Error fetching player rank:', err);
      if (err.response && err.response.status === 404) {
        setError('User not found in leaderboard');
      } else {
        setError('Failed to fetch player rank');
      }
      setRankData(null);
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    fetchPlayerRank();
  };

  const handleInputChange = (e) => {
    setUserId(e.target.value);
    if (error) setError(null);
  };

  return (
    <div className="player-rank-container">
      <h2>🔍 Check Player Rank</h2>
      
      <form onSubmit={handleSubmit} className="rank-form">
        <div className="input-group">
          <input
            type="number"
            placeholder="Enter User ID"
            value={userId}
            onChange={handleInputChange}
            className="user-id-input"
            min="1"
          />
          <button 
            type="submit" 
            disabled={loading || !userId.trim()}
            className="search-btn"
          >
            {loading ? 'Searching...' : 'Get Rank'}
          </button>
        </div>
      </form>

      {error && (
        <div className="error-message">
          {error}
        </div>
      )}

      {rankData && (
        <div className="rank-result">
          <div className="rank-card">
            <div className="rank-info">
              <span className="label">User ID:</span>
              <span className="value">{rankData.user_id}</span>
            </div>
            <div className="rank-info">
              <span className="label">Rank:</span>
              <span className="value rank-number">#{rankData.rank}</span>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default PlayerRank;