from fastapi import FastAPI, UploadFile, File, HTTPException

import model_loader
from predict import run_prediction

app = FastAPI(title="AgriLens-AI")


@app.on_event("startup")
def startup_event():
    model_loader.load_model()


@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    if not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="File must be an image")

    image_bytes = await file.read()
    result = run_prediction(image_bytes)
    return result