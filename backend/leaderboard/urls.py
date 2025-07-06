from django.urls import path
from . import views

urlpatterns = [
    path('submit/', views.submit_score, name='submit_score'),
    path('top/', views.get_top_leaderboard, name='top_leaderboard'),
    path('rank/<int:user_id>/', views.get_user_rank, name='user_rank'),
]