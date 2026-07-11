import base64

import cv2
import numpy as np
import tensorflow as tf
import matplotlib.pyplot as plt

import model_loader as ml


def compute_gradcam(img_batch, class_index=None):
    img_tensor = tf.cast(img_batch, tf.float32)

    with tf.GradientTape() as tape:
        x = ml.augmentation_layer(img_tensor, training=False)
        x = tf.keras.applications.efficientnet.preprocess_input(x)

        conv_output = ml.efficientnet_layer(x, training=False)
        tape.watch(conv_output)

        x = ml.gap_layer(conv_output)
        x = ml.dropout_layer(x, training=False)
        predictions = ml.dense_layer(x)

        if class_index is None:
            class_index = int(tf.argmax(predictions[0]))

        class_score = predictions[:, class_index]

    grads = tape.gradient(class_score, conv_output)
    pooled_grads = tf.reduce_mean(grads, axis=(0, 1, 2))

    heatmap = conv_output[0] @ pooled_grads[..., tf.newaxis]
    heatmap = tf.squeeze(heatmap).numpy()

    heatmap = np.maximum(heatmap, 0)
    if heatmap.max() > 0:
        heatmap /= heatmap.max()

    confidence = float(predictions[0][class_index]) * 100

    return heatmap, class_index, confidence


def overlay_gradcam(img_uint8, heatmap, alpha=0.4):
    h, w = img_uint8.shape[:2]
    heatmap_resized = cv2.resize(heatmap, (w, h))
    colormap = plt.colormaps['jet']
    heatmap_colored = (colormap(heatmap_resized)[:, :, :3] * 255).astype(np.uint8)
    return cv2.addWeighted(img_uint8, 1 - alpha, heatmap_colored, alpha, 0)


def overlay_to_base64(overlay_rgb):
    success, buffer = cv2.imencode(".png", cv2.cvtColor(overlay_rgb, cv2.COLOR_RGB2BGR))
    return base64.b64encode(buffer).decode("utf-8")


def predict_with_gradcam(img_array, class_index=None, alpha=0.4):
    img_uint8 = img_array.astype(np.uint8)
    img_batch = np.expand_dims(img_array, axis=0)

    heatmap, pred_index, confidence = compute_gradcam(img_batch, class_index)
    overlay = overlay_gradcam(img_uint8, heatmap, alpha)

    pred_class_raw = ml.CLASS_NAMES[pred_index]
    deficiency_label = ml.LABEL_MAP[pred_class_raw]
    gradcam_base64 = overlay_to_base64(overlay)

    return pred_class_raw, deficiency_label, confidence, gradcam_base64