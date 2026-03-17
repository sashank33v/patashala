import sys
sys.path.append(".")
from app.app import SessionLocal, Topic

db = SessionLocal()

db.add(Topic(
    slug="sine-wave",
    name="Sine Wave",
    subject="Trigonometry",
    viz_type="sine_wave",
    config={"amplitude": 1, "frequency": 1, "title": "Sine Wave"},
    description="Explore how amplitude and frequency affect a sine wave."
))

db.add(Topic(
    slug="cosine-wave",
    name="Cosine Wave",
    subject="Trigonometry",
    viz_type="cosine_wave",
    config={"amplitude": 1, "frequency": 1, "title": "Cosine Wave"},
    description="See the relationship between sine and cosine."
))

db.add(Topic(
    slug="unit-circle",
    name="Unit Circle",
    subject="Trigonometry",
    viz_type="unit_circle",
    config={},
    description="Understand how angles map to coordinates on the unit circle."
))

db.commit()
db.close()
print("Seeded successfully.")
