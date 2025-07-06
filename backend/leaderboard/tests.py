from django.test import TestCase
from django.contrib.auth import get_user_model
from rest_framework.test import APITestCase
from rest_framework import status
from .models import GameSession, Leaderboard

User = get_user_model()


class LeaderboardModelTests(TestCase):
    def setUp(self):
        self.user1 = User.objects.create_user(username='player1', password='test123')
        self.user2 = User.objects.create_user(username='player2', password='test123')

    def test_game_session_creation(self):
        session = GameSession.objects.create(user=self.user1, score=100)
        self.assertEqual(session.user, self.user1)
        self.assertEqual(session.score, 100)
        self.assertEqual(session.game_mode, 'classic')

    def test_leaderboard_creation(self):
        leaderboard = Leaderboard.objects.create(user=self.user1, total_score=500, rank=1)
        self.assertEqual(leaderboard.user, self.user1)
        self.assertEqual(leaderboard.total_score, 500)
        self.assertEqual(leaderboard.rank, 1)


class LeaderboardAPITests(APITestCase):
    def setUp(self):
        self.user1 = User.objects.create_user(username='player1', password='test123')
        self.user2 = User.objects.create_user(username='player2', password='test123')

    def test_submit_score(self):
        url = '/api/leaderboard/submit/'
        data = {'user_id': self.user1.id, 'score': 150}
        response = self.client.post(url, data, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertIn('message', response.data)
        
        # Check if game session was created
        self.assertTrue(GameSession.objects.filter(user=self.user1, score=150).exists())

    def test_get_top_leaderboard(self):
        # Create some test data
        GameSession.objects.create(user=self.user1, score=200)
        GameSession.objects.create(user=self.user2, score=150)
        
        # Create leaderboard entries
        Leaderboard.objects.create(user=self.user1, total_score=200, rank=1)
        Leaderboard.objects.create(user=self.user2, total_score=150, rank=2)
        
        url = '/api/leaderboard/top/'
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 2)

    def test_get_user_rank(self):
        # Create leaderboard entry
        Leaderboard.objects.create(user=self.user1, total_score=300, rank=1)
        
        url = f'/api/leaderboard/rank/{self.user1.id}/'
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['user_id'], self.user1.id)
        self.assertEqual(response.data['rank'], 1)

    def test_get_user_rank_not_found(self):
        url = f'/api/leaderboard/rank/{999}/'
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)