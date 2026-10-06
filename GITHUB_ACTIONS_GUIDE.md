# 🌥️ GitHub Actions - Cloud Automation Guide

## ✅ **What This Does**

Your dashboard now updates **automatically in the cloud** - no Mac needed!

---

## 🚀 **How to Update Your Dashboard (3 Easy Ways)**

### **Method 1: GitHub Website (Easiest)** ⭐

1. Export CSV from Salesforce:
   - Go to your report: https://org62.lightning.force.com/lightning/r/Report/00Oed00000AP8XhEAL/view?queryScope=userFolders
   - Click dropdown next to "Edit" → Export → Details Only → CSV
   - Download the file

2. Upload to GitHub:
   - Go to: https://github.com/rituraman-prog/salesforce-dashboard/tree/main/uploads
   - Click **"Add file"** → **"Upload files"**
   - Drag your CSV file
   - Click **"Commit changes"**

3. **Done!** GitHub Actions processes it automatically:
   - ✅ Clears database
   - ✅ Imports CSV data
   - ✅ Exports to JSON
   - ✅ Updates dashboard (1-2 minutes)

---

### **Method 2: Git Command Line** ⭐

```bash
# Export CSV from Salesforce first, then:

cd ~/salesforce-opportunity-tool

# Copy CSV to uploads folder
cp ~/Downloads/report*.csv uploads/

# Push to GitHub
git add uploads/*.csv
git commit -m "Update: New Salesforce data"
git push origin main

# GitHub Actions processes automatically!
```

---

### **Method 3: Manual Trigger** ⭐

If you already have a CSV in the `uploads/` folder:

1. Go to: https://github.com/rituraman-prog/salesforce-dashboard/actions
2. Click **"Process Salesforce CSV and Update Dashboard"**
3. Click **"Run workflow"** → **"Run workflow"** button
4. **Done!** Processes latest CSV in uploads/

---

## 📊 **Monitoring Progress**

### **Watch GitHub Actions:**

1. Go to: https://github.com/rituraman-prog/salesforce-dashboard/actions
2. See latest workflow run
3. Click on it to see live progress

### **Workflow Steps:**

```
1. 📥 Checkout repository
2. 🐍 Set up Python
3. 📦 Install dependencies
4. 🗑️ Clear database
5. 📊 Process CSV
6. 📤 Export to JSON
7. 🔄 Commit and push
```

**Total time:** ~2-3 minutes

---

## ✅ **What's Automated**

| Step | Where | When |
|------|-------|------|
| **CSV Upload** | You (manual) | When you want fresh data |
| **Process CSV** | ☁️ GitHub Actions | Automatic (on upload) |
| **Clear Database** | ☁️ GitHub Actions | Automatic |
| **Export JSON** | ☁️ GitHub Actions | Automatic |
| **Push to GitHub** | ☁️ GitHub Actions | Automatic |
| **Dashboard Update** | ☁️ GitHub Pages | Automatic (1-2 min) |

**Mac needed?** ❌ **NO!**

---

## 🎯 **Key Benefits**

✅ **24/7 Cloud Processing** - Works even when Mac is off  
✅ **Free** - GitHub Actions is free for public repos  
✅ **Fast** - Updates in 2-3 minutes  
✅ **Automatic** - Just upload CSV, rest is automatic  
✅ **Always Fresh** - Database clears before each import  
✅ **Exact Match** - Dashboard = Salesforce report count  

---

## 🔍 **Troubleshooting**

### **Dashboard not updating?**

1. **Check workflow status:**
   - https://github.com/rituraman-prog/salesforce-dashboard/actions
   - Look for red ❌ (failed) or green ✅ (success)

2. **Click failed workflow** to see error logs

3. **Common issues:**
   - CSV format changed → Update app.py mapping
   - File too large → GitHub has 100MB limit
   - Git conflicts → Pull latest changes first

---

## 📱 **Quick Reference**

| What | URL |
|------|-----|
| **Dashboard** | https://rituraman-prog.github.io/salesforce-dashboard/ |
| **Upload CSV** | https://github.com/rituraman-prog/salesforce-dashboard/tree/main/uploads |
| **Actions Log** | https://github.com/rituraman-prog/salesforce-dashboard/actions |
| **Salesforce Report** | https://org62.lightning.force.com/lightning/r/Report/00Oed00000AP8XhEAL/view?queryScope=userFolders |

---

## 🎊 **You're All Set!**

### **The New Workflow:**

```
Export CSV from Salesforce
  ↓
Upload to GitHub (web or git)
  ↓
☁️ GitHub Actions processes automatically
  ↓
Dashboard updates (2-3 minutes)
  ↓
✅ Done! (Mac can be off!)
```

**No more hourly automation on your Mac!**  
**No more LaunchAgent!**  
**Just upload when you want fresh data!**

🚀 **Enjoy your cloud-powered dashboard!** 🚀
