from django.db import models
from django.contrib.auth.models import AbstractUser


class User(AbstractUser):
    join_date = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return self.username


class GameSession(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='game_sessions')
    score = models.IntegerField()
    game_mode = models.CharField(max_length=50, default='classic')
    timestamp = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        indexes = [
            models.Index(fields=['user']),
            models.Index(fields=['timestamp']),
        ]
    
    def __str__(self):
        return f"{self.user.username} - {self.score} - {self.timestamp}"


class Leaderboard(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='leaderboard_entry')
    total_score = models.IntegerField(default=0)
    rank = models.IntegerField(default=0)
    
    class Meta:
        indexes = [
            models.Index(fields=['total_score']),
            models.Index(fields=['rank']),
        ]
        ordering = ['-total_score']
    
    def __str__(self):
        return f"{self.user.username} - Rank {self.rank} - Score {self.total_score}"