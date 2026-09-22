import 'package:flutter/material.dart';

/// A dummy, Razorpay-styled payment sheet. Purely visual — no real
/// payment SDK/API is involved. Method tabs (Card/UPI/Netbanking) just
/// swap which static fields are shown; nothing entered here is read.
///
/// Returns `true` once the user taps "Pay" and the fake processing delay
/// completes, or `null` if they dismiss the sheet without paying.
Future<bool?> showRazorpayStyleCheckout(
  BuildContext context, {
  required double amount,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    // The checkout screen's context is nested inside go_router's own
    // Navigator (via the ShellRoute). Without useRootNavigator: true, this
    // sheet is pushed onto that *nested* Navigator — and the subsequent
    // context.go('/orders') call swaps that Navigator's page stack out
    // from under the sheet, which stops it from dismissing itself even
    // after Navigator.pop() runs (the order still places correctly, but
    // the sheet is orphaned on screen showing "Processing..." forever).
    // Using the root navigator keeps the sheet's route completely
    // independent of go_router's page stack.
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (context) => _RazorpaySheet(amount: amount),
  );
}

enum _PayMethod { card, upi, netbanking }

class _RazorpaySheet extends StatefulWidget {
  final double amount;

  const _RazorpaySheet({required this.amount});

  @override
  State<_RazorpaySheet> createState() => _RazorpaySheetState();
}

class _RazorpaySheetState extends State<_RazorpaySheet> {
  _PayMethod _method = _PayMethod.card;
  bool _processing = false;

  static const _brandNavy = Color(0xFF0C2340);
  static const _brandBlue = Color(0xFF3395FF);

  Future<void> _pay() async {
    setState(() => _processing = true);
    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          width: 400,
          margin: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: _processing ? _buildProcessing() : _buildForm(context),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: _brandNavy,
      padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Razorpay',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'DEMO',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'MONOLITH',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${widget.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            icon: const Icon(Icons.close, color: Colors.white70, size: 20),
            splashRadius: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(),
        Row(
          children: [
            _MethodTab(
              label: 'Card',
              selected: _method == _PayMethod.card,
              onTap: () => setState(() => _method = _PayMethod.card),
            ),
            _MethodTab(
              label: 'UPI',
              selected: _method == _PayMethod.upi,
              onTap: () => setState(() => _method = _PayMethod.upi),
            ),
            _MethodTab(
              label: 'Netbanking',
              selected: _method == _PayMethod.netbanking,
              onTap: () => setState(() => _method = _PayMethod.netbanking),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: _buildMethodBody(),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _pay,
              style: ElevatedButton.styleFrom(
                backgroundColor: _brandBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                elevation: 0,
              ),
              child: Text(
                'Pay \$${widget.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            'Demo payment · no money moved',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
        ),
      ],
    );
  }

  Widget _buildMethodBody() {
    switch (_method) {
      case _PayMethod.card:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _DummyField(
              label: 'Card number',
              value: '4242 4242 4242 4242',
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                Expanded(
                  child: _DummyField(label: 'Expiry', value: '12/29'),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _DummyField(label: 'CVV', value: '123'),
                ),
              ],
            ),
          ],
        );
      case _PayMethod.upi:
        return const _DummyField(label: 'UPI ID', value: 'demo@okhdfcbank');
      case _PayMethod.netbanking:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _BankRow(name: 'Demo Bank'),
            _BankRow(name: 'Test National Bank'),
            _BankRow(name: 'Sandbox Trust Bank'),
          ],
        );
    }
  }

  Widget _buildProcessing() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 56),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: _RazorpaySheetState._brandBlue,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Processing...',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MethodTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _MethodTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected
                    ? _RazorpaySheetState._brandBlue
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected
                  ? _RazorpaySheetState._brandNavy
                  : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }
}

class _DummyField extends StatelessWidget {
  final String label;
  final String value;

  const _DummyField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(value, style: const TextStyle(fontSize: 14)),
        ),
      ],
    );
  }
}

class _BankRow extends StatelessWidget {
  final String name;

  const _BankRow({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(
            Icons.account_balance_outlined,
            size: 18,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 10),
          Text(name, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
