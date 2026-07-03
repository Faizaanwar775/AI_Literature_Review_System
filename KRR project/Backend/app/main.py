import uuid
from datetime import datetime

from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List

from app.api.auth import router as auth_router
from app.services import pdf_service
from app.services.ai_service import analyze_paper, compare_papers, generate_literature_review

app = FastAPI(title="KRR — AI Literature Review System", version="1.1.0")

# CORS — allow the Vite dev server (and any origin in dev)
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:5173",
        "http://127.0.0.1:5173",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth_router, prefix="/api/v1/auth", tags=["Auth"])

# In-memory paper store (single source of truth for this session)
db_papers: dict = {}


# ── Pydantic request models ──────────────────────────────────────────────────

class CompareRequest(BaseModel):
    paper_ids: List[str]

class ReviewRequest(BaseModel):
    topic: str
    paper_ids: List[str]


# ── Helper ───────────────────────────────────────────────────────────────────

def _extract_year(metadata: dict) -> str:
    """Try to extract publication year from PDF metadata, fall back to current year."""
    # PyMuPDF exposes 'creationDate' as e.g. "D:20240315120000+00'00'"
    raw = metadata.get("creationDate", "") or metadata.get("modDate", "")
    if raw.startswith("D:") and len(raw) >= 6:
        try:
            return raw[2:6]  # Extract YYYY portion
        except Exception:
            pass
    return str(datetime.now().year)


# ── Endpoints ────────────────────────────────────────────────────────────────

@app.get("/api/library")
async def get_library():
    """Return all papers in the in-memory library."""
    return list(db_papers.values())


@app.post("/api/upload")
async def upload_paper(file: UploadFile = File(...)):
    """Upload a PDF, run AI analysis, and store in the library."""
    if not file.filename.lower().endswith(".pdf"):
        raise HTTPException(status_code=400, detail="Only PDF files are supported.")

    # 1. Extract text + metadata from the PDF
    pdf_data = await pdf_service.process_pdf(file)

    # 2. Run AI analysis on extracted text
    analysis_result = await analyze_paper(pdf_data["text"])

    # 3. Build and persist the paper record
    paper_id = str(uuid.uuid4())
    metadata = pdf_data.get("metadata", {})

    db_papers[paper_id] = {
        "id": paper_id,
        "title": metadata.get("title") or file.filename.replace(".pdf", "") or "Unknown Title",
        "authors": metadata.get("author") or "Unknown Author",
        "year": _extract_year(metadata),
        # First 1000 chars as an abstract preview
        "abstract_summary": pdf_data["text"][:1000] + "…",
        # Full AI analysis nested here — consumed by AnalysisView tabs
        "deep_analysis": analysis_result,
        # Top-level gaps shortcut — consumed by the Research Gaps sidebar card
        "gaps": analysis_result.get("gaps", []),
    }

    print(f"✅ Paper stored: {paper_id} — '{db_papers[paper_id]['title']}'")
    return {"status": "success", "data": db_papers[paper_id]}


@app.post("/api/compare")
async def api_compare_papers(request: CompareRequest):
    """Compare two (or more) papers already in the library."""
    valid_ids = [pid for pid in request.paper_ids if pid in db_papers]
    if len(valid_ids) < 2:
        raise HTTPException(
            status_code=400,
            detail="At least 2 valid paper IDs are required for comparison."
        )

    # Use the AI-extracted deep analysis for richer comparisons
    def _paper_context(pid: str) -> str:
        p = db_papers[pid]
        da = p.get("deep_analysis", {}) or {}
        return (
            f"Title: {p.get('title', 'Unknown')}\n"
            f"Research Problem: {da.get('research_problem', 'N/A')}\n"
            f"Methodology: {str(da.get('methodology', 'N/A'))[:500]}\n"
            f"Results: {str(da.get('results', 'N/A'))[:500]}\n"
            f"Limitations: {str(da.get('limitations', 'N/A'))[:300]}"
        )

    text1 = _paper_context(valid_ids[0])
    text2 = _paper_context(valid_ids[1])

    result = await compare_papers(text1, text2)
    return {"status": "success", "data": result}


@app.post("/api/generate-review")
async def api_generate_review(request: ReviewRequest):
    """Generate a literature review from a topic + list of paper IDs."""
    if not request.topic or not request.topic.strip():
        raise HTTPException(status_code=400, detail="A topic is required.")

    valid_papers = [db_papers[pid] for pid in request.paper_ids if pid in db_papers]
    if not valid_papers:
        raise HTTPException(
            status_code=400,
            detail="No valid papers found for the given IDs. Upload papers first."
        )

    review = await generate_literature_review(request.topic, valid_papers)
    return {
        "status": "success",
        "data": {
            "topic": request.topic,
            "papers_analyzed": len(valid_papers),
            "review_content": review,
        }
    }


# ── Dev entry point ──────────────────────────────────────────────────────────
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)