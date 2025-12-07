import {
  Dashboard as DashboardIcon,
  Inventory as InventoryIcon,
  ShoppingCart as ShoppingCartIcon,
  AccountBalance as AccountBalanceIcon,
  BarChart as BarChartIcon,
  QuestionAnswer as QuestionAnswerIcon,
  Star as StarIcon,
  Settings as SettingsIcon,
  Notifications as NotificationsIcon,
  Campaign as CampaignIcon,
} from '@mui/icons-material';

export interface NavItem {
  title: string;
  path: string;
  icon: any;
  badge?: number;
}

export const navConfig: NavItem[] = [
  {
    title: '대시보드',
    path: '/dashboard',
    icon: DashboardIcon,
  },
  {
    title: '상품 관리',
    path: '/products',
    icon: InventoryIcon,
  },
  {
    title: '주문 관리',
    path: '/orders',
    icon: ShoppingCartIcon,
    badge: 8, // 새 주문
  },
  {
    title: '정산 내역',
    path: '/settlements',
    icon: AccountBalanceIcon,
  },
  {
    title: '상품 문의',
    path: '/inquiries',
    icon: QuestionAnswerIcon,
    badge: 3,
  },
  {
    title: '리뷰 관리',
    path: '/reviews',
    icon: StarIcon,
  },
  {
    title: '통계',
    path: '/analytics',
    icon: BarChartIcon,
  },
  {
    title: '프로모션',
    path: '/promotions',
    icon: CampaignIcon,
  },
  {
    title: '설정',
    path: '/settings',
    icon: SettingsIcon,
  },
];

