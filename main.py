from fastapi import FastAPI, Form, UploadFile, Request, Response, status
from fastapi.templating import Jinja2Templates
import uvicorn
import requests
import os

templates = Jinja2Templates(directory=".")
app = FastAPI()

@app.get("/")
async def index(request: Request):
    return templates.TemplateResponse("index.html", {"request": request})

@app.head("/", status_code=200)
async def health(response: Response):
    response.status_code = status.HTTP_200_OK
    return

@app.post("/image")
async def process(
    *,
    image: UploadFile = Form(...),
    request: Request,
):
    image_contents = await image.read()
    response = requests.post(
        "https://autoderm.firstderm.com/v1/query?language=en&model=autoderm_v2_0",
        headers={"Api-Key": os.getenv("API_KEY")},
        files={"file": image_contents},
    )

    data = response.json()
    predictions = data["predictions"]

    return templates.TemplateResponse(
        "prediction.html", {"request": request, "predictions": predictions}
    )

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=False)