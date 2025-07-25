from fastapi import APIRouter, HTTPException, status, UploadFile, File, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from typing import List
from datetime import datetime
import uuid
import os

from post.models.post import (
    PostCreate, PostUpdate, PostListResponse, PostDetailResponse,
    PostCreateResponse, PostUpdateResponse, PostDeleteResponse, PostStatus,
    ImageUploadResponse, ImageDeleteResponse, ImageInfo
)
from post.utils.image_utils import image_utils
from auth_utils import verify_token
from database import posts as posts_collection

router = APIRouter(tags=["posts"])
security = HTTPBearer()

async def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security)):
    """현재 인증된 사용자 정보를 가져옵니다"""
    try:
        payload = verify_token(credentials.credentials)
        user_id = payload.get("user_id")
        if user_id is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="유효하지 않은 토큰입니다"
            )
        return user_id
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="인증에 실패했습니다"
        )

@router.post("/", response_model=PostCreateResponse, status_code=status.HTTP_201_CREATED)
async def create_post(post_data: PostCreate, current_user_id: int = Depends(get_current_user)):
    """일기 작성"""
    try:
        collection = posts_collection
        
        # 새로운 일기 ID 생성
        post_id = str(uuid.uuid4())
        
        # 현재 시간
        current_time = datetime.now()
        
        # 이미지 처리
        images_info = []
        if post_data.images:
            for temp_filename in post_data.images:
                try:
                    # 임시 파일을 정식 업로드 폴더로 이동
                    permanent_filename = image_utils.move_temp_to_permanent(temp_filename, post_id)
                    
                    # 이미지 정보 저장
                    file_info = image_utils.get_file_info(permanent_filename)
                    images_info.append({
                        "filename": permanent_filename,
                        "original_filename": temp_filename,
                        "file_path": os.path.join("uploads/images", permanent_filename),
                        "file_size": file_info["file_size"] if file_info else 0,
                        "upload_date": current_time
                    })
                except HTTPException:
                    # 임시 파일 이동 실패 시 다른 임시 파일들 정리
                    for temp_file in post_data.images:
                        image_utils.delete_temp_file(temp_file)
                    raise
        
        # 일기 데이터 저장 (사용자 ID 추가)
        new_post = {
            "post_id": post_id,
            "user_id": current_user_id,  # 사용자 ID 추가
            "content": post_data.content,
            "status": post_data.status,
            "images": images_info,
            "created_at": current_time
        }
        
        # MongoDB 문서 생성 및 저장
        result = collection.insert_one(new_post)
        
        if not result.inserted_id:
            # 저장 실패 시 업로드된 이미지들 삭제
            for img_info in images_info:
                image_utils.delete_permanent_file(img_info["filename"])
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="일기 저장에 실패했습니다"
            )
        
        return PostCreateResponse(
            message="일기가 성공적으로 작성되었습니다",
            post_id=post_id
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"일기 작성 중 오류가 발생했습니다: {str(e)}"
        )

@router.get("/", response_model=List[PostListResponse])
async def get_posts(current_user_id: int = Depends(get_current_user)):
    """사용자별 일기 목록 조회"""
    try:
        collection = posts_collection
        
        # 현재 사용자의 삭제되지 않은 일기만 조회
        query = {
            "user_id": current_user_id,
            "status": {"$ne": PostStatus.DELETED}
        }
        cursor = collection.find(query).sort("created_at", -1)
        
        posts = []
        for doc in cursor:
            # 이미지 정보 변환
            images = []
            for img_data in doc.get("images", []):
                images.append(ImageInfo(
                    filename=img_data["filename"],
                    original_filename=img_data["original_filename"],
                    file_path=img_data["file_path"],
                    file_size=img_data["file_size"],
                    upload_date=img_data["upload_date"]
                ))
            
            posts.append(PostListResponse(
                id=doc["post_id"],
                content=doc["content"],
                status=doc["status"],
                created_at=doc["created_at"],
                images=images
            ))
        
        return posts
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"일기 목록 조회 중 오류가 발생했습니다: {str(e)}"
        )

@router.get("/{post_id}", response_model=PostDetailResponse)
async def get_post_detail(post_id: str, current_user_id: int = Depends(get_current_user)):
    """일기 상세 조회 (본인의 일기만 조회 가능)"""
    try:
        collection = posts_collection
        
        # 본인의 일기만 조회
        post_doc = collection.find_one({
            "post_id": post_id,
            "user_id": current_user_id
        })
        if not post_doc:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="해당 일기를 찾을 수 없습니다"
            )
        
        # 삭제된 일기는 조회 불가
        if post_doc["status"] == PostStatus.DELETED:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="해당 일기를 찾을 수 없습니다"
            )
        
        # 이미지 정보 변환
        images = []
        for img_data in post_doc.get("images", []):
            images.append(ImageInfo(
                filename=img_data["filename"],
                original_filename=img_data["original_filename"],
                file_path=img_data["file_path"],
                file_size=img_data["file_size"],
                upload_date=img_data["upload_date"]
            ))
        
        return PostDetailResponse(
            id=post_doc["post_id"],
            content=post_doc["content"],
            status=post_doc["status"],
            created_at=post_doc["created_at"],
            images=images
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"일기 조회 중 오류가 발생했습니다: {str(e)}"
        )

@router.put("/{post_id}", response_model=PostUpdateResponse)
async def update_post(post_id: str, post_data: PostUpdate, current_user_id: int = Depends(get_current_user)):
    """일기 수정 (본인의 일기만 수정 가능)"""
    try:
        collection = posts_collection
        
        # 본인의 일기 존재 여부 확인
        existing_post = collection.find_one({
            "post_id": post_id,
            "user_id": current_user_id
        })
        if not existing_post:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="해당 일기를 찾을 수 없습니다"
            )
        
        # 삭제된 일기는 수정 불가
        if existing_post["status"] == PostStatus.DELETED:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="해당 일기를 찾을 수 없습니다"
            )
        
        # 변경된 필드만 업데이트
        update_data = post_data.dict(exclude_unset=True)
        
        result = collection.update_one(
            {"post_id": post_id, "user_id": current_user_id},
            {"$set": update_data}
        )
        
        if result.modified_count == 0:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="일기 수정에 실패했습니다"
            )
        
        return PostUpdateResponse(
            message="일기가 성공적으로 수정되었습니다",
            post_id=post_id
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"일기 수정 중 오류가 발생했습니다: {str(e)}"
        )

@router.delete("/{post_id}", response_model=PostDeleteResponse)
async def delete_post(post_id: str, current_user_id: int = Depends(get_current_user)):
    """일기 삭제 (본인의 일기만 삭제 가능)"""
    try:
        collection = posts_collection
        
        # 본인의 일기 존재 여부 확인
        existing_post = collection.find_one({
            "post_id": post_id,
            "user_id": current_user_id
        })
        if not existing_post:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="해당 일기를 찾을 수 없습니다"
            )
        
        # 이미 삭제된 일기인지 확인
        if existing_post["status"] == PostStatus.DELETED:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="해당 일기를 찾을 수 없습니다"
            )
        
        # 소프트 삭제 (상태만 변경)
        result = collection.update_one(
            {"post_id": post_id, "user_id": current_user_id},
            {"$set": {
                "status": PostStatus.DELETED
            }}
        )
        
        if result.modified_count == 0:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="일기 삭제에 실패했습니다"
            )
        
        return PostDeleteResponse(
            message="일기가 성공적으로 삭제되었습니다",
            post_id=post_id
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"일기 삭제 중 오류가 발생했습니다: {str(e)}"
        )

@router.get("/date/{date}", response_model=List[PostListResponse])
async def get_posts_by_date(date: str, current_user_id: int = Depends(get_current_user)):
    """특정 날짜의 사용자별 일기 목록 조회"""
    try:
        collection = posts_collection
        
        # 날짜 형식 검증 (YYYY-MM-DD)
        try:
            datetime.strptime(date, "%Y-%m-%d")
        except ValueError:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="잘못된 날짜 형식입니다. YYYY-MM-DD 형식이어야 합니다."
            )
        
        # 해당 날짜의 현재 사용자의 게시된 일기만 조회
        query = {
            "user_id": current_user_id,
            "created_at": {
                "$gte": datetime.strptime(f"{date} 00:00:00", "%Y-%m-%d %H:%M:%S"),
                "$lt": datetime.strptime(f"{date} 23:59:59", "%Y-%m-%d %H:%M:%S")
            },
            "status": {"$ne": PostStatus.DELETED}
        }
        
        cursor = collection.find(query).sort("created_at", -1)
        
        posts = []
        for doc in cursor:
            # 이미지 정보 변환
            images = []
            for img_data in doc.get("images", []):
                images.append(ImageInfo(
                    filename=img_data["filename"],
                    original_filename=img_data["original_filename"],
                    file_path=img_data["file_path"],
                    file_size=img_data["file_size"],
                    upload_date=img_data["upload_date"]
                ))
            
            posts.append(PostListResponse(
                id=doc["post_id"],
                content=doc["content"],
                status=doc["status"],
                created_at=doc["created_at"],
                images=images
            ))
        
        return posts
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"일기 목록 조회 중 오류가 발생했습니다: {str(e)}"
        )

@router.get("/health", status_code=status.HTTP_200_OK)
async def health_check():
    """헬스 체크"""
    try:
        collection = posts_collection
        
        total_posts = collection.count_documents({})
        published_posts = collection.count_documents({"status": PostStatus.PUBLISHED})
        
        return {
            "status": "healthy", 
            "database": "connected",
            "total_posts": total_posts,
            "published_posts": published_posts
        }
    except Exception as e:
        return {
            "status": "unhealthy", 
            "database": "disconnected",
            "error": str(e)
        } 