#!/bin/bash
# Automatically process any new CSV files and update dashboard

cd ~/salesforce-opportunity-tool

echo "========================================"
echo "🔄 Auto CSV Processing & GitHub Sync"
echo "Started: $(date '+%Y-%m-%d %H:%M:%S')"
echo "========================================"

# Find the most recent CSV file
LATEST_CSV=$(ls -t uploads/*.csv 2>/dev/null | head -1)

if [ -z "$LATEST_CSV" ]; then
    echo "ℹ️  No CSV files found in uploads/"
    echo "   Keeping existing data"
    exit 0
fi

# Check if this CSV was already processed
LAST_PROCESSED_FILE="data/last_processed_csv.txt"
if [ -f "$LAST_PROCESSED_FILE" ]; then
    LAST_PROCESSED=$(cat "$LAST_PROCESSED_FILE")
    if [ "$LATEST_CSV" = "$LAST_PROCESSED" ]; then
        echo "ℹ️  Latest CSV already processed: $(basename $LATEST_CSV)"
        echo "   No update needed"
        exit 0
    fi
fi

echo "📄 Processing: $(basename $LATEST_CSV)"
echo ""

# Activate virtual environment
source venv/bin/activate

# Clear database first (to match report exactly)
echo "🗑️  Clearing database for fresh import..."
python3 << 'CLEAR_EOF'
import sqlite3
from db_helper import get_db_connection

conn = get_db_connection()
cursor = conn.cursor()
cursor.execute('DELETE FROM opportunities')
conn.commit()
conn.close()
print("✅ Database cleared")
CLEAR_EOF

echo ""

# Process the CSV
python3 << EOF
import sys
sys.path.insert(0, '.')
from app import process_csv, read_csv_with_encoding

csv_file = '$LATEST_CSV'
print(f"Reading CSV: {csv_file}")

try:
    df = read_csv_with_encoding(csv_file)
    result = process_csv(df, csv_file)

    if result.get('success'):
        print(f"✅ Processed successfully!")
        print(f"   New: {result.get('new', 0)}")
        print(f"   Updated: {result.get('updated', 0)}")
        sys.exit(0)
    else:
        print(f"❌ Error: {result.get('error', 'Unknown')}")
        sys.exit(1)
except Exception as e:
    print(f"❌ Error: {str(e)}")
    sys.exit(1)
EOF

if [ $? -ne 0 ]; then
    echo "❌ CSV processing failed"
    exit 1
fi

# Export to JSON
echo ""
echo "📊 Exporting to JSON..."
python3 export_to_json.py

if [ $? -ne 0 ]; then
    echo "❌ Export failed"
    exit 1
fi

# Mark this CSV as processed
echo "$LATEST_CSV" > "$LAST_PROCESSED_FILE"

# Push to GitHub
echo ""
echo "📤 Pushing to GitHub..."

git add data/opportunities.json data/last_sync.txt data/last_processed_csv.txt

if git diff --cached --quiet; then
    echo "ℹ️  No changes to push"
    exit 0
fi

TIMESTAMP=$(date '+%Y-%m-%d %H:%M')
RECORD_COUNT=$(grep "Total opportunities" data/last_sync.txt | awk '{print $3}')

git commit -m "Auto-update: $RECORD_COUNT opportunities ($TIMESTAMP)"
git push origin main

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Successfully updated!"
    echo "📊 Dashboard will refresh in 1-2 minutes"
    echo "🌐 URL: https://rituraman-prog.github.io/salesforce-dashboard/"
else
    echo "❌ Push to GitHub failed"
    exit 1
fi

echo ""
echo "========================================"
echo "✅ Sync Complete!"
echo "========================================"
