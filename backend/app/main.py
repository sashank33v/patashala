from typing import Any
from urllib.parse import urlencode

from fastapi import Depends, FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.cache import cache_client
from app.db import Base, engine, get_db
from app.engines.mensuration_engine import MensurationEngine
from app.engines.trig_engine import TrigEngine
from app.models import AuthUser, Progress, User
from app.schemas import (
    LoginRequest,
    ProgressCreate,
    ProgressOut,
    RegisterRequest,
    UserCreate,
)
from app.topic_catalog import TOPIC_BY_ID, TOPICS

app = FastAPI(title="Patashala API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

Base.metadata.create_all(bind=engine)


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}


@app.post("/auth/register")
def register(payload: RegisterRequest, db: Session = Depends(get_db)) -> dict[str, Any]:
    existing = db.query(AuthUser).filter(AuthUser.username == payload.username).first()
    if existing:
        raise HTTPException(status_code=400, detail="Username already exists")

    user = User(name=payload.name)
    db.add(user)
    db.commit()
    db.refresh(user)

    auth = AuthUser(user_id=user.id, username=payload.username, password=payload.password)
    db.add(auth)
    db.commit()

    return {"user_id": user.id, "name": user.name, "username": auth.username}


@app.post("/auth/login")
def login(payload: LoginRequest, db: Session = Depends(get_db)) -> dict[str, Any]:
    auth = db.query(AuthUser).filter(AuthUser.username == payload.username).first()
    if not auth or auth.password != payload.password:
        raise HTTPException(status_code=401, detail="Invalid username or password")

    user = db.query(User).filter(User.id == auth.user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    return {"user_id": user.id, "name": user.name, "username": auth.username}


@app.post("/users")
def create_user(payload: UserCreate, db: Session = Depends(get_db)) -> dict[str, Any]:
    user = User(name=payload.name)
    db.add(user)
    db.commit()
    db.refresh(user)
    return {"id": user.id, "name": user.name}


@app.get("/topics")
def get_topics() -> list[dict[str, Any]]:
    return TOPICS


@app.get("/visualization/{topic_id}")
def get_visualization(
    topic_id: str,
    request: Request,
) -> dict[str, Any]:
    topic = TOPIC_BY_ID.get(topic_id)
    if not topic:
        raise HTTPException(status_code=404, detail="Topic not found")

    params = {
        key: value
        for key, value in request.query_params.items()
        if value not in (None, "")
    }

    key = f"viz:{topic_id}:{urlencode(sorted(params.items()))}"
    cached = cache_client.get_json(key)
    if cached:
        return cached

    if topic["engine"] == "trig":
        payload = TrigEngine.build(topic["visualization_key"], params)
    else:
        payload = MensurationEngine.build(topic["visualization_key"], params)

    response = {
        "topic": {
            "id": topic["id"],
            "title": topic["title"],
            "subject": topic["subject"],
            "description": topic["description"],
        },
        "visualization": payload,
    }

    cache_client.set_json(key, response)
    return response


@app.get("/presets/{topic_id}")
def get_presets(topic_id: str) -> dict[str, Any]:
    topic = TOPIC_BY_ID.get(topic_id)
    if not topic:
        raise HTTPException(status_code=404, detail="Topic not found")
    return {
        "topic_id": topic_id,
        "presets": topic.get("presets", []),
    }


@app.post("/progress", response_model=ProgressOut)
def save_progress(payload: ProgressCreate, db: Session = Depends(get_db)) -> Progress:
    if payload.topic not in TOPIC_BY_ID:
        raise HTTPException(status_code=400, detail="Invalid topic")

    user = db.query(User).filter(User.id == payload.user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    existing = db.query(Progress).filter(
        Progress.user_id == payload.user_id,
        Progress.topic == payload.topic,
    ).first()

    if existing:
        existing.completed = payload.completed
        progress = existing
    else:
        progress = Progress(
            user_id=payload.user_id,
            topic=payload.topic,
            completed=payload.completed,
        )
        db.add(progress)

    db.commit()
    db.refresh(progress)
    return progress


@app.get("/progress/{user_id}")
def get_progress(user_id: int, db: Session = Depends(get_db)) -> dict[str, Any]:
    completed_rows = db.query(Progress).filter(
        Progress.user_id == user_id,
        Progress.completed.is_(True),
    ).all()
    completed_topics = [row.topic for row in completed_rows]

    by_subject = {
        "Trigonometry": [t for t in TOPICS if t["subject"] == "Trigonometry"],
        "Mensuration": [t for t in TOPICS if t["subject"] == "Mensuration"],
    }

    summary = {}
    for subject, topic_list in by_subject.items():
        total = len(topic_list)
        done = sum(1 for topic in topic_list if topic["id"] in completed_topics)
        summary[subject] = {
            "completed": done,
            "total": total,
            "percent": round((done / total) * 100, 1) if total else 0,
        }

    badges = []
    if len(completed_topics) >= 2:
        badges.append("Explorer")
    if summary["Trigonometry"]["percent"] == 100:
        badges.append("Triangle Star")
    if summary["Mensuration"]["percent"] == 100:
        badges.append("Area Hero")

    return {
        "user_id": user_id,
        "completed_topics": completed_topics,
        "summary": summary,
        "badges": badges,
    }


@app.get("/recommendation/{user_id}")
def get_recommendation(user_id: int, db: Session = Depends(get_db)) -> dict[str, Any]:
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    completed_rows = db.query(Progress).filter(
        Progress.user_id == user_id,
        Progress.completed.is_(True),
    ).all()
    completed = {row.topic for row in completed_rows}

    next_topic = next((topic for topic in TOPICS if topic["id"] not in completed), None)

    if next_topic:
        return {
            "user_id": user_id,
            "message": "Keep going! This is your next best topic.",
            "topic": {
                "id": next_topic["id"],
                "title": next_topic["title"],
                "subject": next_topic["subject"],
                "description": next_topic["description"],
            },
            "remaining": len(TOPICS) - len(completed),
        }

    return {
        "user_id": user_id,
        "message": "Amazing! You completed all topics.",
        "topic": None,
        "remaining": 0,
    }


@app.get("/leaderboard")
def get_leaderboard(db: Session = Depends(get_db)) -> dict[str, Any]:
    rows = (
        db.query(
            User.id.label("user_id"),
            User.name.label("name"),
            func.count(Progress.topic).label("completed_count"),
        )
        .outerjoin(
            Progress,
            (Progress.user_id == User.id) & (Progress.completed.is_(True)),
        )
        .group_by(User.id, User.name)
        .order_by(func.count(Progress.topic).desc(), User.id.asc())
        .limit(10)
        .all()
    )

    return {
        "leaders": [
            {
                "rank": idx + 1,
                "user_id": row.user_id,
                "name": row.name,
                "completed_count": int(row.completed_count or 0),
            }
            for idx, row in enumerate(rows)
        ]
    }
