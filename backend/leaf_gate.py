import numpy as np
import tensorflow as tf
from tensorflow.keras.applications.efficientnet import preprocess_input

MODEL_PATH = "model/leaf_gate_model.keras"
LEAF_THRESHOLD = 0.5  # sigmoid output: 0 = maize/leaf, 1 = non_maize

_gate_model = None


def load_gate_model():
    global _gate_model
    _gate_model = tf.keras.models.load_model(MODEL_PATH)
    return _gate_model


def is_plant_image(img_array_uint8):
    """
    img_array_uint8: (224, 224, 3) uint8 RGB array
    Returns True if the trained gate classifies the image as a maize leaf.
    """
    batch = np.expand_dims(img_array_uint8.astype(np.float32), axis=0)
    batch = preprocess_input(batch)
    prediction = _gate_model.predict(batch, verbose=0)[0][0]
    return prediction < LEAF_THRESHOLD