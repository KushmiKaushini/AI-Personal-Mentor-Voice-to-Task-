from sqlalchemy import Column, Integer, String, DateTime, Text
from sqlalchemy.ext.declarative import declarative_base
import datetime

Base = declarative_base()

class Task(Base):
    __tablename__ = "tasks"

    id = Column(Integer, primary_key=True, index=True)
    subject = Column(String, index=True) # One of the 8 subjects
    task_name = Column(String)
    description = Column(Text, nullable=True)
    deadline = Column(String, nullable=True) # Storing as string for simplicity in voice extraction, or can be DateTime
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
    status = Column(String, default="pending") # pending, completed
