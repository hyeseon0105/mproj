from flask import Flask, request, jsonify
from flask_cors import CORS
import os
from dotenv import load_dotenv
import httpx
import tempfile
import uuid
from datetime import datetime
import logging

# 환경 변수 로드
load_dotenv()

app = Flask(__name__)
CORS(app)

# OpenAI API 설정
api_key = os.getenv('OPENAI_API_KEY')
if not api_key:
    raise ValueError("OPENAI_API_KEY 환경 변수가 설정되지 않았습니다.")

# 로깅 설정
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# 허용된 오디오 포맷
ALLOWED_EXTENSIONS = {'mp3', 'wav', 'm4a', 'ogg', 'flac'}
MAX_FILE_SIZE = 25 * 1024 * 1024  # 25MB

def allowed_file(filename):
    """파일 확장자 검증"""
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def transcribe_audio(audio_file_path, language='ko'):
    """OpenAI Whisper API를 사용하여 오디오를 텍스트로 변환"""
    try:
        headers = {
            "Authorization": f"Bearer {api_key}"
        }
        
        with open(audio_file_path, 'rb') as audio_file:
            files = {
                'file': audio_file,
                'model': (None, 'whisper-1'),
                'language': (None, language),
                'response_format': (None, 'verbose_json')
            }
            
            with httpx.Client() as client:
                response = client.post(
                    "https://api.openai.com/v1/audio/transcriptions",
                    headers=headers,
                    files=files,
                    timeout=60.0
                )
                response.raise_for_status()
                result = response.json()
                
        return {
            'success': True,
            'text': result.get('text', ''),
            'language': result.get('language', language),
            'duration': result.get('duration', 0),
            'segments': result.get('segments', [])
        }
        
    except Exception as e:
        logger.error(f"STT 변환 중 오류: {str(e)}")
        return {
            'success': False,
            'error': str(e)
        }

@app.route('/stt/transcribe', methods=['POST'])
def transcribe():
    """오디오 파일을 텍스트로 변환하는 엔드포인트"""
    try:
        # 파일 검증
        if 'audio' not in request.files:
            return jsonify({'error': '오디오 파일이 없습니다.'}), 400
        
        file = request.files['audio']
        if file.filename == '':
            return jsonify({'error': '파일이 선택되지 않았습니다.'}), 400
        
        if not allowed_file(file.filename):
            return jsonify({'error': f'지원하지 않는 파일 형식입니다. 지원 형식: {", ".join(ALLOWED_EXTENSIONS)}'}), 400
        
        # 파일 크기 검증
        file.seek(0, 2)  # 파일 끝으로 이동
        file_size = file.tell()
        file.seek(0)  # 파일 시작으로 복귀
        
        if file_size > MAX_FILE_SIZE:
            return jsonify({'error': f'파일 크기가 너무 큽니다. 최대 {MAX_FILE_SIZE // (1024*1024)}MB까지 지원합니다.'}), 400
        
        # 언어 설정 (기본값: 한국어)
        language = request.form.get('language', 'ko')
        
        # 임시 파일로 저장
        temp_dir = tempfile.gettempdir()
        temp_filename = f"stt_{uuid.uuid4()}_{file.filename}"
        temp_path = os.path.join(temp_dir, temp_filename)
        
        try:
            file.save(temp_path)
            logger.info(f"임시 파일 저장: {temp_path}")
            
            # STT 변환
            result = transcribe_audio(temp_path, language)
            
            if result['success']:
                return jsonify({
                    'success': True,
                    'text': result['text'],
                    'language': result['language'],
                    'duration': result['duration'],
                    'segments': result['segments'],
                    'timestamp': datetime.now().isoformat()
                })
            else:
                return jsonify({'error': result['error']}), 500
                
        finally:
            # 임시 파일 삭제
            if os.path.exists(temp_path):
                os.remove(temp_path)
                logger.info(f"임시 파일 삭제: {temp_path}")
    
    except Exception as e:
        logger.error(f"STT 엔드포인트 오류: {str(e)}")
        return jsonify({'error': '서버 내부 오류가 발생했습니다.'}), 500

@app.route('/stt/transcribe-chunk', methods=['POST'])
def transcribe_chunk():
    """오디오 청크를 텍스트로 변환하는 엔드포인트 (실시간용)"""
    try:
        # 파일 검증
        if 'audio' not in request.files:
            return jsonify({'error': '오디오 파일이 없습니다.'}), 400
        
        file = request.files['audio']
        if file.filename == '':
            return jsonify({'error': '파일이 선택되지 않았습니다.'}), 400
        
        if not allowed_file(file.filename):
            return jsonify({'error': f'지원하지 않는 파일 형식입니다. 지원 형식: {", ".join(ALLOWED_EXTENSIONS)}'}), 400
        
        # 언어 설정 (기본값: 한국어)
        language = request.form.get('language', 'ko')
        
        # 임시 파일로 저장
        temp_dir = tempfile.gettempdir()
        temp_filename = f"stt_chunk_{uuid.uuid4()}_{file.filename}"
        temp_path = os.path.join(temp_dir, temp_filename)
        
        try:
            file.save(temp_path)
            logger.info(f"임시 청크 파일 저장: {temp_path}")
            
            # STT 변환 (청크용 - 더 빠른 응답)
            result = transcribe_audio(temp_path, language)
            
            if result['success']:
                return jsonify({
                    'success': True,
                    'text': result['text'],
                    'language': result['language'],
                    'duration': result['duration'],
                    'is_chunk': True,
                    'timestamp': datetime.now().isoformat()
                })
            else:
                return jsonify({'error': result['error']}), 500
                
        finally:
            # 임시 파일 삭제
            if os.path.exists(temp_path):
                os.remove(temp_path)
                logger.info(f"임시 청크 파일 삭제: {temp_path}")
    
    except Exception as e:
        logger.error(f"STT 청크 엔드포인트 오류: {str(e)}")
        return jsonify({'error': '서버 내부 오류가 발생했습니다.'}), 500

@app.route('/stt/health', methods=['GET'])
def health_check():
    """서비스 상태 확인"""
    return jsonify({
        'status': 'healthy',
        'service': 'STT Service',
        'timestamp': datetime.now().isoformat(),
        'supported_formats': list(ALLOWED_EXTENSIONS),
        'max_file_size_mb': MAX_FILE_SIZE // (1024*1024)
    })

@app.route('/stt/supported-languages', methods=['GET'])
def supported_languages():
    """지원하는 언어 목록"""
    return jsonify({
        'languages': {
            'ko': '한국어',
            'en': 'English',
            'ja': '日本語',
            'zh': '中文',
            'es': 'Español',
            'fr': 'Français',
            'de': 'Deutsch',
            'it': 'Italiano',
            'pt': 'Português',
            'ru': 'Русский'
        }
    })

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5001) 