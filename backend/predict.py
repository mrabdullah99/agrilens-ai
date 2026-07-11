import io

import numpy as np
from PIL import Image

import gradcam
from recommendation import get_recommendation


def preprocess_image(image_bytes):
    img = Image.open(io.BytesIO(image_bytes)).convert("RGB").resize((224, 224))
    return np.array(img).astype(np.float32)


def run_prediction(image_bytes):
    img_array = preprocess_image(image_bytes)
    pred_class_raw, deficiency_label, confidence, gradcam_base64 = gradcam.predict_with_gradcam(img_array)
    recommendation = get_recommendation(deficiency_label)

    return {
        "prediction": deficiency_label,
        "confidence": round(confidence, 2),
        "recommendation": recommendation,
        "gradcam": gradcam_base64,
    }