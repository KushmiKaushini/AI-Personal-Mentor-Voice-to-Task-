from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from . import models, database
from pydantic import BaseModel

app = FastAPI(title="AI Personal Mentor Backend")

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

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
