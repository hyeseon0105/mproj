from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from routes.auth import router as auth_router
<<<<<<< HEAD
from post.routes.posts import router as posts_router
from post.database.mongodb import init_mongodb
=======
from routes.user_settings import router as user_settings_router
from post.routes.posts import router as posts_router
>>>>>>> origin/main
import os
# from routes.asr import router as asr_router

app = FastAPI(
    title="AI Mini Implementation - 통합 API",
    description="인증 시스템과 포스트 시스템을 통합한 FastAPI 애플리케이션",
    version="1.0.0"
)

# CORS 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 실제 운영환경에서는 구체적인 도메인을 지정해야 합니다
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 정적 파일 서빙 설정
if os.path.exists("uploads"):
    app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")

# 라우터 등록
app.include_router(auth_router, prefix="/api/auth", tags=["auth"])
<<<<<<< HEAD
=======
app.include_router(user_settings_router, prefix="/api/user-settings", tags=["user-settings"])
>>>>>>> origin/main
app.include_router(posts_router, prefix="/api/posts", tags=["posts"])
# app.include_router(asr_router, prefix="/api", tags=["asr"])

# 애플리케이션 시작 시 실행
@app.on_event("startup")
async def startup_event():
    """애플리케이션 시작 시 초기화"""
    print("애플리케이션이 시작됩니다...")
    
    # 업로드 디렉토리 생성
    upload_dirs = ["uploads/images", "uploads/temp"]
    for directory in upload_dirs:
        os.makedirs(directory, exist_ok=True)
        print(f"[OK] 업로드 디렉토리 생성: {directory}")
    
<<<<<<< HEAD
    # MongoDB 초기화
    success = init_mongodb()
    if success:
        print("[OK] MongoDB 연결 성공")
    else:
        print("[WARNING] MongoDB 연결 실패 - 일부 기능이 제한될 수 있습니다")
=======
    # mini-project 데이터베이스 사용 (database.py에서 설정됨)
    print("[OK] mini-project 데이터베이스 사용")
>>>>>>> origin/main

# 루트 경로
@app.get("/")
async def root():
    """루트 경로 - API 정보 반환"""
    return {
        "message": "AI Mini Implementation API에 오신 것을 환영합니다",
        "version": "1.0.0",
<<<<<<< HEAD
        "features": ["인증 시스템", "포스트 시스템", "이미지 업로드"],
=======
        "features": ["인증 시스템", "포스트 시스템", "이미지 업로드", "사용자 설정"],
>>>>>>> origin/main
        "docs": "/docs",
        "redoc": "/redoc"
    }

# 헬스 체크 엔드포인트
@app.get("/health")
async def health_check():
    """애플리케이션 상태 확인"""
    return {
        "status": "healthy", 
        "message": "API가 정상적으로 동작 중입니다",
        "services": {
            "auth": "available",
<<<<<<< HEAD
            "posts": "available"
=======
            "posts": "available",
            "user-settings": "available"
>>>>>>> origin/main
        }
    }



