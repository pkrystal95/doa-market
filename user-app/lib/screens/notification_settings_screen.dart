import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _marketingPush = true;
  bool _orderPush = true;
  bool _shippingPush = true;
  bool _eventPush = true;
  bool _noticePush = true;
  bool _nightPush = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _marketingPush = prefs.getBool('marketing_push') ?? true;
      _orderPush = prefs.getBool('order_push') ?? true;
      _shippingPush = prefs.getBool('shipping_push') ?? true;
      _eventPush = prefs.getBool('event_push') ?? true;
      _noticePush = prefs.getBool('notice_push') ?? true;
      _nightPush = prefs.getBool('night_push') ?? false;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('알림 설정'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildSectionHeader('푸시 알림'),
          _buildSwitchTile(
            title: '마케팅 정보 수신',
            subtitle: '할인, 이벤트 등의 마케팅 정보를 받습니다',
            value: _marketingPush,
            onChanged: (value) {
              setState(() => _marketingPush = value);
              _saveSetting('marketing_push', value);
            },
          ),
          _buildSwitchTile(
            title: '주문 알림',
            subtitle: '주문 접수, 결제 완료 등의 알림을 받습니다',
            value: _orderPush,
            onChanged: (value) {
              setState(() => _orderPush = value);
              _saveSetting('order_push', value);
            },
          ),
          _buildSwitchTile(
            title: '배송 알림',
            subtitle: '배송 시작, 배송 완료 등의 알림을 받습니다',
            value: _shippingPush,
            onChanged: (value) {
              setState(() => _shippingPush = value);
              _saveSetting('shipping_push', value);
            },
          ),
          _buildSwitchTile(
            title: '이벤트 알림',
            subtitle: '특가, 쿠폰 등의 이벤트 알림을 받습니다',
            value: _eventPush,
            onChanged: (value) {
              setState(() => _eventPush = value);
              _saveSetting('event_push', value);
            },
          ),
          _buildSwitchTile(
            title: '공지사항 알림',
            subtitle: '중요 공지사항 알림을 받습니다',
            value: _noticePush,
            onChanged: (value) {
              setState(() => _noticePush = value);
              _saveSetting('notice_push', value);
            },
          ),
          const Divider(height: 32, thickness: 8, color: Color(0xFFF5F5F5)),
          _buildSectionHeader('수신 시간 설정'),
          _buildSwitchTile(
            title: '야간 알림 수신 (21:00 ~ 08:00)',
            subtitle: '야간 시간대에도 알림을 받습니다',
            value: _nightPush,
            onChanged: (value) {
              setState(() => _nightPush = value);
              _saveSetting('night_push', value);
            },
          ),
          const Divider(height: 32, thickness: 8, color: Color(0xFFF5F5F5)),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '알림 설정 안내',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '• 주문, 배송 알림은 서비스 제공을 위한 필수 알림입니다.\n'
                  '• 마케팅 정보 수신 동의는 언제든지 철회하실 수 있습니다.\n'
                  '• 일부 알림은 기기 설정에서 차단될 수 있습니다.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      color: Colors.white,
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
