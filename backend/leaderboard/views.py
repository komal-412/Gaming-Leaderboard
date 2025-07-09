from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from django.db.models import Sum
from django.db import transaction
from django.core.cache import cache
from .models import User, GameSession, Leaderboard
import logging

logger = logging.getLogger(__name__)

@api_view(['GET'])
def get_top_leaderboard(request):
    """Ultra-fast top 10 leaderboard"""
    cache_key = 'leaderboard_top_10'
    cached_data = cache.get(cache_key)
    
    if cached_data:
        return Response(cached_data)
    
    try:
        # Get top 10 by score directly (no complex joins)
        top_players = Leaderboard.objects.select_related('user').order_by('-total_score')[:10]
        
        data = []
        for index, entry in enumerate(top_players, 1):
            data.append({
                'rank': index,
                'user_id': entry.user.id,
                'username': entry.user.username,
                'total_score': entry.total_score
            })
        
        cache.set(cache_key, data, 60)  # Cache for 1 minute
        return Response(data)
        
    except Exception as e:
        logger.error(f"Error in get_top_leaderboard: {str(e)}")
        return Response([])  # Return empty list on error

@api_view(['GET'])
def get_user_rank(request, user_id):
    """Ultra-fast user rank lookup"""
    try:
        leaderboard_entry = Leaderboard.objects.select_related('user').get(user_id=user_id)
        
        # Calculate rank by counting higher scores (fast query)
        higher_scores = Leaderboard.objects.filter(total_score__gt=leaderboard_entry.total_score).count()
        
        return Response({
            'user_id': leaderboard_entry.user.id,
            'username': leaderboard_entry.user.username,
            'rank': higher_scores + 1,
            'total_score': leaderboard_entry.total_score
        })
        
    except Leaderboard.DoesNotExist:
        return Response({'error': 'User not in leaderboard'}, status=404)
    except Exception as e:
        return Response({'error': 'Server error'}, status=500)

@api_view(['POST'])
def submit_score(request):
    """ULTRA-OPTIMIZED score submission - fastest possible"""
    # Minimal validation for maximum speed
    user_id = request.data.get('user_id')
    score = request.data.get('score')
    
    if not user_id or score is None:
        return Response({'error': 'Missing data'}, status=400)
    
    try:
        user_id = int(user_id)
        score = int(score)
    except:
        return Response({'error': 'Invalid data'}, status=400)
    
    if score < 0:
        return Response({'error': 'Negative score'}, status=400)
    
    try:
        # FASTEST POSSIBLE: Direct database operations, no complex queries
        with transaction.atomic():
            # Create session (minimal fields)
            GameSession.objects.create(
                user_id=user_id,
                score=score,
                game_mode=request.data.get('game_mode', 'classic')
            )
            
            # Calculate total efficiently
            total_score = GameSession.objects.filter(user_id=user_id).aggregate(
                total=Sum('score')
            )['total'] or 0
            
            # Update leaderboard
            Leaderboard.objects.update_or_create(
                user_id=user_id,
                defaults={'total_score': total_score}
            )
        
        # Minimal cache clearing
        cache.delete('leaderboard_top_10')
        
        return Response({
            'message': 'Success',
            'total_score': total_score
        }, status=201)
        
    except Exception as e:
        logger.error(f"Submit error: {str(e)}")
        return Response({'error': 'Server error'}, status=500)
