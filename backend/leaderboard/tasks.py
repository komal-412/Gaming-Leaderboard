from celery import shared_task
from django.core.cache import cache
from .models import Leaderboard
import logging

logger = logging.getLogger(__name__)


@shared_task
def recompute_all_ranks():
    """
    Periodic task to recompute all ranks in batch
    """
    try:
        leaderboard_entries = Leaderboard.objects.order_by('-total_score')
        
        for index, entry in enumerate(leaderboard_entries, start=1):
            entry.rank = index
        
        # Bulk update for performance
        Leaderboard.objects.bulk_update(leaderboard_entries, ['rank'])
        
        # Clear all rank caches
        cache.delete('leaderboard_top_10')
        
        # Clear individual user rank caches
        for entry in leaderboard_entries:
            cache.delete(f'user_rank_{entry.user_id}')
        
        logger.info(f"Successfully recomputed ranks for {len(leaderboard_entries)} users")
        
    except Exception as e:
        logger.error(f"Error recomputing ranks: {str(e)}")
        raise