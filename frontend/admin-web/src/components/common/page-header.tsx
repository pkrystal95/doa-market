import { Box, Typography, Breadcrumbs, Link, Stack, Button } from '@mui/material';
import { NavigateNext, Add } from '@mui/icons-material';

interface Breadcrumb {
  label: string;
  href?: string;
}

interface PageHeaderProps {
  title: string;
  subtitle?: string;
  breadcrumbs?: Breadcrumb[];
  action?: {
    label: string;
    onClick: () => void;
    icon?: React.ReactNode;
  };
}

export function PageHeader({ title, subtitle, breadcrumbs, action }: PageHeaderProps) {
  return (
    <Box sx={{ mb: 4 }}>
      {breadcrumbs && breadcrumbs.length > 0 && (
        <Breadcrumbs
          separator={<NavigateNext fontSize="small" />}
          sx={{ mb: 2 }}
        >
          {breadcrumbs.map((breadcrumb, index) => (
            breadcrumb.href ? (
              <Link
                key={index}
                underline="hover"
                color="inherit"
                href={breadcrumb.href}
                sx={{ fontSize: 14 }}
              >
                {breadcrumb.label}
              </Link>
            ) : (
              <Typography key={index} color="text.primary" sx={{ fontSize: 14 }}>
                {breadcrumb.label}
              </Typography>
            )
          ))}
        </Breadcrumbs>
      )}
      
      <Stack direction="row" justifyContent="space-between" alignItems="center">
        <Box>
          <Typography variant="h4" sx={{ fontWeight: 700, mb: 0.5 }}>
            {title}
          </Typography>
          {subtitle && (
            <Typography variant="body2" color="text.secondary">
              {subtitle}
            </Typography>
          )}
        </Box>
        
        {action && (
          <Button
            variant="contained"
            startIcon={action.icon || <Add />}
            onClick={action.onClick}
            sx={{ textTransform: 'none', fontWeight: 600 }}
          >
            {action.label}
          </Button>
        )}
      </Stack>
    </Box>
  );
}

