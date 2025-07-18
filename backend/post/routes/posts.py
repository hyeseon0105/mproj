"""
포스트 관련 API 라우터
"""
from fastapi import APIRouter, HTTPException, UploadFile, File, Form, Query
from fastapi.responses import JSONResponse
from typing import List, Optional
import os

from ..models.post import (
    PostCreate, PostUpdate, PostListResponse, PostDetailResponse,
    PostCreateResponse, PostUpdateResponse, PostDeleteResponse,
    ImageUploadResponse, ImageDeleteResponse
)
from ..database.mongodb import (
    create_post, get_posts, get_post_by_id, update_post, delete_post
)
from ..utils.image_utils import (
    save_temp_image, move_temp_to_permanent, delete_temp_file,
    delete_permanent_file, get_image_info, validate_images_list
)

router = APIRouter()

# =====================================
# 포스트 CRUD API
# =====================================

@router.post("/posts/", response_model=PostCreateResponse)
async def create_new_post(post: PostCreate):
    """새 글 생성"""
    try:
        # 이미지 검증 및 처리
        valid_images = validate_images_list(post.images or [])
        
        # 글 데이터 준비
        post_data = {
            "title": post.title,
            "content": post.content,
            "status": post.status,
            "images": []
        }
        
        # 데이터베이스에 글 생성
        post_id = create_post(post_data)
        
        # 임시 이미지들을 영구 저장소로 이동
        permanent_images = []
        for temp_filename in valid_images:
            try:
                permanent_path = move_temp_to_permanent(temp_filename)
                # 파일 정보 생성
                file_size = os.path.getsize(permanent_path)
                original_filename = temp_filename  # 실제로는 원본 파일명을 별도로 저장해야 함
                image_info = get_image_info(temp_filename, file_size, original_filename)
                permanent_images.append(image_info)
            except Exception as e:
                print(f"이미지 이동 실패: {temp_filename}, 오류: {str(e)}")
        
        # 이미지 정보를 데이터베이스에 업데이트
        if permanent_images:
            update_post(post_id, {"images": permanent_images})
        
        return PostCreateResponse(
            message="글이 성공적으로 생성되었습니다",
            post_id=post_id
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"글 생성 중 오류가 발생했습니다: {str(e)}")

@router.get("/posts/", response_model=List[PostListResponse])
async def get_post_list(
    status: str = Query(default="published", description="글 상태"),
    skip: int = Query(default=0, ge=0, description="건너뛸 글 수"),
    limit: int = Query(default=10, ge=1, le=100, description="가져올 글 수")
):
    """글 목록 조회 (최신순)"""
    try:
        posts = get_posts(status=status, skip=skip, limit=limit)
        
        # 응답 모델에 맞게 변환
        result = []
        for post in posts:
            result.append(PostListResponse(
                id=post["id"],
                title=post["title"],
                status=post["status"],
                created_at=post["created_at"],
                updated_at=post["updated_at"],
                images=post.get("images", [])
            ))
        
        return result
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"글 목록 조회 중 오류가 발생했습니다: {str(e)}")

@router.get("/posts/{post_id}", response_model=PostDetailResponse)
async def get_post_detail(post_id: str):
    """특정 글 상세 조회"""
    post = get_post_by_id(post_id)
    
    if not post:
        raise HTTPException(status_code=404, detail="글을 찾을 수 없습니다")
    
    return PostDetailResponse(
        id=post["id"],
        title=post["title"],
        content=post["content"],
        status=post["status"],
        created_at=post["created_at"],
        updated_at=post["updated_at"],
        images=post.get("images", [])
    )

@router.put("/posts/{post_id}", response_model=PostUpdateResponse)
async def update_existing_post(post_id: str, post_update: PostUpdate):
    """글 수정"""
    # 글 존재 확인
    existing_post = get_post_by_id(post_id)
    if not existing_post:
        raise HTTPException(status_code=404, detail="글을 찾을 수 없습니다")
    
    try:
        # 수정할 데이터 준비
        update_data = {}
        
        if post_update.title is not None:
            update_data["title"] = post_update.title
        if post_update.content is not None:
            update_data["content"] = post_update.content
        if post_update.status is not None:
            update_data["status"] = post_update.status
        
        # 이미지 업데이트 처리
        if post_update.images is not None:
            valid_images = validate_images_list(post_update.images)
            
            # 기존 이미지들 삭제
            for image_info in existing_post.get("images", []):
                delete_permanent_file(image_info.get("filename", ""))
            
            # 새 이미지들 처리
            permanent_images = []
            for temp_filename in valid_images:
                try:
                    permanent_path = move_temp_to_permanent(temp_filename)
                    file_size = os.path.getsize(permanent_path)
                    original_filename = temp_filename
                    image_info = get_image_info(temp_filename, file_size, original_filename)
                    permanent_images.append(image_info)
                except Exception as e:
                    print(f"이미지 이동 실패: {temp_filename}, 오류: {str(e)}")
            
            update_data["images"] = permanent_images
        
        # 데이터베이스 업데이트
        success = update_post(post_id, update_data)
        
        if not success:
            raise HTTPException(status_code=500, detail="글 수정에 실패했습니다")
        
        return PostUpdateResponse(
            message="글이 성공적으로 수정되었습니다",
            post_id=post_id
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"글 수정 중 오류가 발생했습니다: {str(e)}")

@router.delete("/posts/{post_id}", response_model=PostDeleteResponse)
async def delete_existing_post(post_id: str):
    """글 삭제 (상태 변경)"""
    # 글 존재 확인
    existing_post = get_post_by_id(post_id)
    if not existing_post:
        raise HTTPException(status_code=404, detail="글을 찾을 수 없습니다")
    
    try:
        # 글 상태를 'deleted'로 변경
        success = delete_post(post_id)
        
        if not success:
            raise HTTPException(status_code=500, detail="글 삭제에 실패했습니다")
        
        return PostDeleteResponse(
            message="글이 성공적으로 삭제되었습니다",
            post_id=post_id
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"글 삭제 중 오류가 발생했습니다: {str(e)}")

# =====================================
# 이미지 업로드 API
# =====================================

@router.post("/posts/images/upload", response_model=ImageUploadResponse)
async def upload_temp_image(file: UploadFile = File(...)):
    """임시 이미지 업로드"""
    try:
        filename, file_size = await save_temp_image(file)
        
        return ImageUploadResponse(
            message="이미지가 성공적으로 업로드되었습니다",
            filename=filename,
            file_size=file_size
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"이미지 업로드 중 오류가 발생했습니다: {str(e)}")

@router.delete("/posts/images/temp/{filename}", response_model=ImageDeleteResponse)
async def delete_temp_image(filename: str):
    """임시 이미지 삭제"""
    try:
        success = delete_temp_file(filename)
        
        if not success:
            raise HTTPException(status_code=404, detail="파일을 찾을 수 없습니다")
        
        return ImageDeleteResponse(
            message="임시 이미지가 성공적으로 삭제되었습니다",
            filename=filename
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"이미지 삭제 중 오류가 발생했습니다: {str(e)}")

# =====================================
# 헬스 체크 API
# =====================================

@router.get("/posts/health")
async def posts_health_check():
    """포스트 서비스 상태 확인"""
    try:
        # 데이터베이스 연결 테스트
        test_posts = get_posts(limit=1)
        
        return {
            "status": "healthy",
            "message": "포스트 서비스가 정상적으로 작동 중입니다",
            "database": "connected"
        }
        
    except Exception as e:
        return JSONResponse(
            status_code=503,
            content={
                "status": "unhealthy",
                "message": "포스트 서비스에 문제가 있습니다",
                "error": str(e)
            }
        ) 