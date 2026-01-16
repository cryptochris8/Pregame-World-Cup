// World Cup 2026 Teams Data
const worldCupTeams = [
    // CONCACAF
    { name: 'USA', flag: '🇺🇸', confederation: 'CONCACAF' },
    { name: 'Mexico', flag: '🇲🇽', confederation: 'CONCACAF' },
    { name: 'Canada', flag: '🇨🇦', confederation: 'CONCACAF' },
    { name: 'Costa Rica', flag: '🇨🇷', confederation: 'CONCACAF' },
    { name: 'Jamaica', flag: '🇯🇲', confederation: 'CONCACAF' },
    { name: 'Panama', flag: '🇵🇦', confederation: 'CONCACAF' },
    { name: 'Honduras', flag: '🇭🇳', confederation: 'CONCACAF' },

    // UEFA (Europe)
    { name: 'England', flag: '🏴󠁧󠁢󠁥󠁮󠁧󠁿', confederation: 'UEFA' },
    { name: 'France', flag: '🇫🇷', confederation: 'UEFA' },
    { name: 'Spain', flag: '🇪🇸', confederation: 'UEFA' },
    { name: 'Germany', flag: '🇩🇪', confederation: 'UEFA' },
    { name: 'Portugal', flag: '🇵🇹', confederation: 'UEFA' },
    { name: 'Netherlands', flag: '🇳🇱', confederation: 'UEFA' },
    { name: 'Belgium', flag: '🇧🇪', confederation: 'UEFA' },
    { name: 'Italy', flag: '🇮🇹', confederation: 'UEFA' },
    { name: 'Croatia', flag: '🇭🇷', confederation: 'UEFA' },
    { name: 'Denmark', flag: '🇩🇰', confederation: 'UEFA' },
    { name: 'Switzerland', flag: '🇨🇭', confederation: 'UEFA' },
    { name: 'Poland', flag: '🇵🇱', confederation: 'UEFA' },
    { name: 'Serbia', flag: '🇷🇸', confederation: 'UEFA' },
    { name: 'Austria', flag: '🇦🇹', confederation: 'UEFA' },

    // CONMEBOL (South America)
    { name: 'Brazil', flag: '🇧🇷', confederation: 'CONMEBOL' },
    { name: 'Argentina', flag: '🇦🇷', confederation: 'CONMEBOL' },
    { name: 'Uruguay', flag: '🇺🇾', confederation: 'CONMEBOL' },
    { name: 'Colombia', flag: '🇨🇴', confederation: 'CONMEBOL' },
    { name: 'Chile', flag: '🇨🇱', confederation: 'CONMEBOL' },
    { name: 'Ecuador', flag: '🇪🇨', confederation: 'CONMEBOL' },
    { name: 'Peru', flag: '🇵🇪', confederation: 'CONMEBOL' },

    // CAF (Africa)
    { name: 'Senegal', flag: '🇸🇳', confederation: 'CAF' },
    { name: 'Morocco', flag: '🇲🇦', confederation: 'CAF' },
    { name: 'Tunisia', flag: '🇹🇳', confederation: 'CAF' },
    { name: 'Nigeria', flag: '🇳🇬', confederation: 'CAF' },
    { name: 'Cameroon', flag: '🇨🇲', confederation: 'CAF' },
    { name: 'Ghana', flag: '🇬🇭', confederation: 'CAF' },
    { name: 'Egypt', flag: '🇪🇬', confederation: 'CAF' },
    { name: 'Algeria', flag: '🇩🇿', confederation: 'CAF' },
    { name: 'Ivory Coast', flag: '🇨🇮', confederation: 'CAF' },

    // AFC (Asia)
    { name: 'Japan', flag: '🇯🇵', confederation: 'AFC' },
    { name: 'South Korea', flag: '🇰🇷', confederation: 'AFC' },
    { name: 'Iran', flag: '🇮🇷', confederation: 'AFC' },
    { name: 'Saudi Arabia', flag: '🇸🇦', confederation: 'AFC' },
    { name: 'Australia', flag: '🇦🇺', confederation: 'AFC' },
    { name: 'Qatar', flag: '🇶🇦', confederation: 'AFC' },

    // OFC (Oceania)
    { name: 'New Zealand', flag: '🇳🇿', confederation: 'OFC' },

    // Additional teams to reach 48
    { name: 'Ukraine', flag: '🇺🇦', confederation: 'UEFA' },
    { name: 'Sweden', flag: '🇸🇪', confederation: 'UEFA' },
    { name: 'Norway', flag: '🇳🇴', confederation: 'UEFA' },
    { name: 'Mali', flag: '🇲🇱', confederation: 'CAF' },
    { name: 'Burkina Faso', flag: '🇧🇫', confederation: 'CAF' },
];

// Load teams into grid
function loadTeams() {
    const teamsGrid = document.getElementById('teams-grid');
    if (!teamsGrid) return;

    teamsGrid.innerHTML = worldCupTeams.map(team => `
        <div class="team-card bg-white rounded-xl p-6 shadow-md hover:shadow-xl cursor-pointer text-center">
            <div class="text-5xl mb-3">${team.flag}</div>
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
