import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { Table, Button, Space, Alert, Tag, Modal, Form, Input, Select, message, Descriptions } from 'antd'
import { ReloadOutlined, PlusOutlined, EyeOutlined, DeleteOutlined } from '@ant-design/icons'
import type { ColumnsType } from 'antd/es/table'
import { inquiriesApi } from '@/services/api'

const { TextArea } = Input

interface Inquiry {
  id: string
  userId: string
  category: string
  title: string
  content: string
  status: string
  priority: string
  answer?: string
  answeredAt?: string
  createdAt: string
}

const SELLER_ID = 'seller-id-placeholder' // 실제로는 로그인한 판매자 ID

export default function Inquiries() {
  const [page, setPage] = useState(1)
  const [pageSize, setPageSize] = useState(10)
  const [isCreateModalOpen, setIsCreateModalOpen] = useState(false)
  const [isDetailModalOpen, setIsDetailModalOpen] = useState(false)
  const [selectedInquiry, setSelectedInquiry] = useState<Inquiry | null>(null)
  const [form] = Form.useForm()
  const queryClient = useQueryClient()

  const { data, isLoading, error, refetch } = useQuery({
    queryKey: ['inquiries', page, pageSize],
    queryFn: () => inquiriesApi.getAll(page, pageSize, SELLER_ID),
  })

  const createMutation = useMutation({
    mutationFn: (values: any) => inquiriesApi.create({ ...values, userId: SELLER_ID }),
    onSuccess: () => {
      message.success('문의사항이 등록되었습니다.')
      queryClient.invalidateQueries({ queryKey: ['inquiries'] })
      setIsCreateModalOpen(false)
      form.resetFields()
    },
  })

  const deleteMutation = useMutation({
    mutationFn: (id: string) => inquiriesApi.delete(id),
    onSuccess: () => {
      message.success('문의사항이 삭제되었습니다.')
      queryClient.invalidateQueries({ queryKey: ['inquiries'] })
    },
  })

  const handleCreate = () => {
    form.resetFields()
    form.setFieldsValue({
      category: '일반문의',
      priority: 'medium',
    })
    setIsCreateModalOpen(true)
  }

  const handleViewDetail = (record: Inquiry) => {
    setSelectedInquiry(record)
    setIsDetailModalOpen(true)
  }

  const handleDelete = (id: string) => {
    Modal.confirm({
      title: '삭제 확인',
      content: '정말로 이 문의사항을 삭제하시겠습니까?',
      okText: '삭제',
      cancelText: '취소',
      onOk: () => deleteMutation.mutate(id),
    })
  }

  const handleSubmit = (values: any) => {
    createMutation.mutate(values)
  }

  const columns: ColumnsType<Inquiry> = [
    {
      title: '카테고리',
      dataIndex: 'category',
      key: 'category',
      render: (category: string) => <Tag>{category}</Tag>,
    },
    {
      title: '제목',
      dataIndex: 'title',
      key: 'title',
      render: (title: string, record) => (
        <Button type="link" onClick={() => handleViewDetail(record)}>
          {title}
        </Button>
      ),
    },
    {
      title: '우선순위',
      dataIndex: 'priority',
      key: 'priority',
      render: (priority: string) => {
        const colorMap: Record<string, string> = {
          low: 'default',
          medium: 'blue',
          high: 'orange',
          urgent: 'red',
        }
        const textMap: Record<string, string> = {
          low: '낮음',
          medium: '보통',
          high: '높음',
          urgent: '긴급',
        }
        return <Tag color={colorMap[priority]}>{textMap[priority] || priority}</Tag>
      },
    },
    {
      title: '상태',
      dataIndex: 'status',
      key: 'status',
      render: (status: string) => {
        const colorMap: Record<string, string> = {
          pending: 'warning',
          in_progress: 'processing',
          answered: 'success',
          closed: 'default',
        }
        const textMap: Record<string, string> = {
          pending: '대기',
          in_progress: '처리중',
          answered: '답변완료',
          closed: '종료',
        }
        return <Tag color={colorMap[status]}>{textMap[status] || status}</Tag>
      },
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
            icon={<EyeOutlined />}
            onClick={() => handleViewDetail(record)}
          >
            상세
          </Button>
          <Button
            type="link"
            danger
            icon={<DeleteOutlined />}
            onClick={() => handleDelete(record.id)}
            disabled={record.status !== 'pending'}
          >
            삭제
          </Button>
        </Space>
      ),
    },
  ]

  if (error) {
    return <Alert message="오류" description="문의사항 데이터를 불러오는데 실패했습니다." type="error" />
  }

  const inquiries = data?.data?.data || []
  const pagination = data?.data?.pagination

  return (
    <>
      <Space direction="vertical" size="large" style={{ width: '100%' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <h1>문의사항</h1>
          <Space>
            <Button icon={<ReloadOutlined />} onClick={() => refetch()}>
              새로고침
            </Button>
            <Button type="primary" icon={<PlusOutlined />} onClick={handleCreate}>
              문의하기
            </Button>
          </Space>
        </div>

        <Alert
          message="문의 안내"
          description="관리자에게 문의사항을 남기실 수 있습니다. 답변은 영업일 기준 1-2일 내에 등록됩니다."
          type="info"
          showIcon
        />

        <Table
          columns={columns}
          dataSource={inquiries}
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

      {/* 문의 작성 모달 */}
      <Modal
        title="문의하기"
        open={isCreateModalOpen}
        onCancel={() => {
          setIsCreateModalOpen(false)
          form.resetFields()
        }}
        onOk={() => form.submit()}
        width={700}
      >
        <Form form={form} layout="vertical" onFinish={handleSubmit}>
          <Form.Item
            name="category"
            label="문의 유형"
            rules={[{ required: true, message: '문의 유형을 선택해주세요' }]}
          >
            <Select>
              <Select.Option value="일반문의">일반문의</Select.Option>
              <Select.Option value="상품문의">상품문의</Select.Option>
              <Select.Option value="주문/배송">주문/배송</Select.Option>
              <Select.Option value="결제">결제</Select.Option>
              <Select.Option value="환불/취소">환불/취소</Select.Option>
              <Select.Option value="정산">정산</Select.Option>
              <Select.Option value="기타">기타</Select.Option>
            </Select>
          </Form.Item>
          <Form.Item
            name="title"
            label="제목"
            rules={[{ required: true, message: '제목을 입력해주세요' }]}
          >
            <Input placeholder="문의 제목" />
          </Form.Item>
          <Form.Item
            name="content"
            label="내용"
            rules={[{ required: true, message: '내용을 입력해주세요' }]}
          >
            <TextArea rows={6} placeholder="문의 내용을 상세히 입력해주세요" />
          </Form.Item>
          <Form.Item name="priority" label="우선순위">
            <Select>
              <Select.Option value="low">낮음</Select.Option>
              <Select.Option value="medium">보통</Select.Option>
              <Select.Option value="high">높음</Select.Option>
              <Select.Option value="urgent">긴급</Select.Option>
            </Select>
          </Form.Item>
        </Form>
      </Modal>

      {/* 문의 상세 모달 */}
      <Modal
        title="문의 상세"
        open={isDetailModalOpen}
        onCancel={() => {
          setIsDetailModalOpen(false)
          setSelectedInquiry(null)
        }}
        footer={[
          <Button key="close" onClick={() => setIsDetailModalOpen(false)}>
            닫기
          </Button>,
        ]}
        width={700}
      >
        {selectedInquiry && (
          <Descriptions column={1} bordered>
            <Descriptions.Item label="카테고리">{selectedInquiry.category}</Descriptions.Item>
            <Descriptions.Item label="제목">{selectedInquiry.title}</Descriptions.Item>
            <Descriptions.Item label="내용">
              <div style={{ whiteSpace: 'pre-wrap' }}>{selectedInquiry.content}</div>
            </Descriptions.Item>
            <Descriptions.Item label="우선순위">
              <Tag color={
                selectedInquiry.priority === 'urgent' ? 'red' :
                selectedInquiry.priority === 'high' ? 'orange' :
                selectedInquiry.priority === 'medium' ? 'blue' : 'default'
              }>
                {selectedInquiry.priority === 'urgent' ? '긴급' :
                 selectedInquiry.priority === 'high' ? '높음' :
                 selectedInquiry.priority === 'medium' ? '보통' : '낮음'}
              </Tag>
            </Descriptions.Item>
            <Descriptions.Item label="상태">
              <Tag color={
                selectedInquiry.status === 'answered' ? 'success' :
                selectedInquiry.status === 'in_progress' ? 'processing' :
                selectedInquiry.status === 'closed' ? 'default' : 'warning'
              }>
                {selectedInquiry.status === 'answered' ? '답변완료' :
                 selectedInquiry.status === 'in_progress' ? '처리중' :
                 selectedInquiry.status === 'closed' ? '종료' : '대기'}
              </Tag>
            </Descriptions.Item>
            {selectedInquiry.answer && (
              <>
                <Descriptions.Item label="관리자 답변">
                  <div style={{
                    whiteSpace: 'pre-wrap',
                    background: '#f5f5f5',
                    padding: '12px',
                    borderRadius: '4px',
                    marginTop: '8px'
                  }}>
                    {selectedInquiry.answer}
                  </div>
                </Descriptions.Item>
                {selectedInquiry.answeredAt && (
                  <Descriptions.Item label="답변일시">
                    {new Date(selectedInquiry.answeredAt).toLocaleString('ko-KR')}
                  </Descriptions.Item>
                )}
              </>
            )}
            <Descriptions.Item label="작성일시">
              {new Date(selectedInquiry.createdAt).toLocaleString('ko-KR')}
            </Descriptions.Item>
          </Descriptions>
        )}
      </Modal>
    </>
  )
}
