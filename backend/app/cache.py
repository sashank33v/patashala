import json
import os

import redis


class CacheClient:
    def __init__(self):
        self._memory = {}
        self._redis = None
        redis_url = os.getenv("REDIS_URL", "redis://redis:6379/0")
        try:
            self._redis = redis.Redis.from_url(
                redis_url,
                decode_responses=True,
                socket_connect_timeout=0.2,
                socket_timeout=0.2,
            )
            self._redis.ping()
        except Exception:
            self._redis = None

    def get_json(self, key: str):
        if self._redis:
            cached = self._redis.get(key)
            return json.loads(cached) if cached else None
        return self._memory.get(key)

    def set_json(self, key: str, value: dict, ttl: int = 600):
        if self._redis:
            self._redis.setex(key, ttl, json.dumps(value))
            return
        self._memory[key] = value


cache_client = CacheClient()
