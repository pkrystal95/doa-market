import { useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import { Table, Input, Button, Space, Alert, Spin } from 'antd'
import { SearchOutlined, ReloadOutlined } from '@ant-design/icons'
import type { ColumnsType } from 'antd/es/table'
import { usersApi } from '@/services/api'

interface User {
  id: string
  name: string
  email: string
  phone?: string
  role: string
  grade: string
  status: string
}

export default function Users() {
  const [page, setPage] = useState(1)
  const [pageSize, setPageSize] = useState(10)
  const [searchQuery, setSearchQuery] = useState('')

  const { data, isLoading, error, refetch } = useQuery({
    queryKey: ['users', page, pageSize],
    queryFn: () => usersApi.getAll(page, pageSize),
  })

  const columns: ColumnsType<User> = [
    {
      title: '사용자 ID',
      dataIndex: 'id',
      key: 'id',
      render: (text: string) => text.substring(0, 8) + '...',
    },
    {
      title: '이름',
      dataIndex: 'name',
      key: 'name',
    },
    {
      title: '이메일',
      dataIndex: 'email',
      key: 'email',
    },
    {
      title: '전화번호',
      dataIndex: 'phone',
      key: 'phone',
    },
    {
      title: '등급',
      dataIndex: 'grade',
      key: 'grade',
    },
    {
      title: '상태',
      dataIndex: 'status',
      key: 'status',
    },
  ]

  if (error) {
    return <Alert message="오류" description="사용자 데이터를 불러오는데 실패했습니다." type="error" />
  }

  const users = data?.data?.data || []
  const pagination = data?.data?.pagination

  return (
    <>
      <Space direction="vertical" size="large" style={{ width: '100%' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <h1>사용자 관리</h1>
          <Button icon={<ReloadOutlined />} onClick={() => refetch()}>
            새로고침
          </Button>
        </div>

        <Input
          placeholder="사용자 검색..."
          prefix={<SearchOutlined />}
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          style={{ marginBottom: 16 }}
        />

        <Table
          columns={columns}
          dataSource={users}
          rowKey="id"
          loading={isLoading}
          pagination={{
            current: page,
            pageSize: pageSize,
            total: users.length,
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
