import { Routes, Route, Navigate } from 'react-router-dom'
import Layout from '@/components/Layout'
import Dashboard from '@/pages/Dashboard'
import Users from '@/pages/Users'
import Products from '@/pages/Products'
import Orders from '@/pages/Orders'
import Sellers from '@/pages/Sellers'
import Notices from '@/pages/Notices'
import Inquiries from '@/pages/Inquiries'
import Policies from '@/pages/Policies'

function App() {
  return (
    <Routes>
      <Route path="/" element={<Layout />}>
        <Route index element={<Navigate to="/dashboard" replace />} />
        <Route path="dashboard" element={<Dashboard />} />
        <Route path="users" element={<Users />} />
        <Route path="products" element={<Products />} />
        <Route path="orders" element={<Orders />} />
        <Route path="sellers" element={<Sellers />} />
        <Route path="notices" element={<Notices />} />
        <Route path="inquiries" element={<Inquiries />} />
        <Route path="policies" element={<Policies />} />
      </Route>
    </Routes>
  )
}

export default App
