#Explainable BEARING FAULT DIAGNOSIS BY DEEP LEARNING

This repository presents an **interpretable deep learning framework** for **rolling element bearing fault diagnosis**. The methodology combines **raw vibration signal modeling**, **frequency domain transformation**, and **explainability tools** (SHAP) for insightful diagnostics aligned with physical fault frequencies.

---

## 📌 Key Contributions

- A **1D Convolutional Neural Network (1D-CNN)** was trained directly on **raw time-domain vibration data**, leveraging the temporal and phase characteristics of the signal for high classification accuracy.

- A **sliding-window inference method** was implemented. Each windowed segment of the test signal was independently predicted, followed by a **majority vote** strategy to determine the final diagnosis.

- A **harmonic spectral energy analysis** was applied to identify which windows contribute most to the model’s decisions. The five most energy-rich segments (based on harmonic energy of the first 5 harmonics) were selected for deeper interpretation.

- A custom **Differentiable Discrete Fourier Transform (DFT) Layer** was integrated into the network architecture to allow **frequency-aware learning** without breaking the end-to-end differentiability of the deep learning pipeline.

- To increase transparency, **SHAP (SHapley Additive exPlanations)** was used on selected high-energy segments. This revealed **frequency components that drive the model's predictions**, particularly aligning with known fault harmonics.

- The SHAP analysis revealed distinct peaks at the **1st, 2nd, and 3rd harmonics** of characteristic fault frequencies (e.g., BPFO, BPFI), showing that **the model's learned features are consistent with engineering domain knowledge**.

---

## Workflow Overview

1. **MATLAB Preprocessing**  
   Raw bearing signals are segmented, labeled, and exported as `.csv` files using:
   - `1_convert_to_matrix.m`
   - `2_split_segments.m`
   - `3_generate_labels.m`

2. **Model Development (Python/Colab)**  
   - Trains 1D-CNN on raw time-domain data.
   - Uses a custom `DFTLayer` to convert signals into frequency space.
   - Applies SHAP for model interpretability.

3. **Explainability & Visualization**  
   - SHAP values are overlaid on FFT magnitude plots.
   - Fault frequencies (BPFI, BPFO, BSF, FTF) are marked for comparison.

##Results Summary

## Results Summary

| Metric              | Raw Time-Series (1DCNN) | FFT-Transformed Data (DFT + 1DCNN) |
|---------------------|-------------------------|------------------------------------|
| Training Accuracy    | 99.59%                  | 99.36%                             |
| Validation Accuracy  | 99.69%                  | 99.63%                             |
| **Testing Accuracy** | **93.14%**              | **82.22%**                        |

---

##Why Interpretability Matters

In industrial diagnostics, a prediction alone is not enough — **engineers must understand the reasoning** behind a fault classification. This project bridges that gap by:
- Linking learned features to known fault frequencies.
- Revealing inner model mechanisms through SHAP values.

