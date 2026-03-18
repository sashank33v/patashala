from sqlalchemy import Boolean, Column, ForeignKey, Integer, String

from app.db import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(80), nullable=False)


class AuthUser(Base):
    __tablename__ = "auth_users"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), unique=True, nullable=False)
    username = Column(String(50), unique=True, nullable=False)
    password = Column(String(128), nullable=False)


class Progress(Base):
    __tablename__ = "progress"

    user_id = Column(Integer, ForeignKey("users.id"), primary_key=True)
    topic = Column(String(80), primary_key=True)
    completed = Column(Boolean, nullable=False, default=False)
