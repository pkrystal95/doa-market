import { useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import { Table, Button, Space, Alert, Tag } from 'antd'
import { ReloadOutlined } from '@ant-design/icons'
import type { ColumnsType } from 'antd/es/table'
import { ordersApi } from '@/services/api'

interface Order {
  orderId: string
  userId: string
  totalAmount: number
  status: string
  createdAt: string
}

const getStatusColor = (status: string) => {
  switch (status) {
    case 'pending':
      return 'warning'
    case 'processing':
      return 'processing'
    case 'shipped':
      return 'blue'
    case 'delivered':
      return 'success'
    case 'cancelled':
      return 'error'
    default:
      return 'default'
  }
}

const getStatusText = (status: string) => {
  switch (status) {
    case 'pending':
      return '대기'
    case 'processing':
      return '처리중'
    case 'shipped':
      return '배송중'
    case 'delivered':
      return '배송완료'
    case 'cancelled':
      return '취소'
    default:
      return status
  }
}

export default function Orders() {
  const [page, setPage] = useState(1)
  const [pageSize, setPageSize] = useState(10)

  const { data, isLoading, error, refetch } = useQuery({
    queryKey: ['orders', page, pageSize],
    queryFn: () => ordersApi.getAll(page, pageSize),
  })

  const columns: ColumnsType<Order> = [
    {
      title: '주문 ID',
      dataIndex: 'orderId',
      key: 'orderId',
      render: (text: string) => text.substring(0, 8) + '...',
    },
    {
      title: '사용자 ID',
      dataIndex: 'userId',
      key: 'userId',
      render: (text: string) => text.substring(0, 8) + '...',
    },
    {
      title: '총 금액',
      dataIndex: 'totalAmount',
      key: 'totalAmount',
      render: (amount: number) => `₩${amount.toLocaleString()}`,
    },
    {
      title: '상태',
      dataIndex: 'status',
      key: 'status',
      render: (status: string) => (
        <Tag color={getStatusColor(status)}>{getStatusText(status)}</Tag>
      ),
    },
    {
      title: '주문일시',
      dataIndex: 'createdAt',
      key: 'createdAt',
      render: (date: string) => new Date(date).toLocaleString('ko-KR'),
    },
  ]

  if (error) {
    return <Alert message="오류" description="주문 데이터를 불러오는데 실패했습니다." type="error" />
  }

  const orders = data?.data?.data || []
  const pagination = data?.data?.pagination

  return (
    <>
      <Space direction="vertical" size="large" style={{ width: '100%' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <h1>주문 관리</h1>
          <Button icon={<ReloadOutlined />} onClick={() => refetch()}>
            새로고침
          </Button>
        </div>

        <Table
          columns={columns}
          dataSource={orders}
          rowKey="orderId"
          loading={isLoading}
          pagination={{
            current: page,
            pageSize: pageSize,
            total: pagination?.total || 0,
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
