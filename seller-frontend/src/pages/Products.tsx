import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { Table, Button, Space, Alert, Tag, Modal, Form, Input, InputNumber, Select, message } from 'antd'
import { ReloadOutlined, PlusOutlined, EditOutlined, DeleteOutlined } from '@ant-design/icons'
import type { ColumnsType } from 'antd/es/table'
import { productsApi } from '@/services/api'

const { TextArea } = Input

interface Product {
  id: string
  name: string
  description: string
  category: string
  price: number
  stock: number
  status: string
  createdAt: string
}

const SELLER_ID = 'seller-id-placeholder' // 실제로는 로그인한 판매자 ID

export default function Products() {
  const [page, setPage] = useState(1)
  const [pageSize, setPageSize] = useState(10)
  const [isModalOpen, setIsModalOpen] = useState(false)
  const [editingProduct, setEditingProduct] = useState<Product | null>(null)
  const [form] = Form.useForm()
  const queryClient = useQueryClient()

  const { data, isLoading, error, refetch } = useQuery({
    queryKey: ['products', page, pageSize],
    queryFn: () => productsApi.getAll(page, pageSize, SELLER_ID),
  })

  const createMutation = useMutation({
    mutationFn: (values: any) => productsApi.create({ ...values, sellerId: SELLER_ID }),
    onSuccess: () => {
      message.success('상품이 등록되었습니다.')
      queryClient.invalidateQueries({ queryKey: ['products'] })
      setIsModalOpen(false)
      form.resetFields()
    },
  })

  const updateMutation = useMutation({
    mutationFn: ({ id, data }: { id: string; data: any }) => productsApi.update(id, data),
    onSuccess: () => {
      message.success('상품이 수정되었습니다.')
      queryClient.invalidateQueries({ queryKey: ['products'] })
      setIsModalOpen(false)
      setEditingProduct(null)
      form.resetFields()
    },
  })

  const deleteMutation = useMutation({
    mutationFn: (id: string) => productsApi.delete(id),
    onSuccess: () => {
      message.success('상품이 삭제되었습니다.')
      queryClient.invalidateQueries({ queryKey: ['products'] })
    },
  })

  const handleCreate = () => {
    setEditingProduct(null)
    form.resetFields()
    form.setFieldsValue({ status: 'active', stock: 0 })
    setIsModalOpen(true)
  }

  const handleEdit = (record: Product) => {
    setEditingProduct(record)
    form.setFieldsValue(record)
    setIsModalOpen(true)
  }

  const handleDelete = (id: string) => {
    Modal.confirm({
      title: '삭제 확인',
      content: '정말로 이 상품을 삭제하시겠습니까?',
      okText: '삭제',
      cancelText: '취소',
      onOk: () => deleteMutation.mutate(id),
    })
  }

  const handleSubmit = (values: any) => {
    if (editingProduct) {
      updateMutation.mutate({ id: editingProduct.id, data: values })
    } else {
      createMutation.mutate(values)
    }
  }

  const columns: ColumnsType<Product> = [
    {
      title: '상품명',
      dataIndex: 'name',
      key: 'name',
    },
    {
      title: '카테고리',
      dataIndex: 'category',
      key: 'category',
      render: (category: string) => <Tag>{category}</Tag>,
    },
    {
      title: '가격',
      dataIndex: 'price',
      key: 'price',
      render: (price: number) => `₩${price.toLocaleString()}`,
    },
    {
      title: '재고',
      dataIndex: 'stock',
      key: 'stock',
      render: (stock: number) => (
        <Tag color={stock > 10 ? 'green' : stock > 0 ? 'orange' : 'red'}>{stock}</Tag>
      ),
    },
    {
      title: '상태',
      dataIndex: 'status',
      key: 'status',
      render: (status: string) => {
        const colorMap: Record<string, string> = {
          active: 'success',
          inactive: 'default',
          out_of_stock: 'error',
        }
        const textMap: Record<string, string> = {
          active: '판매중',
          inactive: '판매중지',
          out_of_stock: '품절',
        }
        return <Tag color={colorMap[status]}>{textMap[status] || status}</Tag>
      },
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
    return <Alert message="오류" description="상품 데이터를 불러오는데 실패했습니다." type="error" />
  }

  const products = data?.data?.data || []
  const pagination = data?.data?.pagination

  return (
    <>
      <Space direction="vertical" size="large" style={{ width: '100%' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <h1>상품 관리</h1>
          <Space>
            <Button icon={<ReloadOutlined />} onClick={() => refetch()}>
              새로고침
            </Button>
            <Button type="primary" icon={<PlusOutlined />} onClick={handleCreate}>
              상품 등록
            </Button>
          </Space>
        </div>

        <Table
          columns={columns}
          dataSource={products}
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
        title={editingProduct ? '상품 수정' : '상품 등록'}
        open={isModalOpen}
        onCancel={() => {
          setIsModalOpen(false)
          setEditingProduct(null)
          form.resetFields()
        }}
        onOk={() => form.submit()}
        width={700}
      >
        <Form form={form} layout="vertical" onFinish={handleSubmit}>
          <Form.Item
            name="name"
            label="상품명"
            rules={[{ required: true, message: '상품명을 입력해주세요' }]}
          >
            <Input placeholder="상품명" />
          </Form.Item>
          <Form.Item
            name="description"
            label="상품 설명"
            rules={[{ required: true, message: '상품 설명을 입력해주세요' }]}
          >
            <TextArea rows={4} placeholder="상품 설명" />
          </Form.Item>
          <Form.Item
            name="category"
            label="카테고리"
            rules={[{ required: true, message: '카테고리를 입력해주세요' }]}
          >
            <Input placeholder="카테고리" />
          </Form.Item>
          <Form.Item
            name="price"
            label="가격"
            rules={[{ required: true, message: '가격을 입력해주세요' }]}
          >
            <InputNumber
              style={{ width: '100%' }}
              placeholder="가격"
              formatter={value => `₩ ${value}`.replace(/\B(?=(\d{3})+(?!\d))/g, ',')}
            />
          </Form.Item>
          <Form.Item
            name="stock"
            label="재고"
            rules={[{ required: true, message: '재고를 입력해주세요' }]}
          >
            <InputNumber style={{ width: '100%' }} placeholder="재고" min={0} />
          </Form.Item>
          <Form.Item name="status" label="상태">
            <Select>
              <Select.Option value="active">판매중</Select.Option>
              <Select.Option value="inactive">판매중지</Select.Option>
              <Select.Option value="out_of_stock">품절</Select.Option>
            </Select>
          </Form.Item>
        </Form>
      </Modal>
    </>
  )
}
