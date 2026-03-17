# =============================================================================
# PATASHALA BACKEND — COMPLETE CODE
# =============================================================================
# File structure this covers:
#   backend/app/db.py
#   backend/app/models.py
#   backend/app/cache.py
#   backend/app/trig_engine.py
#   backend/app/main.py
# =============================================================================


# =============================================================================
# 1. db.py — PostgreSQL Connection & Session
# =============================================================================

import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from dotenv import load_dotenv

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# =============================================================================
# 2. models.py — SQLAlchemy Database Models
# =============================================================================

from sqlalchemy import Column, Integer, String, JSON, Text

class Topic(Base):
    __tablename__ = "topics"

    id          = Column(Integer, primary_key=True, index=True)
    slug        = Column(String, unique=True, index=True)   # e.g. "sine-wave"
    name        = Column(String)                             # e.g. "Sine Wave"
    subject     = Column(String)                             # e.g. "Trigonometry"
    viz_type    = Column(String)                             # "chart" | "simulation" | "animation"
    config      = Column(JSON)                               # parameters for the viz engine
    description = Column(Text, nullable=True)


# =============================================================================
# 3. cache.py — Redis Connection & Utilities
# =============================================================================

import json
import redis

REDIS_URL = os.getenv("REDIS_URL", "redis://localhost:6379")
redis_client = redis.from_url(REDIS_URL, decode_responses=True)

def get_cached(key: str):
    value = redis_client.get(key)
    if value:
        return json.loads(value)
    return None

def set_cache(key: str, data: dict, ttl: int = 3600):
    redis_client.setex(key, ttl, json.dumps(data))


# =============================================================================
# 4. trig_engine.py — Visualization Computation Logic
# =============================================================================

import numpy as np

def generate_visualization(viz_type: str, config: dict) -> dict:
    if viz_type == "sine_wave":
        return _sine_wave(config)
    elif viz_type == "cosine_wave":
        return _cosine_wave(config)
    elif viz_type == "unit_circle":
        return _unit_circle(config)
    else:
        return {"error": f"Unknown viz_type: {viz_type}"}

def _sine_wave(config: dict) -> dict:
    amplitude = config.get("amplitude", 1)
    frequency = config.get("frequency", 1)
    x = np.linspace(0, 2 * np.pi, 300)
    y = amplitude * np.sin(frequency * x)
    return {
        "viz_type": "sine_wave",
        "x": x.tolist(),
        "y": y.tolist(),
        "x_label": "Angle (radians)",
        "y_label": "sin(x)",
        "title": config.get("title", "Sine Wave"),
    }

def _cosine_wave(config: dict) -> dict:
    amplitude = config.get("amplitude", 1)
    frequency = config.get("frequency", 1)
    x = np.linspace(0, 2 * np.pi, 300)
    y = amplitude * np.cos(frequency * x)
    return {
        "viz_type": "cosine_wave",
        "x": x.tolist(),
        "y": y.tolist(),
        "x_label": "Angle (radians)",
        "y_label": "cos(x)",
        "title": config.get("title", "Cosine Wave"),
    }

def _unit_circle(config: dict) -> dict:
    angles = np.linspace(0, 2 * np.pi, 360)
    return {
        "viz_type": "unit_circle",
        "circle_x": np.cos(angles).tolist(),
        "circle_y": np.sin(angles).tolist(),
        "title": "Unit Circle",
    }


# =============================================================================
# 5. main.py — FastAPI App, Routes & Startup
# =============================================================================

from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session

# Create all database tables on startup
Base.metadata.create_all(bind=engine)

from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="Patashala API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/health")
def health_check():
    return {"status": "ok"}

@app.get("/api/topics")
def list_topics(db: Session = Depends(get_db)):
    topics = db.query(Topic).all()
    return [
        {
            "id": t.id,
            "slug": t.slug,
            "name": t.name,
            "subject": t.subject
        }
        for t in topics
    ]


@app.get("/api/topics/{slug}")
def get_topic(slug: str, db: Session = Depends(get_db)):
    # Step 1 — Check Redis cache
    cached = get_cached(f"topic:{slug}")
    if cached:
        return cached

    # Step 2 — Query PostgreSQL
    topic = db.query(Topic).filter(Topic.slug == slug).first()
    if not topic:
        raise HTTPException(status_code=404, detail="Topic not found")

    # Step 3 — Generate visual payload
    payload = generate_visualization(topic.viz_type, topic.config or {})
    payload["name"]        = topic.name
    payload["description"] = topic.description

    # Step 4 — Cache result and return
    set_cache(f"topic:{slug}", payload)
    return payload
