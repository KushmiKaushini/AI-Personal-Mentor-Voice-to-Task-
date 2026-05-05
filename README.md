# AI Personal Mentor: Voice-to-Task Agent

This project is an intelligent task manager for IT undergraduates that converts voice recordings into structured study tasks and deadlines, automatically syncing them to a local SQLite database.

## Features
- **Voice-to-Text & Extraction**: Uses Google Gemini 1.5 Flash to process audio and extract tasks.
- **Structured Data**: Extracts 'Subject', 'Task Name', 'Description', and 'Deadline'.
- **REST API Integration**: Updates a local SQLite database via a FastAPI backend.
- **Subject Filtering**: Targeted for 8 specific IT subjects.

## Project Structure
- `backend/`: FastAPI server and SQLite database logic.
- `agent/`: Gemini-powered voice processing logic.
- `main.py`: Command-line interface to process audio files.

## Setup Instructions

1. **Install Dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

2. **Configure Environment**:
   - Copy `.env.example` to `.env`.
   - Add your [Google Gemini API Key](https://aistudio.google.com/app/apikey).

3. **Start the Backend**:
   ```bash
   python -m backend.app
   ```
   The API will be available at `http://localhost:8000`.

4. **Run the Agent**:
   ```bash
   python main.py path/to/your/audio_file.mp3
   ```

## Customizing Subjects
You can modify the list of 8 subjects in `agent/voice_processor.py`:
```python
SUBJECTS = [
    "Software Engineering",
    "Data Structures & Algorithms",
    "Database Management Systems",
    # ... add your subjects here
]
```
