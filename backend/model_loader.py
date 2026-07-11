import tensorflow as tf
from keras.layers import GlobalAveragePooling2D, Dropout, Dense

MODEL_PATH = "model/maize_nutrient_model_v3.keras"

CLASS_NAMES = ["ALL Present", "ALLAB", "KAB", "NAB", "PAB", "ZNAB"]

LABEL_MAP = {
    "ALL Present": "Multiple Nutrient Deficiencies",
    "ALLAB": "Healthy Leaf",
    "NAB": "Nitrogen Deficiency",
    "PAB": "Phosphorus Deficiency",
    "KAB": "Potassium Deficiency",
    "ZNAB": "Zinc Deficiency",
}

deployed_model = None
augmentation_layer = None
efficientnet_layer = None
gap_layer = None
dropout_layer = None
dense_layer = None


def load_model():
    global deployed_model, augmentation_layer, efficientnet_layer
    global gap_layer, dropout_layer, dense_layer

    deployed_model = tf.keras.models.load_model(MODEL_PATH)

    augmentation_layer = deployed_model.layers[1]
    efficientnet_layer = deployed_model.get_layer("efficientnetb0")
    gap_layer = next(
        layer for layer in deployed_model.layers
        if isinstance(layer, GlobalAveragePooling2D)
    )
    dropout_layer = next(
        layer for layer in deployed_model.layers
        if isinstance(layer, Dropout)
    )
    dense_layer = next(
        layer for layer in deployed_model.layers
        if isinstance(layer, Dense)
    )

    return deployed_model