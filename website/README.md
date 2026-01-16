# Pregame World Cup 2026 Website

Landing page for the Pregame World Cup 2026 mobile app.

## Features

- 🎨 Beautiful gradient design (purple → blue → orange)
- ⚡ Fast, lightweight static HTML
- 📱 Fully responsive mobile-first design
- 🎯 SEO optimized
- 🏆 All 48 World Cup teams
- ✨ Smooth animations and interactions

## Tech Stack

- **HTML5** - Semantic markup
- **Tailwind CSS** - Utility-first styling via CDN
- **Vanilla JavaScript** - No framework dependencies
- **Netlify** - Hosting and deployment

## Local Development

Simply open `index.html` in your browser. No build step required!

```bash
# Or use a local server
python -m http.server 8000
# Then visit http://localhost:8000
```

## Deploying to Netlify

### Method 1: Drag and Drop
1. Go to [Netlify](https://app.netlify.com/)
2. Drag the entire `website` folder to the deploy area
3. Done! Your site is live

### Method 2: Git Integration
1. Push this `website` folder to a GitHub repository
2. Connect repository to Netlify
3. Set build settings:
   - **Build command:** (leave empty)
   - **Publish directory:** `.` or `website`
4. Deploy!

### Method 3: Netlify CLI
```bash
# Install Netlify CLI
npm install -g netlify-cli

# Login to Netlify
netlify login

# Deploy
cd website
netlify deploy --prod
```

## File Structure

```
website/
├── index.html          # Main landing page
├── css/
│   └── styles.css      # Custom CSS
├── js/
│   └── main.js         # JavaScript functionality
├── images/             # Image assets (add your images here)
├── netlify.toml        # Netlify configuration
└── README.md           # This file
```

## Customization

### Update Download Links
In `index.html`, replace the `#` href attributes with your actual App Store and Google Play links:

```html
<a href="https://apps.apple.com/your-app-link">Download for iOS</a>
<a href="https://play.google.com/your-app-link">Download for Android</a>
```

### Add App Screenshots
Place screenshots in the `images/` folder and update the HTML to display them.

### Analytics
Add Google Analytics or your preferred analytics tool in the `<head>` section.

## SEO Checklist

- ✅ Meta tags added
- ✅ Semantic HTML structure
- ✅ Mobile-responsive
- ✅ Fast loading (no heavy frameworks)
- 🔲 Add Open Graph tags for social sharing
- 🔲 Add structured data (JSON-LD)
- 🔲 Submit sitemap to Google Search Console

## Future Enhancements

- [ ] Add blog section for World Cup news
- [ ] Create team detail pages (SEO boost)
- [ ] Add player profile pages
- [ ] Integrate with Flutter web app
- [ ] Add video highlights
- [ ] Newsletter signup

## Support

For questions or issues, contact [your-email@example.com]

## License

© 2026 Pregame World Cup. All rights reserved.
