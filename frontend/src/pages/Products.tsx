import { useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import { Table, Input, Button, Space, Alert, Tag } from 'antd'
import { SearchOutlined, ReloadOutlined } from '@ant-design/icons'
import type { ColumnsType } from 'antd/es/table'
import { productsApi } from '@/services/api'

interface Product {
  id: string
  name: string
  categoryId: string
  price: string
  stockQuantity: number
  sellerId: string
}

export default function Products() {
  const [page, setPage] = useState(1)
  const [pageSize, setPageSize] = useState(10)
  const [searchQuery, setSearchQuery] = useState('')

  const { data, isLoading, error, refetch } = useQuery({
    queryKey: ['products', page, pageSize],
    queryFn: () => productsApi.getAll(page, pageSize),
  })

  const columns: ColumnsType<Product> = [
    {
      title: '상품 ID',
      dataIndex: 'id',
      key: 'id',
      render: (text: string) => text.substring(0, 8) + '...',
    },
    {
      title: '상품명',
      dataIndex: 'name',
      key: 'name',
    },
    {
      title: '카테고리 ID',
      dataIndex: 'categoryId',
      key: 'categoryId',
      render: (categoryId: string) => <Tag>{categoryId.substring(0, 8)}...</Tag>,
    },
    {
      title: '가격',
      dataIndex: 'price',
      key: 'price',
      render: (price: string) => `₩${parseFloat(price).toLocaleString()}`,
    },
    {
      title: '재고',
      dataIndex: 'stockQuantity',
      key: 'stockQuantity',
      render: (stock: number) => (
        <Tag color={stock > 10 ? 'green' : 'orange'}>{stock}</Tag>
      ),
    },
    {
      title: '판매자 ID',
      dataIndex: 'sellerId',
      key: 'sellerId',
      render: (text: string) => text.substring(0, 8) + '...',
    },
  ]

  if (error) {
    return <Alert message="오류" description="상품 데이터를 불러오는데 실패했습니다." type="error" />
  }

  const products = data?.data?.data || []
  const pagination = data?.data?.pagination

  return (
    <>
      <Space direction="vertical" size="large" style={{ width: '100%' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <h1>상품 관리</h1>
          <Button icon={<ReloadOutlined />} onClick={() => refetch()}>
            새로고침
          </Button>
        </div>

        <Input
          placeholder="상품 검색..."
          prefix={<SearchOutlined />}
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          style={{ marginBottom: 16 }}
        />

        <Table
          columns={columns}
          dataSource={products}
          rowKey="id"
          loading={isLoading}
          pagination={{
            current: page,
            pageSize: pageSize,
            total: products.length,
            showSizeChanger: true,
            showTotal: (total) => `총 ${total}개`,
            onChange: (page, pageSize) => {
              setPage(page)
              setPageSize(pageSize)
            },
          }}
        />
      </Space>
    </>
  )
}
