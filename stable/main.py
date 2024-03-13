from fastapi import FastAPI, Form, UploadFile, File, Request, Response, status, HTTPException, Depends
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles
from pydantic import HttpUrl
from typing import List, Optional
from database import SessionLocal, engine
from sqlalchemy.orm import Session
import uvicorn
import requests
import os
import json
from models import Prediction, UserInput
from fastapi.templating import Jinja2Templates
from sqlalchemy import func
from datetime import datetime
import time

templates = Jinja2Templates(directory=".")
app = FastAPI()

# Define multiple API keys
API_KEYS = ["5675fd21-7929-2597-6c8e-69e220ede9a2", "03e9fc01-f3a7-00a9-1d9a-191ac262ea91", "other_api_key_2"]
current_api_key_index = 0

def get_current_api_key():
    global current_api_key_index
    return API_KEYS[current_api_key_index]

def rotate_api_key():
    global current_api_key_index
    current_api_key_index = (current_api_key_index + 1) % len(API_KEYS)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

db_dependency = Depends(get_db)

current_directory = os.path.dirname(os.path.abspath(__file__))
static_directory = os.path.join(current_directory, "static")
os.makedirs(static_directory, exist_ok=True)

app.mount("/static", StaticFiles(directory=static_directory), name="static")
app.mount("/static", StaticFiles(directory="static"), name="static")

@app.get("/")
async def index(request: Request):
    return templates.TemplateResponse("index.html", {"request": request})

# @app.get("/")
# async def hero(request: Request):
#     return templates.TemplateResponse("hero.html", {"request": request})

@app.head("/", status_code=200)
async def health(response: Response):
    response.status_code = status.HTTP_200_OK
    return

@app.post("/image")
async def process(
    image: UploadFile = Form(...),
    request: Request = None,
    db: Session = db_dependency
):
    if request is None:
        raise HTTPException(status_code=500, detail="Internal Server Error: Request object not received.")

    image_contents = await image.read()
    image_filename = image.filename
    timestamp = int(time.time())  # Generate a timestamp
    unique_filename = f"{timestamp}_{image_filename}"  # Unique filename
    image_path = os.path.join("static", unique_filename)  # Path to save the image
    image_url = f"/{unique_filename}"  # URL to access the saved image

    try:
        # Save the image to the static directory
        with open(image_path, "wb") as f:
            f.write(image_contents)

        # Call the Autoderm API
        api_key = get_current_api_key()  # Get the current API key
        response = requests.post(
            "https://autoderm.ai/v1/query?model=autoderm_v2_2&language=en",
            headers={"Api-Key": api_key},
            files={"file": image_contents},
        )

        if response.status_code == 429:  # API rate limit exceeded
            rotate_api_key()  # Rotate to the next API key
            api_key = get_current_api_key()  # Get the new current API key
            response = requests.post(
                "https://autoderm.ai/v1/query?model=autoderm_v2_2&language=en",
                headers={"Api-Key": api_key},
                files={"file": image_contents},
            )

        data = response.json()

        predictions = data.get("predictions", [])
        confidence_scores = [prediction.get("confidence", 0) for prediction in predictions]

        return templates.TemplateResponse(
            "prediction.html", {"request": request, "image_url": image_url, "predictions": predictions, "confidence_scores": confidence_scores}
        )
    except Exception as e:
        # Handle any exceptions
        return HTTPException(status_code=500, detail=f"Internal Server Error: {str(e)}")

@app.post("/save_results")
async def save_results(
    request: Request,
    image_path: str = Form(...),
    predictions: List[str] = Form(...),
    confidence_scores: List[float] = Form(...),
    read_more_urls: List[str] = Form(...),
    db: Session = db_dependency
):
    if request is None:
        raise HTTPException(status_code=500, detail="Internal Server Error: Request object not received.")
    
    current_datetime = datetime.now()

    for prediction, confidence_score, read_more_url in zip(predictions, confidence_scores, read_more_urls):
        db_prediction = Prediction(name=prediction, confidence_score=confidence_score, read_more_url=read_more_url, date_added=current_datetime)
        db.add(db_prediction)
        db.flush()  
        db_user_input = UserInput(image=image_path, prediction_id=db_prediction.id)
        db.add(db_user_input)

    db.commit()  

    return {"message": "Results saved successfully"}

@app.get("/results", response_class=HTMLResponse)
async def view_results(request: Request, db: Session = db_dependency):
    results = (
        db.query(Prediction)
        .join(UserInput, Prediction.id == UserInput.prediction_id)
        .filter(func.date(Prediction.date_added) == func.date(UserInput.date_added))
        .order_by(Prediction.date_added)
        .filter(Prediction.id % 5 == 1)  # Filter every 5th row
        .all()
    )

    return templates.TemplateResponse("results.html", {"request": request, "results": results})

@app.get("/result/{result_id}", response_class=HTMLResponse)
async def view_result(request: Request, result_id: int, prediction_date: str, db: Session = db_dependency):
    result = db.query(UserInput).filter_by(id=result_id).first()

    # Convert prediction_date to a datetime object
    prediction_date = datetime.strptime(prediction_date, "%Y-%m-%d %H:%M:%S.%f")

    print("Requested prediction date:", prediction_date)

    # Fetch predictions and filter them based on the prediction_date
    predictions = (
        db.query(Prediction)
        .join(UserInput, Prediction.id == UserInput.prediction_id)
        .filter(func.date(UserInput.date_added) == prediction_date.date())
        .all()
    )

    return templates.TemplateResponse("results_details.html", {"request": request, "result": result, "predictions": predictions, "prediction_date": prediction_date})

if __name__ == "__main__":
    uvicorn.run("main:app", host="localhost", port=3100, reload=False)