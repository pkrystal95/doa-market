import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { Table, Button, Space, Alert, Rate, Modal, Form, Input, message } from 'antd'
import { ReloadOutlined, MessageOutlined } from '@ant-design/icons'
import type { ColumnsType } from 'antd/es/table'
import { reviewsApi } from '@/services/api'

const { TextArea } = Input

interface Review {
  id: string
  productName: string
  userName: string
  rating: number
  content: string
  reply?: string
  createdAt: string
}

const SELLER_ID = 'seller-id-placeholder'

export default function Reviews() {
  const [page, setPage] = useState(1)
  const [pageSize, setPageSize] = useState(10)
  const [isReplyModalOpen, setIsReplyModalOpen] = useState(false)
  const [selectedReview, setSelectedReview] = useState<Review | null>(null)
  const [form] = Form.useForm()
  const queryClient = useQueryClient()

  const { data, isLoading, error, refetch } = useQuery({
    queryKey: ['reviews', page, pageSize],
    queryFn: () => reviewsApi.getAll(page, pageSize, SELLER_ID),
  })

  const replyMutation = useMutation({
    mutationFn: ({ id, reply }: { id: string; reply: string }) =>
      reviewsApi.reply(id, reply),
    onSuccess: () => {
      message.success('답변이 등록되었습니다.')
      queryClient.invalidateQueries({ queryKey: ['reviews'] })
      setIsReplyModalOpen(false)
      setSelectedReview(null)
      form.resetFields()
    },
  })

  const handleReply = (record: Review) => {
    setSelectedReview(record)
    form.setFieldsValue({ reply: record.reply || '' })
    setIsReplyModalOpen(true)
  }

  const handleSubmitReply = (values: any) => {
    if (selectedReview) {
      replyMutation.mutate({ id: selectedReview.id, reply: values.reply })
    }
  }

  const columns: ColumnsType<Review> = [
    {
      title: '상품명',
      dataIndex: 'productName',
      key: 'productName',
    },
    {
      title: '작성자',
      dataIndex: 'userName',
      key: 'userName',
    },
    {
      title: '평점',
      dataIndex: 'rating',
      key: 'rating',
      render: (rating: number) => <Rate disabled value={rating} />,
    },
    {
      title: '리뷰 내용',
      dataIndex: 'content',
      key: 'content',
      ellipsis: true,
    },
    {
      title: '답변 여부',
      dataIndex: 'reply',
      key: 'reply',
      render: (reply: string) => reply ? '답변완료' : '미답변',
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
        <Button
          type="link"
          icon={<MessageOutlined />}
          onClick={() => handleReply(record)}
        >
          {record.reply ? '답변 수정' : '답변 작성'}
        </Button>
      ),
    },
  ]

  if (error) {
    return <Alert message="오류" description="리뷰 데이터를 불러오는데 실패했습니다." type="error" />
  }

  const reviews = data?.data?.data || []
  const pagination = data?.data?.pagination

  return (
    <>
      <Space direction="vertical" size="large" style={{ width: '100%' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <h1>리뷰 관리</h1>
          <Button icon={<ReloadOutlined />} onClick={() => refetch()}>
            새로고침
          </Button>
        </div>

        <Table
          columns={columns}
          dataSource={reviews}
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
        title="답변 작성"
        open={isReplyModalOpen}
        onCancel={() => {
          setIsReplyModalOpen(false)
          setSelectedReview(null)
          form.resetFields()
        }}
        onOk={() => form.submit()}
        width={700}
      >
        <Form form={form} layout="vertical" onFinish={handleSubmitReply}>
          {selectedReview && (
            <div style={{ marginBottom: 16, padding: 12, background: '#f5f5f5', borderRadius: 4 }}>
              <p><strong>상품:</strong> {selectedReview.productName}</p>
              <p><strong>평점:</strong> <Rate disabled value={selectedReview.rating} /></p>
              <p><strong>리뷰:</strong> {selectedReview.content}</p>
            </div>
          )}
          <Form.Item
            name="reply"
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
