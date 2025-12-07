import { useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import { Table, Button, Space, Alert, Tag } from 'antd'
import { ReloadOutlined, DollarOutlined } from '@ant-design/icons'
import type { ColumnsType } from 'antd/es/table'
import { settlementsApi } from '@/services/api'

interface Settlement {
  id: string
  period: string
  totalSales: number
  commission: number
  settlementAmount: number
  status: string
  requestedAt?: string
  completedAt?: string
}

const SELLER_ID = 'seller-id-placeholder'

const getStatusColor = (status: string) => {
  switch (status) {
    case 'pending':
      return 'warning'
    case 'processing':
      return 'processing'
    case 'completed':
      return 'success'
    case 'rejected':
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
    case 'completed':
      return '완료'
    case 'rejected':
      return '거절'
    default:
      return status
  }
}

export default function Settlements() {
  const [page, setPage] = useState(1)
  const [pageSize, setPageSize] = useState(10)

  const { data, isLoading, error, refetch } = useQuery({
    queryKey: ['settlements', page, pageSize],
    queryFn: () => settlementsApi.getAll(page, pageSize, SELLER_ID),
  })

  const columns: ColumnsType<Settlement> = [
    {
      title: '정산 기간',
      dataIndex: 'period',
      key: 'period',
    },
    {
      title: '총 매출',
      dataIndex: 'totalSales',
      key: 'totalSales',
      render: (amount: number) => `₩${amount?.toLocaleString() || 0}`,
    },
    {
      title: '수수료',
      dataIndex: 'commission',
      key: 'commission',
      render: (amount: number) => `₩${amount?.toLocaleString() || 0}`,
    },
    {
      title: '정산 금액',
      dataIndex: 'settlementAmount',
      key: 'settlementAmount',
      render: (amount: number) => (
        <span style={{ fontWeight: 'bold', color: '#52c41a' }}>
          ₩{amount?.toLocaleString() || 0}
        </span>
      ),
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
      title: '신청일',
      dataIndex: 'requestedAt',
      key: 'requestedAt',
      render: (date: string) => date ? new Date(date).toLocaleDateString('ko-KR') : '-',
    },
    {
      title: '완료일',
      dataIndex: 'completedAt',
      key: 'completedAt',
      render: (date: string) => date ? new Date(date).toLocaleDateString('ko-KR') : '-',
    },
  ]

  if (error) {
    return <Alert message="오류" description="정산 데이터를 불러오는데 실패했습니다." type="error" />
  }

  const settlements = data?.data?.data || []
  const pagination = data?.data?.pagination

  return (
    <>
      <Space direction="vertical" size="large" style={{ width: '100%' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <h1>정산 관리</h1>
          <Space>
            <Button icon={<ReloadOutlined />} onClick={() => refetch()}>
              새로고침
            </Button>
            <Button type="primary" icon={<DollarOutlined />}>
              정산 신청
            </Button>
          </Space>
        </div>

        <Alert
          message="정산 안내"
          description="매월 1일에 전월 매출에 대한 정산이 자동으로 생성됩니다. 정산 신청 후 영업일 기준 3-5일 내에 입금됩니다."
          type="info"
          showIcon
        />

        <Table
          columns={columns}
          dataSource={settlements}
          rowKey="id"
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
