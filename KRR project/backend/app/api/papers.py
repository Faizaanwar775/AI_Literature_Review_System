from fastapi import APIRouter, UploadFile, File, HTTPException
from app.services.pdf_service import extract_text_from_pdf
from app.services.ai_service import analyze_paper
import uuid

router = APIRouter()

# Mock Database
db_papers = {}

@router.post("/upload")
async def upload_and_analyze_pdf(file: UploadFile = File(...)):
    if not file.filename.endswith('.pdf'):
        raise HTTPException(400, "Invalid file type. PDF required.")
    
    file_bytes = await file.read()
    text = await extract_text_from_pdf(file_bytes)
    
    # Run AI Analysis
    try:
        analysis = await analyze_paper(text)
        paper_id = str(uuid.uuid4())
        
        # Save to mock DB
        db_papers[paper_id] = {"id": paper_id, **analysis}
        
        return {"status": "success", "data": db_papers[paper_id]}
    except Exception as e:
        raise HTTPException(500, f"Analysis failed: {str(e)}")

@router.get("/{paper_id}")
async def get_paper(paper_id: str):
    if paper_id not in db_papers:
        raise HTTPException(404, "Paper not found")
    return db_papers[paper_id]