#!/bin/bash

echo "🧹 Gaming Leaderboard - File Cleanup Script"

echo "📋 This will remove unnecessary scripts and keep only essential files"
echo ""
echo "Files to be REMOVED (development/testing scripts):"
echo "  - populate_data.sh (old version)"
echo "  - populate_data_with_logs.sh"
echo "  - populate_large_dataset.sql"
echo "  - recovery_check.sh" 
echo "  - diagnose_users.sh"
echo "  - force_create_users.sh"
echo "  - diagnose_performance_issue.sh"
echo "  - fix_performance_issues.sh"
echo "  - performance_test.sh (original)"
echo "  - check_db_status.sh"
echo "  - fix_data_integrity.sh"
echo "  - fix_startup.sh"
echo "  - force_clean.sh"
echo "  - fresh_start_setup.sh"
echo "  - view_logs.sh"
echo "  - WHERE_TO_RUN_COMMANDS.md"
echo "  - LARGE_DATASET_TESTING.md"
echo ""
echo "Files to be KEPT (essential for production):"
echo "  ✅ docker-compose.yml"
echo "  ✅ README.md"
echo "  ✅ DEVELOPMENT.md"
echo "  ✅ SCORE_SUBMISSION.md"
echo "  ✅ backend/ (entire directory)"
echo "  ✅ frontend/ (entire directory)"
echo "  ✅ setup.sh"
echo "  ✅ clean_restart.sh"
echo "  ✅ demo_scores.sh"
echo "  ✅ test_api.sh"
echo "  ✅ troubleshoot.sh"
echo "  ✅ populate_large_data.sh"
echo "  ✅ performance_test_fixed.sh"
echo "  ✅ manual_populate.sh"
echo "  ✅ quick_test.sh"
echo "  ✅ .env.example"
echo ""

read -p "Continue with cleanup? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cleanup cancelled."
    exit 1
fi

echo ""
echo "🗑️  Removing unnecessary files..."

# Remove old/redundant scripts
rm -f populate_data.sh
rm -f populate_data_with_logs.sh
rm -f populate_large_dataset.sql
rm -f recovery_check.sh
rm -f diagnose_users.sh
rm -f force_create_users.sh
rm -f diagnose_performance_issue.sh
rm -f fix_performance_issues.sh
rm -f performance_test.sh
rm -f check_db_status.sh
rm -f fix_data_integrity.sh
rm -f fix_startup.sh
rm -f force_clean.sh
rm -f fresh_start_setup.sh
rm -f view_logs.sh

# Remove redundant documentation
rm -f WHERE_TO_RUN_COMMANDS.md
rm -f LARGE_DATASET_TESTING.md

echo "✅ Cleanup completed!"

echo ""
echo "📁 Final project structure:"
echo "Gaming Leaderboard/"
echo "├── 📄 README.md                    # Main documentation"
echo "├── 📄 DEVELOPMENT.md               # Development guide"
echo "├── 📄 SCORE_SUBMISSION.md          # API usage guide"
echo "├── 📄 docker-compose.yml           # Container orchestration"
echo "├── 📄 .env.example                 # Environment variables template"
echo "├── 📁 backend/                     # Django backend"
echo "│   ├── gaming_leaderboard/         # Django project"
echo "│   ├── leaderboard/                # Django app"
echo "│   ├── requirements.txt"
echo "│   ├── Dockerfile"
echo "│   └── manage.py"
echo "├── 📁 frontend/                    # React frontend"
echo "│   ├── src/"
echo "│   ├── public/"
echo "│   ├── package.json"
echo "│   └── Dockerfile"
echo "└── 🔧 Scripts:"
echo "    ├── setup.sh                    # Initial setup"
echo "    ├── clean_restart.sh            # Clean restart"
echo "    ├── demo_scores.sh              # Demo data"
echo "    ├── test_api.sh                 # API testing"
echo "    ├── troubleshoot.sh             # Troubleshooting"
echo "    ├── populate_large_data.sh      # Large dataset population"
echo "    ├── performance_test_fixed.sh   # Performance testing"
echo "    ├── manual_populate.sh          # Manual data creation"
echo "    └── quick_test.sh               # Quick system test"

echo ""
echo "🎯 Essential commands after cleanup:"
echo ""
echo "🚀 Setup & Start:"
echo "   ./setup.sh                       # Initial setup"
echo "   docker compose up -d             # Start services"
echo ""
echo "📊 Add Data:"
echo "   ./quick_test.sh                  # Add sample data"
echo "   ./demo_scores.sh                 # Add demo scores"
echo "   ./populate_large_data.sh         # Add large dataset"
echo ""
echo "🧪 Testing:"
echo "   ./test_api.sh                    # Test API endpoints"
echo "   ./performance_test_fixed.sh      # Performance testing"
echo ""
echo "🔧 Maintenance:"
echo "   ./clean_restart.sh               # Clean restart"
echo "   ./troubleshoot.sh                # Diagnose issues"
echo ""
echo "📚 Documentation:"
echo "   README.md                        # Main documentation"
echo "   SCORE_SUBMISSION.md              # API usage guide"
echo "   DEVELOPMENT.md                   # Development commands"

echo ""
echo "✨ Project is now cleaned up and production-ready!"