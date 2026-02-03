import 'package:flutter/material.dart';
import 'package:currency_picker/currency_picker.dart'; 
import 'currency_service.dart'; 

class CurrencyConverterPage extends StatefulWidget {
  const CurrencyConverterPage({super.key});

  @override
  State<CurrencyConverterPage> createState() => _CurrencyConverterPageState();
}

class _CurrencyConverterPageState extends State<CurrencyConverterPage> {
  final ExchangeRateApi _rateApi = ExchangeRateApi(); 
  
  final TextEditingController _amount1Controller = TextEditingController();
  final TextEditingController _amount2Controller = TextEditingController();

  Currency _currency1 = CurrencyService().findByCode('INR')!; 
  Currency _currency2 = CurrencyService().findByCode('USD')!;

  Map<String, dynamic> _rates = {}; 
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchRates();
  }

  Future<void> _fetchRates() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final rates = await _rateApi.getRates();
      setState(() {
        _rates = rates;
        _isLoading = false;
      });
      
      if (_amount1Controller.text.isNotEmpty) {
        _convert(true);
      }
      
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Check Internet or API Key";
      });
    }
  }

  void _convert(bool topFieldChanged) {
    if (_rates.isEmpty) return;
    if (!_rates.containsKey(_currency1.code) || !_rates.containsKey(_currency2.code)) return;

    double rate1 = double.parse(_rates[_currency1.code].toString());
    double rate2 = double.parse(_rates[_currency2.code].toString());

    if (topFieldChanged) {
      double amount1 = double.tryParse(_amount1Controller.text) ?? 0;
      double result = (amount1 / rate1) * rate2;
      _amount2Controller.text = result.toStringAsFixed(2);
    } else {
      double amount2 = double.tryParse(_amount2Controller.text) ?? 0;
      double result = (amount2 / rate2) * rate1;
      _amount1Controller.text = result.toStringAsFixed(2);
    }
  }

  void _swapCurrencies() {
    setState(() {
      final temp = _currency1;
      _currency1 = _currency2;
      _currency2 = temp;
      _convert(true); 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Currency Pro", 
                            style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              onPressed: _fetchRates,
                              icon: const Icon(Icons.refresh, color: Colors.cyanAccent),
                              tooltip: "Refresh Rates",
                            ),
                          ),
                        ],
                      ),
                      if (_errorMessage.isNotEmpty) 
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Text(_errorMessage, style: const TextStyle(color: Colors.redAccent)),
                        ),
                      const SizedBox(height: 40),
                      _buildInputCard("From", _amount1Controller, _currency1, true, (newCurrency) {
                        setState(() { _currency1 = newCurrency; _convert(false); });
                      }),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: _swapCurrencies,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.cyanAccent,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.cyanAccent.withOpacity(0.3), blurRadius: 10, spreadRadius: 2)
                            ]
                          ),
                          child: const Icon(Icons.swap_vert, color: Colors.black, size: 32),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildInputCard("To", _amount2Controller, _currency2, false, (newCurrency) {
                        setState(() { _currency2 = newCurrency; _convert(true); });
                      }),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildInputCard(String title, TextEditingController controller, Currency currency, bool isTop, Function(Currency) onSelect) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.white54, fontSize: 14)),
              GestureDetector(
                onTap: () {
                  showCurrencyPicker(
                    context: context,
                    showFlag: true,
                    showCurrencyName: true,
                    showCurrencyCode: true,
                    theme: CurrencyPickerThemeData(
                      backgroundColor: const Color(0xFF1E1E2C),
                      titleTextStyle: const TextStyle(color: Colors.white),
                      subtitleTextStyle: const TextStyle(color: Colors.white60),
                      flagSize: 25,
                    ),
                    onSelect: onSelect,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Text(currency.flag ?? "", style: const TextStyle(fontSize: 24)), 
                      const SizedBox(width: 8),
                      Text(currency.code, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      const Icon(Icons.arrow_drop_down, color: Colors.white54)
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Text(currency.symbol, style: const TextStyle(color: Colors.cyanAccent, fontSize: 28)),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "0.00",
                    hintStyle: TextStyle(color: Colors.white12),
                  ),
                  onChanged: (val) => _convert(isTop), 
                ),
              ),
            ],
          ),
          Text(currency.name, style: const TextStyle(color: Colors.white30, fontSize: 12)),
        ],
      ),
    );
  }
}