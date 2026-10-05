#!/bin/bash
# FULLY AUTOMATED SYNC - Zero Manual Work Required!
# Automatically logs into Salesforce, exports data, updates dashboard

cd ~/salesforce-opportunity-tool

echo "========================================================================"
echo "🤖 FULLY AUTOMATED SALESFORCE SYNC"
echo "========================================================================"
echo "Started: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# Step 1: Auto-export from Salesforce (browser automation)
echo "Step 1: Logging into Salesforce and exporting data..."
echo "────────────────────────────────────────────────────────"

source venv/bin/activate
python3 auto_export_final.py

if [ $? -ne 0 ]; then
    echo "❌ Auto-export failed"
    echo ""
    echo "Falling back to manual CSV processing..."
    # Fall back to processing existing CSVs
    ./auto_process_csv.sh
    exit $?
fi

# Step 2: Move downloaded CSV to uploads folder
echo ""
echo "Step 2: Moving CSV to uploads folder..."
echo "────────────────────────────────────────────────────────"

# Find the most recent CSV in Downloads
LATEST_DOWNLOAD=$(ls -t ~/Downloads/report*.csv 2>/dev/null | head -1)

if [ -z "$LATEST_DOWNLOAD" ]; then
    echo "⚠️  No new CSV found in Downloads"
    echo "   Checking uploads folder for existing data..."
    ./auto_process_csv.sh
    exit $?
fi

# Copy to uploads folder
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
DEST_FILE="uploads/${TIMESTAMP}_$(basename "$LATEST_DOWNLOAD")"

cp "$LATEST_DOWNLOAD" "$DEST_FILE"
echo "✅ Copied: $(basename "$LATEST_DOWNLOAD")"
echo "   → $DEST_FILE"

# Step 3: Clear database (to match report exactly)
echo ""
echo "Step 3a: Clearing database for fresh import..."
echo "────────────────────────────────────────────────────────"

python3 << 'CLEAR_EOF'
import sqlite3
from db_helper import get_db_connection

conn = get_db_connection()
cursor = conn.cursor()
cursor.execute('DELETE FROM opportunities')
conn.commit()
conn.close()
print("✅ Database cleared (ready for fresh import)")
CLEAR_EOF

# Step 3b: Process the new CSV
echo ""
echo "Step 3b: Processing CSV data..."
echo "────────────────────────────────────────────────────────"

python3 << EOF
import sys
sys.path.insert(0, '.')
from app import process_csv, read_csv_with_encoding

csv_file = '$DEST_FILE'
print(f"Processing: {csv_file}")

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

# Step 4: Export to JSON
echo ""
echo "Step 4: Exporting to JSON..."
echo "────────────────────────────────────────────────────────"

python3 export_to_json.py

if [ $? -ne 0 ]; then
    echo "❌ Export failed"
    exit 1
fi

# Step 5: Push to GitHub
echo ""
echo "Step 5: Pushing to GitHub..."
echo "────────────────────────────────────────────────────────"

git add data/opportunities.json data/last_sync.txt

if git diff --cached --quiet; then
    echo "ℹ️  No changes to push"
    exit 0
fi

TIMESTAMP_COMMIT=$(date '+%Y-%m-%d %H:%M')
RECORD_COUNT=$(grep "Total opportunities" data/last_sync.txt | awk '{print $3}')

git commit -m "Auto-update: $RECORD_COUNT opportunities ($TIMESTAMP_COMMIT) [Fully Automated]"
git push origin main

if [ $? -eq 0 ]; then
    echo ""
    echo "========================================================================"
    echo "✅ FULLY AUTOMATED SYNC COMPLETED!"
    echo "========================================================================"
    echo "📊 Opportunities: $RECORD_COUNT"
    echo "⏰ Next sync: 1 hour from now"
    echo "🌐 Dashboard: https://rituraman-prog.github.io/salesforce-dashboard/"
    echo "========================================================================"
else
    echo "❌ Push to GitHub failed"
    exit 1
fi
