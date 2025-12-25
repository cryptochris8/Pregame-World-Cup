// Unified Theme System for Pregame Web Portal
// Matches the Flutter app color scheme for consistency

export const theme = {
  // Primary Brand Colors (Premium Sports Feel)
  colors: {
    primary: {
      deepBlue: '#1E3A8A',      // Deep, trustworthy blue
      vibrantOrange: '#FF6B35',  // Energetic orange
      electricBlue: '#3B82F6',   // Electric blue
      gold: '#FBBF24',           // Championship gold
    },
    
    // Secondary Palette (Modern & Sophisticated)
    secondary: {
      purple: '#8B5CF6',         // Premium purple
      teal: '#14B8A6',           // Fresh teal
      rose: '#F43F5E',           // Attention-grabbing rose
      emerald: '#10B981',        // Success green
    },
    
    // Neutral Colors (Professional & Clean)
    neutral: {
      backgroundLight: '#F8FAFC', // Cool light background
      backgroundDark: '#0F172A',  // Rich dark background
      surfaceLight: '#FFFFFF',    // Pure white surface
      surfaceDark: '#1E293B',     // Deep surface
      surfaceElevated: '#334155', // Elevated dark surface
    },
    
    // Text Colors (Optimized Readability)
    text: {
      primary: '#0F172A',         // Deep primary text
      secondary: '#64748B',       // Subtle secondary text
      tertiary: '#94A3B8',        // Light tertiary text
      light: '#F8FAFC',          // Light text for dark backgrounds
      lightSecondary: '#CBD5E1',  // Secondary light text
    },
    
    // Semantic Colors (Clear Communication)
    semantic: {
      success: '#059669',         // Green success
      warning: '#D97706',         // Amber warning
      error: '#DC2626',           // Red error
      info: '#2563EB',            // Blue info
    },
  },
  
  // Typography Scale
  typography: {
    fontFamily: {
      sans: ['Inter', 'system-ui', 'sans-serif'],
      mono: ['JetBrains Mono', 'monospace'],
    },
    fontSize: {
      xs: '0.75rem',     // 12px
      sm: '0.875rem',    // 14px
      base: '1rem',      // 16px
      lg: '1.125rem',    // 18px
      xl: '1.25rem',     // 20px
      '2xl': '1.5rem',   // 24px
      '3xl': '1.875rem', // 30px
      '4xl': '2.25rem',  // 36px
    },
    fontWeight: {
      normal: '400',
      medium: '500',
      semibold: '600',
      bold: '700',
    },
    lineHeight: {
      tight: '1.25',
      normal: '1.5',
      relaxed: '1.75',
    },
  },
  
  // Spacing Scale
  spacing: {
    xs: '0.25rem',    // 4px
    sm: '0.5rem',     // 8px
    md: '1rem',       // 16px
    lg: '1.5rem',     // 24px
    xl: '2rem',       // 32px
    '2xl': '3rem',    // 48px
    '3xl': '4rem',    // 64px
  },
  
  // Border Radius
  borderRadius: {
    sm: '0.375rem',   // 6px
    md: '0.5rem',     // 8px
    lg: '0.75rem',    // 12px
    xl: '1rem',       // 16px
    '2xl': '1.25rem', // 20px
    full: '9999px',
  },
  
  // Shadows
  shadows: {
    sm: '0 1px 2px 0 rgb(0 0 0 / 0.05)',
    md: '0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1)',
    lg: '0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1)',
    xl: '0 20px 25px -5px rgb(0 0 0 / 0.1), 0 8px 10px -6px rgb(0 0 0 / 0.1)',
  },
  
  // Gradients
  gradients: {
    primary: 'linear-gradient(135deg, #1E3A8A 0%, #3B82F6 100%)',
    accent: 'linear-gradient(135deg, #FF6B35 0%, #FBBF24 100%)',
    success: 'linear-gradient(135deg, #14B8A6 0%, #10B981 100%)',
    premium: 'linear-gradient(135deg, #8B5CF6 0%, #F43F5E 100%)',
  },
  
  // Breakpoints
  breakpoints: {
    sm: '640px',
    md: '768px',
    lg: '1024px',
    xl: '1280px',
    '2xl': '1536px',
  },
  
  // Animation
  animation: {
    duration: {
      fast: '150ms',
      normal: '300ms',
      slow: '500ms',
    },
    easing: {
      easeOut: 'cubic-bezier(0, 0, 0.2, 1)',
      easeIn: 'cubic-bezier(0.4, 0, 1, 1)',
      easeInOut: 'cubic-bezier(0.4, 0, 0.2, 1)',
    },
  },
} as const;

// CSS Custom Properties for easy usage
export const cssVariables = `
  :root {
    /* Colors */
    --color-primary-deep-blue: ${theme.colors.primary.deepBlue};
    --color-primary-vibrant-orange: ${theme.colors.primary.vibrantOrange};
    --color-primary-electric-blue: ${theme.colors.primary.electricBlue};
    --color-primary-gold: ${theme.colors.primary.gold};
    
    --color-secondary-purple: ${theme.colors.secondary.purple};
    --color-secondary-teal: ${theme.colors.secondary.teal};
    --color-secondary-rose: ${theme.colors.secondary.rose};
    --color-secondary-emerald: ${theme.colors.secondary.emerald};
    
    --color-neutral-bg-light: ${theme.colors.neutral.backgroundLight};
    --color-neutral-bg-dark: ${theme.colors.neutral.backgroundDark};
    --color-neutral-surface-light: ${theme.colors.neutral.surfaceLight};
    --color-neutral-surface-dark: ${theme.colors.neutral.surfaceDark};
    
    --color-text-primary: ${theme.colors.text.primary};
    --color-text-secondary: ${theme.colors.text.secondary};
    --color-text-tertiary: ${theme.colors.text.tertiary};
    --color-text-light: ${theme.colors.text.light};
    
    --color-success: ${theme.colors.semantic.success};
    --color-warning: ${theme.colors.semantic.warning};
    --color-error: ${theme.colors.semantic.error};
    --color-info: ${theme.colors.semantic.info};
    
    /* Gradients */
    --gradient-primary: ${theme.gradients.primary};
    --gradient-accent: ${theme.gradients.accent};
    --gradient-success: ${theme.gradients.success};
    --gradient-premium: ${theme.gradients.premium};
    
    /* Spacing */
    --spacing-xs: ${theme.spacing.xs};
    --spacing-sm: ${theme.spacing.sm};
    --spacing-md: ${theme.spacing.md};
    --spacing-lg: ${theme.spacing.lg};
    --spacing-xl: ${theme.spacing.xl};
    --spacing-2xl: ${theme.spacing['2xl']};
    --spacing-3xl: ${theme.spacing['3xl']};
    
    /* Border Radius */
    --radius-sm: ${theme.borderRadius.sm};
    --radius-md: ${theme.borderRadius.md};
    --radius-lg: ${theme.borderRadius.lg};
    --radius-xl: ${theme.borderRadius.xl};
    --radius-2xl: ${theme.borderRadius['2xl']};
    
    /* Shadows */
    --shadow-sm: ${theme.shadows.sm};
    --shadow-md: ${theme.shadows.md};
    --shadow-lg: ${theme.shadows.lg};
    --shadow-xl: ${theme.shadows.xl};
    
    /* Animation */
    --duration-fast: ${theme.animation.duration.fast};
    --duration-normal: ${theme.animation.duration.normal};
    --duration-slow: ${theme.animation.duration.slow};
    
    --easing-out: ${theme.animation.easing.easeOut};
    --easing-in: ${theme.animation.easing.easeIn};
    --easing-in-out: ${theme.animation.easing.easeInOut};
  }
`;

// Utility functions for theme usage
export const getColor = (path: string) => {
  const keys = path.split('.');
  let value: any = theme.colors;
  
  for (const key of keys) {
    value = value[key];
    if (!value) return undefined;
  }
  
  return value;
};

export const getSpacing = (size: keyof typeof theme.spacing) => {
  return theme.spacing[size];
};

export const getRadius = (size: keyof typeof theme.borderRadius) => {
  return theme.borderRadius[size];
};

export const getShadow = (size: keyof typeof theme.shadows) => {
  return theme.shadows[size];
};

// Type exports for TypeScript
export type ThemeColors = typeof theme.colors;
export type ThemeSpacing = typeof theme.spacing;
export type ThemeBorderRadius = typeof theme.borderRadius;
export type ThemeShadows = typeof theme.shadows; 