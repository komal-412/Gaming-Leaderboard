import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom';
import axios from 'axios';
import PlayerRank from '../components/PlayerRank';

// Mock axios
jest.mock('axios');
const mockedAxios = axios;

describe('PlayerRank Component', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  test('renders player rank title', () => {
    render(<PlayerRank />);
    expect(screen.getByText('🔍 Check Player Rank')).toBeInTheDocument();
  });

  test('renders input and button', () => {
    render(<PlayerRank />);
    expect(screen.getByPlaceholderText('Enter User ID')).toBeInTheDocument();
    expect(screen.getByText('Get Rank')).toBeInTheDocument();
  });

  test('displays rank data after successful fetch', async () => {
    const mockData = { user_id: 1, rank: 5 };
    mockedAxios.get.mockResolvedValue({ data: mockData });
    
    render(<PlayerRank />);
    
    const input = screen.getByPlaceholderText('Enter User ID');
    const button = screen.getByText('Get Rank');
    
    fireEvent.change(input, { target: { value: '1' } });
    fireEvent.click(button);
    
    await waitFor(() => {
      expect(screen.getByText('User ID:')).toBeInTheDocument();
      expect(screen.getByText('Rank:')).toBeInTheDocument();
      expect(screen.getByText('#5')).toBeInTheDocument();
    });
  });

  test('displays error message when user not found', async () => {
    mockedAxios.get.mockRejectedValue({
      response: { status: 404 }
    });
    
    render(<PlayerRank />);
    
    const input = screen.getByPlaceholderText('Enter User ID');
    const button = screen.getByText('Get Rank');
    
    fireEvent.change(input, { target: { value: '999' } });
    fireEvent.click(button);
    
    await waitFor(() => {
      expect(screen.getByText('User not found in leaderboard')).toBeInTheDocument();
    });
  });
});