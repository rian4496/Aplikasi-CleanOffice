const functions = require("firebase-functions");
const admin = require("firebase-admin");
const os = require("os");
const path = require("path");
const fs = require("fs");
const ExcelJS = require("exceljs");
const puppeteer = require("puppeteer");
const archiver = require("archiver");

admin.initializeApp();

const storage = admin.storage();

/**
 * Generates the HTML content for a single receipt.
 * @param {object} data The data for the receipt.
 * @return {string} The HTML string.
 */
function getReceiptHtml(data) {
  return `
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8" />
        <title>Kwitansi</title>
        <style>
            body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; margin: 40px; font-size: 14px; }
            .kwitansi-box { max-width: 800px; margin: auto; padding: 30px; border: 1px solid #eee; box-shadow: 0 0 10px rgba(0, 0, 0, 0.15); }
            .header { text-align: center; margin-bottom: 20px; }
            .header h1 { margin: 0; font-size: 24px; }
            .info-table { width: 100%; line-height: inherit; text-align: left; }
            .info-table td { padding: 5px; vertical-align: top; }
            .info-table .label { font-weight: bold; width: 150px; }
            .terbilang { font-style: italic; background-color: #f2f2f2; padding: 15px; border-radius: 5px; margin-top: 20px; }
            .footer { text-align: right; margin-top: 50px; }
        </style>
    </head>
    <body>
        <div class="kwitansi-box">
            <div class="header">
                <h1>KWITANSI</h1>
                <span>No: ${data.NoKwitansi || ''}</span>
            </div>
            <table class="info-table">
                <tr><td class="label">Telah terima dari</td><td>: ${data.NamaPenerima || ''}</td></tr>
                <tr><td class="label">Uang sejumlah</td><td>: Rp ${new Intl.NumberFormat('id-ID').format(data.JumlahUang || 0)}</td></tr>
                <tr><td class="label">Untuk pembayaran</td><td>: ${data.Keterangan || ''}</td></tr>
            </table>
            <div class="terbilang">
                <strong>Terbilang:</strong> ${data.Terbilang || ''}
            </div>
            <div class="footer">
                Jakarta, ${data.Tanggal ? new Date(data.Tanggal).toLocaleDateString('id-ID', { day: 'numeric', month: 'long', year: 'numeric' }) : ''}<br /><br /><br />
                (___________________)
            </div>
        </div>
    </body>
    </html>
  `;
}

exports.processExcelAndGeneratePdf = functions.region('asia-southeast2').https.onCall(async (data, context) => {
  // 1. Authenticate user
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'The function must be called while authenticated.');
  }

  const filePath = data.filePath;
  if (!filePath) {
    throw new functions.https.HttpsError('invalid-argument', 'The function must be called with one argument "filePath".');
  }

  const bucket = storage.bucket();
  const tempExcelPath = path.join(os.tmpdir(), path.basename(filePath));
  const pdfOutputDir = path.join(os.tmpdir(), 'pdf_outputs');
  fs.mkdirSync(pdfOutputDir, { recursive: true });

  try {
    // 2. Download Excel file from Storage
    await bucket.file(filePath).download({ destination: tempExcelPath });

    // 3. Read and parse Excel
    const workbook = new ExcelJS.Workbook();
    await workbook.xlsx.readFile(tempExcelPath);
    const worksheet = workbook.worksheets[0];
    const pdfPromises = [];
    const generatedPdfPaths = [];

    const browser = await puppeteer.launch({ args: ['--no-sandbox'] });
    const page = await browser.newPage();

    // Loop through rows (skip header)
    for (let i = 2; i <= worksheet.rowCount; i++) {
      const row = worksheet.getRow(i);
      const rowData = {
        NoKwitansi: row.getCell(1).value,
        Tanggal: row.getCell(2).value,
        NamaPenerima: row.getCell(3).value,
        JumlahUang: row.getCell(4).value,
        Terbilang: row.getCell(5).value,
        Keterangan: row.getCell(6).value,
      };

      // 4. Generate PDF for each row
      const htmlContent = getReceiptHtml(rowData);
      await page.setContent(htmlContent, { waitUntil: 'networkidle0' });
      
      const pdfPath = path.join(pdfOutputDir, `kwitansi-${rowData.NoKwitansi || i}.pdf`);
      await page.pdf({ path: pdfPath, format: 'A4' });
      generatedPdfPaths.push(pdfPath);
    }

    await browser.close();

    if (generatedPdfPaths.length === 0) {
      throw new Error("Tidak ada data yang bisa diproses di file Excel.");
    }

    let finalFilePath;
    let finalFileName;
    const timestamp = Date.now();
    const userId = context.auth.uid;

    // 5. Zip PDFs if more than one
    if (generatedPdfPaths.length > 1) {
      finalFileName = `results/${userId}-${timestamp}-kwitansi.zip`;
      finalFilePath = path.join(os.tmpdir(), 'kwitansi.zip');
      const output = fs.createWriteStream(finalFilePath);
      const archive = archiver('zip', { zlib: { level: 9 } });

      const streamEnd = new Promise((resolve, reject) => {
        output.on('close', resolve);
        archive.on('error', reject);
      });

      archive.pipe(output);
      generatedPdfPaths.forEach(p => {
        archive.file(p, { name: path.basename(p) });
      });
      await archive.finalize();
      await streamEnd; // Wait for stream to finish

    } else {
      finalFileName = `results/${userId}-${timestamp}-kwitansi.pdf`;
      finalFilePath = generatedPdfPaths[0];
    }

    // 6. Upload result to Storage
    const [uploadedFile] = await bucket.upload(finalFilePath, {
      destination: finalFileName,
      metadata: { contentType: finalFileName.endsWith('.zip') ? 'application/zip' : 'application/pdf' },
    });

    // 7. Return signed URL
    const signedUrl = await uploadedFile.getSignedUrl({
      action: 'read',
      expires: Date.now() + 1000 * 60 * 15, // 15 minutes
    });

    return { downloadUrl: signedUrl[0] };

  } catch (error) {
    console.error("Error processing file:", error);
    throw new functions.https.HttpsError('internal', error.message, error);
  } finally {
    // Cleanup temporary files
    fs.unlinkSync(tempExcelPath);
    fs.rmSync(pdfOutputDir, { recursive: true, force: true });
  }
});
