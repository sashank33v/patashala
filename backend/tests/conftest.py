import os

import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

os.environ["DATABASE_URL"] = "sqlite:///./test_patashala.db"
os.environ["REDIS_URL"] = "redis://localhost:6399/0"

from app.db import Base  # noqa: E402
from app.models import AuthUser, User  # noqa: E402


SQLALCHEMY_TEST_DATABASE_URL = "sqlite:///./test_patashala.db"
engine = create_engine(SQLALCHEMY_TEST_DATABASE_URL, connect_args={"check_same_thread": False})
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


@pytest.fixture(scope="function")
def db_session():
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)

    db = TestingSessionLocal()
    db.add(User(id=1, name="Test Student"))
    db.commit()
    db.add(AuthUser(user_id=1, username="student", password="student123"))
    db.commit()

    try:
        yield db
    finally:
        db.close()
