'use client';

import { createTheme, alpha } from '@mui/material/styles';

// Color palette inspired by Minimal template
const palette = {
  primary: {
    lighter: '#C8FAD6',
    light: '#5BE49B',
    main: '#00A76F',
    dark: '#007867',
    darker: '#004B50',
    contrastText: '#FFFFFF',
  },
  secondary: {
    lighter: '#EFD6FF',
    light: '#C684FF',
    main: '#8E33FF',
    dark: '#5119B7',
    darker: '#27097A',
    contrastText: '#FFFFFF',
  },
  info: {
    lighter: '#CAFDF5',
    light: '#61F3F3',
    main: '#00B8D9',
    dark: '#006C9C',
    darker: '#003768',
    contrastText: '#FFFFFF',
  },
  success: {
    lighter: '#D8FBDE',
    light: '#86E8AB',
    main: '#36B37E',
    dark: '#1B806A',
    darker: '#0A5554',
    contrastText: '#FFFFFF',
  },
  warning: {
    lighter: '#FFF5CC',
    light: '#FFD666',
    main: '#FFAB00',
    dark: '#B76E00',
    darker: '#7A4100',
    contrastText: '#1C252E',
  },
  error: {
    lighter: '#FFE9D5',
    light: '#FFAC82',
    main: '#FF5630',
    dark: '#B71D18',
    darker: '#7A0916',
    contrastText: '#FFFFFF',
  },
  grey: {
    50: '#FCFDFD',
    100: '#F9FAFB',
    200: '#F4F6F8',
    300: '#DFE3E8',
    400: '#C4CDD5',
    500: '#919EAB',
    600: '#637381',
    700: '#454F5B',
    800: '#1C252E',
    900: '#141A21',
  },
};

// Create theme
export const themeOptions = {
  palette: {
    mode: 'light',
    ...palette,
    text: {
      primary: palette.grey[800],
      secondary: palette.grey[600],
      disabled: palette.grey[500],
    },
    background: {
      paper: '#FFFFFF',
      default: '#FFFFFF',
    },
    action: {
      hover: alpha(palette.grey[500], 0.08),
      selected: alpha(palette.grey[500], 0.16),
      disabled: alpha(palette.grey[500], 0.8),
      disabledBackground: alpha(palette.grey[500], 0.24),
    },
  },
  typography: {
    fontFamily: [
      'Public Sans',
      '-apple-system',
      'BlinkMacSystemFont',
      '"Segoe UI"',
      'Roboto',
      '"Helvetica Neue"',
      'Arial',
      'sans-serif',
    ].join(','),
    h1: {
      fontWeight: 700,
      fontSize: '2.5rem',
      lineHeight: 1.2,
    },
    h2: {
      fontWeight: 700,
      fontSize: '2rem',
      lineHeight: 1.3,
    },
    h3: {
      fontWeight: 700,
      fontSize: '1.75rem',
      lineHeight: 1.4,
    },
    h4: {
      fontWeight: 700,
      fontSize: '1.5rem',
      lineHeight: 1.4,
    },
    h5: {
      fontWeight: 600,
      fontSize: '1.25rem',
      lineHeight: 1.5,
    },
    h6: {
      fontWeight: 600,
      fontSize: '1.125rem',
      lineHeight: 1.5,
    },
    subtitle1: {
      fontWeight: 600,
      fontSize: '1rem',
      lineHeight: 1.5,
    },
    subtitle2: {
      fontWeight: 600,
      fontSize: '0.875rem',
      lineHeight: 1.57,
    },
    body1: {
      fontSize: '1rem',
      lineHeight: 1.5,
    },
    body2: {
      fontSize: '0.875rem',
      lineHeight: 1.57,
    },
    caption: {
      fontSize: '0.75rem',
      lineHeight: 1.66,
    },
  },
  shape: {
    borderRadius: 8,
  },
  shadows: [
    'none',
    '0px 2px 4px rgba(0,0,0,0.08)',
    '0px 3px 6px rgba(0,0,0,0.10)',
    '0px 4px 8px rgba(0,0,0,0.12)',
    '0px 6px 12px rgba(0,0,0,0.14)',
    '0px 8px 16px rgba(0,0,0,0.16)',
    '0px 12px 24px rgba(0,0,0,0.18)',
    '0px 16px 32px rgba(0,0,0,0.20)',
    '0px 20px 40px rgba(0,0,0,0.22)',
    '0px 24px 48px rgba(0,0,0,0.24)',
    '0px 0px 0px 0px rgba(0,0,0,0)',
    '0px 0px 0px 0px rgba(0,0,0,0)',
    '0px 0px 0px 0px rgba(0,0,0,0)',
    '0px 0px 0px 0px rgba(0,0,0,0)',
    '0px 0px 0px 0px rgba(0,0,0,0)',
    '0px 0px 0px 0px rgba(0,0,0,0)',
    '0px 0px 0px 0px rgba(0,0,0,0)',
    '0px 0px 0px 0px rgba(0,0,0,0)',
    '0px 0px 0px 0px rgba(0,0,0,0)',
    '0px 0px 0px 0px rgba(0,0,0,0)',
    '0px 24px 48px rgba(145, 158, 171, 0.24)',
    '0px 0px 2px 0px rgba(145, 158, 171, 0.2), 0px 24px 48px -4px rgba(145, 158, 171, 0.24)',
    '0px 0px 2px 0px rgba(145, 158, 171, 0.2), 0px 24px 48px -4px rgba(145, 158, 171, 0.24)',
    '0px 0px 2px 0px rgba(145, 158, 171, 0.2), 0px 24px 48px -4px rgba(145, 158, 171, 0.24)',
    '0px 0px 2px 0px rgba(145, 158, 171, 0.2), 0px 24px 48px -4px rgba(145, 158, 171, 0.24)',
  ],
  components: {
    MuiButton: {
      styleOverrides: {
        root: {
          textTransform: 'none',
          fontWeight: 600,
        },
        sizeLarge: {
          padding: '12px 24px',
        },
      },
    },
    MuiCard: {
      styleOverrides: {
        root: {
          boxShadow: '0px 0px 2px 0px rgba(145, 158, 171, 0.2), 0px 12px 24px -4px rgba(145, 158, 171, 0.12)',
          borderRadius: 16,
        },
      },
    },
    MuiTextField: {
      defaultProps: {
        variant: 'outlined',
      },
    },
  },
};

export const theme = createTheme(themeOptions);
export default theme;

