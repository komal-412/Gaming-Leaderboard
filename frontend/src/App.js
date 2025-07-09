import React, { useState, useEffect } from 'react';
import './App.css';

function App() {
  const [leaderboard, setLeaderboard] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  
  // Score submission state
  const [submissionForm, setSubmissionForm] = useState({
    username: '',
    score: '',
    gameMode: 'classic'
  });
  const [submitting, setSubmitting] = useState(false);
  const [submitMessage, setSubmitMessage] = useState('');

  const fetchLeaderboard = async () => {
    try {
      setLoading(true);
      const response = await fetch('http://localhost:8000/api/leaderboard/top/');
      if (!response.ok) {
        throw new Error('Failed to fetch leaderboard');
      }
      const data = await response.json();
      setLeaderboard(data);
      setError(null);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const handleSubmitScore = async (e) => {
    e.preventDefault();
    
    if (!submissionForm.username.trim() || !submissionForm.score) {
      setSubmitMessage('Please fill in all fields');
      return;
    }

    if (submissionForm.score < 0) {
      setSubmitMessage('Score must be non-negative');
      return;
    }

    setSubmitting(true);
    setSubmitMessage('');

    try {
      // Create a simple hash from username to get consistent user_id
      const userId = Math.abs(submissionForm.username.split('').reduce((a, b) => {
        a = ((a << 5) - a) + b.charCodeAt(0);
        return a & a;
      }, 0)) % 1000 + 1;

      const submitResponse = await fetch('http://localhost:8000/api/leaderboard/submit/', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          user_id: userId,
          score: parseInt(submissionForm.score),
          game_mode: submissionForm.gameMode
        }),
      });

      if (submitResponse.ok) {
        const result = await submitResponse.json();
        setSubmitMessage(`✅ Score submitted successfully! Total score: ${result.total_score}`);
        setSubmissionForm({ username: '', score: '', gameMode: 'classic' });
        
        // Refresh leaderboard after successful submission
        setTimeout(() => {
          fetchLeaderboard();
        }, 1000);
      } else {
        const errorData = await submitResponse.json();
        setSubmitMessage(`❌ Error: ${errorData.error || 'Failed to submit score'}`);
      }
    } catch (err) {
      setSubmitMessage(`❌ Error: ${err.message}`);
    } finally {
      setSubmitting(false);
    }
  };

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setSubmissionForm(prev => ({
      ...prev,
      [name]: value
    }));
  };

  useEffect(() => {
    fetchLeaderboard();
  }, []);

  return (
    <div className="App">
      <header className="App-header">
        <h1>🏆 Gaming Leaderboard</h1>
        
        {/* Score Submission Form */}
        <div className="score-submission">
          <h2>📝 Submit New Score</h2>
          <form onSubmit={handleSubmitScore} className="submission-form">
            <div className="form-group">
              <label htmlFor="username">Player Name:</label>
              <input
                type="text"
                id="username"
                name="username"
                value={submissionForm.username}
                onChange={handleInputChange}
                placeholder="Enter your username"
                disabled={submitting}
                required
              />
            </div>
            
            <div className="form-group">
              <label htmlFor="score">Score:</label>
              <input
                type="number"
                id="score"
                name="score"
                value={submissionForm.score}
                onChange={handleInputChange}
                placeholder="Enter your score"
                min="0"
                disabled={submitting}
                required
              />
            </div>
            
            <div className="form-group">
              <label htmlFor="gameMode">Game Mode:</label>
              <select
                id="gameMode"
                name="gameMode"
                value={submissionForm.gameMode}
                onChange={handleInputChange}
                disabled={submitting}
              >
                <option value="classic">Classic</option>
                <option value="solo">Solo</option>
                <option value="team">Team</option>
                <option value="ranked">Ranked</option>
                <option value="casual">Casual</option>
              </select>
            </div>
            
            <button 
              type="submit" 
              className="submit-button"
              disabled={submitting}
            >
              {submitting ? '⏳ Submitting...' : '🚀 Submit Score'}
            </button>
          </form>
          
          {submitMessage && (
            <div className={`submit-message ${submitMessage.includes('✅') ? 'success' : 'error'}`}>
              {submitMessage}
            </div>
          )}
        </div>

        {/* Leaderboard Display */}
        <div className="leaderboard-section">
          <h2>🏅 Top Players</h2>
          <button onClick={fetchLeaderboard} className="refresh-button" disabled={loading}>
            {loading ? '⏳ Loading...' : '🔄 Refresh Leaderboard'}
          </button>
          
          {error && (
            <div className="error-message">
              ❌ Error: {error}
            </div>
          )}

          {!loading && !error && (
            <div className="leaderboard">
              {leaderboard.length > 0 ? (
                <table className="leaderboard-table">
                  <thead>
                    <tr>
                      <th>Rank</th>
                      <th>Player</th>
                      <th>Total Score</th>
                    </tr>
                  </thead>
                  <tbody>
                    {leaderboard.map((player) => (
                      <tr key={player.user_id} className={player.rank <= 3 ? `rank-${player.rank}` : ''}>
                        <td>
                          {player.rank === 1 && '🥇'}
                          {player.rank === 2 && '🥈'}
                          {player.rank === 3 && '🥉'}
                          {player.rank > 3 && `#${player.rank}`}
                        </td>
                        <td>{player.username}</td>
                        <td>{player.total_score.toLocaleString()}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              ) : (
                <p>No players yet. Be the first to submit a score! 🎮</p>
              )}
            </div>
          )}
        </div>
      </header>
    </div>
  );
}

export default App;