import { useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import { Table, Button, Space, Alert, Tag } from 'antd'
import { ReloadOutlined, CheckCircleOutlined, StopOutlined } from '@ant-design/icons'
import type { ColumnsType } from 'antd/es/table'
import { sellersApi } from '@/services/api'

interface Seller {
  id: string
  userId: string
  storeName: string
  businessNumber: string
  status: string
  verifiedAt?: string
}

const getStatusColor = (status: string) => {
  switch (status) {
    case 'verified':
      return 'success'
    case 'pending':
      return 'processing'
    case 'rejected':
      return 'error'
    case 'suspended':
      return 'error'
    default:
      return 'default'
  }
}

const getStatusText = (status: string) => {
  switch (status) {
    case 'verified':
      return '승인됨'
    case 'pending':
      return '대기중'
    case 'rejected':
      return '거절됨'
    case 'suspended':
      return '정지'
    default:
      return status
  }
}

export default function Sellers() {
  const [page, setPage] = useState(1)
  const [pageSize, setPageSize] = useState(10)

  const { data, isLoading, error, refetch } = useQuery({
    queryKey: ['sellers', page, pageSize],
    queryFn: () => sellersApi.getAll(page, pageSize),
  })

  const handleApprove = async (sellerId: string) => {
    try {
      await sellersApi.approve(sellerId)
      refetch()
    } catch (error) {
      console.error('Failed to approve seller:', error)
    }
  }

  const handleSuspend = async (sellerId: string) => {
    try {
      await sellersApi.suspend(sellerId)
      refetch()
    } catch (error) {
      console.error('Failed to suspend seller:', error)
    }
  }

  const columns: ColumnsType<Seller> = [
    {
      title: '판매자 ID',
      dataIndex: 'id',
      key: 'id',
      render: (text: string) => text.substring(0, 8) + '...',
    },
    {
      title: '상호명',
      dataIndex: 'storeName',
      key: 'storeName',
    },
    {
      title: '사업자번호',
      dataIndex: 'businessNumber',
      key: 'businessNumber',
    },
    {
      title: '사용자 ID',
      dataIndex: 'userId',
      key: 'userId',
      render: (text: string) => text.substring(0, 8) + '...',
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
      title: '작업',
      key: 'actions',
      render: (_, record) => (
        <Space size="small">
          <Button
            type="primary"
            icon={<CheckCircleOutlined />}
            onClick={() => handleApprove(record.id)}
            disabled={record.status === 'verified'}
            size="small"
          >
            승인
          </Button>
          <Button
            danger
            icon={<StopOutlined />}
            onClick={() => handleSuspend(record.id)}
            disabled={record.status === 'suspended'}
            size="small"
          >
            정지
          </Button>
        </Space>
      ),
    },
  ]

  if (error) {
    return <Alert message="오류" description="판매자 데이터를 불러오는데 실패했습니다." type="error" />
  }

  const sellers = data?.data?.data || []
  const pagination = data?.data?.pagination

  return (
    <>
      <Space direction="vertical" size="large" style={{ width: '100%' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <h1>판매자 관리</h1>
          <Button icon={<ReloadOutlined />} onClick={() => refetch()}>
            새로고침
          </Button>
        </div>

        <Table
          columns={columns}
          dataSource={sellers}
          rowKey="id"
          loading={isLoading}
          pagination={{
            current: page,
            pageSize: pageSize,
            total: sellers.length,
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
