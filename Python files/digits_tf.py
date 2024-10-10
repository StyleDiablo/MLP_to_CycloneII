import tensorflow as tf
import numpy as np
from sklearn.datasets import load_digits
from sklearn.model_selection import train_test_split
import json


digits = load_digits()
x_data = digits.images
y_data = digits.target

x_data = x_data / 16.0  
x_train, x_val, y_train, y_val = train_test_split(x_data, y_data, test_size=0.3, random_state=42)

model = tf.keras.models.Sequential()
model.add(tf.keras.layers.Flatten())
model.add(tf.keras.layers.Dense(16,activation=tf.nn.sigmoid))
model.add(tf.keras.layers.Dense(10,activation=tf.nn.sigmoid))
model.add(tf.keras.layers.Dense(10,activation=tf.nn.sigmoid))



# Compile the 
model.compile(optimizer='adam',
              loss=tf.keras.losses.SparseCategoricalCrossentropy(from_logits=True),
              metrics=['accuracy'])

early_stopping = tf.keras.callbacks.EarlyStopping(monitor='val_accuracy', patience=5, restore_best_weights=True)

model.fit(x_train, y_train, epochs=20, batch_size=3, validation_data=(x_val, y_val), callbacks=[early_stopping])

weightList = []
biasList = []
for i in range(1,len(model.layers)):
    weights = model.layers[i].get_weights()[0]
    weightList.append((weights.T).tolist())
    bias = [[float(b)] for b in model.layers[i].get_weights()[1]]
    biasList.append(bias)

data = {"weights": weightList,"biases":biasList}
f = open('weightsandbiases.txt', "w")
json.dump(data, f)
f.close()



