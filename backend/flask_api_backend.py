from flask import Flask, request, jsonify
from flask_cors import CORS
import cv2
import face_recognition
import numpy as np
import os
from datetime import datetime
import json
import base64
from io import BytesIO
from PIL import Image
import qrcode
import uuid

app = Flask(__name__)
CORS(app)

PATH_WAJAH = 'data_wajah'
PATH_DATA = 'data'
PATH_USERS = os.path.join(PATH_DATA, 'users.json')
PATH_ATTENDANCE = os.path.join(PATH_DATA, 'attendance.json')
PATH_SESSIONS = os.path.join(PATH_DATA, 'sessions.json')

encoded_known_faces = []
names = []

# Inisialisasi direktori dan file data
def initialize_data():
    if not os.path.exists(PATH_WAJAH):
        os.makedirs(PATH_WAJAH)
    if not os.path.exists(PATH_DATA):
        os.makedirs(PATH_DATA)
    
    # Inisialisasi file JSON jika belum ada
    if not os.path.exists(PATH_USERS):
        with open(PATH_USERS, 'w') as f:
            json.dump([], f)
    
    if not os.path.exists(PATH_ATTENDANCE):
        with open(PATH_ATTENDANCE, 'w') as f:
            json.dump([], f)
    
    if not os.path.exists(PATH_SESSIONS):
        with open(PATH_SESSIONS, 'w') as f:
            json.dump([], f)

# Data dosen pre-registered
PREREGISTERED_DOSEN = {
    "dosen@kampus.id": {
        "password": "dosen123",
        "nama": "Dr. Ahmad Wijaya, M.Kom.",
        "nidn": "12345678",
        "mata_kuliah": ["Pemrograman Mobile", "Kecerdasan Buatan"]
    },
    "admin@kampus.id": {
        "password": "admin123",
        "nama": "Prof. Sari Dewi, M.Sc.",
        "nidn": "87654321",
        "mata_kuliah": ["Basis Data", "Algoritma Pemrograman"]
    }
}

# Load wajah terdaftar
def load_known_faces():
    """Load all known face encodings from `users.json`.
    Backwards-compatible: also scan `data_wajah` image files if present.
    """
    global encoded_known_faces, names
    encoded_known_faces = []
    names = []

    # Load from users JSON (single consolidated store)
    users_data = load_json_data(PATH_USERS)
    print("[INFO] Memuat wajah terdaftar dari users.json...")
    for user in users_data:
        # encoding may be stored as 'encoding' (list) inside user record
        if user and isinstance(user, dict) and 'encoding' in user and user['encoding']:
            try:
                encoding = np.array(user['encoding'])
                encoded_known_faces.append(encoding)
                # Normalize name to underscore-lowercase to keep compatibility
                nama_key = user.get('nama') or user.get('name') or user.get('email')
                if isinstance(nama_key, str):
                    norm_name = nama_key.replace(' ', '_').lower()
                else:
                    norm_name = str(nama_key).lower()
                names.append(norm_name)
                print(f"[OK] {norm_name} → loaded from users.json")
            except Exception as e:
                print(f"[WARN] Invalid encoding for user {user}: {e}")

    # Also load any remaining image files for backwards compatibility during transition
    if os.path.exists(PATH_WAJAH):
        print("[INFO] Memuat wajah lama dari file...")
        for filename in os.listdir(PATH_WAJAH):
            if filename.endswith(('.jpg', '.png', '.jpeg')):
                # Check if this face is already in names to avoid duplicates
                name_from_file = "_".join(os.path.splitext(filename)[0].split("_")[:-1])
                name_from_file = name_from_file.strip().lower()

                if name_from_file not in [name.lower() for name in names]:
                    img_path = os.path.join(PATH_WAJAH, filename)
                    img = cv2.imread(img_path)
                    if img is not None:
                        img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
                        enc = face_recognition.face_encodings(img_rgb)
                        if enc:
                            encoded_known_faces.append(enc[0])
                            names.append(name_from_file)
                            print(f"[OK] {filename} → {name_from_file} (from file)")

# Load data dari JSON
def load_json_data(file_path):
    try:
        with open(file_path, 'r') as f:
            return json.load(f)
    except:
        return []

# Save data ke JSON
def save_json_data(file_path, data):
    try:
        with open(file_path, 'w') as f:
            json.dump(data, f, indent=2)
        return True
    except Exception as e:
        print(f"[ERROR] Save JSON: {e}")
        return False

# Base64 ke OpenCV image
def base64_to_image(base64_string):
    try:
        img_data = base64.b64decode(base64_string.split(',')[1] if ',' in base64_string else base64_string)
        img = Image.open(BytesIO(img_data))
        return cv2.cvtColor(np.array(img), cv2.COLOR_RGB2BGR)
    except Exception as e:
        print(f"[ERROR] Decode image: {e}")
        return None

# ============ API ENDPOINTS BARU ============

@app.route('/api/login', methods=['POST'])
def login():
    try:
        data = request.json
        email = data.get('email', '').strip().lower()
        password = data.get('password', '')
        role = data.get('role', '')

        if role == 'dosen':
            # Cek dosen preregistered
            if email in PREREGISTERED_DOSEN:
                dosen_data = PREREGISTERED_DOSEN[email]
                if dosen_data['password'] == password:
                    return jsonify({
                        'success': True,
                        'message': 'Login berhasil',
                        'data': {
                            'id': f"D{email}",
                            'nama': dosen_data['nama'],
                            'email': email,
                            'role': 'dosen',
                            'nidn': dosen_data['nidn'],
                            'mata_kuliah': dosen_data['mata_kuliah']
                        }
                    })
            
            return jsonify({'success': False, 'message': 'Email atau password salah'}), 401
        
        elif role == 'mahasiswa':
            # Cek mahasiswa terdaftar (dari data wajah)
            nama_normalized = email.replace('_', ' ').lower()
            if nama_normalized in [name.lower() for name in names]:
                # Load user data dari JSON
                users_data = load_json_data(PATH_USERS)
                user_data = next((u for u in users_data if u['nama'].lower() == nama_normalized), None)
                
                if user_data:
                    return jsonify({
                        'success': True,
                        'message': 'Login berhasil',
                        'data': user_data
                    })
                else:
                    # Buat user data baru
                    user_data = {
                        'id': f"M{str(uuid.uuid4())[:8]}",
                        'nama': nama_normalized.title(),
                        'email': email,
                        'role': 'mahasiswa',
                        'nim': '',
                        'created_at': datetime.now().isoformat()
                    }
                    users_data.append(user_data)
                    save_json_data(PATH_USERS, users_data)
                    
                    return jsonify({
                        'success': True,
                        'message': 'Login berhasil',
                        'data': user_data
                    })
            
            return jsonify({'success': False, 'message': 'Mahasiswa tidak terdaftar. Silakan registrasi wajah terlebih dahulu'}), 401
        
        return jsonify({'success': False, 'message': 'Role tidak valid'}), 400

    except Exception as e:
        return jsonify({'success': False, 'message': f'Error: {str(e)}'}), 500

# NOTE: The previous preregister-only `register_dosen_face` handler has been removed
# to allow registering any dosen via the single `/api/register-dosen` endpoint.
# The consolidated implementation lives later in this file as `register_dosen`.
@app.route("/api/register-mahasiswa", methods=["POST"])
def register_mahasiswa():
    try:
        data = request.json
        # debug incoming payload
        print(f"[DEBUG] /api/register-mahasiswa payload: {data}")
        nama = data.get("nama")
        nim = data.get("nim")
        email = data.get("email")
        password = data.get("password")
        image = data.get("image")

        if not all([nama, nim, email, password, image]):
            return jsonify({"success": False, "message": "Data tidak lengkap"}), 400

        # proses wajah
        img = base64_to_image(image)
        rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        enc = face_recognition.face_encodings(rgb)

        if not enc:
            return jsonify({"success": False, "message": "Wajah tidak terdeteksi"}), 400

        encoding = enc[0]

        # Save user with encoding into users.json (single consolidated file)
        users = load_json_data(PATH_USERS)

        # If user exists by email, update; otherwise append new
        existing = next((u for u in users if isinstance(u, dict) and u.get('email', '').lower() == email.lower()), None)
        if existing:
            existing['encoding'] = encoding.tolist()
            existing['nama'] = nama
            existing['nim'] = nim
            existing['role'] = 'mahasiswa'
            existing['password'] = password
        else:
            user_entry = {
                'id': f"M{uuid.uuid4().hex[:8]}",
                'nama': nama,
                'email': email,
                'nim': nim,
                'role': 'mahasiswa',
                'password': password,
                'encoding': encoding.tolist(),
                'created_at': datetime.now().isoformat()
            }
            users.append(user_entry)

        save_json_data(PATH_USERS, users)

        # Reload known faces after registration
        load_known_faces()

        return jsonify({"success": True, "message": "Registrasi mahasiswa berhasil"})

    except Exception as e:
        return jsonify({"success": False, "message": str(e)}), 500

# ==============================
# LOGIN DOSEN
# ==============================
@app.route("/api/login-dosen", methods=["POST"])
def login_dosen():
    data = request.json
    email = data.get("email", "").lower()
    password = data.get("password", "")

    if email not in PREREGISTERED_DOSEN:
        return jsonify({"success": False, "message": "Akun tidak ditemukan"}), 404

    dosen = PREREGISTERED_DOSEN[email]

    if password != dosen["password"]:
        return jsonify({"success": False, "message": "Password salah"}), 400

    return jsonify({
        "success": True,
        "message": "Login berhasil",
        "nama": dosen["nama"],
        "email": email,
        "mata_kuliah": dosen["mata_kuliah"],
        "role": "dosen"
    })

@app.route('/api/register-dosen', methods=['POST'])
def register_dosen():
    try:
        data = request.json
        # debug incoming payload
        print(f"[DEBUG] /api/register-dosen payload: {data}")

        nama = data.get('nama', '').strip()
        nidn = data.get('nidn', '').strip()
        mata_kuliah = data.get('mata_kuliah', '').strip()
        email = data.get('email', '').strip()
        password = data.get('password', '').strip()
        image_base64 = data.get('image')

        # Validasi
        if not nama or not nidn or not email or not image_base64:
            return jsonify({
                'success': False,
                'message': 'Nama, NIDN, Email dan Gambar wajib diisi'
            }), 400

        # Convert Base64 ke gambar
        img = base64_to_image(image_base64)
        if img is None:
            return jsonify({'success': False, 'message': 'Gambar tidak valid'}), 400

        # Encode wajah
        rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        encodings = face_recognition.face_encodings(rgb)
        if not encodings:
            return jsonify({'success': False, 'message': 'Wajah tidak terdeteksi'}), 400

        # Simpan user dosen beserta encoding wajah ke users.json (consolidated)
        users = load_json_data(PATH_USERS)
        user_data = {
            'id': f"D{uuid.uuid4().hex[:8]}",
            'nama': nama,
            'nidn': nidn,
            'email': email,
            'role': 'dosen',
            'mata_kuliah': mata_kuliah,
            'password': password,
            'encoding': encodings[0].tolist(),
            'created_at': datetime.now().isoformat()
        }
        users.append(user_data)
        save_json_data(PATH_USERS, users)

        # Reload known faces
        load_known_faces()

        return jsonify({
            'success': True,
            'message': f'Dosen {nama} berhasil didaftarkan',
            'data': user_data
        })

    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500


@app.route('/api/mahasiswa/attendance', methods=['POST'])
def mahasiswa_attendance():
    try:
        data = request.json
        mahasiswa_id = data.get('mahasiswa_id')
        session_id = data.get('session_id')
        barcode_data_str = data.get('barcode_data')
        image_base64 = data.get('image')
        
        # Verifikasi barcode dan session
        sessions = load_json_data(PATH_SESSIONS)
        session = next((s for s in sessions if s['session_id'] == session_id), None)
        
        if not session:
            return jsonify({'success': False, 'message': 'Sesi absen tidak valid'}), 400
        
        if not session['is_active']:
            return jsonify({'success': False, 'message': 'Sesi absen sudah berakhir'}), 400
        
        # Verifikasi barcode data
        try:
            scanned_data = json.loads(barcode_data_str)
            if scanned_data.get('session_id') != session_id:
                return jsonify({'success': False, 'message': 'Barcode tidak valid'}), 400
        except:
            return jsonify({'success': False, 'message': 'Format barcode tidak valid'}), 400
        
        # Verifikasi wajah mahasiswa
        if not image_base64:
            return jsonify({'success': False, 'message': 'Gambar wajah diperlukan'}), 400
        
        img = base64_to_image(image_base64)
        if img is None:
            return jsonify({'success': False, 'message': 'Format gambar tidak valid'}), 400
        
        rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        encodings = face_recognition.face_encodings(rgb)
        
        if not encodings:
            return jsonify({'success': False, 'message': 'Wajah tidak terdeteksi'}), 400
        
        encode = encodings[0]
        if len(encoded_known_faces) == 0:
            return jsonify({'success': False, 'message': 'Belum ada wajah terdaftar'}), 400
        
        hasil = face_recognition.compare_faces(encoded_known_faces, encode, tolerance=0.6)
        jarak = face_recognition.face_distance(encoded_known_faces, encode)
        
        if len(jarak) > 0:
            idx_match = np.argmin(jarak)
            if hasil[idx_match]:
                nama_mahasiswa = names[idx_match].replace('_', ' ').title()
                
                # Catat absensi
                attendance_data = {
                    'id': str(uuid.uuid4()),
                    'mahasiswa_id': mahasiswa_id,
                    'nama': nama_mahasiswa,
                    'mata_kuliah': session['mata_kuliah'],
                    'session_id': session_id,
                    'dosen': session['dosen_name'],
                    'tanggal': datetime.now().strftime('%Y-%m-%d'),
                    'waktu': datetime.now().strftime('%H:%M:%S'),
                    'status': 'hadir'
                }
                
                # Simpan ke attendance.json
                attendance_list = load_json_data(PATH_ATTENDANCE)
                attendance_list.append(attendance_data)
                save_json_data(PATH_ATTENDANCE, attendance_list)
                
                # Update session dengan mahasiswa yang sudah absen
                if mahasiswa_id not in session['mahasiswa_absen']:
                    session['mahasiswa_absen'].append(mahasiswa_id)
                    save_json_data(PATH_SESSIONS, sessions)
                
                return jsonify({
                    'success': True,
                    'message': f'Absensi berhasil untuk {nama_mahasiswa}',
                    'data': attendance_data
                })
        
        return jsonify({'success': False, 'message': 'Wajah tidak dikenali'}), 401
        
    except Exception as e:
        return jsonify({'success': False, 'message': f'Error: {str(e)}'}), 500

@app.route('/api/sessions/active', methods=['GET'])
def get_active_sessions():
    """Mendapatkan sesi aktif untuk dosen"""
    try:
        dosen_id = request.args.get('dosen_id')
        sessions = load_json_data(PATH_SESSIONS)
        
        active_sessions = [
            s for s in sessions 
            if s['is_active'] and s['dosen_id'] == dosen_id
        ]
        
        return jsonify({
            'success': True,
            'data': active_sessions
        })
    except Exception as e:
        return jsonify({'success': False, 'message': f'Error: {str(e)}'}), 500

@app.route('/api/sessions/end', methods=['POST'])
def end_session():
    """Mengakhiri sesi absen"""
    try:
        data = request.json
        session_id = data.get('session_id')
        
        sessions = load_json_data(PATH_SESSIONS)
        session = next((s for s in sessions if s['session_id'] == session_id), None)
        
        if session:
            session['is_active'] = False
            session['waktu_selesai'] = datetime.now().strftime('%H:%M:%S')
            save_json_data(PATH_SESSIONS, sessions)
            
            return jsonify({
                'success': True,
                'message': 'Sesi absen berhasil diakhiri'
            })
        else:
            return jsonify({'success': False, 'message': 'Sesi tidak ditemukan'}), 404
            
    except Exception as e:
        return jsonify({'success': False, 'message': f'Error: {str(e)}'}), 500

# ============ API ENDPOINTS YANG SUDAH ADA (DIUPDATE) ============

@app.route('/api/health', methods=['GET'])
def health():
    users_data = load_json_data(PATH_USERS)
    mahasiswa_count = len([u for u in users_data if u['role'] == 'mahasiswa'])
    
    return jsonify({
        'status': 'ok', 
        'message': 'Server running',
        'registered_users': len(set(names)),
        'mahasiswa_count': mahasiswa_count,
        'dosen_count': len(PREREGISTERED_DOSEN)
    })

@app.route('/api/register', methods=['POST'])
def register_face():
    try:
        data = request.json
        # debug incoming payload
        print(f"[DEBUG] /api/register payload: {data}")
        nama = data.get('nama', '').strip().replace(" ", "_").lower()
        image_base64 = data.get('image')
        nim = data.get('nim', '')
        
        if not nama or not image_base64:
            return jsonify({'success': False, 'message': 'Nama dan gambar harus diisi'}), 400
        
        # Convert base64 to image
        img = base64_to_image(image_base64)
        if img is None:
            return jsonify({'success': False, 'message': 'Format gambar tidak valid'}), 400
        
        # Deteksi wajah
        rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        encodings = face_recognition.face_encodings(rgb)
        
        if not encodings:
            return jsonify({'success': False, 'message': 'Wajah tidak terdeteksi. Pastikan wajah terlihat jelas'}), 400
        
        # Save encoding directly into users.json
        users_data = load_json_data(PATH_USERS)
        user_exists = any(u['nama'].lower() == nama.replace('_', ' ').lower() for u in users_data)
        user_data = None

        if user_exists:
            # Update existing user's encoding
            for u in users_data:
                if isinstance(u, dict) and u.get('nama','').lower() == nama.replace('_', ' ').lower():
                    u['encoding'] = encodings[0].tolist()
                    user_data = u
                    break
        else:
            user_data = {
                'id': f"M{str(uuid.uuid4())[:8]}",
                'nama': nama.replace('_', ' ').title(),
                'email': f"{nama}@student.kampus.id",
                'role': 'mahasiswa',
                'nim': nim,
                'encoding': encodings[0].tolist(),
                'created_at': datetime.now().isoformat()
            }
            users_data.append(user_data)

        save_json_data(PATH_USERS, users_data)

        # Reload known faces
        load_known_faces()

        return jsonify({
            'success': True,
            'message': f'Wajah {nama.replace("_", " ").title()} berhasil didaftarkan',
            'user_data': user_data
        })
    
    except Exception as e:
        return jsonify({'success': False, 'message': f'Error: {str(e)}'}), 500

@app.route('/api/recognize', methods=['POST'])
def recognize_face():
    try:
        data = request.json
        image_base64 = data.get('image')
        
        if not image_base64:
            return jsonify({'success': False, 'message': 'Gambar tidak ditemukan'}), 400
        
        # Convert base64 to image
        img = base64_to_image(image_base64)
        if img is None:
            return jsonify({'success': False, 'message': 'Format gambar tidak valid'}), 400
            
        rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        
        # Deteksi wajah
        lokasi = face_recognition.face_locations(rgb)
        encodings = face_recognition.face_encodings(rgb, lokasi)
        
        if not encodings:
            return jsonify({'success': False, 'message': 'Wajah tidak terdeteksi'})
        
        if len(encoded_known_faces) == 0:
            return jsonify({'success': False, 'message': 'Belum ada wajah terdaftar. Silakan daftar terlebih dahulu'})
        
        results = []
        for encode in encodings:
            hasil = face_recognition.compare_faces(encoded_known_faces, encode, tolerance=0.6)
            jarak = face_recognition.face_distance(encoded_known_faces, encode)
            
            if len(jarak) > 0:
                idx_match = np.argmin(jarak)
                if hasil[idx_match]:
                    nama = names[idx_match]
                    
                    # Cek absensi hari ini dari JSON
                    tanggal = datetime.now().strftime('%Y-%m-%d')
                    attendance_list = load_json_data(PATH_ATTENDANCE)
                    sudah_absen = any(
                        a['nama'].lower() == nama.replace('_', ' ').lower() and 
                        a['tanggal'] == tanggal 
                        for a in attendance_list
                    )
                    
                    if not sudah_absen:
                        # Catat absensi otomatis
                        attendance_data = {
                            'id': str(uuid.uuid4()),
                            'nama': nama.replace('_', ' ').title(),
                            'tanggal': tanggal,
                            'waktu': datetime.now().strftime('%H:%M:%S'),
                            'status': 'hadir',
                            'type': 'direct'
                        }
                        attendance_list.append(attendance_data)
                        save_json_data(PATH_ATTENDANCE, attendance_list)
                    
                    results.append({
                        'nama': nama.replace("_", " ").title(),
                        'sudah_absen': sudah_absen,
                        'confidence': float(1 - jarak[idx_match])
                    })
        
        if results:
            return jsonify({'success': True, 'data': results})
        else:
            return jsonify({'success': False, 'message': 'Wajah tidak dikenali. Silakan daftar terlebih dahulu'})
    
    except Exception as e:
        return jsonify({'success': False, 'message': f'Error: {str(e)}'}), 500

@app.route('/api/attendance', methods=['GET'])
def get_attendance():
    try:
        date_filter = request.args.get('date', datetime.now().strftime('%Y-%m-%d'))
        mata_kuliah = request.args.get('mata_kuliah')
        
        attendance_list = load_json_data(PATH_ATTENDANCE)
        
        filtered_attendance = []
        for item in attendance_list:
            if date_filter == 'all' or item.get('tanggal') == date_filter:
                if not mata_kuliah or item.get('mata_kuliah') == mata_kuliah:
                    filtered_attendance.append(item)
        
        # Sort by time (newest first)
        filtered_attendance.sort(key=lambda x: x.get('waktu', ''), reverse=True)
        
        return jsonify({'success': True, 'data': filtered_attendance})
    
    except Exception as e:
        return jsonify({'success': False, 'message': f'Error: {str(e)}'}), 500

@app.route('/api/users', methods=['GET'])
def get_users():
    try:
        role = request.args.get('role', '')
        users_data = load_json_data(PATH_USERS)
        
        if role:
            filtered_users = [u for u in users_data if u['role'] == role]
        else:
            filtered_users = users_data
        
        return jsonify({'success': True, 'data': filtered_users})
    except Exception as e:
        return jsonify({'success': False, 'message': f'Error: {str(e)}'}), 500

@app.route('/api/stats', methods=['GET'])
def get_stats():
    try:
        total_users = len(set(names))
        users_data = load_json_data(PATH_USERS)
        attendance_list = load_json_data(PATH_ATTENDANCE)
        
        # Count today's attendance
        tanggal = datetime.now().strftime('%Y-%m-%d')
        today_count = len([a for a in attendance_list if a.get('tanggal') == tanggal])
        
        # Count by role
        mahasiswa_count = len([u for u in users_data if u['role'] == 'mahasiswa'])
        dosen_count = len(PREREGISTERED_DOSEN)
        
        return jsonify({
            'success': True,
            'data': {
                'total_users': total_users,
                'today_attendance': today_count,
                'mahasiswa_count': mahasiswa_count,
                'dosen_count': dosen_count,
                'date': tanggal
            }
        })
    except Exception as e:
        return jsonify({'success': False, 'message': f'Error: {str(e)}'}), 500

if __name__ == '__main__':
    print("=" * 50)
    print("SISTEM ABSENSI WAJAH DENGAN ROLE - BACKEND SERVER")
    print("=" * 50)
    initialize_data()
    load_known_faces()
    print(f"\nServer siap di: http://10.91.229.67:5000")
    print(f"Total wajah terdaftar: {len(set(names))}")
    print(f"Dosen terdaftar: {len(PREREGISTERED_DOSEN)}")
    print("Login Dosen:")
    for email, data in PREREGISTERED_DOSEN.items():
        print(f"   Email: {email} | Password: {data['password']}")
    print("=" * 50 + "\n")
    app.run(host='0.0.0.0', port=5000, debug=True)