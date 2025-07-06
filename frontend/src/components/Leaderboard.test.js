import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom';
import axios from 'axios';
import Leaderboard from '../components/Leaderboard';

// Mock axios
jest.mock('axios');
const mockedAxios = axios;

describe('Leaderboard Component', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  test('renders leaderboard title', () => {
    mockedAxios.get.mockResolvedValue({ data: [] });
    render(<Leaderboard />);
    expect(screen.getByText('🏆 Top Players')).toBeInTheDocument();
  });

  test('displays loading state initially', () => {
    mockedAxios.get.mockResolvedValue({ data: [] });
    render(<Leaderboard />);
    expect(screen.getByText('Loading leaderboard...')).toBeInTheDocument();
  });

  test('displays leaderboard data', async () => {
    const mockData = [
      { user: 1, username: 'player1', total_score: 1500, rank: 1 },
      { user: 2, username: 'player2', total_score: 1200, rank: 2 },
    ];
    
    mockedAxios.get.mockResolvedValue({ data: mockData });
    
    render(<Leaderboard />);
    
    await waitFor(() => {
      expect(screen.getByText('player1')).toBeInTheDocument();
      expect(screen.getByText('player2')).toBeInTheDocument();
      expect(screen.getByText('1,500')).toBeInTheDocument();
      expect(screen.getByText('1,200')).toBeInTheDocument();
    });
  });

  test('displays empty state when no players', async () => {
    mockedAxios.get.mockResolvedValue({ data: [] });
    
    render(<Leaderboard />);
    
    await waitFor(() => {
      expect(screen.getByText('No players yet!')).toBeInTheDocument();
    });
  });
});