import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../models/property_model.dart';
import '../../../models/reservation_model.dart';
import '../../../models/user_model.dart';
import '../../../services/payment_service.dart';
import '../../../services/property_service.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key, required this.reservation, required this.user});
  final ReservationModel reservation;
  final UserModel user;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _paymentService = PaymentService();
  final _propertyService = PropertyService();

  bool _preparing = true;
  bool _launchingCheckout = false;
  String? _error;
  int _amountCentavos = 0;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    try {
      final PropertyModel? property = await _propertyService.getProperty(widget.reservation.propertyId);
      final price = property?.pricePerMonth ?? 0;
      _amountCentavos = (price * 100).round();

      await _paymentService.ensurePaymentDoc(
        reservationId: widget.reservation.id,
        tenantId: widget.user.uid,
        amountCentavos: _amountCentavos,
      );
    } catch (e) {
      _error = 'Could not prepare this payment. Please try again.';
    } finally {
      if (mounted) setState(() => _preparing = false);
    }
  }

  Future<void> _payNow() async {
    setState(() {
      _launchingCheckout = true;
      _error = null;
    });
    try {
      final checkoutUrl = await _paymentService.requestCheckoutUrl(widget.reservation.id);
      final uri = Uri.parse(checkoutUrl);

      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && mounted) {
        setState(() => _error = 'Could not open the checkout page.');
      }
    } on PaymentException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _launchingCheckout = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: _preparing
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<Map<String, dynamic>?>(
              stream: _paymentService.watchPayment(widget.reservation.id),
              builder: (context, snapshot) {
                final data = snapshot.data;
                final isPaid = data?['isPaid'] == true;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.l),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.reservation.propertyName.isNotEmpty
                                  ? widget.reservation.propertyName
                                  : 'Property',
                              style: AppTypography.headingM,
                            ),
                            const SizedBox(height: AppSpacing.s),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '₱${(_amountCentavos / 100).toStringAsFixed(2)}',
                                  style: AppTypography.displayL.copyWith(color: AppColors.navy800),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text('Reservation fee', style: AppTypography.bodyS),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      if (isPaid) ...[
                        _ReceiptCard(data: data!),
                      ] else ...[
                        Text(
                          'Payment is processed securely through PayMongo. '
                          "You'll be taken to their checkout page to pay.",
                          style: AppTypography.bodyM.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        if (_error != null) ...[
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.m),
                            decoration: BoxDecoration(
                              color: AppColors.dangerBg,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Text(_error!, style: AppTypography.bodyS.copyWith(color: AppColors.danger)),
                          ),
                          const SizedBox(height: AppSpacing.l),
                        ],
                        AppButton(
                          label: 'Pay with card',
                          icon: Icons.credit_card_rounded,
                          fullWidth: true,
                          loading: _launchingCheckout,
                          onPressed: _launchingCheckout ? null : _payNow,
                        ),
                        const SizedBox(height: AppSpacing.m),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(strokeWidth: 1.5),
                            ),
                            const SizedBox(width: AppSpacing.s),
                            Text(
                              'Waiting for payment confirmation…',
                              style: AppTypography.bodyS.copyWith(color: AppColors.textTertiary),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _ReceiptCard extends StatelessWidget {
  const _ReceiptCard({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.successBg,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.success),
              const SizedBox(width: AppSpacing.s),
              Text('Payment received', style: AppTypography.headingS.copyWith(color: AppColors.success)),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          if (data['referenceNumber'] != null) _receiptRow('Reference No.', '${data['referenceNumber']}'),
          _receiptRow('Status', 'PAID'),
        ],
      ),
    );
  }

  Widget _receiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodyS),
          Text(value, style: AppTypography.mono),
        ],
      ),
    );
  }
}
