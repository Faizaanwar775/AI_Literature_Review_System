from fastapi import APIRouter, HTTPException, Depends
from typing import List
import json
from app.core.models import LitReviewRequest
from app.services.ai_service import generate_literature_review
from app.api.auth import get_current_user

# Note: We import db_papers from papers.py just for this mock example.
# In production, you would fetch these by ID from PostgreSQL/MongoDB.
from app.api.papers import db_papers 

router = APIRouter()

@router.post("/generate")
async def create_literature_review(
    request: LitReviewRequest, 
    current_user: str = Depends(get_current_user)
):
    """
    Takes an array of paper IDs and a topic, aggregates their deep analysis,
    and generates a full academic literature review write-up.
    """
    if len(request.paper_ids) < 2:
        raise HTTPException(
            status_code=400, 
            detail="Please select at least 2 papers for a cross-paper literature review."
        )

    aggregated_data = []
    
    for pid in request.paper_ids:
        if pid not in db_papers:
            raise HTTPException(status_code=404, detail=f"Paper with ID {pid} not found in database.")
        
        # Extract only the critical information to prevent exceeding LLM context windows
        paper = db_papers[pid]
        summary_context = {
            "title": paper.get("title", "Unknown Title"),
            "authors": paper.get("authors", []),
            "research_problem": paper.get("research_problem", ""),
            "methodology": paper.get("methodology", ""),
            "results": paper.get("results", ""),
            "limitations": paper.get("limitations", "")
        }
        aggregated_data.append(summary_context)

    # Convert the Python dictionary payload to a formatted JSON string for the AI prompt
    context_string = json.dumps(aggregated_data, indent=2)

    try:
        # Call the AI service from ai_service.py
        review_markdown = await generate_literature_review(request.topic, context_string)
        
        return {
            "status": "success",
            "data": {
                "topic": request.topic,
                "papers_analyzed": len(request.paper_ids),
                "review_content": review_markdown # Returns Markdown string for the frontend to render
            }
        }
    except Exception as e:
        raise HTTPException(
            status_code=500, 
            detail=f"Literature review generation failed: {str(e)}"
        )