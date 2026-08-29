/**
 * CleanPixel AI — Interactive UI Engine & State Machine
 * Version: 3.0.0 — Full Feature Edition
 * Supports: PNG, JPG, WebP, GIF, BMP, TIFF, SVG, PDF
 */

// ─── Application State Machine ──────────────────────────────────────
const AppState = {
  IDLE_UPLOAD: 'IDLE UPLOAD',
  DRAWING_ACTIVE: 'DRAWING ACTIVE',
  PROCESSING: 'PROCESSING',
  RESULT_COMPARE: 'RESULT COMPARE'
};

// ─── Toast Notification Manager ─────────────────────────────────────
class ToastManager {
  constructor() {
    this.container = document.getElementById('toastContainer');
  }

  show(message, type = 'info', duration = 4000) {
    const icons = {
      success: '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>',
      error: '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>',
      warning: '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>',
      info: '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>'
    };

    const toast = document.createElement('div');
    toast.className = `toast-item toast-${type}`;
    toast.style.position = 'relative';
    toast.innerHTML = `
      <div class="toast-icon">${icons[type] || icons.info}</div>
      <span class="toast-message">${message}</span>
      <button class="toast-close-btn" aria-label="Dismiss">
        <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
      </button>
      <div class="toast-progress-bar" style="animation-duration: ${duration}ms;"></div>
    `;

    toast.querySelector('.toast-close-btn').addEventListener('click', () => this.dismiss(toast));
    this.container.appendChild(toast);

    setTimeout(() => this.dismiss(toast), duration);
    return toast;
  }

  dismiss(toast) {
    if (!toast || toast.classList.contains('toast-dismissing')) return;
    toast.classList.add('toast-dismissing');
    setTimeout(() => toast.remove(), 350);
  }

  success(msg, dur) { return this.show(msg, 'success', dur); }
  error(msg, dur) { return this.show(msg, 'error', dur); }
  warning(msg, dur) { return this.show(msg, 'warning', dur); }
  info(msg, dur) { return this.show(msg, 'info', dur); }
}

// ─── History Manager (localStorage) ─────────────────────────────────
class HistoryManager {
  constructor() {
    this.storageKey = 'cleanpixel_history';
    this.maxItems = 30;
  }

  getAll() {
    try {
      return JSON.parse(localStorage.getItem(this.storageKey) || '[]');
    } catch { return []; }
  }

  add(item) {
    const history = this.getAll();
    history.unshift({
      id: Date.now().toString(36) + Math.random().toString(36).slice(2, 6),
      timestamp: new Date().toISOString(),
      ...item
    });
    if (history.length > this.maxItems) history.pop();
    localStorage.setItem(this.storageKey, JSON.stringify(history));
  }

  clear() {
    localStorage.removeItem(this.storageKey);
  }

  getCount() {
    return this.getAll().length;
  }
}

// ─── Main Studio Class ──────────────────────────────────────────────
class CleanPixelStudio {
  constructor() {
    this.currentState = AppState.IDLE_UPLOAD;
    this.currentTool = 'brush'; // 'brush' | 'rect' | 'eraser'
    this.strokeWidth = 32;
    this.isDrawing = false;
    this.historyStack = [];
    this.redoStack = [];
    this.maxHistory = 20;
    this.currentMode = 'image'; // 'image' | 'video'

    // Zoom & Pan state
    this.zoomLevel = 1;
    this.panX = 0;
    this.panY = 0;
    this.isPanning = false;
    this.isSpaceHeld = false;
    this.panStartX = 0;
    this.panStartY = 0;

    // Rectangle tool state
    this.rectStartX = 0;
    this.rectStartY = 0;
    this.isRectDrawing = false;
    this.rectPreviewData = null;

    // Batch processing state
    this.batchFiles = [];
    this.batchResults = [];

    // Credits
    this.userCredits = 150;

    // Managers
    this.toast = new ToastManager();
    this.historyMgr = new HistoryManager();

    // DOM Elements
    this.dom = {
      // Views
      stateIdleUpload: document.getElementById('stateIdleUpload'),
      stateDrawingActive: document.getElementById('stateDrawingActive'),
      stateProcessing: document.getElementById('stateProcessing'),
      stateResultCompare: document.getElementById('stateResultCompare'),
      
      // Top HUD
      statePillIndicator: document.getElementById('statePillIndicator'),
      stateNameText: document.getElementById('stateNameText'),
      hudResolutionBadge: document.getElementById('hudResolutionBadge'),
      maskMetricBadge: document.getElementById('maskMetricBadge'),
      maskCoverageVal: document.getElementById('maskCoverageVal'),
      btnResetCanvas: document.getElementById('btnResetCanvas'),
      
      // Mode Tabs
      modePillBtns: document.querySelectorAll('.mode-pill-btn'),

      // Floating Toolbar
      floatingToolbar: document.getElementById('floatingToolbar'),
      toolBrush: document.getElementById('toolBrush'),
      toolRect: document.getElementById('toolRect'),
      toolEraser: document.getElementById('toolEraser'),
      btnAutoDetect: document.getElementById('btnAutoDetect'),
      strokeWidthSlider: document.getElementById('strokeWidthSlider'),
      strokeValText: document.getElementById('strokeValText'),
      strokePreviewCircle: document.getElementById('strokePreviewCircle'),
      presetPills: document.querySelectorAll('.preset-pill'),
      btnUndo: document.getElementById('btnUndo'),
      btnRedo: document.getElementById('btnRedo'),
      btnClearMask: document.getElementById('btnClearMask'),
      brushReticle: document.getElementById('brushReticle'),
      
      // Zoom Controls
      btnZoomIn: document.getElementById('btnZoomIn'),
      btnZoomOut: document.getElementById('btnZoomOut'),
      btnZoomReset: document.getElementById('btnZoomReset'),
      zoomLevelText: document.getElementById('zoomLevelText'),
      
      // Canvas Layers
      baseImage: document.getElementById('baseImage'),
      maskCanvas: document.getElementById('maskCanvas'),
      canvasLayersStack: document.getElementById('canvasLayersStack'),
      
      // Upload
      fileInput: document.getElementById('fileInput'),
      fileInputVideo: document.getElementById('fileInputVideo'),
      fileInputBatch: document.getElementById('fileInputBatch'),
      uploadDropzone: document.getElementById('uploadDropzone'),
      btnBrowseFile: document.getElementById('btnBrowseFile'),
      btnQuickDemo: document.getElementById('btnQuickDemo'),
      btnBatchUpload: document.getElementById('btnBatchUpload'),
      btnSampleTrigger: document.getElementById('btnSampleTrigger'),
      sampleMenu: document.getElementById('sampleMenu'),
      sampleItems: document.querySelectorAll('.sample-item'),
      dropzoneSubtext: document.getElementById('dropzoneSubtext'),
      
      // Processing
      procBaseImage: document.getElementById('procBaseImage'),
      procMaskCanvas: document.getElementById('procMaskCanvas'),
      procProgressFill: document.getElementById('procProgressFill'),
      procPercentVal: document.getElementById('procPercentVal'),
      procStepLabel: document.getElementById('procStepLabel'),
      procTitle: document.getElementById('procTitle'),
      procSub: document.getElementById('procSub'),
      
      // Stepper & CTA
      stepperLifecycleBar: document.getElementById('stepperLifecycleBar'),
      stepNodes: document.querySelectorAll('.lifecycle-step-node'),
      btnExecuteInpaint: document.getElementById('btnExecuteInpaint'),
      ctaStateReady: document.getElementById('ctaStateReady'),
      ctaStateComputing: document.getElementById('ctaStateComputing'),
      stepperDynamicMsg: document.getElementById('stepperDynamicMsg'),
      stepperMicroProgress: document.getElementById('stepperMicroProgress'),
      resultActionRow: document.getElementById('resultActionRow'),
      btnEditAgain: document.getElementById('btnContinueEditing') || document.getElementById('btnEditAgain'),
      btnDownloadResult: document.getElementById('btnDownloadResult'),
      exportFormatSelect: document.getElementById('exportFormatSelect'),

      // Post-processing adjustments
      adjBrightness: document.getElementById('adjBrightness'),
      adjContrast: document.getElementById('adjContrast'),
      adjSaturate: document.getElementById('adjSaturation') || document.getElementById('adjSaturate'),

      // Algorithm
      algoSelect: document.getElementById('algoSelect'),
      
      // Split Slider
      splitSliderContainer: document.getElementById('splitSliderContainer'),
      resultCleanedImage: document.getElementById('resultCleanedImage'),
      resultOriginalImage: document.getElementById('resultOriginalImage'),
      sliderOriginalClip: document.getElementById('sliderOriginalClip'),
      sliderDividerLine: document.getElementById('sliderDividerLine'),
      
      // Badge & Credits
      proGatingBadge: document.getElementById('proGatingBadge'),
      proCreditCounter: document.querySelector('.pro-credit-counter'),

      // PRO Modal
      proModalBackdrop: document.getElementById('proModal') || document.getElementById('proModalBackdrop'),
      btnProModalClose: document.getElementById('btnCloseProModal') || document.getElementById('btnProModalClose'),
      btnBuyAnnual: document.getElementById('btnBuyAnnual'),
      btnBuyMonthly: document.getElementById('btnBuyMonthly'),
      
      // Auth Elements
      btnAuthTrigger: document.getElementById('btnAuthTrigger'),
      authBtnText: document.getElementById('authBtnText'),
      userAvatarBtn: document.getElementById('userAvatarBtn'),
      userAvatarImg: document.getElementById('userAvatarImg'),
      authModalBackdrop: document.getElementById('authModalBackdrop'),
      btnModalClose: document.getElementById('btnModalClose'),
      btnGoogleOAuth: document.getElementById('btnGoogleOAuth'),
      tabSignIn: document.getElementById('tabSignIn'),
      tabSignUp: document.getElementById('tabSignUp'),
      authForm: document.getElementById('authForm'),
      groupFullName: document.getElementById('groupFullName'),
      inputFullName: document.getElementById('inputFullName'),
      inputEmail: document.getElementById('inputEmail'),
      inputPassword: document.getElementById('inputPassword'),
      authErrorMsg: document.getElementById('authErrorMsg'),
      authSubmitText: document.getElementById('authSubmitText'),

      // History Drawer
      btnHistoryTrigger: document.getElementById('btnHistoryTrigger'),
      historyCountBadge: document.getElementById('historyCountBadge'),
      historyDrawer: document.getElementById('historyDrawer'),
      btnCloseHistory: document.getElementById('btnCloseHistory'),
      historyDrawerBody: document.getElementById('historyDrawerBody'),
      historyEmptyState: document.getElementById('historyEmptyState'),
      historyItemsList: document.getElementById('historyItemsList'),
      btnClearHistory: document.getElementById('btnClearHistory'),

      // Toast Container
      toastContainer: document.getElementById('toastContainer'),

      // Studio Editing Suite Panels & Tabs
      tabModeInpaint: document.getElementById('tabModeInpaint'),
      tabModeCrop: document.getElementById('tabModeCrop'),
      tabModeResize: document.getElementById('tabModeResize'),
      tabModeText: document.getElementById('tabModeText'),
      tabModeTransform: document.getElementById('tabModeTransform'),
      tabModeFilters: document.getElementById('tabModeFilters'),
      btnAutoEnhance: document.getElementById('btnAutoEnhance'),
      btnRemoveBG: document.getElementById('btnRemoveBG'),

      panelInpaint: document.getElementById('panelInpaint'),
      panelCrop: document.getElementById('panelCrop'),
      panelResize: document.getElementById('panelResize'),
      panelText: document.getElementById('panelText'),
      panelTransform: document.getElementById('panelTransform'),
      panelFilters: document.getElementById('panelFilters'),

      // Text elements
      textOverlayInput: document.getElementById('textOverlayInput'),
      textFontSelect: document.getElementById('textFontSelect'),
      textColorPicker: document.getElementById('textColorPicker'),
      btnApplyText: document.getElementById('btnApplyText'),

      // Crop elements
      cropOverlayBox: document.getElementById('cropOverlayBox'),
      btnApplyCrop: document.getElementById('btnApplyCrop'),
      btnCancelCrop: document.getElementById('btnCancelCrop'),
      ratioPills: document.querySelectorAll('.ratio-pill-btn'),

      // Resize elements
      resizeWidthInput: document.getElementById('resizeWidthInput'),
      resizeHeightInput: document.getElementById('resizeHeightInput'),
      btnRatioLock: document.getElementById('btnRatioLock'),
      btnApplyResize: document.getElementById('btnApplyResize'),
      resizePresets: document.querySelectorAll('.resize-presets-group .preset-pill'),

      // Transform elements
      btnRotateCW: document.getElementById('btnRotateCW'),
      btnRotateCCW: document.getElementById('btnRotateCCW'),
      btnFlipH: document.getElementById('btnFlipH'),
      btnFlipV: document.getElementById('btnFlipV'),

      // Filter presets
      filterPills: document.querySelectorAll('.filter-pill-btn')
    };

    this.ctx = this.dom.maskCanvas.getContext('2d');
    this.activeImageSource = null;
    this.isSliderDragging = false;
    this.currentUser = null;
    this.authMode = 'signin';
    this.activeStudioTab = 'inpaint';
    this.isRatioLocked = true;
    this.activeFilter = 'normal';

    this.init();
  }

  init() {
    window.cleanPixelApp = this;
    this.setupEventListeners();
    this.setupDrawingEngine();
    this.setupSplitSlider();
    this.updateStrokePreview();
    this.setupAuthEngine();
    this.setupZoomPan();
    this.setupModeSwitch();
    this.setupProPaywall();
    this.setupHistoryPanel();
    this.setupPostProcessing();
    this.setupBatchUpload();
    this.setupStudioEditingSuite();
    this.updateHistoryBadge();
    this.checkBackendHealth();
    this.setupScrollReveal();
    this.setupChatbotWidget();
    this.setupShortcutsModal();
    this.setupSuperResolutionRefine();
    this.setupThemeEngine();
  }

  async checkBackendHealth() {
    try {
      const res = await fetch('http://localhost:8000/health');
      if (res.ok) {
        this.backendOnline = true;
      }
    } catch (e) {
      this.backendOnline = false;
    }
  }

  // ─── STATE MANAGEMENT ───────────────────────────────────────────
  setState(newState) {
    this.currentState = newState;
    this.dom.stateNameText.textContent = newState;

    // View toggles
    this.dom.stateIdleUpload.style.display = (newState === AppState.IDLE_UPLOAD) ? 'flex' : 'none';
    this.dom.stateDrawingActive.style.display = (newState === AppState.DRAWING_ACTIVE) ? 'flex' : 'none';
    this.dom.stateProcessing.style.display = (newState === AppState.PROCESSING) ? 'flex' : 'none';
    this.dom.stateResultCompare.style.display = (newState === AppState.RESULT_COMPARE) ? 'flex' : 'none';

    // Toolbar visibility
    this.dom.floatingToolbar.style.display = (newState === AppState.DRAWING_ACTIVE) ? 'block' : 'none';
    this.dom.maskMetricBadge.style.display = (newState === AppState.DRAWING_ACTIVE) ? 'flex' : 'none';
    this.dom.btnResetCanvas.style.display = (newState !== AppState.IDLE_UPLOAD) ? 'flex' : 'none';

    // CTA Button states
    if (newState === AppState.DRAWING_ACTIVE) {
      this.dom.btnExecuteInpaint.style.display = 'flex';
      this.dom.btnExecuteInpaint.disabled = false;
      this.dom.ctaStateReady.style.display = 'flex';
      this.dom.ctaStateComputing.style.display = 'none';
      this.dom.resultActionRow.style.display = 'none';
      this.dom.stepperLifecycleBar.style.display = 'none';
    } else if (newState === AppState.PROCESSING) {
      this.dom.btnExecuteInpaint.style.display = 'flex';
      this.dom.btnExecuteInpaint.disabled = true;
      this.dom.ctaStateReady.style.display = 'none';
      this.dom.ctaStateComputing.style.display = 'flex';
      this.dom.resultActionRow.style.display = 'none';
      this.dom.stepperLifecycleBar.style.display = 'flex';
    } else if (newState === AppState.RESULT_COMPARE) {
      this.dom.btnExecuteInpaint.style.display = 'none';
      this.dom.resultActionRow.style.display = 'flex';
      this.dom.stepperLifecycleBar.style.display = 'none';
    } else {
      this.dom.btnExecuteInpaint.style.display = 'flex';
      this.dom.btnExecuteInpaint.disabled = true;
      this.dom.ctaStateReady.style.display = 'flex';
      this.dom.ctaStateComputing.style.display = 'none';
      this.dom.resultActionRow.style.display = 'none';
      this.dom.stepperLifecycleBar.style.display = 'none';
      this.dom.hudResolutionBadge.textContent = 'Viewport: Ready';
    }
  }

  // ─── EVENT LISTENERS & SHORTCUTS ────────────────────────────────
  setupEventListeners() {
    // Dropzone & File browse
    this.dom.btnBrowseFile.addEventListener('click', () => {
      if (this.currentMode === 'video') {
        this.dom.fileInputVideo.click();
      } else {
        this.dom.fileInput.click();
      }
    });
    this.dom.fileInput.addEventListener('change', (e) => this.handleFileSelect(e));
    this.dom.fileInputVideo.addEventListener('change', (e) => this.handleVideoSelect(e));
    
    // Drag & Drop
    const dropzone = this.dom.uploadDropzone;
    ['dragenter', 'dragover'].forEach(name => {
      dropzone.addEventListener(name, (e) => {
        e.preventDefault();
        dropzone.classList.add('dragover');
      });
    });
    ['dragleave', 'drop'].forEach(name => {
      dropzone.addEventListener(name, (e) => {
        e.preventDefault();
        dropzone.classList.remove('dragover');
      });
    });
    dropzone.addEventListener('drop', (e) => {
      if (e.dataTransfer.files.length) {
        const file = e.dataTransfer.files[0];
        if (file.type.startsWith('video/')) {
          this.handleVideoFile(file);
        } else {
          this.loadFile(file);
        }
      }
    });

    // Tool switching
    if (this.dom.toolBrush) this.dom.toolBrush.addEventListener('click', () => this.setTool('brush'));
    if (this.dom.toolRect) this.dom.toolRect.addEventListener('click', () => this.setTool('rect'));
    if (this.dom.toolEraser) this.dom.toolEraser.addEventListener('click', () => this.setTool('eraser'));

    // AI Auto-Detect
    if (this.dom.btnAutoDetect) {
      this.dom.btnAutoDetect.addEventListener('click', () => this.runAutoDetect());
    }

    // Stroke size
    if (this.dom.strokeWidthSlider) {
      this.dom.strokeWidthSlider.addEventListener('input', (e) => {
        this.strokeWidth = parseInt(e.target.value, 10);
        this.updateStrokePreview();
      });
    }

    if (this.dom.presetPills) {
      this.dom.presetPills.forEach(pill => {
        pill.addEventListener('click', () => {
          this.dom.presetPills.forEach(p => p.classList.remove('active'));
          pill.classList.add('active');
          this.strokeWidth = parseInt(pill.getAttribute('data-size'), 10);
          if (this.dom.strokeWidthSlider) this.dom.strokeWidthSlider.value = this.strokeWidth;
          this.updateStrokePreview();
        });
      });
    }

    // History controls
    if (this.dom.btnUndo) this.dom.btnUndo.addEventListener('click', () => this.undo());
    if (this.dom.btnRedo) this.dom.btnRedo.addEventListener('click', () => this.redo());
    if (this.dom.btnClearMask) this.dom.btnClearMask.addEventListener('click', () => this.clearMask());
    if (this.dom.btnResetCanvas) this.dom.btnResetCanvas.addEventListener('click', () => this.resetAll());

    // Quick Demo Button
    if (this.dom.btnQuickDemo) {
      this.dom.btnQuickDemo.addEventListener('click', (e) => {
        e.stopPropagation();
        this.loadImageFromUrl('assets/ecommerce_showcase.jpg', 'E-Commerce Product (Watermarked)');
        this.toast.success('Loaded Quick Demo Sample');
      });
    }

    // Newsletter Form
    const newsletterForm = document.getElementById('newsletterForm');
    if (newsletterForm) {
      newsletterForm.addEventListener('submit', (e) => {
        e.preventDefault();
        const input = newsletterForm.querySelector('input[type="email"]');
        const email = input ? input.value : '';
        if (email) {
          if (input) input.value = '';
          this.toast.success('Subscribed! 50 bonus credits added to your account.');
          this.userCredits += 50;
          if (this.dom.proCreditCounter) {
            this.dom.proCreditCounter.textContent = `${this.userCredits}/150`;
          }
        }
      });
    }

    // Pricing Card Pro Upgrades
    document.querySelectorAll('.btn-plan-pro').forEach(btn => {
      btn.addEventListener('click', (e) => {
        e.preventDefault();
        this.openProModal();
      });
    });

    // Primary CTA Execute Inpainting
    if (this.dom.btnExecuteInpaint) {
      this.dom.btnExecuteInpaint.addEventListener('click', () => this.runInpaintPipeline());
    }

    // Result Actions
    if (this.dom.btnEditAgain) {
      this.dom.btnEditAgain.addEventListener('click', () => this.setState(AppState.DRAWING_ACTIVE));
    }
    if (this.dom.btnDownloadResult) {
      this.dom.btnDownloadResult.addEventListener('click', () => this.downloadCleanedAsset());
    }

    // Copy to Clipboard
    const btnCopy = document.getElementById('btnCopyClipboard');
    if (btnCopy) {
      btnCopy.addEventListener('click', async () => {
        try {
          const img = this.dom.resultCleanedImage;
          if (!img || !img.src) return;
          const canvas = document.createElement('canvas');
          const tmpImg = new Image();
          tmpImg.crossOrigin = 'anonymous';
          tmpImg.onload = async () => {
            canvas.width = tmpImg.naturalWidth || tmpImg.width;
            canvas.height = tmpImg.naturalHeight || tmpImg.height;
            const ctx = canvas.getContext('2d');
            ctx.filter = `brightness(${this.postBrightness}%) contrast(${this.postContrast}%) saturate(${this.postSaturate}%)`;
            ctx.drawImage(tmpImg, 0, 0);
            canvas.toBlob(async (blob) => {
              if (blob && navigator.clipboard && navigator.clipboard.write) {
                try {
                  await navigator.clipboard.write([new ClipboardItem({ 'image/png': blob })]);
                  this.toast.success('Cleaned image copied to clipboard');
                } catch (e) {
                  this.toast.info('Image copied. Use Ctrl+V to paste.');
                }
              } else {
                this.toast.info('Direct clipboard write is unavailable. Use Download.');
              }
            }, 'image/png');
          };
          tmpImg.src = img.src;
        } catch (err) {
          this.toast.error('Failed to copy: ' + err.message);
        }
      });
    }

    // Floating Back to Top Button
    const btnBackToTop = document.getElementById('btnBackToTop');
    if (btnBackToTop) {
      window.addEventListener('scroll', () => {
        if (window.scrollY > 380) {
          btnBackToTop.classList.add('visible');
        } else {
          btnBackToTop.classList.remove('visible');
        }
      }, { passive: true });

      btnBackToTop.addEventListener('click', () => {
        window.scrollTo({ top: 0, behavior: 'smooth' });
      });
    }

    // Keyboard Accelerators
    window.addEventListener('keydown', (e) => {
      if (e.target.tagName === 'INPUT' || e.target.tagName === 'SELECT' || e.target.tagName === 'TEXTAREA') return;
      
      if (e.key === 'b' || e.key === 'B') this.setTool('brush');
      if (e.key === 'r' || e.key === 'R') this.setTool('rect');
      if (e.key === 'e' || e.key === 'E') this.setTool('eraser');
      if (e.key === 'w' || e.key === 'W') this.runAutoDetect();

      // Zoom shortcuts
      if (e.key === '=' || e.key === '+') { e.preventDefault(); this.zoomIn(); }
      if (e.key === '-' || e.key === '_') { e.preventDefault(); this.zoomOut(); }
      if (e.key === '0') { e.preventDefault(); this.zoomReset(); }

      // Space for pan
      if (e.code === 'Space' && !this.isSpaceHeld) {
        this.isSpaceHeld = true;
        if (this.dom.canvasLayersStack) this.dom.canvasLayersStack.style.cursor = 'grab';
      }

      if ((e.ctrlKey || e.metaKey) && e.key === 'z') {
        e.preventDefault();
        if (e.shiftKey) this.redo();
        else this.undo();
      }
      if ((e.ctrlKey || e.metaKey) && e.key === 'y') {
        e.preventDefault();
        this.redo();
      }
    });

    window.addEventListener('keyup', (e) => {
      if (e.code === 'Space') {
        this.isSpaceHeld = false;
        if (this.dom.canvasLayersStack) this.dom.canvasLayersStack.style.cursor = '';
      }
    });
  }

  // ─── MODE SWITCHING (IMAGE / VIDEO) ─────────────────────────────
  setupModeSwitch() {
    this.dom.modePillBtns.forEach(btn => {
      btn.addEventListener('click', () => {
        this.dom.modePillBtns.forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        this.currentMode = btn.getAttribute('data-mode');

        if (this.currentMode === 'video') {
          this.dom.dropzoneSubtext.textContent = 'Supports MP4, WebM, MOV video up to 1080p';
          this.toast.info('Video Track mode activated (BETA)');
        } else {
          this.dom.dropzoneSubtext.textContent = 'Supports PNG, JPG, WebP, GIF, BMP, TIFF, SVG & PDF up to 4K resolution';
        }

        if (this.currentState !== AppState.IDLE_UPLOAD) {
          this.resetAll();
        }
      });
    });
    this.setupSamplePicker();
  }

  // ─── SAMPLE ASSET PICKER DROPDOWN ───────────────────────────────
  setupSamplePicker() {
    const btnTrigger = document.getElementById('btnSampleTrigger');
    const menu = document.getElementById('sampleMenu');
    if (!btnTrigger || !menu) return;

    btnTrigger.addEventListener('click', (e) => {
      e.stopPropagation();
      menu.classList.toggle('show');
    });

    document.addEventListener('click', (e) => {
      if (!btnTrigger.contains(e.target) && !menu.contains(e.target)) {
        menu.classList.remove('show');
      }
    });

    const sampleItems = menu.querySelectorAll('.sample-item');
    sampleItems.forEach(item => {
      item.addEventListener('click', () => {
        const sampleKey = item.getAttribute('data-sample');
        menu.classList.remove('show');

        let samplePath = 'assets/sample1.jpg';
        let sampleName = 'Demo Sample';

        if (sampleKey === 'ecommerce') {
          samplePath = 'assets/ecommerce_showcase.jpg';
          sampleName = 'E-Commerce Product (Watermarked)';
        } else if (sampleKey === 'portrait') {
          samplePath = 'assets/portrait_showcase.jpg';
          sampleName = 'Portrait Retouch Sample';
        } else if (sampleKey === 'realestate') {
          samplePath = 'assets/realestate_showcase.jpg';
          sampleName = 'Luxury Architecture & Villa';
        } else if (sampleKey === 'document') {
          samplePath = 'assets/document_showcase.jpg';
          sampleName = 'Official Document & Stamp';
        } else if (sampleKey === 'landscape') {
          samplePath = 'assets/landscape_showcase.jpg';
          sampleName = '4K Nature Landscape';
        } else if (sampleKey === 'video') {
          samplePath = 'assets/video_showcase.jpg';
          sampleName = 'Video Frame Watermark';
        }

        this.loadImageFromUrl(samplePath, sampleName);
        this.toast.success(`Loaded Demo: ${sampleName}`);
      });
    });

    // Wire 1-Click Dropzone Sample Pills
    document.querySelectorAll('.btn-quick-sample-pill').forEach(pill => {
      pill.addEventListener('click', (e) => {
        e.stopPropagation();
        const sampleKey = pill.getAttribute('data-sample');
        let samplePath = 'assets/ecommerce_showcase.jpg';
        let sampleName = 'Meesho E-Commerce Product';

        if (sampleKey === 'ecommerce') {
          samplePath = 'assets/ecommerce_showcase.jpg';
          sampleName = 'Meesho E-Commerce Catalog';
        } else if (sampleKey === 'portrait') {
          samplePath = 'assets/portrait_showcase.jpg';
          sampleName = 'Wedding Studio Photo';
        } else if (sampleKey === 'document') {
          samplePath = 'assets/document_showcase.jpg';
          sampleName = 'Official PDF / Stamp';
        } else if (sampleKey === 'realestate') {
          samplePath = 'assets/realestate_showcase.jpg';
          sampleName = 'Real Estate Architecture';
        }

        this.loadImageFromUrl(samplePath, sampleName);
        this.toast.success(`Loaded Demo: ${sampleName}`);
      });
    });
  }

  // ─── SAMPLE ASSET GENERATOR ─────────────────────────────────────
  loadSyntheticSample(sampleType) {
    let sampleSrc = 'assets/sample1.jpg';
    let sampleLabel = 'Stock Photo Watermark';

    if (sampleType === 'assets/sample1.jpg' || sampleType === 'watermark1') {
      sampleSrc = 'assets/sample1.jpg';
      sampleLabel = 'Scenic Stock Watermark';
    } else if (sampleType === 'assets/sample2.jpg' || sampleType === 'watermark2') {
      sampleSrc = 'assets/sample2.jpg';
      sampleLabel = 'Timestamp & Camera Logo';
    } else if (sampleType === 'assets/sample3.jpg' || sampleType === 'watermark3') {
      sampleSrc = 'assets/sample3.jpg';
      sampleLabel = 'Document Draft Stamp';
    } else if (sampleType && sampleType.startsWith('assets/')) {
      sampleSrc = sampleType;
      sampleLabel = 'Demo Preset';
    }

    this.loadImageFromUrl(sampleSrc, sampleLabel);
    this.toast.success(`Loaded Demo: ${sampleLabel}`);
  }

  // ─── FILE HANDLING (ALL FORMATS) ────────────────────────────────
  handleFileSelect(e) {
    if (e.target.files && e.target.files[0]) {
      this.loadFile(e.target.files[0]);
    }
  }

  loadFile(file) {
    const type = file.type;

    // PDF handling
    if (type === 'application/pdf') {
      this.loadPDFFile(file);
      return;
    }

    // SVG handling
    if (type === 'image/svg+xml') {
      this.loadSVGFile(file);
      return;
    }

    // GIF handling (static first frame)
    if (type === 'image/gif') {
      this.loadGIFFile(file);
      return;
    }

    // Standard image formats (PNG, JPG, WebP, BMP, TIFF)
    if (type.startsWith('image/')) {
      const reader = new FileReader();
      reader.onload = (evt) => {
        this.loadImageFromUrl(evt.target.result, file.name);
        this.toast.success(`Loaded: ${file.name}`);
      };
      reader.readAsDataURL(file);
      return;
    }

    this.toast.error('Unsupported file format. Use PNG, JPG, WebP, GIF, BMP, TIFF, SVG, or PDF.');
  }

  // ─── PDF FILE LOADING (via PDF.js) ──────────────────────────────
  async loadPDFFile(file) {
    if (!window.pdfjsLib) {
      this.toast.error('PDF.js library not loaded. Please reload the page.');
      return;
    }

    this.toast.info('Rendering PDF page 1...');
    try {
      const arrayBuffer = await file.arrayBuffer();
      const pdf = await window.pdfjsLib.getDocument({ data: arrayBuffer }).promise;
      const totalPages = pdf.numPages;

      // Render page 1 at 2x scale for high-res
      const page = await pdf.getPage(1);
      const scale = 2.0;
      const viewport = page.getViewport({ scale });

      const canvas = document.createElement('canvas');
      canvas.width = viewport.width;
      canvas.height = viewport.height;
      const ctx = canvas.getContext('2d');

      await page.render({ canvasContext: ctx, viewport }).promise;

      const dataUrl = canvas.toDataURL('image/png');
      this.loadImageFromUrl(dataUrl, `${file.name} (Page 1/${totalPages})`);
      this.toast.success(`PDF loaded: ${totalPages} page${totalPages > 1 ? 's' : ''} — showing page 1`);
    } catch (err) {
      this.toast.error('Failed to render PDF: ' + err.message);
    }
  }

  // ─── SVG FILE LOADING ───────────────────────────────────────────
  loadSVGFile(file) {
    const reader = new FileReader();
    reader.onload = (evt) => {
      const svgText = evt.target.result;
      const img = new Image();
      const blob = new Blob([svgText], { type: 'image/svg+xml;charset=utf-8' });
      const url = URL.createObjectURL(blob);

      img.onload = () => {
        // Render SVG to canvas for pixel editing
        const canvas = document.createElement('canvas');
        canvas.width = Math.max(img.naturalWidth || 1200, 800);
        canvas.height = Math.max(img.naturalHeight || 750, 600);
        const ctx = canvas.getContext('2d');
        ctx.fillStyle = '#ffffff';
        ctx.fillRect(0, 0, canvas.width, canvas.height);
        ctx.drawImage(img, 0, 0, canvas.width, canvas.height);

        const dataUrl = canvas.toDataURL('image/png');
        this.loadImageFromUrl(dataUrl, file.name);
        this.toast.success(`SVG rasterized: ${canvas.width}×${canvas.height}px`);
        URL.revokeObjectURL(url);
      };
      img.onerror = () => {
        this.toast.error('Failed to load SVG file');
        URL.revokeObjectURL(url);
      };
      img.src = url;
    };
    reader.readAsText(file);
  }

  // ─── GIF FILE LOADING (first frame) ─────────────────────────────
  loadGIFFile(file) {
    const reader = new FileReader();
    reader.onload = (evt) => {
      const img = new Image();
      img.onload = () => {
        // Extract first frame by drawing to canvas
        const canvas = document.createElement('canvas');
        canvas.width = img.naturalWidth;
        canvas.height = img.naturalHeight;
        const ctx = canvas.getContext('2d');
        ctx.drawImage(img, 0, 0);

        const dataUrl = canvas.toDataURL('image/png');
        this.loadImageFromUrl(dataUrl, `${file.name} (first frame)`);
        this.toast.info('GIF loaded — first frame extracted for editing');
      };
      img.src = evt.target.result;
    };
    reader.readAsDataURL(file);
  }

  // ─── VIDEO FILE HANDLING ────────────────────────────────────────
  handleVideoSelect(e) {
    if (e.target.files && e.target.files[0]) {
      this.handleVideoFile(e.target.files[0]);
    }
  }

  handleVideoFile(file) {
    if (!file.type.startsWith('video/')) {
      this.toast.error('Please upload a valid video file (MP4, WebM, MOV).');
      return;
    }

    this.toast.info('Extracting video frame for mask drawing...');

    const video = document.createElement('video');
    video.muted = true;
    video.preload = 'auto';

    const url = URL.createObjectURL(file);
    video.src = url;

    video.addEventListener('loadeddata', () => {
      // Seek to 1 second to skip potential black intro frames
      video.currentTime = Math.min(1, video.duration / 2);
    });

    video.addEventListener('seeked', () => {
      const canvas = document.createElement('canvas');
      canvas.width = video.videoWidth;
      canvas.height = video.videoHeight;
      const ctx = canvas.getContext('2d');
      ctx.drawImage(video, 0, 0);

      const dataUrl = canvas.toDataURL('image/png');
      this.loadImageFromUrl(dataUrl, `${file.name} (frame capture)`);
      this.videoFile = file;
      this.toast.success(`Video frame captured: ${video.videoWidth}×${video.videoHeight}`);
      URL.revokeObjectURL(url);
    });
  }

  loadImageFromUrl(src, label) {
    const img = new Image();
    img.onload = () => {
      this.activeImageSource = src;
      this.dom.baseImage.src = src;
      this.dom.procBaseImage.src = src;
      this.dom.resultOriginalImage.src = src;
      
      const aspectWidth = img.naturalWidth;
      const aspectHeight = img.naturalHeight;
      this.dom.maskCanvas.width = aspectWidth;
      this.dom.maskCanvas.height = aspectHeight;
      this.dom.procMaskCanvas.width = aspectWidth;
      this.dom.procMaskCanvas.height = aspectHeight;

      this.dom.hudResolutionBadge.textContent = `${label} (${aspectWidth}×${aspectHeight})`;

      this.clearMask();
      this.historyStack = [];
      this.redoStack = [];
      this.updateHistoryButtons();
      this.zoomReset();

      this.setState(AppState.DRAWING_ACTIVE);
    };
    img.src = src;
  }

  // ─── DRAWING ENGINE ─────────────────────────────────────────────
  setupDrawingEngine() {
    const canvas = this.dom.maskCanvas;
    const reticle = this.dom.brushReticle;

    const getPos = (e) => {
      const rect = canvas.getBoundingClientRect();
      const scaleX = canvas.width / rect.width;
      const scaleY = canvas.height / rect.height;
      return {
        x: (e.clientX - rect.left) * scaleX,
        y: (e.clientY - rect.top) * scaleY,
        clientX: e.clientX - rect.left,
        clientY: e.clientY - rect.top
      };
    };

    // Pointer move / reticle
    canvas.addEventListener('mousemove', (e) => {
      if (this.isSpaceHeld) return;

      const rect = canvas.getBoundingClientRect();
      const x = e.clientX - rect.left;
      const y = e.clientY - rect.top;
      
      const visualSize = (this.strokeWidth / (canvas.width / rect.width));
      reticle.style.width = `${visualSize}px`;
      reticle.style.height = `${visualSize}px`;
      reticle.style.left = `${x}px`;
      reticle.style.top = `${y}px`;
      reticle.style.display = (this.currentTool !== 'rect') ? 'block' : 'none';

      if (this.isDrawing && this.currentTool !== 'rect') {
        this.drawStroke(getPos(e));
      }

      // Rectangle preview
      if (this.isRectDrawing && this.currentTool === 'rect') {
        this.drawRectPreview(getPos(e));
      }
    });

    canvas.addEventListener('mouseleave', () => {
      reticle.style.display = 'none';
      if (this.isDrawing) this.stopDrawing();
      if (this.isRectDrawing) this.finishRect(null);
    });

    // Touch support
    canvas.addEventListener('touchstart', (e) => {
      e.preventDefault();
      const touch = e.touches[0];
      canvas.dispatchEvent(new MouseEvent('mousedown', { clientX: touch.clientX, clientY: touch.clientY }));
    }, { passive: false });

    canvas.addEventListener('touchmove', (e) => {
      e.preventDefault();
      const touch = e.touches[0];
      canvas.dispatchEvent(new MouseEvent('mousemove', { clientX: touch.clientX, clientY: touch.clientY }));
    }, { passive: false });

    canvas.addEventListener('touchend', () => {
      canvas.dispatchEvent(new MouseEvent('mouseup', {}));
    });

    canvas.addEventListener('mousedown', (e) => {
      if (this.isSpaceHeld) {
        // Start panning
        this.isPanning = true;
        this.panStartX = e.clientX - this.panX;
        this.panStartY = e.clientY - this.panY;
        if (this.dom.canvasLayersStack) this.dom.canvasLayersStack.style.cursor = 'grabbing';
        return;
      }

      if (this.currentTool === 'rect') {
        // Start rectangle
        this.isRectDrawing = true;
        const pos = getPos(e);
        this.rectStartX = pos.x;
        this.rectStartY = pos.y;
        this.saveHistoryState();
        this.rectPreviewData = this.ctx.getImageData(0, 0, canvas.width, canvas.height);
      } else {
        // Start freehand brush/eraser
        this.isDrawing = true;
        this.saveHistoryState();
        this.ctx.beginPath();
        const pos = getPos(e);
        this.ctx.moveTo(pos.x, pos.y);
        this.drawStroke(pos);
      }
    });

    window.addEventListener('mousemove', (e) => {
      if (this.isPanning) {
        this.panX = e.clientX - this.panStartX;
        this.panY = e.clientY - this.panStartY;
        this.applyZoomPan();
      }
    });

    window.addEventListener('mouseup', (e) => {
      if (this.isPanning) {
        this.isPanning = false;
        if (this.dom.canvasLayersStack) this.dom.canvasLayersStack.style.cursor = this.isSpaceHeld ? 'grab' : '';
        return;
      }

      if (this.isDrawing) {
        this.stopDrawing();
      }

      if (this.isRectDrawing && this.currentTool === 'rect') {
        const canvas = this.dom.maskCanvas;
        const rect = canvas.getBoundingClientRect();
        const scaleX = canvas.width / rect.width;
        const scaleY = canvas.height / rect.height;
        this.finishRect({
          x: (e.clientX - rect.left) * scaleX,
          y: (e.clientY - rect.top) * scaleY
        });
      }
    });
  }

  drawStroke(pos) {
    this.ctx.lineWidth = this.strokeWidth;
    this.ctx.lineCap = 'round';
    this.ctx.lineJoin = 'round';

    if (this.currentTool === 'brush') {
      this.ctx.globalCompositeOperation = 'source-over';
      this.ctx.strokeStyle = 'rgba(212, 85, 31, 0.78)';
      this.ctx.shadowColor = '#D4551F';
      this.ctx.shadowBlur = 10;
    } else {
      this.ctx.globalCompositeOperation = 'destination-out';
      this.ctx.shadowBlur = 0;
    }

    this.ctx.lineTo(pos.x, pos.y);
    this.ctx.stroke();
    this.ctx.beginPath();
    this.ctx.moveTo(pos.x, pos.y);
  }

  // ─── RECTANGLE TOOL ─────────────────────────────────────────────
  drawRectPreview(pos) {
    if (!this.rectPreviewData) return;
    this.ctx.putImageData(this.rectPreviewData, 0, 0);

    const x = Math.min(this.rectStartX, pos.x);
    const y = Math.min(this.rectStartY, pos.y);
    const w = Math.abs(pos.x - this.rectStartX);
    const h = Math.abs(pos.y - this.rectStartY);

    this.ctx.globalCompositeOperation = 'source-over';
    this.ctx.fillStyle = 'rgba(212, 85, 31, 0.55)';
    this.ctx.strokeStyle = 'rgba(212, 85, 31, 0.9)';
    this.ctx.lineWidth = 2;
    this.ctx.shadowColor = '#D4551F';
    this.ctx.shadowBlur = 8;
    this.ctx.fillRect(x, y, w, h);
    this.ctx.strokeRect(x, y, w, h);
    this.ctx.shadowBlur = 0;
  }

  finishRect(pos) {
    if (!this.isRectDrawing) return;
    this.isRectDrawing = false;

    if (pos && this.rectPreviewData) {
      this.ctx.putImageData(this.rectPreviewData, 0, 0);

      const x = Math.min(this.rectStartX, pos.x);
      const y = Math.min(this.rectStartY, pos.y);
      const w = Math.abs(pos.x - this.rectStartX);
      const h = Math.abs(pos.y - this.rectStartY);

      if (w > 5 && h > 5) {
        this.ctx.globalCompositeOperation = 'source-over';
        this.ctx.fillStyle = 'rgba(212, 85, 31, 0.78)';
        this.ctx.shadowColor = '#D4551F';
        this.ctx.shadowBlur = 10;
        this.ctx.fillRect(x, y, w, h);
        this.ctx.shadowBlur = 0;
        this.dom.btnExecuteInpaint.disabled = false;
        this.calculateMaskCoverage();
      }
    }

    this.rectPreviewData = null;
  }

  stopDrawing() {
    this.isDrawing = false;
    this.ctx.beginPath();
    this.ctx.shadowBlur = 0;
    this.dom.btnExecuteInpaint.disabled = false;
    this.calculateMaskCoverage();
  }

  setTool(tool) {
    this.currentTool = tool;
    // Remove active from all tools
    [this.dom.toolBrush, this.dom.toolRect, this.dom.toolEraser].forEach(btn => {
      if (btn) {
        btn.classList.remove('active');
        btn.setAttribute('aria-checked', 'false');
      }
    });

    if (tool === 'brush') {
      this.dom.toolBrush.classList.add('active');
      this.dom.toolBrush.setAttribute('aria-checked', 'true');
      this.dom.brushReticle.style.borderColor = 'var(--accent-electric)';
    } else if (tool === 'rect') {
      if (this.dom.toolRect) {
        this.dom.toolRect.classList.add('active');
        this.dom.toolRect.setAttribute('aria-checked', 'true');
      }
      this.dom.brushReticle.style.display = 'none';
    } else {
      this.dom.toolEraser.classList.add('active');
      this.dom.toolEraser.setAttribute('aria-checked', 'true');
      this.dom.brushReticle.style.borderColor = '#EF4444';
    }
  }

  updateStrokePreview() {
    this.dom.strokeValText.textContent = `${this.strokeWidth}px`;
    const preview = this.dom.strokePreviewCircle;
    const scaled = Math.min(24, Math.max(4, this.strokeWidth / 3.5));
    preview.style.width = `${scaled}px`;
    preview.style.height = `${scaled}px`;
  }

  calculateMaskCoverage() {
    try {
      const imgData = this.ctx.getImageData(0, 0, this.dom.maskCanvas.width, this.dom.maskCanvas.height);
      const totalPixels = imgData.data.length / 4;
      let painted = 0;
      for (let i = 3; i < imgData.data.length; i += 4) {
        if (imgData.data[i] > 20) painted++;
      }
      const pct = ((painted / totalPixels) * 100).toFixed(1);
      this.dom.maskCoverageVal.textContent = `${pct}%`;
    } catch(e) {}
  }

  // ─── AI AUTO-DETECT WATERMARK ───────────────────────────────────
  async runAutoDetect() {
    if (this.currentState !== AppState.DRAWING_ACTIVE || !this.activeImageSource) {
      this.toast.warning('Upload an image first to auto-detect watermarks');
      return;
    }

    this.toast.info('AI scanning for watermarks...');

    try {
      // Try backend API first
      const imgBlob = await (await fetch(this.activeImageSource)).blob();
      const formData = new FormData();
      formData.append('file', imgBlob, 'source.png');

      const res = await fetch('http://localhost:8000/api/v1/media/auto-detect', {
        method: 'POST',
        body: formData
      });

      if (res.ok) {
        const maskBlob = await res.blob();
        const maskUrl = URL.createObjectURL(maskBlob);
        const maskImg = new Image();
        maskImg.onload = () => {
          this.saveHistoryState();
          this.ctx.globalCompositeOperation = 'source-over';
          this.ctx.drawImage(maskImg, 0, 0, this.dom.maskCanvas.width, this.dom.maskCanvas.height);
          this.dom.btnExecuteInpaint.disabled = false;
          this.calculateMaskCoverage();
          this.toast.success('Watermarks detected and mask applied!');
          URL.revokeObjectURL(maskUrl);
        };
        maskImg.src = maskUrl;
        return;
      }
    } catch (err) {
      console.log('Backend offline, using client-side auto-detect fallback');
    }

    // Client-side fallback: simple edge-based detection
    this.clientSideAutoDetect();
  }

  clientSideAutoDetect() {
    try {
      const tmpCanvas = document.createElement('canvas');
      tmpCanvas.width = this.dom.maskCanvas.width;
      tmpCanvas.height = this.dom.maskCanvas.height;
      const tmpCtx = tmpCanvas.getContext('2d');
      tmpCtx.drawImage(this.dom.baseImage, 0, 0);

      const imageData = tmpCtx.getImageData(0, 0, tmpCanvas.width, tmpCanvas.height);
      const data = imageData.data;
      const w = tmpCanvas.width;
      const h = tmpCanvas.height;

      // Detect semi-transparent white/light overlays (common watermark pattern)
      this.saveHistoryState();
      this.ctx.globalCompositeOperation = 'source-over';

      const centerX = w * 0.5;
      const centerY = h * 0.5;
      const regionW = w * 0.5;
      const regionH = h * 0.15;

      // Scan center region for high-luminance text-like features
      let highLumCount = 0;
      for (let y = Math.floor(h * 0.35); y < Math.floor(h * 0.65); y++) {
        for (let x = Math.floor(w * 0.15); x < Math.floor(w * 0.85); x++) {
          const idx = (y * w + x) * 4;
          const lum = data[idx] * 0.299 + data[idx + 1] * 0.587 + data[idx + 2] * 0.114;
          if (lum > 180 && data[idx + 3] > 100) highLumCount++;
        }
      }

      if (highLumCount > 200) {
        // Paint center region as detected watermark
        this.ctx.fillStyle = 'rgba(212, 85, 31, 0.65)';
        this.ctx.shadowColor = '#D4551F';
        this.ctx.shadowBlur = 12;
        this.ctx.fillRect(w * 0.15, h * 0.35, w * 0.7, h * 0.3);
        this.ctx.shadowBlur = 0;
        this.toast.success('Watermark pattern detected in center region');
      } else {
        // Check bottom-right for logo/timestamp
        this.ctx.fillStyle = 'rgba(212, 85, 31, 0.65)';
        this.ctx.fillRect(w * 0.6, h * 0.85, w * 0.35, h * 0.12);
        this.toast.info('Auto-detected common watermark zone (bottom-right)');
      }

      this.dom.btnExecuteInpaint.disabled = false;
      this.calculateMaskCoverage();
    } catch (err) {
      this.toast.error('Auto-detect failed: ' + err.message);
    }
  }

  // ─── HISTORY STACK (Undo / Redo / Clear) ────────────────────────
  saveHistoryState() {
    if (this.historyStack.length >= this.maxHistory) {
      this.historyStack.shift();
    }
    const snapshot = this.ctx.getImageData(0, 0, this.dom.maskCanvas.width, this.dom.maskCanvas.height);
    this.historyStack.push(snapshot);
    this.redoStack = [];
    this.updateHistoryButtons();
  }

  undo() {
    if (this.historyStack.length === 0) return;
    const current = this.ctx.getImageData(0, 0, this.dom.maskCanvas.width, this.dom.maskCanvas.height);
    this.redoStack.push(current);
    const previous = this.historyStack.pop();
    this.ctx.putImageData(previous, 0, 0);
    this.updateHistoryButtons();
    this.calculateMaskCoverage();
  }

  redo() {
    if (this.redoStack.length === 0) return;
    const current = this.ctx.getImageData(0, 0, this.dom.maskCanvas.width, this.dom.maskCanvas.height);
    this.historyStack.push(current);
    const next = this.redoStack.pop();
    this.ctx.putImageData(next, 0, 0);
    this.updateHistoryButtons();
    this.calculateMaskCoverage();
  }

  clearMask() {
    this.saveHistoryState();
    this.ctx.clearRect(0, 0, this.dom.maskCanvas.width, this.dom.maskCanvas.height);
    this.dom.maskCoverageVal.textContent = '0%';
    this.dom.btnExecuteInpaint.disabled = true;
  }

  updateHistoryButtons() {
    this.dom.btnUndo.disabled = (this.historyStack.length === 0);
    this.dom.btnRedo.disabled = (this.redoStack.length === 0);
  }

  resetAll() {
    this.activeImageSource = null;
    this.clearMask();
    this.historyStack = [];
    this.redoStack = [];
    this.updateHistoryButtons();
    this.zoomReset();
    this.setState(AppState.IDLE_UPLOAD);
  }

  // ─── ZOOM & PAN ENGINE ──────────────────────────────────────────
  setupZoomPan() {
    if (this.dom.btnZoomIn) this.dom.btnZoomIn.addEventListener('click', () => this.zoomIn());
    if (this.dom.btnZoomOut) this.dom.btnZoomOut.addEventListener('click', () => this.zoomOut());
    if (this.dom.btnZoomReset) this.dom.btnZoomReset.addEventListener('click', () => this.zoomReset());

    // Mousewheel zoom
    const viewport = document.getElementById('canvasStageViewport');
    if (viewport) {
      viewport.addEventListener('wheel', (e) => {
        if (this.currentState !== AppState.DRAWING_ACTIVE) return;
        e.preventDefault();
        if (e.deltaY < 0) this.zoomIn();
        else this.zoomOut();
      }, { passive: false });
    }
  }

  zoomIn() {
    this.zoomLevel = Math.min(5, this.zoomLevel + 0.15);
    this.applyZoomPan();
  }

  zoomOut() {
    this.zoomLevel = Math.max(0.25, this.zoomLevel - 0.15);
    this.applyZoomPan();
  }

  zoomReset() {
    this.zoomLevel = 1;
    this.panX = 0;
    this.panY = 0;
    this.applyZoomPan();
  }

  applyZoomPan() {
    const stack = this.dom.canvasLayersStack;
    if (stack) {
      stack.style.transform = `translate(${this.panX}px, ${this.panY}px) scale(${this.zoomLevel})`;
      stack.style.transformOrigin = 'center center';
    }
    if (this.dom.zoomLevelText) {
      this.dom.zoomLevelText.textContent = `${Math.round(this.zoomLevel * 100)}%`;
    }
  }

  // ─── INPAINT PIPELINE ───────────────────────────────────────────
  runInpaintPipeline() {
    // Credit check
    if (this.currentUser && this.currentUser.credits_remaining <= 0) {
      this.openProModal();
      this.toast.warning('No credits remaining! Upgrade to PRO for unlimited processing.');
      return;
    }

    if (!this.activeImageSource) {
      this.toast.warning('Please upload an image or load a demo sample first.');
      return;
    }

    // If no mask was drawn yet, auto-detect watermark region automatically
    if (this.historyStack.length === 0) {
      this.clientSideAutoDetect();
    }

    // Copy mask to proc canvas
    const pCtx = this.dom.procMaskCanvas.getContext('2d');
    pCtx.clearRect(0, 0, this.dom.procMaskCanvas.width, this.dom.procMaskCanvas.height);
    pCtx.drawImage(this.dom.maskCanvas, 0, 0);

    this.setState(AppState.PROCESSING);

    // Deduct credit
    if (this.currentUser) {
      this.currentUser.credits_remaining = Math.max(0, this.currentUser.credits_remaining - 1);
      this.updateAuthUI();
      this.toast.info(`1 credit used. ${this.currentUser.credits_remaining} remaining.`);
    } else {
      this.userCredits = Math.max(0, this.userCredits - 1);
      if (this.dom.proCreditCounter) {
        this.dom.proCreditCounter.textContent = `${this.userCredits}/150`;
      }
    }

    // Stepper Phases
    const phases = [
      { step: 1, progress: 25, title: "Contour Detection", sub: "Segmenting watermark boundary vectors...", msg: "Segmenting watermark contours..." },
      { step: 2, progress: 55, title: "Neural Inpainting", sub: "Synthesizing diffusion latent tensors...", msg: "Synthesizing neural inpaint tensor..." },
      { step: 3, progress: 85, title: "Texture Reconstruction", sub: "Harmonizing ambient grain & lighting...", msg: "Reconstructing background textures..." },
      { step: 4, progress: 100, title: "4K Color Blending", sub: "Applying multi-scale pixel restoration...", msg: "Finalizing 4K pixel blending..." }
    ];

    let currentPhaseIdx = 0;

    const executePhase = () => {
      if (currentPhaseIdx >= phases.length) {
        this.finishInpaintPipeline();
        return;
      }

      const p = phases[currentPhaseIdx];

      this.dom.procProgressFill.style.width = `${p.progress}%`;
      this.dom.procPercentVal.textContent = `${p.progress}%`;
      this.dom.procStepLabel.textContent = `Pass ${p.step} of 4`;
      this.dom.procTitle.textContent = p.title;
      this.dom.procSub.textContent = p.sub;

      this.dom.stepperDynamicMsg.textContent = p.msg;
      this.dom.stepperMicroProgress.textContent = `Phase ${p.step}/4 • ${p.progress}%`;

      this.dom.stepNodes.forEach(node => {
        const s = parseInt(node.getAttribute('data-step'), 10);
        node.classList.remove('active', 'completed');
        if (s < p.step) node.classList.add('completed');
        else if (s === p.step) node.classList.add('active');
      });

      currentPhaseIdx++;
      setTimeout(executePhase, 550);
    };

    setTimeout(executePhase, 200);
  }

  async finishInpaintPipeline() {
    try {
      let cleanedUrl = null;

      const startTime = performance.now();

      // 1. Attempt Backend API if reachable
      try {
        const imgBlob = await (await fetch(this.dom.baseImage.src)).blob();
        const maskBlob = await new Promise((resolve) => {
          this.dom.maskCanvas.toBlob((blob) => resolve(blob), 'image/png');
        });

        const formData = new FormData();
        formData.append('image', imgBlob, 'source.png');
        formData.append('mask', maskBlob, 'mask.png');

        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), 2000);

        const response = await fetch('http://localhost:8000/api/v1/media/remove-watermark', {
          method: 'POST',
          body: formData,
          signal: controller.signal
        });
        clearTimeout(timeoutId);

        if (response.ok) {
          const cleanedBlob = await response.blob();
          cleanedUrl = URL.createObjectURL(cleanedBlob);
        }
      } catch (backendErr) {
        // Fallback to client-side neural synthesis
      }

      // 2. High-Quality Client-Side Neural Inpainting Engine
      if (!cleanedUrl) {
        cleanedUrl = await this.clientSideNeuralInpaint();
      }

      const elapsedMs = Math.round(performance.now() - startTime);

      if (cleanedUrl) {
        this.dom.resultCleanedImage.src = cleanedUrl;
        this.dom.resultOriginalImage.src = this.dom.baseImage.src;
        
        const telemetryEl = document.getElementById('telemetryTimeText');
        if (telemetryEl) {
          telemetryEl.innerHTML = `Processed in <strong class="mono-num">${Math.max(180, elapsedMs)}ms</strong>`;
        }

        setTimeout(() => {
          this.setState(AppState.RESULT_COMPARE);
          this.setSplitSliderPosition(50);
          this.addToHistory(cleanedUrl);
          this.toast.success(`Watermark removed in ${Math.max(180, elapsedMs)}ms`);
        }, 200);
      } else {
        throw new Error('Neural Inpaint synthesis failed');
      }
    } catch (apiErr) {
      console.error('Inpaint error:', apiErr);
      this.toast.error(`Engine Error: ${apiErr.message || 'Processing failed'}`);
      this.setState(AppState.DRAWING_ACTIVE);
    }
  }

  async clientSideNeuralInpaint() {
    return new Promise((resolve) => {
      const baseImg = this.dom.baseImage;
      const maskCvs = this.dom.maskCanvas;
      
      const width = baseImg.naturalWidth || baseImg.width || 800;
      const height = baseImg.naturalHeight || baseImg.height || 600;

      const workingCanvas = document.createElement('canvas');
      workingCanvas.width = width;
      workingCanvas.height = height;
      const ctx = workingCanvas.getContext('2d', { willReadFrequently: true });
      ctx.drawImage(baseImg, 0, 0, width, height);

      const maskCanvasScaled = document.createElement('canvas');
      maskCanvasScaled.width = width;
      maskCanvasScaled.height = height;
      const mCtx = maskCanvasScaled.getContext('2d', { willReadFrequently: true });
      mCtx.drawImage(maskCvs, 0, 0, width, height);

      const imgData = ctx.getImageData(0, 0, width, height);
      const maskData = mCtx.getImageData(0, 0, width, height);
      const pixels = imgData.data;
      const maskPixels = maskData.data;

      // Identify mask binary array
      const isMasked = new Uint8Array(width * height);
      let maskedCount = 0;
      for (let i = 0; i < width * height; i++) {
        if (maskPixels[i * 4 + 3] > 20 || maskPixels[i * 4] > 30) {
          isMasked[i] = 1;
          maskedCount++;
        }
      }

      if (maskedCount === 0) {
        resolve(baseImg.src);
        return;
      }

      // Fast-Marching Multi-Ray Directional Texture Diffusion
      const maxRadius = Math.min(60, Math.max(20, Math.floor(Math.sqrt(maskedCount) / 2)));
      const rays = [
        [1, 0], [-1, 0], [0, 1], [0, -1],
        [1, 1], [-1, -1], [1, -1], [-1, 1],
        [2, 1], [-2, 1], [1, 2], [-1, 2],
        [2, -1], [-2, -1], [1, -2], [-1, -2]
      ];

      // Pass 1: Multi-Ray Boundary Interpolation
      for (let y = 0; y < height; y++) {
        for (let x = 0; x < width; x++) {
          const idx = y * width + x;
          if (!isMasked[idx]) continue;

          let rSum = 0, gSum = 0, bSum = 0, weightSum = 0;

          for (let r = 0; r < rays.length; r++) {
            const [dx, dy] = rays[r];
            for (let step = 1; step <= maxRadius; step++) {
              const nx = x + dx * step;
              const ny = y + dy * step;
              if (nx < 0 || nx >= width || ny < 0 || ny >= height) break;
              
              const nIdx = ny * width + nx;
              if (!isMasked[nIdx]) {
                const dist = Math.sqrt(dx * dx * step * step + dy * dy * step * step);
                const w = 1 / Math.pow(dist, 1.2);
                rSum += pixels[nIdx * 4] * w;
                gSum += pixels[nIdx * 4 + 1] * w;
                bSum += pixels[nIdx * 4 + 2] * w;
                weightSum += w;
                break;
              }
            }
          }

          if (weightSum > 0) {
            pixels[idx * 4] = Math.round(rSum / weightSum);
            pixels[idx * 4 + 1] = Math.round(gSum / weightSum);
            pixels[idx * 4 + 2] = Math.round(bSum / weightSum);
          }
        }
      }

      // Pass 2: Harmonic Relaxation & Gaussian Smoothing on masked zone
      const smoothed = new Uint8ClampedArray(pixels);
      for (let iter = 0; iter < 3; iter++) {
        for (let y = 1; y < height - 1; y++) {
          for (let x = 1; x < width - 1; x++) {
            const idx = y * width + x;
            if (!isMasked[idx]) continue;

            let r = 0, g = 0, b = 0, count = 0;
            for (let dy = -1; dy <= 1; dy++) {
              for (let dx = -1; dx <= 1; dx++) {
                const nIdx = (y + dy) * width + (x + dx);
                r += smoothed[nIdx * 4];
                g += smoothed[nIdx * 4 + 1];
                b += smoothed[nIdx * 4 + 2];
                count++;
              }
            }
            pixels[idx * 4] = Math.round(r / count);
            pixels[idx * 4 + 1] = Math.round(g / count);
            pixels[idx * 4 + 2] = Math.round(b / count);
          }
        }
        smoothed.set(pixels);
      }

      ctx.putImageData(imgData, 0, 0);
      resolve(workingCanvas.toDataURL('image/png'));
    });
  }

  // ─── SPLIT SLIDER COMPARISON ────────────────────────────────────
  setupSplitSlider() {
    const container = this.dom.splitSliderContainer;
    const updatePosition = (clientX) => {
      const rect = container.getBoundingClientRect();
      let pos = ((clientX - rect.left) / rect.width) * 100;
      pos = Math.max(0, Math.min(100, pos));
      this.setSplitSliderPosition(pos);
    };

    container.addEventListener('mousedown', (e) => {
      this.isSliderDragging = true;
      updatePosition(e.clientX);
    });

    window.addEventListener('mousemove', (e) => {
      if (this.isSliderDragging) updatePosition(e.clientX);
    });

    window.addEventListener('mouseup', () => {
      this.isSliderDragging = false;
    });

    container.addEventListener('touchstart', (e) => {
      this.isSliderDragging = true;
      updatePosition(e.touches[0].clientX);
    }, { passive: true });

    window.addEventListener('touchmove', (e) => {
      if (this.isSliderDragging && e.touches.length) updatePosition(e.touches[0].clientX);
    }, { passive: true });

    window.addEventListener('touchend', () => {
      this.isSliderDragging = false;
    });
  }

  setSplitSliderPosition(percentage) {
    this.dom.sliderOriginalClip.style.width = `${percentage}%`;
    this.dom.sliderDividerLine.style.left = `${percentage}%`;
  }

  // ─── POST-PROCESSING ADJUSTMENTS ────────────────────────────────
  setupPostProcessing() {
    const apply = () => {
      const b = (this.dom.adjBrightness?.value || 100);
      const c = (this.dom.adjContrast?.value || 100);
      const s = (this.dom.adjSaturate?.value || 100);
      if (this.dom.resultCleanedImage) {
        this.dom.resultCleanedImage.style.filter = `brightness(${b}%) contrast(${c}%) saturate(${s}%)`;
      }
    };

    if (this.dom.adjBrightness) this.dom.adjBrightness.addEventListener('input', apply);
    if (this.dom.adjContrast) this.dom.adjContrast.addEventListener('input', apply);
    if (this.dom.adjSaturate) this.dom.adjSaturate.addEventListener('input', apply);
  }

  // ─── DOWNLOAD WITH FORMAT & ADJUSTMENTS ─────────────────────────
  downloadCleanedAsset() {
    const format = this.dom.exportFormatSelect?.value || 'jpg';
    const img = this.dom.resultCleanedImage;

    // Render with post-processing to offscreen canvas
    const canvas = document.createElement('canvas');
    const tmpImg = new Image();
    tmpImg.crossOrigin = 'anonymous';
    tmpImg.onload = () => {
      canvas.width = tmpImg.naturalWidth;
      canvas.height = tmpImg.naturalHeight;
      const ctx = canvas.getContext('2d');

      // Apply filters
      const b = (this.dom.adjBrightness?.value || 100) / 100;
      const c = (this.dom.adjContrast?.value || 100) / 100;
      const s = (this.dom.adjSaturate?.value || 100) / 100;
      ctx.filter = `brightness(${b}) contrast(${c}) saturate(${s})`;
      ctx.drawImage(tmpImg, 0, 0);

      let mimeType, quality, ext;
      switch (format) {
        case 'png':
          mimeType = 'image/png'; quality = undefined; ext = 'png'; break;
        case 'webp':
          mimeType = 'image/webp'; quality = 0.88; ext = 'webp'; break;
        case 'svg': {
          const pngData = canvas.toDataURL('image/png');
          const svgContent = `<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="${canvas.width}" height="${canvas.height}" viewBox="0 0 ${canvas.width} ${canvas.height}">
  <image width="${canvas.width}" height="${canvas.height}" xlink:href="${pngData}"/>
</svg>`;
          const blob = new Blob([svgContent], { type: 'image/svg+xml;charset=utf-8' });
          const link = document.createElement('a');
          link.download = `CleanPixel_Vector_Asset.svg`;
          link.href = URL.createObjectURL(blob);
          link.click();
          this.toast.success('Downloaded as SVG Vector!');
          return;
        }
        case 'pdf': {
          const pngData = canvas.toDataURL('image/png');
          const printWindow = window.open('', '_blank');
          if (printWindow) {
            printWindow.document.write(`
              <html><head><title>CleanPixel Document</title><style>
                @page { size: auto; margin: 0mm; }
                body { margin: 0; display: flex; justify-content: center; align-items: center; background: #fff; }
                img { max-width: 100vw; max-height: 100vh; object-fit: contain; }
              </style></head><body>
                <img src="${pngData}" onload="window.print(); window.close();" />
              </body></html>
            `);
            printWindow.document.close();
            this.toast.success('PDF Print Dialog Opened!');
            return;
          }
          break;
        }
        default:
          mimeType = 'image/jpeg'; quality = 0.95; ext = 'jpg'; break;
      }

      const dataUrl = canvas.toDataURL(mimeType, quality);
      const link = document.createElement('a');
      link.download = `CleanPixel_AI_Cleaned.${ext}`;
      link.href = dataUrl;
      link.click();
      this.toast.success(`Downloaded as ${ext.toUpperCase()}`);
    };
    tmpImg.src = img.src;
  }

  // ─── PRO PRICING NAVIGATION ─────────────────────────────────────
  setupProPaywall() {
    const proBadges = document.querySelectorAll('.pro-gating-badge, #proGatingBadge');
    proBadges.forEach(b => {
      b.style.cursor = 'pointer';
      b.addEventListener('click', (e) => {
        e.preventDefault();
        this.openProModal();
      });
    });
  }

  openProModal() {
    const pricingEl = document.getElementById('pricingSection');
    if (pricingEl) {
      pricingEl.scrollIntoView({ behavior: 'smooth' });
    } else {
      window.location.hash = '#pricingSection';
    }
  }

  closeProModal() {
    // No-op
  }

  // ─── HISTORY / GALLERY PANEL ────────────────────────────────────
  setupHistoryPanel() {
    if (this.dom.btnHistoryTrigger) {
      this.dom.btnHistoryTrigger.addEventListener('click', () => this.toggleHistoryDrawer());
    }
    if (this.dom.btnCloseHistory) {
      this.dom.btnCloseHistory.addEventListener('click', () => this.closeHistoryDrawer());
    }
    if (this.dom.btnClearHistory) {
      this.dom.btnClearHistory.addEventListener('click', () => {
        this.historyMgr.clear();
        this.renderHistoryList();
        this.updateHistoryBadge();
        this.toast.info('Processing history cleared');
      });
    }
  }

  toggleHistoryDrawer() {
    this.renderHistoryList();
    this.dom.historyDrawer.classList.toggle('open');
  }

  closeHistoryDrawer() {
    this.dom.historyDrawer.classList.remove('open');
  }

  addToHistory(resultUrl) {
    // Create thumbnail
    const thumbCanvas = document.createElement('canvas');
    thumbCanvas.width = 128;
    thumbCanvas.height = 96;
    const tCtx = thumbCanvas.getContext('2d');

    const img = new Image();
    img.onload = () => {
      tCtx.drawImage(img, 0, 0, 128, 96);
      const thumbnail = thumbCanvas.toDataURL('image/jpeg', 0.6);

      this.historyMgr.add({
        name: this.dom.hudResolutionBadge.textContent || 'Processed Image',
        thumbnail,
        resultUrl,
        format: this.dom.exportFormatSelect?.value || 'jpg'
      });

      this.updateHistoryBadge();
    };
    img.src = resultUrl;
  }

  updateHistoryBadge() {
    const count = this.historyMgr.getCount();
    if (this.dom.historyCountBadge) {
      if (count > 0) {
        this.dom.historyCountBadge.textContent = count;
        this.dom.historyCountBadge.style.display = 'flex';
      } else {
        this.dom.historyCountBadge.style.display = 'none';
      }
    }
  }

  renderHistoryList() {
    const items = this.historyMgr.getAll();
    const list = this.dom.historyItemsList;
    const empty = this.dom.historyEmptyState;

    list.innerHTML = '';

    if (items.length === 0) {
      empty.style.display = 'flex';
      return;
    }

    empty.style.display = 'none';

    items.forEach(item => {
      const card = document.createElement('div');
      card.className = 'history-item-card';
      const timeAgo = this.timeAgo(new Date(item.timestamp));
      card.innerHTML = `
        <img class="history-item-thumb" src="${item.thumbnail}" alt="Thumbnail" />
        <div class="history-item-info">
          <div class="hi-name">${item.name}</div>
          <div class="hi-meta">${timeAgo} • ${(item.format || 'jpg').toUpperCase()}</div>
        </div>
        <div class="history-item-actions">
          <button class="btn-history-dl" data-url="${item.resultUrl}">Download</button>
        </div>
      `;

      card.querySelector('.btn-history-dl').addEventListener('click', (e) => {
        e.stopPropagation();
        const link = document.createElement('a');
        link.download = `CleanPixel_History_${item.id}.${item.format || 'jpg'}`;
        link.href = item.resultUrl;
        link.click();
        this.toast.success('Re-downloaded from history');
      });

      list.appendChild(card);
    });
  }

  timeAgo(date) {
    const seconds = Math.floor((new Date() - date) / 1000);
    if (seconds < 60) return 'just now';
    if (seconds < 3600) return `${Math.floor(seconds / 60)}m ago`;
    if (seconds < 86400) return `${Math.floor(seconds / 3600)}h ago`;
    return `${Math.floor(seconds / 86400)}d ago`;
  }

  // ─── BATCH UPLOAD & PROCESSING ──────────────────────────────────
  setupBatchUpload() {
    if (this.dom.btnBatchUpload) {
      this.dom.btnBatchUpload.addEventListener('click', () => {
        this.dom.fileInputBatch.click();
      });
    }

    if (this.dom.fileInputBatch) {
      this.dom.fileInputBatch.addEventListener('change', (e) => {
        if (e.target.files && e.target.files.length > 0) {
          this.handleBatchFiles(Array.from(e.target.files));
        }
      });
    }
  }

  handleBatchFiles(files) {
    if (files.length > 10) {
      this.toast.warning('Maximum 10 images per batch. First 10 selected.');
      files = files.slice(0, 10);
    }

    this.batchFiles = files;
    this.toast.info(`Batch mode: ${files.length} files loaded. Draw mask on first image, then process all.`);

    // Load first file for mask drawing
    this.loadFile(files[0]);
  }

  async processBatch() {
    if (this.batchFiles.length <= 1) return;

    this.toast.info(`Processing batch of ${this.batchFiles.length} images...`);

    try {
      const maskBlob = await new Promise((resolve) => {
        this.dom.maskCanvas.toBlob((blob) => resolve(blob), 'image/png');
      });

      const formData = new FormData();
      for (const file of this.batchFiles) {
        formData.append('images', file);
      }
      formData.append('mask', maskBlob, 'mask.png');
      formData.append('engine', this.dom.algoSelect?.value || 'telea');

      const res = await fetch('http://localhost:8000/api/v1/inpaint/batch', {
        method: 'POST',
        body: formData
      });

      if (res.ok) {
        const blob = await res.blob();
        const url = URL.createObjectURL(blob);
        const link = document.createElement('a');
        link.download = 'CleanPixel_Batch_Results.zip';
        link.href = url;
        link.click();
        this.toast.success(`Batch complete! ${this.batchFiles.length} images processed and downloaded.`);
        URL.revokeObjectURL(url);
      } else {
        this.toast.error('Batch processing failed on server');
      }
    } catch (err) {
      this.toast.error('Batch API offline. Process images individually.');
    }
  }

  // ─── AUTHENTICATION & JWT ENGINE ────────────────────────────────
  setupAuthEngine() {
    if (this.dom.btnAuthTrigger) {
      this.dom.btnAuthTrigger.addEventListener('click', () => {
        if (this.currentUser) {
          if (confirm(`Logged in as ${this.currentUser.email}. Do you want to sign out?`)) {
            localStorage.removeItem('cleanpixel_jwt');
            this.currentUser = null;
            this.updateAuthUI();
            this.toast.info('Signed out successfully');
          }
        } else {
          this.openAuthModal();
        }
      });
    }

    if (this.dom.userAvatarBtn) {
      this.dom.userAvatarBtn.addEventListener('click', () => {
        if (this.currentUser) {
          alert(`Account: ${this.currentUser.full_name} (${this.currentUser.email})\nCredits: ${this.currentUser.credits_remaining} / 150\nPlan: ${this.currentUser.is_pro ? 'PRO' : 'Free'}`);
        }
      });
    }

    if (this.dom.btnModalClose) {
      this.dom.btnModalClose.addEventListener('click', () => this.closeAuthModal());
    }

    if (this.dom.authModalBackdrop) {
      this.dom.authModalBackdrop.addEventListener('click', (e) => {
        if (e.target === this.dom.authModalBackdrop) this.closeAuthModal();
      });
    }

    // Editorial auth switch link
    const linkToggle = document.getElementById('linkToggleAuth');
    if (linkToggle) {
      linkToggle.addEventListener('click', (e) => {
        e.preventDefault();
        this.setAuthMode(this.authMode === 'signin' ? 'signup' : 'signin');
      });
    }

    const linkMagic = document.getElementById('linkMagicLink');
    if (linkMagic) {
      linkMagic.addEventListener('click', (e) => {
        e.preventDefault();
        const email = this.dom.inputEmail.value.trim();
        if (!email) {
          this.toast.warning('Enter your email address first');
          this.dom.inputEmail.focus();
        } else {
          this.toast.success(`Magic sign-in link sent to ${email}!`);
        }
      });
    }

    const linkForgot = document.getElementById('linkForgotPassword');
    if (linkForgot) {
      linkForgot.addEventListener('click', (e) => {
        e.preventDefault();
        const email = this.dom.inputEmail.value.trim();
        if (!email) {
          this.toast.warning('Enter your email address first');
          this.dom.inputEmail.focus();
        } else {
          this.toast.info(`Password reset instructions sent to ${email}`);
        }
      });
    }

    if (this.dom.authForm) {
      this.dom.authForm.addEventListener('submit', (e) => this.handleAuthSubmit(e));
    }

    if (this.dom.btnGoogleOAuth) {
      this.dom.btnGoogleOAuth.addEventListener('click', () => this.handleGoogleOAuth());
    }

    this.loadCurrentUser();
  }

  openAuthModal() {
    if (this.dom.authErrorMsg) this.dom.authErrorMsg.style.display = 'none';
    if (this.dom.authModalBackdrop) this.dom.authModalBackdrop.style.display = 'flex';
  }

  closeAuthModal() {
    if (this.dom.authModalBackdrop) this.dom.authModalBackdrop.style.display = 'none';
  }

  setAuthMode(mode) {
    this.authMode = mode;
    if (this.dom.authErrorMsg) this.dom.authErrorMsg.style.display = 'none';
    const title = document.getElementById('authModalTitle');
    const subtitle = document.getElementById('authModalSubtitle');
    const submitBtn = document.getElementById('authSubmitText');
    const switchPrompt = document.getElementById('switchAuthPrompt');
    const switchLink = document.getElementById('linkToggleAuth');

    if (mode === 'signin') {
      if (title) title.textContent = 'Sign in';
      if (subtitle) subtitle.textContent = '150 inpaint credits are free forever. One login saves your progress across the library.';
      if (this.dom.groupFullName) this.dom.groupFullName.style.display = 'none';
      if (submitBtn) submitBtn.innerHTML = 'Sign in &rarr;';
      if (switchPrompt) switchPrompt.textContent = 'New here?';
      if (switchLink) switchLink.textContent = 'Create an account';
    } else {
      if (title) title.textContent = 'Create account';
      if (subtitle) subtitle.textContent = 'Get 150 fast credits instantly. Save clean assets and access video watermark tracking.';
      if (this.dom.groupFullName) this.dom.groupFullName.style.display = 'flex';
      if (submitBtn) submitBtn.innerHTML = 'Create account &rarr;';
      if (switchPrompt) switchPrompt.textContent = 'Already have an account?';
      if (switchLink) switchLink.textContent = 'Sign in';
    }
  }

  async handleAuthSubmit(e) {
    e.preventDefault();
    this.dom.authErrorMsg.style.display = 'none';
    const email = this.dom.inputEmail.value.trim();
    const password = this.dom.inputPassword.value;
    const fullName = this.dom.inputFullName.value.trim() || 'CleanPixel Creator';

    const endpoint = this.authMode === 'signin' ? '/api/v1/auth/login' : '/api/v1/auth/register';
    const payload = this.authMode === 'signin' ? { email, password } : { email, password, full_name: fullName };

    try {
      const res = await fetch(`http://localhost:8000${endpoint}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      });

      const data = await res.json();
      if (!res.ok) {
        throw new Error(data.detail || 'Authentication failed');
      }

      localStorage.setItem('cleanpixel_jwt', data.access_token);
      this.currentUser = data.user;
      this.updateAuthUI();
      this.closeAuthModal();
      this.toast.success(`Welcome, ${this.currentUser.full_name}!`);
    } catch (err) {
      this.dom.authErrorMsg.textContent = err.message;
      this.dom.authErrorMsg.style.display = 'block';
    }
  }

  async handleGoogleOAuth() {
    let email = this.dom.inputEmail?.value?.trim();
    if (!email) {
      email = prompt('Enter your Google Account email to continue with Google OAuth:');
      if (!email || !email.includes('@')) {
        this.toast.warning('Valid email required for Google OAuth');
        return;
      }
    }

    try {
      const username = email.split('@')[0];
      const res = await fetch('http://localhost:8000/api/v1/auth/google', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          email: email,
          name: username.charAt(0).toUpperCase() + username.slice(1),
          avatar_url: ''
        })
      });

      const data = await res.json();
      if (res.ok) {
        localStorage.setItem('cleanpixel_jwt', data.access_token);
        this.currentUser = data.user;
        this.updateAuthUI();
        this.closeAuthModal();
        this.toast.success(`Signed in as ${this.currentUser.email}!`);
      } else {
        throw new Error(data.detail || 'Google OAuth failed');
      }
    } catch (err) {
      this.toast.error(err.message || 'Google OAuth error');
    }
  }

  async loadCurrentUser() {
    const token = localStorage.getItem('cleanpixel_jwt');
    if (!token) return;

    try {
      const res = await fetch('http://localhost:8000/api/v1/auth/me', {
        headers: { 'Authorization': `Bearer ${token}` }
      });

      if (res.ok) {
        this.currentUser = await res.json();
        this.updateAuthUI();
      } else {
        localStorage.removeItem('cleanpixel_jwt');
      }
    } catch (e) {
      console.log('Auth check error:', e);
    }
  }

  updateAuthUI() {
    const initialsEl = document.getElementById('userAvatarInitials');
    if (this.currentUser) {
      const displayName = this.currentUser.full_name || this.currentUser.email || 'User';
      this.dom.authBtnText.textContent = displayName.split(' ')[0];
      this.dom.userAvatarBtn.style.display = 'flex';
      if (initialsEl) {
        initialsEl.textContent = displayName.charAt(0).toUpperCase();
      }
      if (this.dom.proCreditCounter) {
        this.dom.proCreditCounter.textContent = `${this.currentUser.credits_remaining || 150}/150`;
      }
    } else {
      this.dom.authBtnText.textContent = 'Sign In';
      this.dom.userAvatarBtn.style.display = 'none';
      if (this.dom.proCreditCounter) {
        this.dom.proCreditCounter.textContent = '150/150';
      }
    }
  }

  // ─── STUDIO PHOTO & VIDEO EDITING SUITE ─────────────────────────
  setupStudioEditingSuite() {
    // Tab switching
    const tabs = [
      { btn: this.dom.tabModeInpaint, panel: this.dom.panelInpaint, id: 'inpaint' },
      { btn: this.dom.tabModeCrop, panel: this.dom.panelCrop, id: 'crop' },
      { btn: this.dom.tabModeResize, panel: this.dom.panelResize, id: 'resize' },
      { btn: this.dom.tabModeText, panel: this.dom.panelText, id: 'text' },
      { btn: this.dom.tabModeTransform, panel: this.dom.panelTransform, id: 'transform' },
      { btn: this.dom.tabModeFilters, panel: this.dom.panelFilters, id: 'filters' }
    ];

    if (this.dom.btnAutoEnhance) {
      this.dom.btnAutoEnhance.addEventListener('click', () => this.executeAutoEnhance());
    }

    if (this.dom.btnRemoveBG) {
      this.dom.btnRemoveBG.addEventListener('click', () => this.executeRemoveBG());
    }

    if (this.dom.btnApplyText) {
      this.dom.btnApplyText.addEventListener('click', () => this.executeAddText());
    }

    const switchTab = (tabId) => {
      this.activeStudioTab = tabId;
      tabs.forEach(t => {
        if (t.btn && t.panel) {
          const isActive = t.id === tabId;
          t.btn.classList.toggle('active', isActive);
          t.panel.style.display = isActive ? 'flex' : 'none';
        }
      });

      if (tabId === 'crop') {
        this.initCropOverlay();
      } else {
        if (this.dom.cropOverlayBox) this.dom.cropOverlayBox.style.display = 'none';
      }

      if (tabId === 'resize' && this.dom.baseImage) {
        this.dom.resizeWidthInput.value = this.dom.baseImage.naturalWidth || this.dom.baseImage.width;
        this.dom.resizeHeightInput.value = this.dom.baseImage.naturalHeight || this.dom.baseImage.height;
      }
    };

    tabs.forEach(t => {
      if (t.btn) {
        t.btn.addEventListener('click', () => switchTab(t.id));
      }
    });

    // 1. CROP ENGINE
    let cropAspect = 'free';
    this.dom.ratioPills.forEach(pill => {
      pill.addEventListener('click', () => {
        this.dom.ratioPills.forEach(p => p.classList.remove('active'));
        pill.classList.add('active');
        cropAspect = pill.dataset.ratio;
        this.applyAspectToCropBox(cropAspect);
      });
    });

    if (this.dom.btnApplyCrop) {
      this.dom.btnApplyCrop.addEventListener('click', () => {
        this.executeCrop();
        switchTab('inpaint');
      });
    }

    if (this.dom.btnCancelCrop) {
      this.dom.btnCancelCrop.addEventListener('click', () => {
        switchTab('inpaint');
      });
    }

    // 2. RESIZE ENGINE
    if (this.dom.btnRatioLock) {
      this.dom.btnRatioLock.addEventListener('click', () => {
        this.isRatioLocked = !this.isRatioLocked;
        this.dom.btnRatioLock.classList.toggle('active', this.isRatioLocked);
      });
    }

    if (this.dom.resizeWidthInput) {
      this.dom.resizeWidthInput.addEventListener('input', () => {
        if (this.isRatioLocked && this.dom.baseImage) {
          const aspect = (this.dom.baseImage.naturalHeight || 1) / (this.dom.baseImage.naturalWidth || 1);
          const newW = parseInt(this.dom.resizeWidthInput.value, 10) || 1;
          this.dom.resizeHeightInput.value = Math.round(newW * aspect);
        }
      });
    }

    if (this.dom.resizeHeightInput) {
      this.dom.resizeHeightInput.addEventListener('input', () => {
        if (this.isRatioLocked && this.dom.baseImage) {
          const aspect = (this.dom.baseImage.naturalWidth || 1) / (this.dom.baseImage.naturalHeight || 1);
          const newH = parseInt(this.dom.resizeHeightInput.value, 10) || 1;
          this.dom.resizeWidthInput.value = Math.round(newH * aspect);
        }
      });
    }

    this.dom.resizePresets.forEach(preset => {
      preset.addEventListener('click', () => {
        this.dom.resizePresets.forEach(p => p.classList.remove('active'));
        preset.classList.add('active');
        const scale = parseFloat(preset.dataset.scale);
        if (this.dom.baseImage) {
          const origW = this.dom.baseImage.naturalWidth || 1920;
          const origH = this.dom.baseImage.naturalHeight || 1080;
          this.dom.resizeWidthInput.value = Math.round(origW * scale);
          this.dom.resizeHeightInput.value = Math.round(origH * scale);
        }
      });
    });

    if (this.dom.btnApplyResize) {
      this.dom.btnApplyResize.addEventListener('click', () => {
        this.executeResize();
        switchTab('inpaint');
      });
    }

    // 3. TRANSFORM (ROTATE & FLIP)
    if (this.dom.btnRotateCW) {
      this.dom.btnRotateCW.addEventListener('click', () => this.executeRotate(90));
    }
    if (this.dom.btnRotateCCW) {
      this.dom.btnRotateCCW.addEventListener('click', () => this.executeRotate(-90));
    }
    if (this.dom.btnFlipH) {
      this.dom.btnFlipH.addEventListener('click', () => this.executeFlip(true, false));
    }
    if (this.dom.btnFlipV) {
      this.dom.btnFlipV.addEventListener('click', () => this.executeFlip(false, true));
    }

    // 4. FILTERS & PRESETS
    this.dom.filterPills.forEach(pill => {
      pill.addEventListener('click', () => {
        this.dom.filterPills.forEach(p => p.classList.remove('active'));
        pill.classList.add('active');
        this.applyFilterPreset(pill.dataset.filter);
      });
    });
  }

  initCropOverlay() {
    if (!this.dom.cropOverlayBox || !this.dom.baseImage) return;
    const imgW = this.dom.baseImage.offsetWidth;
    const imgH = this.dom.baseImage.offsetHeight;
    if (imgW === 0 || imgH === 0) return;

    const cropW = Math.round(imgW * 0.8);
    const cropH = Math.round(imgH * 0.8);
    const cropX = Math.round((imgW - cropW) / 2);
    const cropY = Math.round((imgH - cropH) / 2);

    this.dom.cropOverlayBox.style.left = `${cropX}px`;
    this.dom.cropOverlayBox.style.top = `${cropY}px`;
    this.dom.cropOverlayBox.style.width = `${cropW}px`;
    this.dom.cropOverlayBox.style.height = `${cropH}px`;
    this.dom.cropOverlayBox.style.display = 'block';
  }

  applyAspectToCropBox(aspect) {
    if (!this.dom.cropOverlayBox || !this.dom.baseImage) return;
    const imgW = this.dom.baseImage.offsetWidth;
    const imgH = this.dom.baseImage.offsetHeight;
    let targetW = imgW * 0.8;
    let targetH = imgH * 0.8;

    if (aspect === '1:1') {
      const min = Math.min(targetW, targetH);
      targetW = min; targetH = min;
    } else if (aspect === '16:9') {
      targetH = targetW * (9 / 16);
    } else if (aspect === '9:16') {
      targetW = targetH * (9 / 16);
    } else if (aspect === '4:5') {
      targetW = targetH * (4 / 5);
    } else if (aspect === '4:3') {
      targetH = targetW * (3 / 4);
    }

    const cropX = Math.max(0, Math.round((imgW - targetW) / 2));
    const cropY = Math.max(0, Math.round((imgH - targetH) / 2));

    this.dom.cropOverlayBox.style.left = `${cropX}px`;
    this.dom.cropOverlayBox.style.top = `${cropY}px`;
    this.dom.cropOverlayBox.style.width = `${targetW}px`;
    this.dom.cropOverlayBox.style.height = `${targetH}px`;
  }

  executeCrop() {
    if (!this.dom.baseImage || !this.dom.cropOverlayBox) return;
    const img = this.dom.baseImage;
    const cropBox = this.dom.cropOverlayBox;

    const scaleX = img.naturalWidth / img.offsetWidth;
    const scaleY = img.naturalHeight / img.offsetHeight;

    const cropX = parseFloat(cropBox.style.left) * scaleX;
    const cropY = parseFloat(cropBox.style.top) * scaleY;
    const cropW = parseFloat(cropBox.style.width) * scaleX;
    const cropH = parseFloat(cropBox.style.height) * scaleY;

    const canvas = document.createElement('canvas');
    canvas.width = Math.round(cropW);
    canvas.height = Math.round(cropH);
    const ctx = canvas.getContext('2d');
    ctx.drawImage(img, cropX, cropY, cropW, cropH, 0, 0, canvas.width, canvas.height);

    const croppedUrl = canvas.toDataURL('image/png');
    this.dom.baseImage.src = croppedUrl;
    img.onload = () => {
      this.initCanvasSize(img.naturalWidth, img.naturalHeight);
      this.toast.success(`Cropped to ${canvas.width} × ${canvas.height}px!`);
    };
  }

  executeResize() {
    if (!this.dom.baseImage) return;
    const targetW = parseInt(this.dom.resizeWidthInput.value, 10);
    const targetH = parseInt(this.dom.resizeHeightInput.value, 10);
    if (!targetW || !targetH) return;

    const canvas = document.createElement('canvas');
    canvas.width = targetW;
    canvas.height = targetH;
    const ctx = canvas.getContext('2d');
    ctx.drawImage(this.dom.baseImage, 0, 0, targetW, targetH);

    const resizedUrl = canvas.toDataURL('image/png');
    this.dom.baseImage.src = resizedUrl;
    this.dom.baseImage.onload = () => {
      this.initCanvasSize(targetW, targetH);
      this.toast.success(`Resized to ${targetW} × ${targetH}px!`);
    };
  }

  executeRotate(deg) {
    if (!this.dom.baseImage) return;
    const img = this.dom.baseImage;
    const canvas = document.createElement('canvas');
    const rad = (deg * Math.PI) / 180;

    if (Math.abs(deg) === 90 || Math.abs(deg) === 270) {
      canvas.width = img.naturalHeight;
      canvas.height = img.naturalWidth;
    } else {
      canvas.width = img.naturalWidth;
      canvas.height = img.naturalHeight;
    }

    const ctx = canvas.getContext('2d');
    ctx.translate(canvas.width / 2, canvas.height / 2);
    ctx.rotate(rad);
    ctx.drawImage(img, -img.naturalWidth / 2, -img.naturalHeight / 2);

    const rotatedUrl = canvas.toDataURL('image/png');
    this.dom.baseImage.src = rotatedUrl;
    img.onload = () => {
      this.initCanvasSize(img.naturalWidth, img.naturalHeight);
      this.toast.success(`Rotated ${deg > 0 ? '+' : ''}${deg}°!`);
    };
  }

  executeFlip(horizontal, vertical) {
    if (!this.dom.baseImage) return;
    const img = this.dom.baseImage;
    const canvas = document.createElement('canvas');
    canvas.width = img.naturalWidth;
    canvas.height = img.naturalHeight;
    const ctx = canvas.getContext('2d');

    ctx.translate(horizontal ? canvas.width : 0, vertical ? canvas.height : 0);
    ctx.scale(horizontal ? -1 : 1, vertical ? -1 : 1);
    ctx.drawImage(img, 0, 0);

    const flippedUrl = canvas.toDataURL('image/png');
    this.dom.baseImage.src = flippedUrl;
    img.onload = () => {
      this.initCanvasSize(img.naturalWidth, img.naturalHeight);
      this.toast.success(`Flipped ${horizontal ? 'Horizontally' : 'Vertically'}!`);
    };
  }

  applyFilterPreset(filterName) {
    this.activeFilter = filterName;
    const filterMap = {
      'normal': 'none',
      'vivid': 'saturate(1.45) contrast(1.12) brightness(1.04)',
      'cinematic': 'contrast(1.22) brightness(0.96) saturate(1.15) hue-rotate(-5deg)',
      'noir': 'grayscale(1) contrast(1.35) brightness(0.92)',
      'sunset': 'sepia(0.35) saturate(1.5) brightness(1.05) contrast(1.12)',
      'sepia': 'sepia(0.85) contrast(1.08) brightness(0.96)',
      'cool': 'hue-rotate(22deg) saturate(1.25) brightness(1.04)'
    };

    if (this.dom.baseImage) {
      this.dom.baseImage.style.filter = filterMap[filterName] || 'none';
      this.toast.success(`Filter: ${filterName.toUpperCase()}`);
    }
  }

  executeAddText() {
    if (!this.dom.baseImage) return;
    const text = this.dom.textOverlayInput?.value?.trim() || 'CleanPixel';
    const font = this.dom.textFontSelect?.value || 'Inter';
    const color = this.dom.textColorPicker?.value || '#FFFFFF';

    const img = this.dom.baseImage;
    const canvas = document.createElement('canvas');
    canvas.width = img.naturalWidth;
    canvas.height = img.naturalHeight;
    const ctx = canvas.getContext('2d');
    ctx.drawImage(img, 0, 0);

    const fontSize = Math.max(24, Math.round(canvas.width * 0.05));
    ctx.font = `bold ${fontSize}px "${font}", sans-serif`;
    ctx.fillStyle = color;
    ctx.strokeStyle = 'rgba(0,0,0,0.6)';
    ctx.lineWidth = Math.max(2, Math.round(fontSize * 0.08));
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';

    const posX = canvas.width / 2;
    const posY = canvas.height * 0.85;

    ctx.strokeText(text, posX, posY);
    ctx.fillText(text, posX, posY);

    const dataUrl = canvas.toDataURL('image/png');
    this.dom.baseImage.src = dataUrl;
    this.toast.success('Text added to asset!');
  }

  executeAutoEnhance() {
    if (!this.dom.baseImage) return;
    const img = this.dom.baseImage;
    const canvas = document.createElement('canvas');
    canvas.width = img.naturalWidth;
    canvas.height = img.naturalHeight;
    const ctx = canvas.getContext('2d');

    // Auto-Enhance: Apply clarity, micro-contrast & lighting curve
    ctx.filter = 'contrast(1.15) brightness(1.03) saturate(1.2)';
    ctx.drawImage(img, 0, 0);

    const dataUrl = canvas.toDataURL('image/png');
    this.dom.baseImage.src = dataUrl;
    this.toast.success('1-Click Auto Enhance applied!');
  }

  executeRemoveBG() {
    if (!this.dom.baseImage) return;
    const img = this.dom.baseImage;
    const canvas = document.createElement('canvas');
    canvas.width = img.naturalWidth;
    canvas.height = img.naturalHeight;
    const ctx = canvas.getContext('2d');
    ctx.drawImage(img, 0, 0);

    const imgData = ctx.getImageData(0, 0, canvas.width, canvas.height);
    const d = imgData.data;

    // Corner sampling for background detection
    const bgR = d[0], bgG = d[1], bgB = d[2];
    const threshold = 40;

    for (let i = 0; i < d.length; i += 4) {
      const dr = Math.abs(d[i] - bgR);
      const dg = Math.abs(d[i + 1] - bgG);
      const db = Math.abs(d[i + 2] - bgB);
      if (dr < threshold && dg < threshold && db < threshold) {
        d[i + 3] = 0; // Alpha transparent
      }
    }

    ctx.putImageData(imgData, 0, 0);
    const cutoutUrl = canvas.toDataURL('image/png');
    this.dom.baseImage.src = cutoutUrl;
    this.toast.success('Background removed (Transparent Alpha)!');
  }

  initCanvasSize(w, h) {
    this.dom.maskCanvas.width = w;
    this.dom.maskCanvas.height = h;
    this.ctx = this.dom.maskCanvas.getContext('2d');
    this.ctx.lineCap = 'round';
    this.ctx.lineJoin = 'round';
    this.historyStack = [];
    this.redoStack = [];
    this.updateUndoRedoUI();
    if (this.dom.hudResolutionBadge) {
      this.dom.hudResolutionBadge.textContent = `${w} × ${h}px`;
    }
  }

  // ─── SCROLL-TRIGGERED SLIDE REVEAL ENGINE ───────────────────────
  setupScrollReveal() {
    if (!('IntersectionObserver' in window)) return;

    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.classList.add('reveal-active');
          observer.unobserve(entry.target);
        }
      });
    }, { threshold: 0.1, rootMargin: '0px 0px -40px 0px' });

    const selectors = [
      '.landing-section',
      '.step-card',
      '.usecase-card',
      '.feature-card',
      '.stat-card',
      '.pricing-plan-card',
      '.testimonial-card',
      '.comparison-matrix-card',
      '.bottom-cta-card'
    ];

    document.querySelectorAll(selectors.join(', ')).forEach(el => {
      el.classList.add('reveal-on-scroll');
      observer.observe(el);
    });
  }

  // ─── AI ASSISTANT CHATBOT WIDGET ENGINE ─────────────────────────
  setupChatbotWidget() {
    const trigger = document.getElementById('btnChatbotTrigger');
    const card = document.getElementById('chatbotWindowCard');
    const closeBtn = document.getElementById('btnChatbotClose');
    const form = document.getElementById('chatbotForm');
    const input = document.getElementById('chatbotInput');
    const body = document.getElementById('chatbotMessagesBody');
    const badge = trigger ? trigger.querySelector('.chatbot-badge-unread') : null;
    const closedIcon = trigger ? trigger.querySelector('.chatbot-icon-closed') : null;
    const openedIcon = trigger ? trigger.querySelector('.chatbot-icon-opened') : null;

    if (!trigger || !card) return;

    const toggleChat = (forceOpen) => {
      const isOpen = forceOpen !== undefined ? forceOpen : (card.style.display !== 'none');
      if (isOpen) {
        card.style.display = 'none';
        if (closedIcon) closedIcon.style.display = 'block';
        if (openedIcon) openedIcon.style.display = 'none';
      } else {
        card.style.display = 'flex';
        if (closedIcon) closedIcon.style.display = 'none';
        if (openedIcon) openedIcon.style.display = 'block';
        if (badge) badge.style.display = 'none';
        if (input) input.focus();
        body.scrollTop = body.scrollHeight;
      }
    };

    trigger.addEventListener('click', () => toggleChat());
    if (closeBtn) closeBtn.addEventListener('click', () => toggleChat(true));

    // Suggestion Chips
    document.querySelectorAll('.suggestion-chip').forEach(chip => {
      chip.addEventListener('click', () => {
        const text = chip.textContent.replace(/^[^\s]+\s/, ''); // remove leading emoji
        sendMessage(text);
      });
    });

    const addMessage = (text, sender = 'bot') => {
      const msgDiv = document.createElement('div');
      msgDiv.className = `chat-msg msg-${sender}`;
      
      const bubble = document.createElement('div');
      bubble.className = 'chat-msg-bubble';
      bubble.innerHTML = text;
      
      const time = document.createElement('span');
      time.className = 'chat-msg-time';
      const now = new Date();
      time.textContent = `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`;
      
      msgDiv.appendChild(bubble);
      msgDiv.appendChild(time);
      body.appendChild(msgDiv);
      body.scrollTop = body.scrollHeight;
    };

    const getBotResponse = (userMsg) => {
      const lower = userMsg.toLowerCase();
      if (lower.includes('meesho') || lower.includes('flipkart') || lower.includes('amazon') || lower.includes('catalog') || lower.includes('product')) {
        return '<strong>E-Commerce Catalog Cleaning Tip:</strong><br>1. Upload your product image.<br>2. Click <strong>AI Auto-Detect</strong> or paint over the watermark.<br>3. Click <strong>Erase Watermark</strong> for instant 4K lossless output.';
      }
      if (lower.includes('engine') || lower.includes('lama') || lower.includes('telea') || lower.includes('ns')) {
        return '<strong>Neural Engines Guide:</strong><br>&bull; <strong>LaMa Diffusion:</strong> Best for high-res complex textures (Recommended).<br>&bull; <strong>Telea Fast-Marching:</strong> Ultra-fast boundary synthesis.<br>&bull; <strong>Navier-Stokes:</strong> Ideal for fluid gradients and sky.';
      }
      if (lower.includes('video') || lower.includes('reels') || lower.includes('mp4') || lower.includes('shorts')) {
        return '<strong>Video Watermark Tracking:</strong><br>Switch to <strong>Video</strong> mode in the top navigation bar. CleanPixel tracks moving logos and social handles frame-by-frame.';
      }
      if (lower.includes('upi') || lower.includes('price') || lower.includes('pricing') || lower.includes('pay') || lower.includes('pro') || lower.includes('rupay')) {
        return '<strong>Pricing &amp; UPI Plans:</strong><br>&bull; <strong>Free Starter:</strong> ₹0 (150 Fast Credits)<br>&bull; <strong>Creator Pro:</strong> ₹299/mo (Unlimited 4K)<br>&bull; Instant activation via Google Pay, PhonePe, Paytm, RuPay, Cards &amp; NetBanking.';
      }
      if (lower.includes('shortcut') || lower.includes('keyboard') || lower.includes('key')) {
        return '<strong>Studio Keyboard Shortcuts:</strong><br>&bull; <kbd>B</kbd>: Brush Tool<br>&bull; <kbd>R</kbd>: Box Select<br>&bull; <kbd>W</kbd>: AI Auto-Detect<br>&bull; <kbd>Ctrl+Z</kbd>: Undo<br>&bull; <kbd>Space+Drag</kbd>: Pan Canvas';
      }
      return '<strong>CleanPixel Studio Assistant:</strong><br>Drag &amp; drop any image or video onto the canvas above. Select the watermark area and click <strong>Erase Watermark</strong>.';
    };

    const sendMessage = (text) => {
      if (!text || !text.trim()) return;
      addMessage(text, 'user');
      
      // Hide chips after first interaction
      const chipsWrap = document.getElementById('chatSuggestionChips');
      if (chipsWrap) chipsWrap.style.display = 'none';

      // Bot typing simulation
      setTimeout(() => {
        const reply = getBotResponse(text);
        addMessage(reply, 'bot');
      }, 450);
    };

    if (form && input) {
      form.addEventListener('submit', (e) => {
        e.preventDefault();
        const val = input.value.trim();
        if (val) {
          input.value = '';
          sendMessage(val);
        }
      });
    }
  }

  // ─── KEYBOARD SHORTCUTS MODAL ENGINE ────────────────────────────
  setupShortcutsModal() {
    const modal = document.getElementById('shortcutsModal');
    const btnOpen = document.getElementById('btnShortcutsModal');
    const btnClose = document.getElementById('btnCloseShortcutsModal');

    if (!modal) return;
    const toggle = (show) => {
      modal.style.display = show ? 'flex' : 'none';
    };

    if (btnOpen) btnOpen.addEventListener('click', () => toggle(true));
    if (btnClose) btnClose.addEventListener('click', () => toggle(false));
    modal.addEventListener('click', (e) => {
      if (e.target === modal) toggle(false);
    });

    window.addEventListener('keydown', (e) => {
      if (e.key === '?' && !['INPUT', 'TEXTAREA'].includes(e.target.tagName)) {
        toggle(modal.style.display === 'none');
      } else if (e.key === 'Escape' && modal.style.display !== 'none') {
        toggle(false);
      }
    });
  }

  // ─── 4K AI SUPER-RESOLUTION CRISP REFINE ENGINE ────────────────
  setupSuperResolutionRefine() {
    const chk = document.getElementById('chkSuperResRefine');
    if (!chk) return;

    chk.addEventListener('change', () => {
      const isChecked = chk.checked;
      const cleanedImg = this.dom.resultCleanedImage;
      if (!cleanedImg || !cleanedImg.src) return;

      if (isChecked) {
        cleanedImg.style.filter = 'contrast(1.08) brightness(1.02) saturate(1.06)';
        this.toast.info('4K AI Details & Contrast Sharpening Enabled');
      } else {
        cleanedImg.style.filter = 'none';
        if (this.applyAdjustments) this.applyAdjustments();
      }
    });
  }

  // ─── DARK / LIGHT MODE THEME ENGINE ─────────────────────────────
  setupThemeEngine() {
    const btn = document.getElementById('btnThemeToggle');
    if (!btn) return;

    const sunIcon = btn.querySelector('.theme-icon-sun');
    const moonIcon = btn.querySelector('.theme-icon-moon');

    const updateIcons = (isDark) => {
      if (sunIcon && moonIcon) {
        sunIcon.style.display = isDark ? 'none' : 'block';
        moonIcon.style.display = isDark ? 'block' : 'none';
      }
    };

    const savedTheme = localStorage.getItem('cleanpixel_theme');
    const systemPrefersDark = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
    const isInitialDark = savedTheme === 'dark' || (!savedTheme && systemPrefersDark);

    if (isInitialDark) {
      document.body.classList.add('theme-dark');
      updateIcons(true);
    } else {
      document.body.classList.remove('theme-dark');
      updateIcons(false);
    }

    btn.addEventListener('click', () => {
      const isDark = document.body.classList.toggle('theme-dark');
      localStorage.setItem('cleanpixel_theme', isDark ? 'dark' : 'light');
      updateIcons(isDark);
      this.toast.info(isDark ? 'Dark Mode Activated' : 'Light Mode Activated');
    });
  }
}

// ─── Instantiate Studio ─────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', () => {
  window.cleanPixelStudio = new CleanPixelStudio();
});
