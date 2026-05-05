import argparse
import os
import sys
from agent.voice_processor import process_voice_input, sync_tasks_to_backend

def main():
    parser = argparse.ArgumentParser(description="AI Personal Mentor: Voice-to-Task Agent")
    parser.add_argument("audio_file", help="Path to the audio file (mp3, wav, etc.)")
    
    args = parser.parse_args()
    
    if not os.path.exists(args.audio_file):
        print(f"Error: File {args.audio_file} not found.")
        sys.exit(1)
        
    print(f"--- Processing Voice Input: {args.audio_file} ---")
    tasks = process_voice_input(args.audio_file)
    
    if not tasks:
        print("No tasks extracted. Please check the audio quality or the prompt.")
        return
        
    print(f"Extracted {len(tasks)} tasks:")
    for t in tasks:
        print(f"- [{t['subject']}] {t['task_name']} (Deadline: {t['deadline']})")
        
    print("\n--- Syncing to Local Database ---")
    count = sync_tasks_to_backend(tasks)
    print(f"Successfully synced {count} tasks.")

if __name__ == "__main__":
    main()
