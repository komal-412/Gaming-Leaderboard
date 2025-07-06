import React from 'react';
import './App.css';
import Leaderboard from './components/Leaderboard';
import PlayerRank from './components/PlayerRank';

function App() {
  return (
    <div className="App">
      <header className="App-header">
        <h1>🎮 Gaming Leaderboard</h1>
      </header>
      <main className="App-main">
        <div className="container">
          <div className="leaderboard-section">
            <Leaderboard />
          </div>
          <div className="player-rank-section">
            <PlayerRank />
          </div>
        </div>
      </main>
    </div>
  );
}

export default App;