/* ==========================================================================
   SHIFTLY - Core Application & Motion Engine
   Provides: Canvas Particles, Cursor Spotlight, Navbar & Drawer Logic,
   FAQ Accordions, Scroll-triggered Animations
   ========================================================================== */

document.addEventListener('DOMContentLoaded', () => {
  // Initialize Canvas Particle Starfield Background
  initStarfieldCanvas();

  // Initialize Interactive Cursor Follower Spotlight
  initCursorSpotlight();

  // Sticky Navbar Scroll State
  initNavbarScroll();

  // Mobile Navigation Drawer
  initMobileDrawer();

  // FAQ Accordion
  initFaqAccordion();

  // Back To Top Button
  initBackToTop();

  // Scroll Entrance Animations (GSAP or Intersection Observer)
  initScrollAnimations();
});

/* --- Starfield Canvas Animation --- */
function initStarfieldCanvas() {
  const canvas = document.getElementById('bgCanvas');
  if (!canvas) return;

  const ctx = canvas.getContext('2d');
  let width = (canvas.width = window.innerWidth);
  let height = (canvas.height = window.innerHeight);

  window.addEventListener('resize', () => {
    width = canvas.width = window.innerWidth;
    height = canvas.height = window.innerHeight;
    initParticles();
  });

  let particles = [];
  const numParticles = Math.min(Math.floor(width / 20), 60);

  function Particle() {
    this.x = Math.random() * width;
    this.y = Math.random() * height;
    this.size = Math.random() * 2 + 0.5;
    this.vx = (Math.random() - 0.5) * 0.4;
    this.vy = (Math.random() - 0.5) * 0.4;
    this.alpha = Math.random() * 0.6 + 0.2;
    this.color = Math.random() > 0.4 ? '#38BDF8' : (Math.random() > 0.5 ? '#818CF8' : '#C084FC');
  }

  function initParticles() {
    particles = [];
    for (let i = 0; i < numParticles; i++) {
      particles.push(new Particle());
    }
  }

  initParticles();

  function draw() {
    ctx.clearRect(0, 0, width, height);

    for (let i = 0; i < particles.length; i++) {
      const p = particles[i];
      p.x += p.vx;
      p.y += p.vy;

      if (p.x < 0) p.x = width;
      if (p.x > width) p.x = 0;
      if (p.y < 0) p.y = height;
      if (p.y > height) p.y = 0;

      ctx.beginPath();
      ctx.arc(p.x, p.y, p.size, 0, Math.PI * 2);
      ctx.fillStyle = p.color;
      ctx.globalAlpha = p.alpha;
      ctx.fill();

      // Connect nearby particles with subtle glowing lines
      for (let j = i + 1; j < particles.length; j++) {
        const p2 = particles[j];
        const dx = p.x - p2.x;
        const dy = p.y - p2.y;
        const dist = Math.sqrt(dx * dx + dy * dy);

        if (dist < 120) {
          ctx.beginPath();
          ctx.moveTo(p.x, p.y);
          ctx.lineTo(p2.x, p2.y);
          ctx.strokeStyle = '#38BDF8';
          ctx.globalAlpha = (1 - dist / 120) * 0.15;
          ctx.lineWidth = 0.8;
          ctx.stroke();
        }
      }
    }

    ctx.globalAlpha = 1;
    requestAnimationFrame(draw);
  }

  requestAnimationFrame(draw);
}

/* --- Interactive Cursor Spotlight --- */
function initCursorSpotlight() {
  const spotlight = document.querySelector('.cursor-spotlight');
  if (!spotlight || window.innerWidth < 1024) return;

  let mouseX = window.innerWidth / 2;
  let mouseY = window.innerHeight / 2;
  let posX = mouseX;
  let posY = mouseY;

  window.addEventListener('mousemove', (e) => {
    mouseX = e.clientX;
    mouseY = e.clientY;
  });

  function renderSpotlight() {
    // Smooth interpolation (lerp)
    posX += (mouseX - posX) * 0.1;
    posY += (mouseY - posY) * 0.1;

    spotlight.style.transform = `translate3d(${posX}px, ${posY}px, 0)`;
    requestAnimationFrame(renderSpotlight);
  }

  requestAnimationFrame(renderSpotlight);
}

/* --- Sticky Navbar --- */
function initNavbarScroll() {
  const navbar = document.querySelector('.navbar');
  if (!navbar) return;

  window.addEventListener('scroll', () => {
    if (window.scrollY > 40) {
      navbar.classList.add('scrolled');
    } else {
      navbar.classList.remove('scrolled');
    }
  });
}

/* --- Mobile Drawer --- */
function initMobileDrawer() {
  const mobileToggle = document.getElementById('mobileToggle');
  const mobileDrawer = document.getElementById('mobileDrawer');
  const drawerOverlay = document.getElementById('drawerOverlay');
  const drawerClose = document.getElementById('drawerClose');

  if (!mobileToggle || !mobileDrawer) return;

  function openDrawer() {
    mobileDrawer.classList.add('active');
    if (drawerOverlay) drawerOverlay.classList.add('active');
    document.body.style.overflow = 'hidden';
  }

  function closeDrawer() {
    mobileDrawer.classList.remove('active');
    if (drawerOverlay) drawerOverlay.classList.remove('active');
    document.body.style.overflow = '';
  }

  mobileToggle.addEventListener('click', openDrawer);
  if (drawerClose) drawerClose.addEventListener('click', closeDrawer);
  if (drawerOverlay) drawerOverlay.addEventListener('click', closeDrawer);

  const drawerLinks = mobileDrawer.querySelectorAll('a');
  drawerLinks.forEach(link => {
    link.addEventListener('click', closeDrawer);
  });
}

/* --- FAQ Accordion --- */
function initFaqAccordion() {
  const faqItems = document.querySelectorAll('.faq-item');
  if (!faqItems.length) return;

  faqItems.forEach(item => {
    const questionBtn = item.querySelector('.faq-question');
    if (!questionBtn) return;

    questionBtn.addEventListener('click', () => {
      const isActive = item.classList.contains('active');

      // Close all other open accordion items
      faqItems.forEach(otherItem => {
        if (otherItem !== item) {
          otherItem.classList.remove('active');
        }
      });

      // Toggle current
      item.classList.toggle('active', !isActive);
    });
  });
}

/* --- Back To Top Button --- */
function initBackToTop() {
  const backToTopBtn = document.getElementById('backToTop');
  if (!backToTopBtn) return;

  window.addEventListener('scroll', () => {
    if (window.scrollY > 400) {
      backToTopBtn.style.opacity = '1';
      backToTopBtn.style.pointerEvents = 'auto';
    } else {
      backToTopBtn.style.opacity = '0';
      backToTopBtn.style.pointerEvents = 'none';
    }
  });

  backToTopBtn.addEventListener('click', () => {
    window.scrollTo({
      top: 0,
      behavior: 'smooth'
    });
  });
}

/* --- Scroll Entrance Observer --- */
function initScrollAnimations() {
  const observerOptions = {
    threshold: 0.15,
    rootMargin: '0px 0px -50px 0px'
  };

  const animateElements = document.querySelectorAll('.animate-on-scroll');

  const observer = new IntersectionObserver((entries, obs) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('animated');
        obs.unobserve(entry.target);
      }
    });
  }, observerOptions);

  animateElements.forEach(el => observer.observe(el));
}
