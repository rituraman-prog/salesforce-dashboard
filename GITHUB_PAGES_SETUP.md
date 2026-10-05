# GitHub Pages Setup - Fully Automated

## 🎯 What You're Getting

✅ **Static HTML dashboard** hosted on GitHub Pages (100% free)  
✅ **Fully automated** - No manual login or session extraction!  
✅ **Hourly auto-refresh** - Data syncs automatically  
✅ **Public URL** - Share with anyone: `https://yourusername.github.io/salesforce-dashboard`  
✅ **Zero manual work** - Set it once, runs forever!

---

## 🚀 Complete Setup (15 minutes)

### **Step 1: Create Credentials File** (2 minutes)

This stores your Salesforce username and password securely on YOUR machine only (never goes to GitHub!).

```bash
cd ~/salesforce-opportunity-tool

# Create credentials file
nano credentials.conf
```

Add these lines (replace with your actual credentials):
```bash
export SALESFORCE_USERNAME="your.email@company.com"
export SALESFORCE_PASSWORD="your_salesforce_password"
export SALESFORCE_URL="https://login.salesforce.com"
```

Save: `Ctrl+O`, `Enter`, `Ctrl+X`

Make it secure:
```bash
chmod 600 credentials.conf
```

---

### **Step 2: Update index.html** (1 minute)

Edit the dashboard HTML file:
```bash
nano index.html
```

Find this line (around line 200):
```javascript
const GITHUB_USERNAME = 'YOUR_GITHUB_USERNAME';
```

Change it to your actual GitHub username:
```javascript
const GITHUB_USERNAME = 'your-github-username';
```

Save: `Ctrl+O`, `Enter`, `Ctrl+X`

---

### **Step 3: Create GitHub Repository** (2 minutes)

1. Go to **https://github.com/new**
2. **Repository name**: `salesforce-dashboard`
3. **Public** (so GitHub Pages works)
4. **Don't** initialize with README
5. Click **Create repository**

---

### **Step 4: Push Code to GitHub** (3 minutes)

```bash
cd ~/salesforce-opportunity-tool

# Initialize git (if not already)
git init

# Add remote (replace with YOUR username!)
git remote add origin https://github.com/YOUR_USERNAME/salesforce-dashboard.git

# Make sure credentials.conf is NOT pushed
echo "credentials.conf" >> .gitignore

# Initial data sync
source credentials.conf
python3 auto_sync_complete.py  # May require manual login first time

# Export to JSON
python3 export_to_json.py

# Commit everything
git add .
git commit -m "Initial commit: GitHub Pages dashboard"

# Push
git push -u origin main
```

---

### **Step 5: Enable GitHub Pages** (1 minute)

1. Go to your repository on GitHub
2. Click **Settings** tab
3. Scroll down to **Pages** (left sidebar)
4. Under **Source**, select:
   - Branch: **main**
   - Folder: **/ (root)**
5. Click **Save**
6. Wait 1-2 minutes
7. Your URL will appear: `https://YOUR_USERNAME.github.io/salesforce-dashboard`

🎉 **Dashboard is now live!**

---

### **Step 6: Setup Automated Hourly Sync** (5 minutes)

Now let's make it auto-refresh every hour!

#### Create the automation script:

```bash
nano ~/salesforce-opportunity-tool/auto_github_pages_sync.sh
```

Paste this:
```bash
#!/bin/bash
# Automated Salesforce to GitHub Pages Sync

cd ~/salesforce-opportunity-tool

echo "========================================"
echo "🤖 Auto-Sync Started: $(date)"
echo "========================================"

# Load credentials
source credentials.conf

# Step 1: Sync from Salesforce
echo "Step 1: Syncing from Salesforce..."
python3 salesforce_sync_browser.py

if [ $? -ne 0 ]; then
    echo "❌ Sync failed"
    exit 1
fi

# Step 2: Export to JSON
echo "Step 2: Exporting to JSON..."
python3 export_to_json.py

if [ $? -ne 0 ]; then
    echo "❌ Export failed"
    exit 1
fi

# Step 3: Push to GitHub
echo "Step 3: Pushing to GitHub..."

git add data/opportunities.json data/last_sync.txt

# Check if there are changes
if git diff --cached --quiet; then
    echo "ℹ️  No changes (data unchanged)"
    exit 0
fi

# Commit with timestamp
TIMESTAMP=$(date '+%Y-%m-%d %H:%M')
git commit -m "Auto-update: Data refresh ($TIMESTAMP)"

# Push
git push origin main

if [ $? -eq 0 ]; then
    echo "✅ Successfully pushed to GitHub!"
    echo "📊 Dashboard will update in 1-2 minutes"
else
    echo "❌ Push failed"
    exit 1
fi

echo "========================================"
echo "✅ Sync Complete!"
echo "========================================"
```

Save and make executable:
```bash
chmod +x ~/salesforce-opportunity-tool/auto_github_pages_sync.sh
```

#### Test it:
```bash
./auto_github_pages_sync.sh
```

You should see:
```
✅ Successfully pushed to GitHub!
📊 Dashboard will update in 1-2 minutes
```

#### Setup Hourly Automation:

```bash
# Update the LaunchAgent
nano ~/Library/LaunchAgents/com.salesforce.dashboard.sync.plist
```

Change the `ProgramArguments` section to:
```xml
    <key>ProgramArguments</key>
    <array>
        <string>/Users/ritu.raman/salesforce-opportunity-tool/auto_github_pages_sync.sh</string>
    </array>
```

Load it:
```bash
launchctl unload ~/Library/LaunchAgents/com.salesforce.dashboard.sync.plist 2>/dev/null
launchctl load ~/Library/LaunchAgents/com.salesforce.dashboard.sync.plist
```

---

## ✅ You're Done!

### What Happens Now:

```
Every Hour Automatically:
├─ 1. Login to Salesforce (browser automation)
├─ 2. Sync data via API
├─ 3. Export to JSON
├─ 4. Push to GitHub
├─ 5. GitHub Pages updates (1-2 min)
└─ 6. Users see fresh data!
```

### Your Dashboard URL:
```
https://YOUR_USERNAME.github.io/salesforce-dashboard
```

**Share this URL with anyone** - no login required!

---

## 🔐 Security Notes

**What's Public (on GitHub/Dashboard):**
- Dashboard HTML/CSS/JavaScript ✅
- Opportunity data (JSON) ✅
- Charts and statistics ✅

**What's Private (stays on your machine):**
- `credentials.conf` - Your Salesforce password 🔒
- `.sf_session` - Browser session tokens 🔒
- Local database files 🔒

These files are in `.gitignore` and never leave your machine!

---

## 🔄 How Data Updates

### Timeline:
1. **00:00** - Your Mac runs hourly sync
2. **00:01** - Data pushed to GitHub
3. **00:03** - GitHub Pages rebuilds (automatic)
4. **00:03** - Users see new data!

**Total time: ~3 minutes from sync to live**

---

## 🆘 Troubleshooting

### Browser automation requires manual login first time
**Solution**: Run once manually to establish session:
```bash
cd ~/salesforce-opportunity-tool
source credentials.conf
python3 auto_sync_complete.py
```
Login when browser opens, then automation works forever!

### "Push rejected" error
**Solution**: Pull first, then push:
```bash
git pull origin main --rebase
git push origin main
```

### Dashboard shows old data
**Solution**: 
1. Check GitHub: Is `opportunities.json` updating?
2. Clear browser cache and refresh
3. Check GitHub Actions (if any are running)

### Sync fails with "Session expired"
**Solution**: Re-run manual sync once:
```bash
source credentials.conf
python3 auto_sync_complete.py
```

---

## 📊 Dashboard Features

Your GitHub Pages dashboard includes:

✅ **Statistics Cards**
- Total opportunities
- Holdback count
- Framework count
- Umbrella count

✅ **Regional Breakdown**
- All regions with counts
- Total amounts per region

✅ **Filterable Table**
- Filter by region
- Filter by special term
- All opportunity details

✅ **Auto-Refresh**
- Checks for updates every 5 minutes
- Shows last update time

---

## 🎨 Customization

Want to customize the dashboard? Edit `index.html`:

```bash
nano ~/salesforce-opportunity-tool/index.html
```

Changes you can make:
- Colors (search for `#667eea` and `#764ba2`)
- Title and header text
- Add/remove columns in table
- Change auto-refresh interval (line ~580)

After editing:
```bash
git add index.html
git commit -m "Customize dashboard"
git push origin main
```

GitHub Pages updates in 1-2 minutes!

---

## ✅ Final Checklist

- [ ] Created `credentials.conf` with Salesforce login
- [ ] Updated GitHub username in `index.html`
- [ ] Created GitHub repository
- [ ] Pushed code to GitHub
- [ ] Enabled GitHub Pages in repo settings
- [ ] Tested dashboard URL works
- [ ] Created `auto_github_pages_sync.sh`
- [ ] Tested manual sync works
- [ ] Setup LaunchAgent for hourly automation
- [ ] Verified first auto-sync completes

**All done?** Your dashboard is now fully automated! 🎉

---

## 📞 Need Help?

Run diagnostics:
```bash
# Test sync manually
./auto_github_pages_sync.sh

# Check automation status
launchctl list | grep salesforce

# View logs
tail -f ~/salesforce-opportunity-tool/logs/sync.log
```

**Your Dashboard**: `https://YOUR_USERNAME.github.io/salesforce-dashboard`

**Enjoy your automated dashboard!** 🚀
