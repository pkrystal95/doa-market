import {
  Dashboard as DashboardIcon,
  People as PeopleIcon,
  Store as StoreIcon,
  Inventory as InventoryIcon,
  ShoppingCart as ShoppingCartIcon,
  AccountBalance as AccountBalanceIcon,
  Star as StarIcon,
  LocalOffer as LocalOfferIcon,
  Campaign as CampaignIcon,
  BarChart as BarChartIcon,
  Settings as SettingsIcon,
  Notifications as NotificationsIcon,
  Category as CategoryIcon,
} from '@mui/icons-material';

export interface NavItem {
  title: string;
  path: string;
  icon: any;
  badge?: number;
  children?: NavItem[];
}

export const navConfig: NavItem[] = [
  {
    title: '대시보드',
    path: '/dashboard',
    icon: DashboardIcon,
  },
  {
    title: '사용자 관리',
    path: '/users',
    icon: PeopleIcon,
  },
  {
    title: '판매자 관리',
    path: '/sellers',
    icon: StoreIcon,
  },
  {
    title: '상품 관리',
    path: '/products',
    icon: InventoryIcon,
  },
  {
    title: '카테고리 관리',
    path: '/categories',
    icon: CategoryIcon,
  },
  {
    title: '주문 관리',
    path: '/orders',
    icon: ShoppingCartIcon,
    badge: 5, // 새 주문 알림
  },
  {
    title: '정산 관리',
    path: '/settlements',
    icon: AccountBalanceIcon,
  },
  {
    title: '리뷰 관리',
    path: '/reviews',
    icon: StarIcon,
  },
  {
    title: '쿠폰 관리',
    path: '/coupons',
    icon: LocalOfferIcon,
  },
  {
    title: '공지사항',
    path: '/notices',
    icon: CampaignIcon,
  },
  {
    title: '통계',
    path: '/analytics',
    icon: BarChartIcon,
  },
  {
    title: '설정',
    path: '/settings',
    icon: SettingsIcon,
  },
];

