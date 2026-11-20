# PDF password helper

Run this from the `RipPDF` folder:

```bash
./pdf-password.sh "Account Statement  - July 2025.pdf"
```

The helper searches numeric passwords from four through six digits. The first run downloads and builds PDFCrack into `.pdfcrack`; later runs reuse that local build. Your PDFs are not modified.
