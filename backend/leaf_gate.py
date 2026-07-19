# import os
# import numpy as np
# import tensorflow as tf
#
# # Target the 'model' subdirectory safely across operating systems
# GATE_MODEL_PATH = os.path.join(os.path.dirname(__file__), "model", "leaf_gate_model.keras")
# _gate_model = None
#
#
# def load_gate_model():
#     global _gate_model
#     if not os.path.exists(GATE_MODEL_PATH):
#         raise FileNotFoundError(
#             f"Gate model missing at {GATE_MODEL_PATH}. Check your backend/model folder!"
#         )
#     _gate_model = tf.keras.models.load_model(GATE_MODEL_PATH)
#     print("Gate model loaded — assumes label 0='maize', label 1='non_maize'")
#     return _gate_model
#
#
# def is_plant_image(img_array_uint8, confidence_threshold=0.5):
#     global _gate_model
#     if _gate_model is None:
#         load_gate_model()
#
#     # Scale image matching the 0-255 inputs generated during training
#     batch = np.expand_dims(img_array_uint8.astype(np.float32), axis=0)
#
#     # Run binary evaluation
#     prediction = _gate_model.predict(batch, verbose=0)[0][0]
#
#     # Keras implicitly assigns labels alphabetically: 'leaf' -> 0, 'not_leaf' -> 1
#     # Returning True if the model matches closer to the leaf target index (0)
#     return prediction < confidence_threshold

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