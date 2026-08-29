import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cleanpixel_ai/services/purchase_service.dart';

class PaymentCheckoutSheet extends StatefulWidget {
  final String planTitle;
  final String planPrice;
  final String planType;

  const PaymentCheckoutSheet({
    Key? key,
    required this.planTitle,
    required this.planPrice,
    required this.planType,
  }) : super(key: key);

  static Future<bool?> show(
    BuildContext context, {
    required String planTitle,
    required String planPrice,
    required String planType,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => PaymentCheckoutSheet(
        planTitle: planTitle,
        planPrice: planPrice,
        planType: planType,
      ),
    );
  }

  @override
  State<PaymentCheckoutSheet> createState() => _PaymentCheckoutSheetState();
}

class _PaymentCheckoutSheetState extends State<PaymentCheckoutSheet> {
  PaymentMethodType _selectedMethod = PaymentMethodType.googlePlay;
  final TextEditingController _promoController = TextEditingController();
  bool _isProcessing = false;
  String? _processingStatus;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  Future<void> _handlePayment() async {
    HapticFeedback.heavyImpact();
    setState(() {
      _isProcessing = true;
      _processingStatus = "Connecting to Secure Gateway...";
    });

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    if (_selectedMethod == PaymentMethodType.promoCode) {
      if (_promoController.text.trim().isEmpty) {
        setState(() {
          _isProcessing = false;
          _processingStatus = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid Promo / Coupon Code (e.g. CLEANPIXELPRO)')),
        );
        return;
      }

      setState(() => _processingStatus = "Verifying Promotional Voucher...");
      final valid = await PurchaseService.redeemPromoCode(_promoController.text.trim());

      setState(() => _isProcessing = false);

      if (valid && mounted) {
        _showSuccessDialog();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid code! Try: CLEANPIXELPRO or FOUNDER100')),
        );
      }
      return;
    }

    setState(() => _processingStatus = "Processing ${widget.planPrice} Payment via ${_getMethodName(_selectedMethod)}...");
    final success = await PurchaseService.processPayment(
      planType: widget.planType,
      price: widget.planPrice,
      method: _selectedMethod,
    );

    setState(() => _isProcessing = false);

    if (success && mounted) {
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    Navigator.pop(context, true);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF131C2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 18),
            const Text(
              '🎉 Pro Access Unlocked!',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'Unlimited 4K Inpainting, Video Tracking & Lossless Exports are now active forever on your account.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Start Creating in 4K', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMethodName(PaymentMethodType method) {
    switch (method) {
      case PaymentMethodType.googlePlay:
        return 'Google Play';
      case PaymentMethodType.upi:
        return 'UPI / GPay / PhonePe';
      case PaymentMethodType.card:
        return 'Credit / Debit Card';
      case PaymentMethodType.netBanking:
        return 'Net Banking';
      case PaymentMethodType.promoCode:
        return 'Promo Code';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131C2E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black54 : const Color(0xFF2563EB).withValues(alpha: 0.12),
            blurRadius: 32,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Plan Overview Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ORDER SUMMARY', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                    const SizedBox(height: 2),
                    Text(widget.planTitle, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                    const Text('Unlimited 4K Neural Inpainting', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                ),
                Text(
                  widget.planPrice,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'SELECT PAYMENT METHOD',
            style: TextStyle(
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),

          // 1. Google Play Billing
          _buildMethodTile(
            icon: Icons.shop_two_rounded,
            title: 'Google Play Billing',
            subtitle: '1-Tap Fast Checkout & Subscription',
            badge: 'INSTANT',
            type: PaymentMethodType.googlePlay,
            isDark: isDark,
          ),
          const SizedBox(height: 8),

          // 2. UPI
          _buildMethodTile(
            icon: Icons.account_balance_wallet_rounded,
            title: 'UPI / GPay / PhonePe / Paytm',
            subtitle: 'Direct UPI transfer with instant auto-approval',
            badge: 'ZERO FEE',
            type: PaymentMethodType.upi,
            isDark: isDark,
          ),
          const SizedBox(height: 8),

          // 3. Cards
          _buildMethodTile(
            icon: Icons.credit_card_rounded,
            title: 'Credit / Debit Cards',
            subtitle: 'Visa, MasterCard, RuPay, Amex',
            type: PaymentMethodType.card,
            isDark: isDark,
          ),
          const SizedBox(height: 8),

          // 4. Promo Code
          _buildMethodTile(
            icon: Icons.redeem_rounded,
            title: 'Redeem Promo / Voucher Code',
            subtitle: 'Enter coupon (e.g. CLEANPIXELPRO or FOUNDER100)',
            badge: 'FREE PRO',
            type: PaymentMethodType.promoCode,
            isDark: isDark,
          ),

          if (_selectedMethod == PaymentMethodType.promoCode) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _promoController,
              textCapitalization: TextCapitalization.characters,
              style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? const Color(0xFF110817) : const Color(0xFFF0F9FF),
                hintText: 'Enter code: CLEANPIXELPRO',
                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                prefixIcon: const Icon(Icons.discount_rounded, color: Color(0xFF2563EB)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0F2FE))),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Submit Pay Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF38BDF8)]),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF2563EB).withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 4)),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _isProcessing ? null : _handlePayment,
                child: _isProcessing
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                          const SizedBox(width: 10),
                          Text(_processingStatus ?? "Processing...", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        ],
                      )
                    : Text(
                        _selectedMethod == PaymentMethodType.promoCode ? 'Apply & Unlock PRO Free' : 'Pay ${widget.planPrice} & Activate PRO',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required PaymentMethodType type,
    String? badge,
    required bool isDark,
  }) {
    final isSelected = _selectedMethod == type;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedMethod = type);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2563EB).withValues(alpha: isDark ? 0.2 : 0.08)
              : (isDark ? const Color(0xFF110817) : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : (isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE2E8F0)),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF2563EB) : (isDark ? Colors.white38 : const Color(0xFFCBD5E1)),
                  width: 2,
                ),
                color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
              ),
              child: isSelected ? const Icon(Icons.check, size: 10, color: Colors.white) : null,
            ),
            const SizedBox(width: 12),
            Icon(icon, color: isSelected ? const Color(0xFF2563EB) : (isDark ? Colors.white60 : const Color(0xFF64748B)), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF38BDF8)]),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
