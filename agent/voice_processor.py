import os
import google.generativeai as genai
import json
import requests
import logging
from dotenv import load_dotenv

load_dotenv()

# Configure Logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

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
    "Cyber Security",
    "General Study" # Added as fallback
]

def process_voice_input(audio_file_path):
    """
    Processes audio file using Gemini to extract study tasks and deadlines.
    """
    logger.info(f"Processing audio file: {audio_file_path}")
    model = genai.GenerativeModel('gemini-1.5-flash')
    
    # Upload the audio file to Gemini
    try:
        with open(audio_file_path, "rb") as f:
            audio_data = f.read()
            
        if not audio_data:
            logger.error("Audio file is empty")
            return []
    except Exception as e:
        logger.error(f"Error reading audio file: {e}")
        return []
    
    # Determine MIME type
    mime_type = "audio/mp3" # default
    if audio_file_path.endswith(".m4a"):
        mime_type = "audio/mp4" 
    elif audio_file_path.endswith(".wav"):
        mime_type = "audio/wav"
    elif audio_file_path.endswith(".aac"):
        mime_type = "audio/aac"

    prompt = f"""
    You are an AI Study Assistant for IT undergraduates. 
    Listen to the provided audio and extract 'Study Tasks' and 'Deadlines'.
    
    Valid Subjects: {", ".join(SUBJECTS)}
    
    Output the result in a STRICT JSON format as a list of objects.
    Example Output:
    [
        {{"subject": "Subject Name", "task_name": "Task Title", "description": "Short description", "deadline": "YYYY-MM-DD or relative time"}}
    ]
    
    CRITICAL RULES:
    1. Every task MUST be mapped to one of the Valid Subjects listed above.
    2. If a subject isn't clearly mentioned, map it to the most relevant one.
    3. If it doesn't fit any specific technical subject, use 'General Study'.
    4. Do NOT omit any tasks mentioned in the audio.
    5. Return ONLY the JSON list. No conversational text.
    """
    
    try:
        # Passing the prompt and audio data
        response = model.generate_content([
            prompt,
            {"mime_type": mime_type, "data": audio_data}
        ])
        
        text_content = response.text
        logger.info(f"Gemini Raw Response: {text_content}")
        
        # Robust JSON extraction
        json_str = text_content
        if "```json" in text_content:
            json_str = text_content.split("```json")[1].split("```")[0].strip()
        elif "```" in text_content:
            json_str = text_content.split("```")[1].split("```")[0].strip()
            
        # Remove any non-json characters if they exist
        json_str = json_str.strip()
        if not (json_str.startswith('[') or json_str.startswith('{')):
            # Try to find the first [ and last ]
            start = json_str.find('[')
            end = json_str.rfind(']') + 1
            if start != -1 and end != 0:
                json_str = json_str[start:end]

        tasks = json.loads(json_str)
        
        # Ensure it's a list
        if isinstance(tasks, dict):
            tasks = [tasks]
            
        return tasks
    except Exception as e:
        logger.error(f"Error parsing Gemini response: {e}")
        return []

def sync_tasks_to_backend(tasks):
    """
    Sends extracted tasks to the local SQLite storage via REST API.
    """
    synced_count = 0
    for task in tasks:
        try:
            response = requests.post(BACKEND_URL, json=task)
            if response.status_code in [200, 201]:
                logger.info(f"Successfully synced: {task.get('task_name')}")
                synced_count += 1
            else:
                logger.error(f"Failed to sync {task.get('task_name')}: {response.text}")
        except Exception as e:
            logger.error(f"Error calling backend API: {e}")
            
    return synced_count

if __name__ == "__main__":
    # Example usage
    # audio_path = "sample_recording.mp3"
    # if os.path.exists(audio_path):
    #     tasks = process_voice_input(audio_path)
    #     sync_tasks_to_backend(tasks)
    pass
