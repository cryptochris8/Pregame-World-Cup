// World Cup 2026 Teams Data (using ISO country codes for flag images)
const worldCupTeams = [
    // CONCACAF
    { name: 'USA', code: 'us', confederation: 'CONCACAF' },
    { name: 'Mexico', code: 'mx', confederation: 'CONCACAF' },
    { name: 'Canada', code: 'ca', confederation: 'CONCACAF' },
    { name: 'Costa Rica', code: 'cr', confederation: 'CONCACAF' },
    { name: 'Jamaica', code: 'jm', confederation: 'CONCACAF' },
    { name: 'Panama', code: 'pa', confederation: 'CONCACAF' },
    { name: 'Honduras', code: 'hn', confederation: 'CONCACAF' },

    // UEFA (Europe)
    { name: 'England', code: 'gb-eng', confederation: 'UEFA' },
    { name: 'France', code: 'fr', confederation: 'UEFA' },
    { name: 'Spain', code: 'es', confederation: 'UEFA' },
    { name: 'Germany', code: 'de', confederation: 'UEFA' },
    { name: 'Portugal', code: 'pt', confederation: 'UEFA' },
    { name: 'Netherlands', code: 'nl', confederation: 'UEFA' },
    { name: 'Belgium', code: 'be', confederation: 'UEFA' },
    { name: 'Italy', code: 'it', confederation: 'UEFA' },
    { name: 'Croatia', code: 'hr', confederation: 'UEFA' },
    { name: 'Denmark', code: 'dk', confederation: 'UEFA' },
    { name: 'Switzerland', code: 'ch', confederation: 'UEFA' },
    { name: 'Poland', code: 'pl', confederation: 'UEFA' },
    { name: 'Serbia', code: 'rs', confederation: 'UEFA' },
    { name: 'Austria', code: 'at', confederation: 'UEFA' },

    // CONMEBOL (South America)
    { name: 'Brazil', code: 'br', confederation: 'CONMEBOL' },
    { name: 'Argentina', code: 'ar', confederation: 'CONMEBOL' },
    { name: 'Uruguay', code: 'uy', confederation: 'CONMEBOL' },
    { name: 'Colombia', code: 'co', confederation: 'CONMEBOL' },
    { name: 'Chile', code: 'cl', confederation: 'CONMEBOL' },
    { name: 'Ecuador', code: 'ec', confederation: 'CONMEBOL' },
    { name: 'Peru', code: 'pe', confederation: 'CONMEBOL' },

    // CAF (Africa)
    { name: 'Senegal', code: 'sn', confederation: 'CAF' },
    { name: 'Morocco', code: 'ma', confederation: 'CAF' },
    { name: 'Tunisia', code: 'tn', confederation: 'CAF' },
    { name: 'Nigeria', code: 'ng', confederation: 'CAF' },
    { name: 'Cameroon', code: 'cm', confederation: 'CAF' },
    { name: 'Ghana', code: 'gh', confederation: 'CAF' },
    { name: 'Egypt', code: 'eg', confederation: 'CAF' },
    { name: 'Algeria', code: 'dz', confederation: 'CAF' },
    { name: 'Ivory Coast', code: 'ci', confederation: 'CAF' },

    // AFC (Asia)
    { name: 'Japan', code: 'jp', confederation: 'AFC' },
    { name: 'South Korea', code: 'kr', confederation: 'AFC' },
    { name: 'Iran', code: 'ir', confederation: 'AFC' },
    { name: 'Saudi Arabia', code: 'sa', confederation: 'AFC' },
    { name: 'Australia', code: 'au', confederation: 'AFC' },
    { name: 'Qatar', code: 'qa', confederation: 'AFC' },

    // OFC (Oceania)
    { name: 'New Zealand', code: 'nz', confederation: 'OFC' },

    // Additional teams to reach 48
    { name: 'Ukraine', code: 'ua', confederation: 'UEFA' },
    { name: 'Sweden', code: 'se', confederation: 'UEFA' },
    { name: 'Norway', code: 'no', confederation: 'UEFA' },
    { name: 'Mali', code: 'ml', confederation: 'CAF' },
    { name: 'Burkina Faso', code: 'bf', confederation: 'CAF' },
];

// Load teams into grid with flag images from flagcdn.com
function loadTeams() {
    const teamsGrid = document.getElementById('teams-grid');
    if (!teamsGrid) return;

    teamsGrid.innerHTML = worldCupTeams.map(team => `
        <div class="team-card bg-white rounded-xl p-6 shadow-md hover:shadow-xl cursor-pointer text-center">
            <img
                src="https://flagcdn.com/w80/${team.code}.png"
                srcset="https://flagcdn.com/w160/${team.code}.png 2x"
                alt="${team.name} flag"
                class="w-16 h-auto mx-auto mb-3 rounded shadow-sm"
                onerror="this.src='https://flagcdn.com/w80/${team.code.split('-')[0]}.png'"
            />
            <div class="font-semibold text-gray-900">${team.name}</div>
            <div class="text-xs text-gray-500 mt-1">${team.confederation}</div>
        </div>
    `).join('');
}

// Smooth scroll for navigation links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            target.scrollIntoView({
                behavior: 'smooth',
                block: 'start'
            });
        }
    });
});

// Add scroll effect to navbar
let lastScroll = 0;
const navbar = document.querySelector('nav');

window.addEventListener('scroll', () => {
    const currentScroll = window.pageYOffset;

    if (currentScroll > 100) {
        navbar.classList.add('shadow-lg');
    } else {
        navbar.classList.remove('shadow-lg');
    }

    lastScroll = currentScroll;
});

// Load teams when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
    loadTeams();

    // Add animation to stats on scroll
    const observerOptions = {
        threshold: 0.5,
        rootMargin: '0px 0px -100px 0px'
    };

    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('animate-gradient');
            }
        });
    }, observerOptions);

    // Observe stat numbers
    document.querySelectorAll('.text-4xl, .text-5xl').forEach(el => {
        observer.observe(el);
    });
});

// Track download button clicks (you can add analytics here)
document.querySelectorAll('a[href="#download"]').forEach(button => {
    button.addEventListener('click', (e) => {
        console.log('Download button clicked');
        // Add your analytics tracking here
        // e.g., gtag('event', 'click', { event_category: 'download' });
    });
});
