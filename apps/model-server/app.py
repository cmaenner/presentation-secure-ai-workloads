"""Mock AI inference server for the security demo."""

import logging
import os
import time

from fastapi import FastAPI, Request
from pydantic import BaseModel

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("model-server")

app = FastAPI(title="AI Model Server", version="0.1.0")

MODEL_NAME = os.getenv("MODEL_NAME", "demo-llm-v1")
request_count = 0


class InferRequest(BaseModel):
    prompt: str


class InferResponse(BaseModel):
    model: str
    result: str
    token_count: int
    latency_ms: float


@app.get("/healthz")
def healthz():
    return {"status": "ok"}


@app.post("/infer", response_model=InferResponse)
def infer(req: InferRequest, request: Request):
    global request_count
    request_count += 1
    start = time.time()

    caller_ip = request.client.host if request.client else "unknown"
    logger.info(f"[req #{request_count}] from={caller_ip} prompt={req.prompt[:80]}")

    latency = (time.time() - start) * 1000
    return InferResponse(
        model=MODEL_NAME,
        result=f"Mock response for: {req.prompt}",
        token_count=42,
        latency_ms=round(latency, 2),
    )


@app.get("/metrics")
def metrics():
    return {"total_requests": request_count, "model": MODEL_NAME}
