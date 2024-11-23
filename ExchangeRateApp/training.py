import pandas as pd
import numpy as np
from sklearn.preprocessing import MinMaxScaler
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dense, Dropout
import tensorflow as tf

# Load the raw CSV file
file_path = 'lib/past_exchange_rate.csv'
data = pd.read_csv(file_path, header=None)

# Step 1: Extract headers and organize the data
dates = data.iloc[0, 1:]  # The first row contains dates
data.columns = ['Currency Pair'] + dates.tolist()  # Set column headers
data = data.iloc[1:]  # Remove the first row, already used as headers
print("Step 1")
# Step 2: Reshape the data into a long-format DataFrame
formatted_data = data.melt(
    id_vars='Currency Pair', 
    var_name='Date', 
    value_name='Rate'
)
print("Step 2")

# Step 3: Pivot the data so each currency pair is a column
formatted_data = formatted_data.pivot(
    index='Date', 
    columns='Currency Pair', 
    values='Rate'
).reset_index()
print("Step 3")
# Convert rates to float for processing
formatted_data.iloc[:, 1:] = formatted_data.iloc[:, 1:].astype(float)

# Convert the 'Date' column to datetime for time-series handling
formatted_data['Date'] = pd.to_datetime(formatted_data['Date'])

# Save the cleaned data for further use
formatted_data.to_csv('formatted_exchange_rate.csv', index=False)

print("Formatted data preview:")
print(formatted_data.head())

# Load the formatted data
data = pd.read_csv('formatted_exchange_rate.csv')

# Sort by date and set 'Date' as the index
data['Date'] = pd.to_datetime(data['Date'])
data = data.sort_values('Date')
data.set_index('Date', inplace=True)
print("Step 4")
# Normalize the data
scaler = MinMaxScaler(feature_range=(0, 1))
scaled_data = scaler.fit_transform(data)
print("Step 5")
# Create sequences for LSTM
def create_sequences(data, seq_length):
    x, y = [], []
    for i in range(len(data) - seq_length):
        x.append(data[i:i + seq_length])
        y.append(data[i + seq_length])
    return np.array(x), np.array(y)

seq_length = 60  # Use past 60 days to predict the next day
x, y = create_sequences(scaled_data, seq_length)

# Split data into training and testing sets
train_size = int(len(x) * 0.8)
x_train, x_test = x[:train_size], x[train_size:]
y_train, y_test = y[:train_size], y[train_size:]

# Build the LSTM model
model = Sequential([
    LSTM(50, return_sequences=True, input_shape=(x_train.shape[1], x_train.shape[2])),
    Dropout(0.2),
    LSTM(50, return_sequences=False),
    Dropout(0.2),
    Dense(25, activation='relu'),
    Dense(data.shape[1])  # Output layer: predict all currency pairs
])

model.compile(optimizer='adam', loss='mean_squared_error')

# Train the model
history = model.fit(
    x_train, y_train,
    validation_data=(x_test, y_test),
    epochs=50,
    batch_size=32,
    verbose=1
)

model = tf.keras.models.load_model('exchange_rate_prediction_model.h5')

# Convert the model to TensorFlow Lite format
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()

# Save the TFLite model to a file
with open('exchange_rate_model.tflite', 'wb') as f:
    f.write(tflite_model)

print("Model successfully converted to TFLite format: exchange_rate_model.tflite")
