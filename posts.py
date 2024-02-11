from fastapi import APIRouter

router = APIRouter()

@router.get("/posts/")
async def read_posts():
    # Your code here
    pass

@router.get("/posts/{post_id}")
async def read_post(post_id: int):
    # Your code here
    pass

@router.post("/posts/")
async def create_post():
    # Your code here
    pass

@router.put("/posts/{post_id}")
async def update_post(post_id: int):
    # Your code here
    pass

@router.delete("/posts/{post_id}")
async def delete_post(post_id: int):
    # Your code here
    pass