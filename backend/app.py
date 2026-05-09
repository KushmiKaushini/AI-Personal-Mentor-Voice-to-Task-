from fastapi import FastAPI, Depends, HTTPException, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from typing import List
from . import models, database
from pydantic import BaseModel
import shutil
import os
import logging
from agent.voice_processor import process_voice_input

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="AI Personal Mentor Backend")

# Configure CORS - allows all origins for development, restrict in production
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize database
database.init_db()

# Pydantic schemas
class TaskCreate(BaseModel):
    subject: str
    task_name: str
    description: str = None
    deadline: str = None

class Task(TaskCreate):
    id: int
    class Config:
        orm_mode = True

@app.get("/subjects/")
def get_subjects():
    return [
        "Software Engineering",
        "Data Structures & Algorithms",
        "Database Management Systems",
        "Computer Networks",
        "Operating Systems",
        "Artificial Intelligence",
        "Web Development",
        "Cyber Security",
        "General Study"
    ]

@app.post("/tasks/", response_model=Task)
def create_task(task: TaskCreate, db: Session = Depends(database.get_db)):
    db_task = models.Task(**task.dict())
    db.add(db_task)
    db.commit()
    db.refresh(db_task)
    return db_task

@app.get("/tasks/", response_model=List[Task])
def read_tasks(skip: int = 0, limit: int = 100, db: Session = Depends(database.get_db)):
    tasks = db.query(models.Task).offset(skip).limit(limit).all()
    return tasks

@app.get("/tasks/{subject}", response_model=List[Task])
def read_tasks_by_subject(subject: str, db: Session = Depends(database.get_db)):
    tasks = db.query(models.Task).filter(models.Task.subject == subject).all()
    return tasks

@app.patch("/tasks/{task_id}", response_model=Task)
def update_task_status(task_id: int, status: str, db: Session = Depends(database.get_db)):
    db_task = db.query(models.Task).filter(models.Task.id == task_id).first()
    if not db_task:
        raise HTTPException(status_code=404, detail="Task not found")
    db_task.status = status
    db.commit()
    db.refresh(db_task)
    return db_task

@app.delete("/tasks/{task_id}")
def delete_task(task_id: int, db: Session = Depends(database.get_db)):
    db_task = db.query(models.Task).filter(models.Task.id == task_id).first()
    if not db_task:
        raise HTTPException(status_code=404, detail="Task not found")
    db.delete(db_task)
    db.commit()
    return {"message": "Task deleted successfully"}

@app.post("/process-voice/")
async def process_voice(file: UploadFile = File(...), db: Session = Depends(database.get_db)):
    # Create temp directory if it doesn't exist
    temp_dir = "temp_audio"
    os.makedirs(temp_dir, exist_ok=True)
    
    file_path = os.path.join(temp_dir, file.filename)
    
    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
    
    try:
        # Extract tasks using Gemini
        extracted_tasks = process_voice_input(file_path)
        
        created_tasks = []
        for task_data in extracted_tasks:
            db_task = models.Task(**task_data)
            db.add(db_task)
            created_tasks.append(db_task)
        
        db.commit()
        for task in created_tasks:
            db.refresh(task)
            
        return {"message": f"Successfully processed voice. Created {len(created_tasks)} tasks.", "tasks": created_tasks}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        # Cleanup
        if os.path.exists(file_path):
            os.remove(file_path)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
