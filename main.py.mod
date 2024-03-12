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

# Function to save prediction data into the database
def save_prediction_data(db: Session, image_url: str, predictions: list, confidence_scores: list):
    # Implement logic to save prediction data into the database
    pass

# Function to get the latest prediction data from the database
def get_latest_prediction_data(db: Session):
    # Fetch the latest prediction data from the database by joining Prediction with UserInput
    latest_prediction_data = db.query(UserInput.image, Prediction.name, Prediction.confidence_score, Prediction.read_more_url)\
        .join(UserInput, UserInput.prediction_id == Prediction.id)\
        .order_by(Prediction.date_added.desc()).first()

    if latest_prediction_data:
        # If prediction data is available, return it
        return {
            "image_url": latest_prediction_data.image,
            "predictions": latest_prediction_data.name,
            "confidence_scores": latest_prediction_data.confidence_score,
            "read_more_urls": latest_prediction_data.read_more_url
        }
    else:
        # If prediction data is not available, return None
        return None



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
        response_from_autoderm = requests.post(
            "https://autoderm.ai/v1/query?model=autoderm_v2_2&language=en",
            headers={"Api-Key": api_key},
            files={"file": image_contents},
        )

        if response_from_autoderm.status_code == 429:  # API rate limit exceeded
            rotate_api_key()  # Rotate to the next API key
            api_key = get_current_api_key()  # Get the new current API key
            response_from_autoderm = requests.post(
                "https://autoderm.ai/v1/query?model=autoderm_v2_2&language=en",
                headers={"Api-Key": api_key},
                files={"file": image_contents},
            )

        data = response_from_autoderm.json()
        predictions = data.get("predictions", [])
        confidence_scores = [prediction.get("confidence", 0) for prediction in predictions]
        
        save_prediction_data(db, image_path, predictions, confidence_scores)

        return templates.TemplateResponse(
            "prediction.html", {"request": request, "image_url": image_url, "predictions": predictions, "confidence_scores": confidence_scores}
        )
    except Exception as e:
        # Handle any exceptions
        raise HTTPException(status_code=500, detail=f"Internal Server Error: {str(e)}")

# GET endpoint to retrieve prediction data of the latest image
@app.get("/predictionData")
async def get_latest_prediction_data_endpoint(
    request: Request,
    db: Session = Depends(get_db)
):
    # Fetch the latest prediction data from the database
    latest_prediction_data = get_latest_prediction_data(db)
    if latest_prediction_data:
        # If prediction data is available, return it
        return latest_prediction_data
    else:
        # If prediction data is not available, return 404 Not Found
        raise HTTPException(status_code=404, detail="Prediction data not found")

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

# Add the /webphoto endpoint to save images to the cache folder
@app.post("/webphoto")
async def webphoto(image: UploadFile = File(...)):
    # Ensure that the file is an image
    if not image.filename.lower().endswith(('.png', '.jpg', '.jpeg')):
        raise HTTPException(status_code=400, detail="Only PNG, JPG, and JPEG files are allowed.")

    # Read the image contents
    image_contents = await image.read()

    try:
        # Save the image to the cache folder
        filename = os.path.join("cache", image.filename)
        with open(filename, "wb") as f:
            f.write(image_contents)
        
        return {"message": "Image saved successfully", "filename": filename}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to save the image: {str(e)}")

if __name__ == "__main__":
    uvicorn.run("main:app", host="localhost", port=3100, reload=False)