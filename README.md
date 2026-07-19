# 🌱 AgriLens AI

> **An AI-powered mobile application for maize leaf nutrient deficiency detection using Flutter, FastAPI, TensorFlow/Keras, EfficientNetB0, Grad-CAM, and a dedicated leaf validation model for reliable and explainable predictions.**

![Flutter](https://img.shields.io/badge/Flutter-Mobile-02569B?style=for-the-badge)
![TensorFlow](https://img.shields.io/badge/TensorFlow-2.20-FF6F00?style=for-the-badge&logo=tensorflow&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.11-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Keras](https://img.shields.io/badge/Keras-D00000?style=for-the-badge&logo=keras&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)

---

# 📖 Overview

AgriLens AI is an AI-powered mobile application that detects **maize leaf nutrient deficiencies** from images using Deep Learning.

The project combines a **Flutter mobile application**, **FastAPI backend**, and a **TensorFlow/Keras inference pipeline** to deliver nutrient deficiency predictions, confidence scores, Grad-CAM visual explanations, and fertilizer recommendations.

To improve reliability, AgriLens AI first validates whether the uploaded image actually contains a maize leaf before performing nutrient analysis, using a dedicated binary classification model trained separately from the main classifier. Images that do not contain a valid maize leaf are rejected, preventing unnecessary or misleading predictions.

---

# ✨ Features

- 📷 Capture images using the device camera
- 🖼️ Select images from the gallery
- 🍃 Automatic maize leaf validation before analysis
- 🚫 Rejects non-leaf or unsupported images
- 🤖 EfficientNetB0 nutrient deficiency classification
- 📊 Prediction confidence score with top-3 breakdown
- 🔥 Grad-CAM explainable AI visualization
- 🌱 Fertilizer recommendations
- 📱 Flutter mobile application
- ⚡ FastAPI REST API
- 🧩 Modular backend architecture
- 🌙 Light and Dark theme support

---

# 🧠 AI Pipeline

AgriLens AI uses a two-stage AI pipeline, backed by two independently trained EfficientNetB0 models.

## Stage 1 — Leaf Validation (Leaf Gate Model)

Before nutrient analysis begins, a dedicated binary EfficientNetB0 "leaf gate" model checks whether the uploaded image contains a maize leaf.

This model was trained on a custom binary dataset: maize leaf images formed the positive class, while the negative (non-maize) class was assembled from a mix of general-purpose image datasets — Caltech-101, Oxford-IIIT Pet, and Food-101 — to teach the gate to recognize a broad range of non-leaf objects, animals, and scenes. If the uploaded image is flagged as invalid, the application returns an informative message instead of attempting classification.

## Stage 2 — Nutrient Deficiency Classification

Valid maize leaf images are passed to a second EfficientNetB0 model trained using transfer learning in two phases: the base network is first frozen while a new classification head is trained, then the last ~30 layers of the base model are unfrozen and fine-tuned at a lower learning rate for improved accuracy.

The model predicts one of six nutrient conditions and produces a confidence score together with a Grad-CAM visualization highlighting the regions responsible for the prediction. Grad-CAM is implemented with a manual layer-by-layer forward pass (rather than a rebuilt sub-model), which keeps it compatible with Keras 3 / TensorFlow 2.20+ and able to trace gradients through the nested EfficientNetB0 submodel.

---

# 🌿 Supported Classes

The classifier predicts one of the following six categories:

- ✅ Healthy Leaf
- 🌱 Nitrogen Deficiency
- 🌱 Phosphorus Deficiency
- 🌱 Potassium Deficiency
- 🌱 Zinc Deficiency
- ⚠️ Multiple Nutrient Deficiencies

Each predicted class maps to a corresponding fertilizer recommendation (e.g., Urea for nitrogen deficiency, DAP for phosphorus, Muriate of Potash for potassium, Zinc Sulfate for zinc, and a soil test recommendation when multiple deficiencies are detected).

---

# 🔥 Explainable AI

AgriLens AI integrates **Grad-CAM (Gradient-weighted Class Activation Mapping)** to improve model interpretability.

Instead of only displaying a predicted class, the application generates a heatmap highlighting the image regions that contributed most to the prediction, allowing users to better understand the model's decision.

---

# 🏗️ System Architecture

```text
                Flutter Mobile App
                        │
                        ▼
                 FastAPI Backend
                        │
                        ▼
           Leaf Gate Model (Binary EfficientNetB0)
            (Maize Leaf Verification)
                        │
             ┌──────────┴──────────┐
             │                     │
             ▼                     ▼
      Invalid Image          Valid Maize Leaf
             │                     │
             │                     ▼
             │             Image Preprocessing
             │                     │
             │                     ▼
             │      EfficientNetB0 Classifier (6 classes)
             │                     │
             │                     ▼
             │             Grad-CAM Generation
             │                     │
             │                     ▼
             │         Recommendation Engine
             │                     │
             └──────────────► JSON Response
```

---

# 📁 Project Structure

```text
AgriLens AI/
│
├── backend/
│   ├── model/
│   ├── app.py
│   ├── gradcam.py
│   ├── leaf_gate.py
│   ├── model_loader.py
│   ├── predict.py
│   ├── recommendation.py
│   └── requirements.txt
│
├── frontend/
│   └── agrilens_ai/
│       ├── android/
│       ├── ios/
│       ├── lib/
│       │   ├── models/
│       │   ├── providers/
│       │   ├── screens/
│       │   ├── services/
│       │   ├── theme/
│       │   ├── utils/
│       │   ├── widgets/
│       │   └── main.dart
│       ├── linux/
│       ├── macos/
│       ├── windows/
│       ├── web/
│       ├── test/
│       ├── pubspec.yaml
│       └── pubspec.lock
│
├── notebooks/
│   ├── maize_deficiency_efficientnet_b0.ipynb   # Main 6-class classifier training
│   └── train_leaf_gate.ipynb                    # Binary leaf-gate model training
│
├── .gitignore
└── README.md
```

---

# 🚀 Technology Stack

## Mobile Application

- Flutter
- Dart
- Provider
- HTTP
- Image Picker
- Material Design 3

## Backend

- FastAPI
- Uvicorn
- TensorFlow / Keras
- NumPy
- Pillow
- OpenCV
- Matplotlib

## Deep Learning & Training

- EfficientNetB0 (used for both the classifier and the leaf gate)
- Transfer Learning + Fine-Tuning (last ~30 layers unfrozen)
- TensorFlow Datasets (Caltech-101, Oxford-IIIT Pet, Food-101) for negative-class sourcing
- scikit-learn (classification report, confusion matrix)
- Grad-CAM (manual forward-pass implementation)

---

# 🧪 Model Information

| Property | Nutrient Classifier | Leaf Gate Model |
|----------|---------------------|------------------|
| Base Architecture | EfficientNetB0 | EfficientNetB0 |
| Framework | TensorFlow / Keras | TensorFlow / Keras |
| Input Size | 224 × 224 | 224 × 224 |
| Number of Classes | 6 | 2 (maize / non-maize) |
| Training Strategy | Frozen head → fine-tune last 30 layers | Frozen head (linear probe) |
| Explainability | Grad-CAM | — |
| Output | Prediction + Confidence + Heatmap + Recommendation | Valid / Invalid leaf image |

---

# 📡 REST API

## POST `/predict`

Uploads a maize leaf image for analysis.

### Request

```
multipart/form-data
```

### Example Response

```json
{
  "prediction": "Nitrogen Deficiency",
  "confidence": 98.4,
  "recommendation": "Apply nitrogen fertilizer.",
  "gradcam": "<base64_image>"
}
```

If the leaf gate model rejects the image, the API instead returns a message indicating that no valid maize leaf was detected, without running the nutrient classifier.

---

# 📱 Application Workflow

```text
Splash Screen
      │
      ▼
Home Screen
      │
      ▼
Capture / Select Image
      │
      ▼
Leaf Validation (Leaf Gate Model)
      │
      ▼
Prediction (Nutrient Classifier)
      │
      ▼
Grad-CAM Visualization
      │
      ▼
Recommendation
```

---

# ⚙️ Local Setup

## Clone Repository

```bash
git clone https://github.com/mrabdullah99/agrilens-ai.git
```

## Backend

```bash
cd backend

python -m venv .venv

# Windows
.venv\Scripts\activate

pip install -r requirements.txt

uvicorn app:app --reload
```

## Frontend

```bash
cd ../frontend/agrilens_ai

flutter pub get

flutter run
```

---

# 📈 Development Status

- ✅ Nutrient Deficiency Classification Model (EfficientNetB0)
- ✅ Leaf Validation / Gate Model (EfficientNetB0, binary)
- ✅ Grad-CAM Visualization
- ✅ FastAPI Backend
- ✅ Flutter Frontend
- ✅ REST API Integration
- ⏳ Deployment

---

# 💡 Future Improvements

- Support additional crop species
- Plant disease detection
- TensorFlow Lite offline inference
- Cloud deployment
- User authentication
- Prediction history synchronization
- Multi-language support
- GPS-based field records
- Model versioning

---

# 🤝 Contributing

Contributions, suggestions, and feedback are welcome.

Feel free to fork the repository, open an issue, or submit a pull request.

---

# 📄 License

This project is licensed under the MIT License.

---

# 👨‍💻 Author

**Muhammad Abdullah**

Bachelor of Software Engineering

GitHub: https://github.com/mrabdullah99

---

⭐ If you found this project helpful, consider giving it a star!