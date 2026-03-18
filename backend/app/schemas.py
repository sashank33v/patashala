from pydantic import BaseModel, Field


class ProgressCreate(BaseModel):
    user_id: int = Field(..., ge=1)
    topic: str
    completed: bool = True


class ProgressOut(BaseModel):
    user_id: int
    topic: str
    completed: bool


class UserCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=80)


class LoginRequest(BaseModel):
    username: str = Field(..., min_length=3, max_length=50)
    password: str = Field(..., min_length=3, max_length=80)


class RegisterRequest(BaseModel):
    name: str = Field(..., min_length=1, max_length=80)
    username: str = Field(..., min_length=3, max_length=50)
    password: str = Field(..., min_length=3, max_length=80)


class ForgotPasswordRequest(BaseModel):
    username: str = Field(..., min_length=3, max_length=50)
    new_password: str = Field(..., min_length=3, max_length=80)
