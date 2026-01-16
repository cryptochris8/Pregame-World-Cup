# Pregame World Cup 2026 - Netlify Deployment Guide

## Quick Start (Fastest Method)

### Option 1: Drag & Drop to Netlify

1. **Zip the website folder**
   - Right-click the `website` folder
   - Select "Send to > Compressed (zipped) folder"
   - OR just drag the entire `website` folder (Netlify accepts folders too!)

2. **Go to Netlify**
   - Visit https://app.netlify.com/
   - Log in with your account

3. **Deploy**
   - Drag and drop the `website` folder (or zip file) into the deploy area
   - Netlify will automatically deploy
   - You'll get a URL like: `random-name-123.netlify.app`

4. **Custom Domain** (Optional)
   - Click "Domain settings"
   - Add custom domain: `pregame-worldcup.netlify.app` or your own domain
   - Done!

---

## Option 2: Connect to GitHub (Recommended for Updates)

### Step 1: Create GitHub Repository

```bash
# Navigate to website folder
cd D:\Pregame-World-Cup\website

# Initialize git (if not already done)
git init

# Add files
git add .

# Commit
git commit -m "Initial commit - Pregame World Cup website"

# Create repository on GitHub, then:
git remote add origin https://github.com/YOUR-USERNAME/pregame-worldcup-website.git
git branch -M main
git push -u origin main
```

### Step 2: Connect to Netlify

1. Go to https://app.netlify.com/
2. Click "Add new site" > "Import an existing project"
3. Choose "GitHub"
4. Select your repository
5. Configure build settings:
   - **Base directory:** `website` (if repo has other folders) OR leave empty
   - **Build command:** (leave empty)
   - **Publish directory:** `.` OR `website`
6. Click "Deploy site"

### Step 3: Configure Custom Domain

1. In Netlify dashboard, go to "Domain settings"
2. Click "Add custom domain"
3. Enter: `pregame-worldcup.netlify.app` or your own domain
4. Follow DNS configuration if using custom domain

---

## Option 3: Netlify CLI (For Developers)

```bash
# Install Netlify CLI (one-time)
npm install -g netlify-cli

# Login to Netlify
netlify login

# Navigate to website folder
cd D:\Pregame-World-Cup\website

# Initialize Netlify site
netlify init

# Deploy to production
netlify deploy --prod
```

---

## Post-Deployment Checklist

### ✅ Essential Updates

1. **Update Download Links**
   - Edit `index.html`
   - Replace all `href="#download"` with actual App Store/Play Store URLs
   - Example:
     ```html
     <a href="https://apps.apple.com/app/your-app-id">Download for iOS</a>
     <a href="https://play.google.com/store/apps/details?id=com.yourapp">Download for Android</a>
     ```

2. **Add Favicon**
   - Create or download a favicon.ico
   - Place in `website/` folder
   - Add to `<head>`:
     ```html
     <link rel="icon" type="image/x-icon" href="favicon.ico">
     ```

3. **Add Logo/Images**
   - Place app screenshots in `website/images/`
   - Update image src in HTML

### 🎯 SEO Optimization

4. **Add Google Analytics**
   ```html
   <!-- Add in <head> section -->
   <script async src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXXXX"></script>
   <script>
     window.dataLayer = window.dataLayer || [];
     function gtag(){dataLayer.push(arguments);}
     gtag('js', new Date());
     gtag('config', 'G-XXXXXXXXXX');
   </script>
   ```

5. **Add Open Graph Tags** (for social sharing)
   ```html
   <!-- Add in <head> section -->
   <meta property="og:title" content="Pregame World Cup 2026">
   <meta property="og:description" content="Your Ultimate World Cup 2026 Companion">
   <meta property="og:image" content="https://your-site.com/images/og-image.jpg">
   <meta property="og:url" content="https://pregame-worldcup.netlify.app">
   <meta name="twitter:card" content="summary_large_image">
   ```

6. **Submit to Google Search Console**
   - Add site to https://search.google.com/search-console
   - Verify ownership
   - Submit sitemap

### 🚀 Marketing Setup

7. **Create QR Code** for easy mobile downloads
   - Use https://www.qr-code-generator.com/
   - Link to your Netlify site
   - Use in marketing materials

8. **Social Media**
   - Share the website on Twitter, Instagram, Facebook
   - Use hashtags: #WorldCup2026 #FIFA2026 #PregameApp

9. **App Store Optimization**
   - Link website in App Store/Play Store listings
   - Use website URL in marketing materials

---

## Continuous Deployment

Once connected to GitHub:
1. Make changes to HTML/CSS/JS locally
2. Commit and push to GitHub
3. Netlify automatically rebuilds and deploys
4. Changes live in ~30 seconds!

---

## Troubleshooting

### Site not loading?
- Check Netlify deploy log for errors
- Ensure `index.html` is in the publish directory
- Clear browser cache

### Teams not showing?
- Check browser console for JavaScript errors
- Ensure `js/main.js` is loading correctly

### Styles broken?
- Verify Tailwind CDN is loading
- Check `css/styles.css` path is correct

---

## Performance Optimization

### Already Optimized ✅
- Tailwind CSS via CDN (no build needed)
- Minimal JavaScript
- No heavy frameworks
- Fast loading time (~1-2 seconds)

### Future Improvements
- [ ] Add image optimization
- [ ] Implement lazy loading
- [ ] Add service worker for PWA
- [ ] Compress images with WebP

---

## Cost
**FREE!** 🎉
- Netlify free tier includes:
  - 100GB bandwidth/month
  - Unlimited sites
  - HTTPS included
  - Custom domain support

---

## Support
If you encounter issues:
1. Check Netlify docs: https://docs.netlify.com/
2. Netlify community: https://answers.netlify.com/
3. Or contact me for assistance!

---

## Summary

**You're ready to deploy!** 🚀

The fastest way:
1. Go to https://app.netlify.com/
2. Drag the `website` folder to the deploy area
3. Done!

Your World Cup 2026 marketing site will be live in seconds!
