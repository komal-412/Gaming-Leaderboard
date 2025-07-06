from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.response import Response
from django.db import transaction
from django.core.cache import cache
from django.db.models import Sum, F
from .models import User, GameSession, Leaderboard
from .serializers import (
    ScoreSubmissionSerializer, 
    LeaderboardSerializer, 
    RankResponseSerializer
)
import logging

logger = logging.getLogger(__name__)


@api_view(['POST'])
def submit_score(request):
    """
    Submit a new score and update leaderboard atomically
    """
    serializer = ScoreSubmissionSerializer(data=request.data)
    if not serializer.is_valid():
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    user_id = serializer.validated_data['user_id']
    score = serializer.validated_data['score']
    
    try:
        with transaction.atomic():
            # Get user
            user = User.objects.get(id=user_id)
            
            # Create game session
            GameSession.objects.create(user=user, score=score)
            
            # Calculate new total score
            total_score = GameSession.objects.filter(user=user).aggregate(
                total=Sum('score')
            )['total'] or 0
            
            # Update or create leaderboard entry
            leaderboard_entry, created = Leaderboard.objects.get_or_create(
                user=user,
                defaults={'total_score': total_score}
            )
            if not created:
                leaderboard_entry.total_score = total_score
                leaderboard_entry.save()
            
            # Update ranks for all users
            update_all_ranks()
            
            # Clear cache
            cache.delete('leaderboard_top_10')
            cache.delete(f'user_rank_{user_id}')
            
        return Response({
            'message': 'Score submitted successfully',
            'total_score': total_score
        }, status=status.HTTP_201_CREATED)
        
    except User.DoesNotExist:
        return Response(
            {'error': 'User not found'}, 
            status=status.HTTP_404_NOT_FOUND
        )
    except Exception as e:
        logger.error(f"Error submitting score: {str(e)}")
        return Response(
            {'error': 'Internal server error'}, 
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['GET'])
def get_top_leaderboard(request):
    """
    Get top 10 users from leaderboard with Redis caching
    """
    cache_key = 'leaderboard_top_10'
    cached_data = cache.get(cache_key)
    
    if cached_data:
        return Response(cached_data)
    
    try:
        top_users = Leaderboard.objects.select_related('user').order_by('-total_score')[:10]
        serializer = LeaderboardSerializer(top_users, many=True)
        
        # Cache for 5 seconds
        cache.set(cache_key, serializer.data, 5)
        
        return Response(serializer.data)
        
    except Exception as e:
        logger.error(f"Error getting top leaderboard: {str(e)}")
        return Response(
            {'error': 'Internal server error'}, 
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['GET'])
def get_user_rank(request, user_id):
    """
    Get rank for a specific user with Redis caching
    """
    cache_key = f'user_rank_{user_id}'
    cached_rank = cache.get(cache_key)
    
    if cached_rank is not None:
        return Response({'user_id': user_id, 'rank': cached_rank})
    
    try:
        leaderboard_entry = Leaderboard.objects.get(user_id=user_id)
        rank = leaderboard_entry.rank
        
        # Cache for 30 seconds
        cache.set(cache_key, rank, 30)
        
        serializer = RankResponseSerializer({
            'user_id': user_id,
            'rank': rank
        })
        
        return Response(serializer.data)
        
    except Leaderboard.DoesNotExist:
        return Response(
            {'error': 'User not found in leaderboard'}, 
            status=status.HTTP_404_NOT_FOUND
        )
    except Exception as e:
        logger.error(f"Error getting user rank: {str(e)}")
        return Response(
            {'error': 'Internal server error'}, 
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


def update_all_ranks():
    """
    Update ranks for all leaderboard entries
    """
    leaderboard_entries = Leaderboard.objects.order_by('-total_score')
    
    for index, entry in enumerate(leaderboard_entries, start=1):
        entry.rank = index
    
    # Bulk update for performance
    Leaderboard.objects.bulk_update(leaderboard_entries, ['rank'])