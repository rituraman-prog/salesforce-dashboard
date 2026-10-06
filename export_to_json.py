#!/usr/bin/env python3
"""
Export Salesforce Data to JSON for GitHub
Converts local database to JSON format that can be committed to Git
"""

import os
import json
import sqlite3
from datetime import datetime
from pathlib import Path

def export_opportunities_to_json():
    """Export opportunities from database to JSON file"""

    # Database path
    db_path = Path(__file__).parent / 'data' / 'opportunities.db'

    if not db_path.exists():
        print("❌ Database not found. Run sync first.")
        return False

    try:
        print("📊 Exporting data to JSON...")

        # Connect to database
        conn = sqlite3.connect(str(db_path))
        conn.row_factory = sqlite3.Row  # Access columns by name
        cursor = conn.cursor()

        # Get all opportunities
        cursor.execute('SELECT * FROM opportunities ORDER BY close_date DESC')
        rows = cursor.fetchall()

        # Convert to list of dictionaries
        opportunities = []
        for row in rows:
            opportunities.append({
                'id': row['id'],
                'name': row['name'],
                'account_name': row['account_name'],
                'amount': row['amount'],
                'close_date': row['close_date'],
                'stage_name': row['stage_name'],
                'owner_name': row['owner_name'],
                'opportunity_type': row['opportunity_type'],
                'created_date': row['created_date'],
                'last_modified_date': row['last_modified_date'],
                'project_manager': row['project_manager'],
                'project_manager_2': row['project_manager_2'],
                'opportunity_owner': row['opportunity_owner'],
                'region': row['region'],
                'subregion': row['subregion'],
                'special_term': row['special_term'],
                'billing_frequency': row['billing_frequency'],
                'account_number': row['account_number'],
                'amount_currency': row['amount_currency'],
                'opportunity_stage': row['opportunity_stage'],
                'billings_currency': row['billings_currency'],
                'billings': row['billings'],
                'actual_remaining_currency': row['actual_remaining_currency'],
                'actual_remaining': row['actual_remaining'],
                'invoiced_currency': row['invoiced_currency'],
                'invoiced': row['invoiced'],
                'po_number': row['po_number'],
                'exclude_from_billing': row['exclude_from_billing']
            })

        # Get statistics
        cursor.execute('SELECT COUNT(*) as count FROM opportunities')
        total_count = cursor.fetchone()['count']

        cursor.execute("SELECT COUNT(*) as count FROM opportunities WHERE special_term = 'Holdback'")
        holdback_count = cursor.fetchone()['count']

        cursor.execute("SELECT COUNT(*) as count FROM opportunities WHERE special_term = 'Framework'")
        framework_count = cursor.fetchone()['count']

        cursor.execute("SELECT COUNT(*) as count FROM opportunities WHERE special_term = 'Umbrella'")
        umbrella_count = cursor.fetchone()['count']

        # Get regional breakdown
        cursor.execute('''
            SELECT region, COUNT(*) as count, SUM(amount) as total_amount
            FROM opportunities
            WHERE region IS NOT NULL AND region != ''
            GROUP BY region
            ORDER BY count DESC
        ''')
        regions = []
        for row in cursor.fetchall():
            regions.append({
                'region': row['region'],
                'count': row['count'],
                'total_amount': row['total_amount'] or 0
            })

        conn.close()

        # Create export data structure
        export_data = {
            'last_updated': datetime.now().isoformat(),
            'total_opportunities': total_count,
            'statistics': {
                'holdback_count': holdback_count,
                'framework_count': framework_count,
                'umbrella_count': umbrella_count
            },
            'regions': regions,
            'opportunities': opportunities
        }

        # Ensure data directory exists
        data_dir = Path(__file__).parent / 'data'
        data_dir.mkdir(exist_ok=True)

        # Write JSON file
        json_path = data_dir / 'opportunities.json'
        with open(json_path, 'w', encoding='utf-8') as f:
            json.dump(export_data, f, indent=2, ensure_ascii=False)

        # Write timestamp file
        timestamp_path = data_dir / 'last_sync.txt'
        with open(timestamp_path, 'w') as f:
            f.write(f"Last synced: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
            f.write(f"Total opportunities: {total_count}\n")

        print(f"✅ Exported {total_count} opportunities to JSON")
        print(f"   File: {json_path}")
        print(f"   Size: {json_path.stat().st_size / 1024:.1f} KB")

        return True

    except Exception as e:
        print(f"❌ Export failed: {str(e)}")
        return False


if __name__ == '__main__':
    success = export_opportunities_to_json()
    exit(0 if success else 1)
