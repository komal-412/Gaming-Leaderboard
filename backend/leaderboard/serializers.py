from rest_framework import serializers
from .models import User, GameSession, Leaderboard


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'join_date']


class GameSessionSerializer(serializers.ModelSerializer):
    class Meta:
        model = GameSession
        fields = ['id', 'user', 'score', 'game_mode', 'timestamp']


class LeaderboardSerializer(serializers.ModelSerializer):
    username = serializers.CharField(source='user.username', read_only=True)
    
    class Meta:
        model = Leaderboard
        fields = ['user', 'username', 'total_score', 'rank']


class ScoreSubmissionSerializer(serializers.Serializer):
    user_id = serializers.IntegerField()
    score = serializers.IntegerField(min_value=0)


class RankResponseSerializer(serializers.Serializer):
    user_id = serializers.IntegerField()
    rank = serializers.IntegerField()