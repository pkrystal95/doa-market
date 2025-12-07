import { useState } from 'react'
import { Outlet, useNavigate, useLocation } from 'react-router-dom'
import { Layout as AntLayout, Menu, theme } from 'antd'
import {
  DashboardOutlined,
  UserOutlined,
  ShoppingOutlined,
  ShoppingCartOutlined,
  ShopOutlined,
  NotificationOutlined,
  QuestionCircleOutlined,
  FileTextOutlined,
} from '@ant-design/icons'

const { Header, Content, Sider } = AntLayout

interface MenuItem {
  key: string
  icon: JSX.Element
  label: string
  path: string
}

const menuItems: MenuItem[] = [
  { key: 'dashboard', icon: <DashboardOutlined />, label: '대시보드', path: '/dashboard' },
  { key: 'users', icon: <UserOutlined />, label: '사용자 관리', path: '/users' },
  { key: 'products', icon: <ShoppingOutlined />, label: '상품 관리', path: '/products' },
  { key: 'orders', icon: <ShoppingCartOutlined />, label: '주문 관리', path: '/orders' },
  { key: 'sellers', icon: <ShopOutlined />, label: '판매자 관리', path: '/sellers' },
  { key: 'notices', icon: <NotificationOutlined />, label: '공지사항', path: '/notices' },
  { key: 'inquiries', icon: <QuestionCircleOutlined />, label: '문의사항', path: '/inquiries' },
  { key: 'policies', icon: <FileTextOutlined />, label: '정책 관리', path: '/policies' },
]

export default function Layout() {
  const [collapsed, setCollapsed] = useState(false)
  const navigate = useNavigate()
  const location = useLocation()
  const {
    token: { colorBgContainer, borderRadiusLG },
  } = theme.useToken()

  const selectedKey = menuItems.find(item => location.pathname === item.path)?.key || 'dashboard'

  return (
    <AntLayout style={{ minHeight: '100vh' }}>
      <Sider collapsible collapsed={collapsed} onCollapse={setCollapsed}>
        <div
          style={{
            height: 64,
            margin: 16,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            color: '#fff',
            fontSize: collapsed ? 16 : 20,
            fontWeight: 'bold',
          }}
        >
          {collapsed ? 'DOA' : 'DOA Market'}
        </div>
        <Menu
          theme="dark"
          selectedKeys={[selectedKey]}
          mode="inline"
          items={menuItems.map(item => ({
            key: item.key,
            icon: item.icon,
            label: item.label,
            onClick: () => navigate(item.path),
          }))}
        />
      </Sider>
      <AntLayout>
        <Header style={{ padding: 0, background: colorBgContainer, paddingLeft: 24, fontSize: 18 }}>
          관리자 대시보드
        </Header>
        <Content style={{ margin: '24px 16px 0' }}>
          <div
            style={{
              padding: 24,
              minHeight: 360,
              background: colorBgContainer,
              borderRadius: borderRadiusLG,
            }}
          >
            <Outlet />
          </div>
        </Content>
      </AntLayout>
    </AntLayout>
  )
}
