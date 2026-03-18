from types import SimpleNamespace

from app.main import (
    forgot_password,
    get_leaderboard,
    get_progress,
    get_presets,
    get_recommendation,
    get_topics,
    get_visualization,
    login,
    save_progress,
)
from app.schemas import LoginRequest, ProgressCreate
from app.schemas import ForgotPasswordRequest


def test_get_topics():
    data = get_topics()
    assert len(data) == 8
    assert any(topic["id"] == "trig-right-triangle" for topic in data)


def test_get_visualization_triangle():
    request = SimpleNamespace(query_params={"angle": "30", "hypotenuse": "10"})
    response = get_visualization("trig-right-triangle", request)
    assert response["topic"]["id"] == "trig-right-triangle"
    assert response["visualization"]["simulation"]["opposite"] == 5.0


def test_get_visualization_rectangle():
    request = SimpleNamespace(query_params={"length": "7", "width": "3"})
    response = get_visualization("mens-rectangle-area", request)
    assert response["visualization"]["simulation"]["area"] == 21


def test_post_progress(db_session):
    payload = ProgressCreate(user_id=1, topic="mens-rectangle-area", completed=True)
    result = save_progress(payload, db_session)
    assert result.completed is True


def test_get_progress_dashboard(db_session):
    save_progress(ProgressCreate(user_id=1, topic="mens-rectangle-area", completed=True), db_session)
    save_progress(ProgressCreate(user_id=1, topic="trig-right-triangle", completed=True), db_session)

    response = get_progress(1, db_session)
    assert "Explorer" in response["badges"]
    assert response["summary"]["Trigonometry"]["completed"] == 1


def test_get_recommendation(db_session):
    save_progress(ProgressCreate(user_id=1, topic="trig-right-triangle", completed=True), db_session)
    response = get_recommendation(1, db_session)
    assert response["topic"] is not None
    assert response["topic"]["id"] != "trig-right-triangle"
    assert response["remaining"] == 7


def test_get_presets():
    response = get_presets("trig-right-triangle")
    assert response["topic_id"] == "trig-right-triangle"
    assert len(response["presets"]) >= 1


def test_get_leaderboard(db_session):
    result = save_progress(ProgressCreate(user_id=1, topic="mens-rectangle-area", completed=True), db_session)
    assert result.completed is True
    response = get_leaderboard(db_session)
    assert len(response["leaders"]) >= 1
    assert response["leaders"][0]["name"] == "Test Student"


def test_login_success(db_session):
    result = login(LoginRequest(username="student", password="student123"), db_session)
    assert result["user_id"] == 1
    assert result["username"] == "student"


def test_forgot_password_then_login(db_session):
    forgot_password(
        ForgotPasswordRequest(username="student", new_password="newpass123"),
        db_session,
    )
    result = login(LoginRequest(username="student", password="newpass123"), db_session)
    assert result["user_id"] == 1
