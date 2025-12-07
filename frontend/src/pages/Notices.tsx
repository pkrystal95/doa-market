import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { Table, Button, Space, Alert, Tag, Modal, Form, Input, Select, Switch, message } from 'antd'
import { ReloadOutlined, PlusOutlined, EditOutlined, DeleteOutlined, PushpinOutlined } from '@ant-design/icons'
import type { ColumnsType } from 'antd/es/table'
import { noticesApi } from '@/services/api'

const { TextArea } = Input

interface Notice {
  id: string
  title: string
  content: string
  category: string
  status: string
  views: number
  isPinned: boolean
  createdAt: string
}

export default function Notices() {
  const [page, setPage] = useState(1)
  const [pageSize, setPageSize] = useState(10)
  const [isModalOpen, setIsModalOpen] = useState(false)
  const [editingNotice, setEditingNotice] = useState<Notice | null>(null)
  const [form] = Form.useForm()
  const queryClient = useQueryClient()

  const { data, isLoading, error, refetch } = useQuery({
    queryKey: ['notices', page, pageSize],
    queryFn: () => noticesApi.getAll(page, pageSize),
  })

  const createMutation = useMutation({
    mutationFn: (values: any) => noticesApi.create(values),
    onSuccess: () => {
      message.success('공지사항이 생성되었습니다.')
      queryClient.invalidateQueries({ queryKey: ['notices'] })
      setIsModalOpen(false)
      form.resetFields()
    },
  })

  const updateMutation = useMutation({
    mutationFn: ({ id, data }: { id: string; data: any }) => noticesApi.update(id, data),
    onSuccess: () => {
      message.success('공지사항이 수정되었습니다.')
      queryClient.invalidateQueries({ queryKey: ['notices'] })
      setIsModalOpen(false)
      setEditingNotice(null)
      form.resetFields()
    },
  })

  const deleteMutation = useMutation({
    mutationFn: (id: string) => noticesApi.delete(id),
    onSuccess: () => {
      message.success('공지사항이 삭제되었습니다.')
      queryClient.invalidateQueries({ queryKey: ['notices'] })
    },
  })

  const handleCreate = () => {
    setEditingNotice(null)
    form.resetFields()
    form.setFieldsValue({
      category: '공지',
      status: 'draft',
      isPinned: false,
      createdBy: 'admin-id-placeholder'
    })
    setIsModalOpen(true)
  }

  const handleEdit = (record: Notice) => {
    setEditingNotice(record)
    form.setFieldsValue(record)
    setIsModalOpen(true)
  }

  const handleDelete = (id: string) => {
    Modal.confirm({
      title: '삭제 확인',
      content: '정말로 이 공지사항을 삭제하시겠습니까?',
      okText: '삭제',
      cancelText: '취소',
      onOk: () => deleteMutation.mutate(id),
    })
  }

  const handleSubmit = (values: any) => {
    if (editingNotice) {
      updateMutation.mutate({ id: editingNotice.id, data: values })
    } else {
      createMutation.mutate(values)
    }
  }

  const columns: ColumnsType<Notice> = [
    {
      title: '고정',
      dataIndex: 'isPinned',
      key: 'isPinned',
      width: 60,
      render: (isPinned: boolean) => isPinned && <PushpinOutlined style={{ color: '#1890ff' }} />,
    },
    {
      title: '제목',
      dataIndex: 'title',
      key: 'title',
    },
    {
      title: '카테고리',
      dataIndex: 'category',
      key: 'category',
      render: (category: string) => <Tag>{category}</Tag>,
    },
    {
      title: '상태',
      dataIndex: 'status',
      key: 'status',
      render: (status: string) => {
        const colorMap: Record<string, string> = {
          draft: 'default',
          published: 'success',
          archived: 'error',
        }
        const textMap: Record<string, string> = {
          draft: '초안',
          published: '게시됨',
          archived: '보관됨',
        }
        return <Tag color={colorMap[status]}>{textMap[status] || status}</Tag>
      },
    },
    {
      title: '조회수',
      dataIndex: 'views',
      key: 'views',
    },
    {
      title: '작성일',
      dataIndex: 'createdAt',
      key: 'createdAt',
      render: (date: string) => new Date(date).toLocaleDateString('ko-KR'),
    },
    {
      title: '작업',
      key: 'actions',
      render: (_, record) => (
        <Space size="small">
          <Button
            type="link"
            icon={<EditOutlined />}
            onClick={() => handleEdit(record)}
          >
            수정
          </Button>
          <Button
            type="link"
            danger
            icon={<DeleteOutlined />}
            onClick={() => handleDelete(record.id)}
          >
            삭제
          </Button>
        </Space>
      ),
    },
  ]

  if (error) {
    return <Alert message="오류" description="공지사항 데이터를 불러오는데 실패했습니다." type="error" />
  }

  const notices = data?.data?.data || []
  const pagination = data?.data?.pagination

  return (
    <>
      <Space direction="vertical" size="large" style={{ width: '100%' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <h1>공지사항 관리</h1>
          <Space>
            <Button icon={<ReloadOutlined />} onClick={() => refetch()}>
              새로고침
            </Button>
            <Button type="primary" icon={<PlusOutlined />} onClick={handleCreate}>
              공지사항 추가
            </Button>
          </Space>
        </div>

        <Table
          columns={columns}
          dataSource={notices}
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

      <Modal
        title={editingNotice ? '공지사항 수정' : '공지사항 추가'}
        open={isModalOpen}
        onCancel={() => {
          setIsModalOpen(false)
          setEditingNotice(null)
          form.resetFields()
        }}
        onOk={() => form.submit()}
        width={700}
      >
        <Form form={form} layout="vertical" onFinish={handleSubmit}>
          <Form.Item name="createdBy" hidden>
            <Input />
          </Form.Item>
          <Form.Item
            name="title"
            label="제목"
            rules={[{ required: true, message: '제목을 입력해주세요' }]}
          >
            <Input placeholder="공지사항 제목" />
          </Form.Item>
          <Form.Item
            name="content"
            label="내용"
            rules={[{ required: true, message: '내용을 입력해주세요' }]}
          >
            <TextArea rows={6} placeholder="공지사항 내용" />
          </Form.Item>
          <Form.Item name="category" label="카테고리">
            <Select>
              <Select.Option value="공지">공지</Select.Option>
              <Select.Option value="이벤트">이벤트</Select.Option>
              <Select.Option value="업데이트">업데이트</Select.Option>
              <Select.Option value="점검">점검</Select.Option>
            </Select>
          </Form.Item>
          <Form.Item name="status" label="상태">
            <Select>
              <Select.Option value="draft">초안</Select.Option>
              <Select.Option value="published">게시</Select.Option>
              <Select.Option value="archived">보관</Select.Option>
            </Select>
          </Form.Item>
          <Form.Item name="isPinned" label="상단 고정" valuePropName="checked">
            <Switch />
          </Form.Item>
        </Form>
      </Modal>
    </>
  )
}
