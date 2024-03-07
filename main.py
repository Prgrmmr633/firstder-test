from fastapi import FastAPI, Form, UploadFile, Request, Response, status, HTTPException, Depends
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

templates = Jinja2Templates(directory=".")
app = FastAPI()

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

@app.get("/")
async def index(request: Request):
    return templates.TemplateResponse("index.html", {"request": request})

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
    image_path = f"static/{image_filename}"  
    image_url = f"/{image_filename}" 

    with open(image_path, "wb") as f:
        f.write(image_contents)

    response = requests.post(
        "https://autoderm.ai/v1/query?model=autoderm_v2_2&language=en",
        headers={"Api-Key": "5675fd21-7929-2597-6c8e-69e220ede9a2"},
        files={"file": image_contents},
    )

    try:
        data = response.json()
    except json.JSONDecodeError:
        print("Warning: HTTP request returned empty or invalid JSON response")
        data = {}

    predictions = data.get("predictions", [])
    confidence_scores = [prediction.get("confidence", 0) for prediction in predictions]

    return templates.TemplateResponse(
        "prediction.html", {"request": request, "image_url": image_url, "image_path": image_path, "predictions": predictions, "confidence_scores": confidence_scores}
    )

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
    subquery = db.query(func.max(Prediction.confidence_score).label("max_confidence")).group_by(func.date(Prediction.date_added)).subquery()
    results = (
        db.query(Prediction)
        .join(UserInput, Prediction.id == UserInput.prediction_id)
        .filter(func.date(Prediction.date_added) == func.date(UserInput.date_added))
        .filter(Prediction.confidence_score == subquery.c.max_confidence)
        .order_by(Prediction.date_added)
        .all()
    )

    return templates.TemplateResponse("results.html", {"request": request, "results": results})

@app.get("/result/{result_id}", response_class=HTMLResponse)
async def view_result(request: Request, result_id: int, db: Session = db_dependency):
    result = db.query(UserInput).filter_by(id=result_id).first()

    return templates.TemplateResponse("results_details.html", {"request": request, "result": result})

if __name__ == "__main__":
    uvicorn.run("main:app", host="localhost", port=3100, reload=False)
