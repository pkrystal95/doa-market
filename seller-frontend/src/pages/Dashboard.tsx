import { Row, Col, Card, Statistic } from 'antd'
import {
  ShoppingOutlined,
  ShoppingCartOutlined,
  DollarOutlined,
  RiseOutlined,
} from '@ant-design/icons'

export default function Dashboard() {
  return (
    <>
      <h1 style={{ marginBottom: 24 }}>대시보드</h1>
      <Row gutter={[16, 16]}>
        <Col xs={24} sm={12} md={6}>
          <Card>
            <Statistic
              title="등록 상품"
              value={0}
              prefix={<ShoppingOutlined />}
              valueStyle={{ color: '#1890ff' }}
            />
          </Card>
        </Col>
        <Col xs={24} sm={12} md={6}>
          <Card>
            <Statistic
              title="신규 주문"
              value={0}
              prefix={<ShoppingCartOutlined />}
              valueStyle={{ color: '#52c41a' }}
            />
          </Card>
        </Col>
        <Col xs={24} sm={12} md={6}>
          <Card>
            <Statistic
              title="이번달 매출"
              value={0}
              prefix="₩"
              valueStyle={{ color: '#fa8c16' }}
            />
          </Card>
        </Col>
        <Col xs={24} sm={12} md={6}>
          <Card>
            <Statistic
              title="정산 예정 금액"
              value={0}
              prefix="₩"
              suffix={<RiseOutlined />}
              valueStyle={{ color: '#f5222d' }}
            />
          </Card>
        </Col>
      </Row>
    </>
  )
}
