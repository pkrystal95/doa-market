import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { Table, Button, Space, Alert, Tag, Modal, Form, Input, Select, message, Descriptions } from 'antd'
import { ReloadOutlined, MessageOutlined, DeleteOutlined } from '@ant-design/icons'
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

export default function Inquiries() {
  const [page, setPage] = useState(1)
  const [pageSize, setPageSize] = useState(10)
  const [isAnswerModalOpen, setIsAnswerModalOpen] = useState(false)
  const [isDetailModalOpen, setIsDetailModalOpen] = useState(false)
  const [selectedInquiry, setSelectedInquiry] = useState<Inquiry | null>(null)
  const [form] = Form.useForm()
  const queryClient = useQueryClient()

  const { data, isLoading, error, refetch } = useQuery({
    queryKey: ['inquiries', page, pageSize],
    queryFn: () => inquiriesApi.getAll(page, pageSize),
  })

  const answerMutation = useMutation({
    mutationFn: ({ id, answer, answeredBy }: { id: string; answer: string; answeredBy: string }) =>
      inquiriesApi.answer(id, answer, answeredBy),
    onSuccess: () => {
      message.success('답변이 등록되었습니다.')
      queryClient.invalidateQueries({ queryKey: ['inquiries'] })
      setIsAnswerModalOpen(false)
      setSelectedInquiry(null)
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

  const handleAnswer = (record: Inquiry) => {
    setSelectedInquiry(record)
    form.setFieldsValue({ answer: record.answer || '' })
    setIsAnswerModalOpen(true)
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

  const handleSubmitAnswer = (values: any) => {
    if (selectedInquiry) {
      answerMutation.mutate({
        id: selectedInquiry.id,
        answer: values.answer,
        answeredBy: 'admin-id-placeholder',
      })
    }
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
            icon={<MessageOutlined />}
            onClick={() => handleAnswer(record)}
            disabled={record.status === 'closed'}
          >
            답변
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
    return <Alert message="오류" description="문의사항 데이터를 불러오는데 실패했습니다." type="error" />
  }

  const inquiries = data?.data?.data || []
  const pagination = data?.data?.pagination

  return (
    <>
      <Space direction="vertical" size="large" style={{ width: '100%' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <h1>문의사항 관리</h1>
          <Button icon={<ReloadOutlined />} onClick={() => refetch()}>
            새로고침
          </Button>
        </div>

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
            <Descriptions.Item label="내용">{selectedInquiry.content}</Descriptions.Item>
            <Descriptions.Item label="우선순위">{selectedInquiry.priority}</Descriptions.Item>
            <Descriptions.Item label="상태">{selectedInquiry.status}</Descriptions.Item>
            {selectedInquiry.answer && (
              <Descriptions.Item label="답변">{selectedInquiry.answer}</Descriptions.Item>
            )}
            {selectedInquiry.answeredAt && (
              <Descriptions.Item label="답변일시">
                {new Date(selectedInquiry.answeredAt).toLocaleString('ko-KR')}
              </Descriptions.Item>
            )}
            <Descriptions.Item label="작성일시">
              {new Date(selectedInquiry.createdAt).toLocaleString('ko-KR')}
            </Descriptions.Item>
          </Descriptions>
        )}
      </Modal>

      <Modal
        title="답변 작성"
        open={isAnswerModalOpen}
        onCancel={() => {
          setIsAnswerModalOpen(false)
          setSelectedInquiry(null)
          form.resetFields()
        }}
        onOk={() => form.submit()}
        width={700}
      >
        <Form form={form} layout="vertical" onFinish={handleSubmitAnswer}>
          {selectedInquiry && (
            <div style={{ marginBottom: 16, padding: 12, background: '#f5f5f5', borderRadius: 4 }}>
              <p><strong>제목:</strong> {selectedInquiry.title}</p>
              <p><strong>내용:</strong> {selectedInquiry.content}</p>
            </div>
          )}
          <Form.Item
            name="answer"
            label="답변 내용"
            rules={[{ required: true, message: '답변을 입력해주세요' }]}
          >
            <TextArea rows={6} placeholder="답변 내용을 입력하세요" />
          </Form.Item>
        </Form>
      </Modal>
    </>
  )
}
