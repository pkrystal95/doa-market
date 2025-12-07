import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { Table, Button, Space, Alert, Tag, Modal, Form, Input, Select, DatePicker, message } from 'antd'
import { ReloadOutlined, PlusOutlined, EditOutlined, DeleteOutlined, CheckCircleOutlined } from '@ant-design/icons'
import type { ColumnsType } from 'antd/es/table'
import { policiesApi } from '@/services/api'
import dayjs from 'dayjs'

const { TextArea } = Input

interface Policy {
  id: string
  type: string
  title: string
  content: string
  version: string
  status: string
  effectiveDate?: string
  createdAt: string
}

export default function Policies() {
  const [page, setPage] = useState(1)
  const [pageSize, setPageSize] = useState(10)
  const [isModalOpen, setIsModalOpen] = useState(false)
  const [editingPolicy, setEditingPolicy] = useState<Policy | null>(null)
  const [form] = Form.useForm()
  const queryClient = useQueryClient()

  const { data, isLoading, error, refetch } = useQuery({
    queryKey: ['policies', page, pageSize],
    queryFn: () => policiesApi.getAll(page, pageSize),
  })

  const createMutation = useMutation({
    mutationFn: (values: any) => policiesApi.create(values),
    onSuccess: () => {
      message.success('정책이 생성되었습니다.')
      queryClient.invalidateQueries({ queryKey: ['policies'] })
      setIsModalOpen(false)
      form.resetFields()
    },
  })

  const updateMutation = useMutation({
    mutationFn: ({ id, data }: { id: string; data: any }) => policiesApi.update(id, data),
    onSuccess: () => {
      message.success('정책이 수정되었습니다.')
      queryClient.invalidateQueries({ queryKey: ['policies'] })
      setIsModalOpen(false)
      setEditingPolicy(null)
      form.resetFields()
    },
  })

  const activateMutation = useMutation({
    mutationFn: (id: string) => policiesApi.activate(id),
    onSuccess: () => {
      message.success('정책이 활성화되었습니다.')
      queryClient.invalidateQueries({ queryKey: ['policies'] })
    },
  })

  const deleteMutation = useMutation({
    mutationFn: (id: string) => policiesApi.delete(id),
    onSuccess: () => {
      message.success('정책이 삭제되었습니다.')
      queryClient.invalidateQueries({ queryKey: ['policies'] })
    },
  })

  const handleCreate = () => {
    setEditingPolicy(null)
    form.resetFields()
    form.setFieldsValue({
      type: '이용약관',
      version: '1.0.0',
      status: 'draft',
      createdBy: 'admin-id-placeholder'
    })
    setIsModalOpen(true)
  }

  const handleEdit = (record: Policy) => {
    setEditingPolicy(record)
    form.setFieldsValue({
      ...record,
      effectiveDate: record.effectiveDate ? dayjs(record.effectiveDate) : null,
    })
    setIsModalOpen(true)
  }

  const handleActivate = (id: string) => {
    Modal.confirm({
      title: '활성화 확인',
      content: '이 정책을 활성화하시겠습니까? 같은 유형의 다른 활성 정책은 자동으로 보관됩니다.',
      okText: '활성화',
      cancelText: '취소',
      onOk: () => activateMutation.mutate(id),
    })
  }

  const handleDelete = (id: string) => {
    Modal.confirm({
      title: '삭제 확인',
      content: '정말로 이 정책을 삭제하시겠습니까?',
      okText: '삭제',
      cancelText: '취소',
      onOk: () => deleteMutation.mutate(id),
    })
  }

  const handleSubmit = (values: any) => {
    const submitData = {
      ...values,
      effectiveDate: values.effectiveDate ? values.effectiveDate.toISOString() : null,
    }

    if (editingPolicy) {
      updateMutation.mutate({ id: editingPolicy.id, data: submitData })
    } else {
      createMutation.mutate(submitData)
    }
  }

  const columns: ColumnsType<Policy> = [
    {
      title: '유형',
      dataIndex: 'type',
      key: 'type',
      render: (type: string) => <Tag color="blue">{type}</Tag>,
    },
    {
      title: '제목',
      dataIndex: 'title',
      key: 'title',
    },
    {
      title: '버전',
      dataIndex: 'version',
      key: 'version',
    },
    {
      title: '상태',
      dataIndex: 'status',
      key: 'status',
      render: (status: string) => {
        const colorMap: Record<string, string> = {
          draft: 'default',
          active: 'success',
          archived: 'error',
        }
        const textMap: Record<string, string> = {
          draft: '초안',
          active: '활성',
          archived: '보관됨',
        }
        return <Tag color={colorMap[status]}>{textMap[status] || status}</Tag>
      },
    },
    {
      title: '시행일',
      dataIndex: 'effectiveDate',
      key: 'effectiveDate',
      render: (date?: string) => date ? new Date(date).toLocaleDateString('ko-KR') : '-',
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
            icon={<CheckCircleOutlined />}
            onClick={() => handleActivate(record.id)}
            disabled={record.status === 'active'}
          >
            활성화
          </Button>
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
    return <Alert message="오류" description="정책 데이터를 불러오는데 실패했습니다." type="error" />
  }

  const policies = data?.data?.data || []
  const pagination = data?.data?.pagination

  return (
    <>
      <Space direction="vertical" size="large" style={{ width: '100%' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <h1>정책 관리</h1>
          <Space>
            <Button icon={<ReloadOutlined />} onClick={() => refetch()}>
              새로고침
            </Button>
            <Button type="primary" icon={<PlusOutlined />} onClick={handleCreate}>
              정책 추가
            </Button>
          </Space>
        </div>

        <Table
          columns={columns}
          dataSource={policies}
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
        title={editingPolicy ? '정책 수정' : '정책 추가'}
        open={isModalOpen}
        onCancel={() => {
          setIsModalOpen(false)
          setEditingPolicy(null)
          form.resetFields()
        }}
        onOk={() => form.submit()}
        width={800}
      >
        <Form form={form} layout="vertical" onFinish={handleSubmit}>
          <Form.Item name="createdBy" hidden>
            <Input />
          </Form.Item>
          <Form.Item
            name="type"
            label="정책 유형"
            rules={[{ required: true, message: '정책 유형을 선택해주세요' }]}
          >
            <Select>
              <Select.Option value="이용약관">이용약관</Select.Option>
              <Select.Option value="개인정보처리방침">개인정보처리방침</Select.Option>
              <Select.Option value="환불정책">환불정책</Select.Option>
              <Select.Option value="배송정책">배송정책</Select.Option>
              <Select.Option value="판매자정책">판매자정책</Select.Option>
            </Select>
          </Form.Item>
          <Form.Item
            name="title"
            label="제목"
            rules={[{ required: true, message: '제목을 입력해주세요' }]}
          >
            <Input placeholder="정책 제목" />
          </Form.Item>
          <Form.Item
            name="content"
            label="내용"
            rules={[{ required: true, message: '내용을 입력해주세요' }]}
          >
            <TextArea rows={10} placeholder="정책 내용" />
          </Form.Item>
          <Form.Item
            name="version"
            label="버전"
            rules={[{ required: true, message: '버전을 입력해주세요' }]}
          >
            <Input placeholder="1.0.0" />
          </Form.Item>
          <Form.Item name="status" label="상태">
            <Select>
              <Select.Option value="draft">초안</Select.Option>
              <Select.Option value="active">활성</Select.Option>
              <Select.Option value="archived">보관</Select.Option>
            </Select>
          </Form.Item>
          <Form.Item name="effectiveDate" label="시행일">
            <DatePicker style={{ width: '100%' }} />
          </Form.Item>
        </Form>
      </Modal>
    </>
  )
}
