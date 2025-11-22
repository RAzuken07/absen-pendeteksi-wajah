import json
import numpy as np
import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

# Import the functions from the main backend file
from flask_api_backend import load_json_data, PATH_USERS

def test_json_storage():
    """Test that the JSON storage system works correctly"""
    print("Testing JSON storage...")
    
    # Load users and check encodings
    users_data = load_json_data(PATH_USERS)
    faces_list = [u for u in users_data if isinstance(u, dict) and 'encoding' in u]
    print(f"Current face count: {len(faces_list)}")

    # Verify that the stored encodings can be converted back to numpy arrays
    for i, user in enumerate(faces_list):
        try:
            encoding = np.array(user['encoding'])
            print(f"[OK] User {i}: {user.get('nama', user.get('email'))}, encoding shape: {encoding.shape}")
        except Exception as e:
            print(f"[ERROR] Error with user {i} encoding: {e}")
            return False
    
    print("[OK] JSON storage test passed!")
    return True

if __name__ == "__main__":
    test_json_storage()