import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:typed_data';

class PredictScreen extends StatefulWidget {
  @override
  _PredictScreenState createState() => _PredictScreenState();
}

class _PredictScreenState extends State<PredictScreen> {
  String _fromCurrency = 'USD';
  String _toCurrency = 'EUR';
  DateTime _selectedDate = DateTime.now();
  String _predictedRate = 'N/A';

  late Interpreter _interpreter;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  // Load the TensorFlow Lite model
  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('exchange_rate_model.tflite');
      print("Model loaded successfully.");
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  // Method to run the prediction
  Future<void> _runPrediction() async {
    try {
      // Example: Convert user input into a model input tensor
      // Replace this with actual preprocessing logic for your model
      List<double> input = [1.0, 0.5, 0.2, 0.7]; // Example input for the model
      var inputTensor = Float32List.fromList(input).reshape([1, input.length]);

      // Prepare output tensor
      var outputTensor = List.filled(1, 0.0).reshape([1]);

      // Run inference
      _interpreter.run(inputTensor, outputTensor);

      setState(() {
        _predictedRate = outputTensor[0].toStringAsFixed(2); // Update the UI
      });
    } catch (e) {
      print("Error during prediction: $e");
      setState(() {
        _predictedRate = 'Error';
      });
    }
  }

  // Method to open date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  void dispose() {
    _interpreter.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Currency Prediction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Future Exchange Rate Prediction',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // Currency selection dropdowns
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: _fromCurrency,
                  items: ['USD', 'EUR', 'GBP', 'JPY', 'AUD'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _fromCurrency = newValue!;
                    });
                  },
                ),
                Text('to'),
                DropdownButton<String>(
                  value: _toCurrency,
                  items: ['USD', 'EUR', 'GBP', 'JPY', 'AUD'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _toCurrency = newValue!;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            // Date picker
            Row(
              children: [
                Text(
                  'Select Date:',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(width: 10),
                Text(
                  "${_selectedDate.toLocal()}".split(' ')[0],
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: Text('Pick Date'),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Display predicted rate
            Text(
              'Predicted Rate: $_predictedRate',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _runPrediction();
                print('Run Prediction Algorithm');
              },
              child: Text('Run Prediction'),
            ),
          ],
        ),
      ),
    );
  }
}
