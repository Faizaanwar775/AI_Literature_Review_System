from pydantic import BaseModel
from typing import List, Optional

class PaperMetadata(BaseModel):
    title: str
    authors: List[str]
    year: str
    abstract: str

class DeepAnalysis(BaseModel):
    problem_statement: str
    methodology: str
    key_findings: str
    limitations: str
    future_work: str

class ExtractedPaper(BaseModel):
    id: str
    metadata: PaperMetadata
    deep_analysis: DeepAnalysis
    citations: List[str]
    keywords: List[str]

class LitReviewRequest(BaseModel):
    paper_ids: List[str]
    topic: str