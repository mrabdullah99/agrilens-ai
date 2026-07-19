import io

import numpy as np
from PIL import Image

import gradcam
import leaf_gate
from recommendation import get_recommendation


def preprocess_image(image_bytes):
    img = Image.open(io.BytesIO(image_bytes)).convert("RGB").resize((224, 224))
    return np.array(img).astype(np.float32)


def run_prediction(image_bytes):
    img_array = preprocess_image(image_bytes)
    img_uint8 = img_array.astype(np.uint8)
    original_base64 = gradcam.overlay_to_base64(img_uint8)

    if not leaf_gate.is_plant_image(img_uint8):
        return {
            "is_valid": False,
            "prediction": "Not Recognized as a Maize Leaf",
            "confidence": 0.0,
            "recommendation": "Please upload a clear photo of a maize leaf.",
            "gradcam": "",
            "original_image": original_base64,
        }

    pred_class_raw, deficiency_label, confidence, gradcam_base64 = gradcam.predict_with_gradcam(img_array)
    recommendation = get_recommendation(deficiency_label)

    return {
        "is_valid": True,
        "prediction": deficiency_label,
        "confidence": round(confidence, 2),
        "recommendation": recommendation,
        "gradcam": gradcam_base64,
        "original_image": original_base64,
    }