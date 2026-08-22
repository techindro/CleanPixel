# CleanPixel: Image & Video Watermark Remover

CleanPixel is a Python-powered computer vision application designed to seamlessly remove watermarks, logos, and text overlays from both static images and video streams. By leveraging advanced image inpainting techniques, it reconstructs missing pixel data to restore your media without degrading background quality.

## 🚀 Features
* **Multi-Format Support:** Works flawlessly on high-resolution images and videos.
* **Intelligent Inpainting:** Utilizes OpenCV algorithms (`Fast Martching` / `Navier-Stokes`) for seamless blending.
* **Frame-by-Frame Video Processing:** Extracts frames, applies masks, removes watermarks, and re-stitches videos.
* **Interactive UI (Planned):** A lightweight web interface built with Streamlit for quick drag-and-drop cleaning.

## 🛠️ Tech Stack
* **Language:** Python 3.10+
* **Libraries:** OpenCV (`cv2`), NumPy, Streamlit (for UI)
* **Video Handling:** FFmpeg / MoviePy (for audio retention)

## 📦 Installation & Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com
   cd CleanPixel
   ```

2. **Install required dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

## 💻 Usage

### 1. Removing Watermark from an Image
Run the script by providing the path to your source image and a binary mask image (where the watermark area is highlighted in solid white, and the rest is black):

```python
from src.cleaner import remove_watermark

remove_watermark(
    image_path="input.jpg", 
    mask_path="mask.jpg", 
    output_path="cleaned_output.jpg"
)
```

### 2. Processing a Video (Coming Soon)
The pipeline will break down video files frame-by-frame, apply static/dynamic masks, and rebuild the video file.

## 🗺️ Roadmap
- [x] Core image inpainting algorithm using OpenCV.
- [ ] Frame-by-frame video processing script.
- [ ] Streamlit web dashboard with a canvas brush tool to draw masks manually.
- [ ] Integration of Deep Learning models (e.g., GANs / LaMa Inpainting) for automated watermark detection.

## 📄 License
This project is licensed under the MIT License - see the LICENSE file for details.

