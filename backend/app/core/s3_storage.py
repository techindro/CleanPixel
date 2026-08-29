import boto3
from botocore.exceptions import NoCredentialsError
import os
from pathlib import Path
from app.core.config import settings

class S3StorageService:
    """
    AWS S3 Cloud Storage Manager for CleanPixel source & cleaned media.
    """
    def __init__(self):
        self.bucket_name = getattr(settings, 'AWS_S3_BUCKET_NAME', os.getenv('AWS_S3_BUCKET_NAME', 'cleanpixel-assets'))
        self.s3_client = boto3.client(
            's3',
            aws_access_key_id=os.getenv('AWS_ACCESS_KEY_ID'),
            aws_secret_access_key=os.getenv('AWS_SECRET_ACCESS_KEY'),
            region_name=os.getenv('AWS_REGION', 'us-east-1')
        )

    def upload_file(self, local_file_path: str, s3_key: str) -> str:
        """Uploads a local file to S3 and returns its public or presigned URL."""
        try:
            self.s3_client.upload_file(local_file_path, self.bucket_name, s3_key)
            return f"https://{self.bucket_name}.s3.amazonaws.com/{s3_key}"
        except NoCredentialsError:
            print("AWS credentials not configured. Using local storage fallback.")
            return local_file_path
        except Exception as e:
            print(f"Failed to upload {local_file_path} to S3: {e}")
            return local_file_path

    def download_file(self, s3_key: str, local_destination_path: str) -> bool:
        """Downloads a file from S3 to local storage."""
        try:
            os.makedirs(os.path.dirname(local_destination_path), exist_ok=True)
            self.s3_client.download_file(self.bucket_name, s3_key, local_destination_path)
            return True
        except Exception as e:
            print(f"Failed to download {s3_key} from S3: {e}")
            return False

s3_service = S3StorageService()
