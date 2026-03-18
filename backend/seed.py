from app.db import Base, SessionLocal, engine
from app.models import AuthUser, User


Base.metadata.create_all(bind=engine)


def seed() -> None:
    db = SessionLocal()
    try:
        user = db.query(User).filter(User.id == 1).first()
        if not user:
            user = User(id=1, name="Student Demo")
            db.add(user)
            db.commit()
            db.refresh(user)

        auth = db.query(AuthUser).filter(AuthUser.username == "student").first()
        if not auth:
            db.add(AuthUser(user_id=user.id, username="student", password="student123"))
            db.commit()
    finally:
        db.close()


if __name__ == "__main__":
    seed()
    print("Seeded demo login: username=student password=student123")
