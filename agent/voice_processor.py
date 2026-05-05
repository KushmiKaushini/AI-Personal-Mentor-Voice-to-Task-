import os
import google.generativeai as genai
import json
import requests
from dotenv import load_dotenv

load_dotenv()

# Configure Gemini
GENAI_API_KEY = os.getenv("GENAI_API_KEY")
if not GENAI_API_KEY:
    raise ValueError("GENAI_API_KEY not found in environment variables")

genai.configure(api_key=GENAI_API_KEY)

# Backend API configuration
BACKEND_URL = "http://localhost:8000/tasks/"

# List of 8 Subjects for IT Undergraduates (Example)
SUBJECTS = [
    "Software Engineering",
    "Data Structures & Algorithms",
    "Database Management Systems",
    "Computer Networks",
    "Operating Systems",
    "Artificial Intelligence",
    "Web Development",
    "Cyber Security"
]

def process_voice_input(audio_file_path):
    """
    Processes audio file using Gemini to extract study tasks and deadlines.
    """
    model = genai.GenerativeModel('gemini-1.5-flash')
    
    # Upload the audio file to Gemini
    with open(audio_file_path, "rb") as f:
        audio_data = f.read()
    
    # Determine MIME type
    mime_type = "audio/mp3" # default
    if audio_file_path.endswith(".m4a"):
        mime_type = "audio/mp4" # Gemini uses audio/mp4 for m4a
    elif audio_file_path.endswith(".wav"):
        mime_type = "audio/wav"
    elif audio_file_path.endswith(".aac"):
        mime_type = "audio/aac"

    prompt = f"""
    You are an AI Study Assistant for IT undergraduates. 
    Listen to the provided audio and extract 'Study Tasks' and 'Deadlines'.
    
    Valid Subjects: {", ".join(SUBJECTS)}
    
    Output the result in a strict JSON format as a list of objects:
    [
        {{"subject": "Subject Name", "task_name": "Task Title", "description": "Short description", "deadline": "YYYY-MM-DD or relative time"}}
    ]
    
    Only include tasks for the valid subjects listed above. If a subject isn't mentioned clearly, try to map it to the closest valid subject.
    """
    
    # Passing the prompt and audio data
    response = model.generate_content([
        prompt,
        {"mime_type": mime_type, "data": audio_data}
    ])
    
    try:
        # Extract JSON from the response text
        # Gemini might wrap it in markdown code blocks
        text_content = response.text
        if "```json" in text_content:
            json_str = text_content.split("```json")[1].split("```")[0].strip()
        else:
            json_str = text_content.strip()
            
        tasks = json.loads(json_str)
        return tasks
    except Exception as e:
        print(f"Error parsing Gemini response: {e}")
        print(f"Raw Response: {response.text}")
        return []

def sync_tasks_to_backend(tasks):
    """
    Sends extracted tasks to the local SQLite storage via REST API.
    """
    synced_count = 0
    for task in tasks:
        try:
            response = requests.post(BACKEND_URL, json=task)
            if response.status_code == 200 or response.status_code == 201:
                print(f"Successfully synced: {task['task_name']}")
                synced_count += 1
            else:
                print(f"Failed to sync {task['task_name']}: {response.text}")
        except Exception as e:
            print(f"Error calling backend API: {e}")
            
    return synced_count

if __name__ == "__main__":
    # Example usage
    # audio_path = "sample_recording.mp3"
    # if os.path.exists(audio_path):
    #     tasks = process_voice_input(audio_path)
    #     sync_tasks_to_backend(tasks)
    pass
