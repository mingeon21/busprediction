import 'package:currencyexchangerate/exchange_rate_service.dart';
import 'package:flutter/material.dart';

class CurrencyCalculator extends StatefulWidget {
  @override
  _CurrencyCalculatorState createState() => _CurrencyCalculatorState();
}

class _CurrencyCalculatorState extends State<CurrencyCalculator> {
  final TextEditingController _amountController = TextEditingController();
  String _fromCurrency = 'USD';
  String _toCurrency = 'EUR';
  double _exchangeRate = 0.0;
  double _convertedAmount = 0.0;

  @override
  void initState() {
    super.initState();
    print('CurrencyCalculator');
    _amountController.text = '100';
    _fetchExchangeRate();
  }

  Future<void> _fetchExchangeRate() async {
    print('from:$_fromCurrency');
    try {
      final currencyMap = await ExchangeRateService.getRealTimeRates(_fromCurrency);
      print(currencyMap);
      print(_toCurrency);
      setState(() {
        _exchangeRate = currencyMap[_toCurrency]!;
        _convertAmount();
      });
        
    } catch (e) {
      print('error:$e');
    }
  }

  void _convertAmount() {
    print('_convertAmount');
    final double amount = double.tryParse(_amountController.text) ?? 0;
    setState(() {
      _convertedAmount = amount * _exchangeRate;
    });
    print(amount);
    print(_convertedAmount);
    print(_exchangeRate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Currency Calculator'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Amount in $_fromCurrency',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _convertAmount();
              },
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: DropdownButton<String>(
                    value: _fromCurrency,
                    items: <String>['USD', 'EUR', 'GBP', 'JPY', 'AUD'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _fromCurrency = newValue!;
                        _fetchExchangeRate();
                      });
                    },
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: DropdownButton<String>(
                    value: _toCurrency,
                    items: <String>['USD', 'EUR', 'GBP', 'JPY', 'AUD'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _toCurrency = newValue!;
                        _fetchExchangeRate();
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Exchange Rate: ${_exchangeRate.toStringAsFixed(2)} $_fromCurrency to $_toCurrency',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              'Converted Amount: ${_convertedAmount.toStringAsFixed(2)} $_toCurrency',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
