import { Router } from 'express';
import Order from '../models/order.model';
import { eventBus } from '../index';
import { EventType } from '../events';
import { logger } from '../utils/logger';
import { OrderSaga } from '../saga/orderSaga';

const router = Router();

// Track active sagas
const activeSagas = new Map<string, OrderSaga>();

router.get('/', async (req, res) => {
  try {
    const orders = await Order.findAll();
    res.json({ success: true, data: orders });
  } catch (error: any) {
    logger.error('Error fetching orders:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

router.post('/', async (req, res) => {
  try {
    const { userId, items, totalAmount, shippingAddress } = req.body;

    // Create order
    const order = await Order.create({
      userId,
      sellerId: items[0]?.sellerId || 'default-seller',
      totalAmount,
      orderNumber: `ORD-${Date.now()}`,
      status: 'pending',
      paymentStatus: 'pending',
    });

    logger.info(`Order created: ${order.id}`);

    // Publish ORDER_CREATED event
    await eventBus.publish(EventType.ORDER_CREATED, {
      orderId: order.id,
      userId: order.userId,
      items: items || [],
      totalAmount: order.totalAmount,
      shippingAddress: shippingAddress || {
        name: 'Default',
        phone: '000-0000-0000',
        address: 'Default Address',
        city: 'Seoul',
        postalCode: '00000',
      },
    });

    logger.info(`ORDER_CREATED event published for order: ${order.id}`);

    // Start Saga orchestration
    const saga = new OrderSaga(order.id, eventBus);
    activeSagas.set(order.id, saga);

    // Run saga asynchronously (don't block response)
    saga.start().then(() => {
      logger.info(`Saga completed successfully for order: ${order.id}`);
      activeSagas.delete(order.id);
    }).catch((error) => {
      logger.error(`Saga failed for order: ${order.id}`, error);
      activeSagas.delete(order.id);
    });

    res.status(201).json({
      success: true,
      data: order,
      message: 'Order created. Processing payment and inventory reservation...',
    });
  } catch (error: any) {
    logger.error('Error creating order:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// Get saga status
router.get('/:id/saga-status', async (req, res) => {
  try {
    const { id } = req.params;
    const saga = activeSagas.get(id);

    if (!saga) {
      return res.json({
        success: true,
        data: { orderId: id, status: 'completed_or_not_found' },
      });
    }

    res.json({
      success: true,
      data: {
        orderId: id,
        status: saga.getState(),
      },
    });
  } catch (error: any) {
    logger.error('Error getting saga status:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

router.patch('/:id/status', async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    const order = await Order.findByPk(id);
    if (!order) {
      return res.status(404).json({ success: false, error: 'Order not found' });
    }

    order.status = status;
    await order.save();

    logger.info(`Order ${id} status updated to: ${status}`);

    // Publish event based on status change
    if (status === 'confirmed') {
      await eventBus.publish(EventType.ORDER_CONFIRMED, {
        orderId: order.id,
        userId: order.userId,
        paymentId: 'payment-id', // Should come from payment service
      });
    } else if (status === 'cancelled') {
      await eventBus.publish(EventType.ORDER_CANCELLED, {
        orderId: order.id,
        userId: order.userId,
        reason: req.body.reason || 'User cancelled',
      });
    }

    res.json({ success: true, data: order });
  } catch (error: any) {
    logger.error('Error updating order status:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

export default router;

