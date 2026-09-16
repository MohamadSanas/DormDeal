import cloudinary
import cloudinary.uploader
from app.database.connection import settings
import logging

logger = logging.getLogger(__name__)

# Configure Cloudinary if keys are provided in environment
if settings.CLOUDINARY_CLOUD_NAME and settings.CLOUDINARY_API_KEY:
    cloudinary.config(
        cloud_name=settings.CLOUDINARY_CLOUD_NAME,
        api_key=settings.CLOUDINARY_API_KEY,
        api_secret=settings.CLOUDINARY_API_SECRET
    )

def upload_image(file_data) -> str | None:
    try:
        if not settings.CLOUDINARY_CLOUD_NAME:
            logger.warning("Cloudinary not configured. Skipping upload.")
            return None
            
        result = cloudinary.uploader.upload(file_data)
        return result.get('secure_url')
    except Exception as e:
        logger.error(f"Error uploading to cloudinary: {e}")
        return None
