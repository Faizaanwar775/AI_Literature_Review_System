from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    PROJECT_NAME: str = "AI Literature Review System"
    VERSION: str = "1.1.0"
    API_V1_STR: str = "/api/v1"

    # JWT Configuration — override in .env for production
    SECRET_KEY: str = "change-me-in-production-use-a-long-random-string"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60

    # Groq API key (loaded from .env automatically)
    GROQ_API_KEY: str = ""

    class Config:
        env_file = ".env"
        extra = "ignore"


settings = Settings()