import { Routes, Route, Navigate } from 'react-router-dom'
import Layout from '@/components/Layout'
import Dashboard from '@/pages/Dashboard'
import Products from '@/pages/Products'
import Orders from '@/pages/Orders'
import Reviews from '@/pages/Reviews'
import Settlements from '@/pages/Settlements'
import Inquiries from '@/pages/Inquiries'

function App() {
  return (
    <Routes>
      <Route path="/" element={<Layout />}>
        <Route index element={<Navigate to="/dashboard" replace />} />
        <Route path="dashboard" element={<Dashboard />} />
        <Route path="products" element={<Products />} />
        <Route path="orders" element={<Orders />} />
        <Route path="reviews" element={<Reviews />} />
        <Route path="settlements" element={<Settlements />} />
        <Route path="inquiries" element={<Inquiries />} />
      </Route>
    </Routes>
  )
}

export default App
