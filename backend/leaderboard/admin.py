from django.contrib import admin
from .models import User, GameSession, Leaderboard


@admin.register(User)
class UserAdmin(admin.ModelAdmin):
    list_display = ['username', 'id', 'join_date', 'is_active']
    list_filter = ['join_date', 'is_active']
    search_fields = ['username']
    readonly_fields = ['join_date']


@admin.register(GameSession)
class GameSessionAdmin(admin.ModelAdmin):
    list_display = ['user', 'score', 'game_mode', 'timestamp']
    list_filter = ['game_mode', 'timestamp']
    search_fields = ['user__username']
    readonly_fields = ['timestamp']
    ordering = ['-timestamp']


@admin.register(Leaderboard)
class LeaderboardAdmin(admin.ModelAdmin):
    list_display = ['user', 'total_score', 'rank']
    list_filter = ['rank']
    search_fields = ['user__username']
    ordering = ['rank']