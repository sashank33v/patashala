import math
from typing import Any


class TrigEngine:
    @staticmethod
    def build(topic_key: str, params: dict[str, Any]) -> dict[str, Any]:
        if topic_key == "right_triangle":
            return TrigEngine.right_triangle(params)
        if topic_key == "sine_cosine":
            return TrigEngine.sine_cosine(params)
        if topic_key == "angle_rotation":
            return TrigEngine.angle_rotation(params)
        if topic_key == "shadow_length":
            return TrigEngine.shadow_length(params)
        raise ValueError(f"Unsupported trigonometry topic: {topic_key}")

    @staticmethod
    def right_triangle(params: dict[str, Any]) -> dict[str, Any]:
        angle = float(params.get("angle", 35.0))
        hypotenuse = float(params.get("hypotenuse", 10.0))
        angle_rad = math.radians(max(5.0, min(85.0, angle)))

        opposite = round(hypotenuse * math.sin(angle_rad), 2)
        adjacent = round(hypotenuse * math.cos(angle_rad), 2)

        return {
            "viz_type": "triangle",
            "graph": {
                "points": [[0, 0], [adjacent, 0], [adjacent, opposite], [0, 0]],
                "labels": {
                    "adjacent": adjacent,
                    "opposite": opposite,
                    "hypotenuse": hypotenuse,
                    "angle": round(math.degrees(angle_rad), 1),
                },
            },
            "simulation": {
                "angle": round(math.degrees(angle_rad), 1),
                "hypotenuse": hypotenuse,
                "opposite": opposite,
                "adjacent": adjacent,
            },
            "animation_steps": [
                "Draw a horizontal base line.",
                "Lift the side to create a right triangle.",
                "Show how angle changes opposite and adjacent sides.",
            ],
            "controls": [
                {"id": "angle", "type": "slider", "min": 5, "max": 85, "value": round(math.degrees(angle_rad), 1)},
                {"id": "hypotenuse", "type": "slider", "min": 5, "max": 20, "value": hypotenuse},
            ],
        }

    @staticmethod
    def sine_cosine(params: dict[str, Any]) -> dict[str, Any]:
        angle = float(params.get("angle", 30.0))
        angle = max(0.0, min(360.0, angle))
        angle_rad = math.radians(angle)

        x_values = list(range(0, 361, 15))
        sine_points = [[x, round(math.sin(math.radians(x)), 4)] for x in x_values]
        cosine_points = [[x, round(math.cos(math.radians(x)), 4)] for x in x_values]

        return {
            "viz_type": "line_graph",
            "graph": {
                "x_label": "Angle (degrees)",
                "y_label": "Value",
                "series": [
                    {"name": "Sine", "points": sine_points},
                    {"name": "Cosine", "points": cosine_points},
                ],
                "active_point": {
                    "angle": angle,
                    "sin": round(math.sin(angle_rad), 4),
                    "cos": round(math.cos(angle_rad), 4),
                },
            },
            "simulation": {
                "angle": angle,
                "unit_circle_x": round(math.cos(angle_rad), 4),
                "unit_circle_y": round(math.sin(angle_rad), 4),
            },
            "animation_steps": [
                "Rotate the line from the origin.",
                "Project the point to horizontal and vertical axes.",
                "Compare cosine (x) and sine (y) visually.",
            ],
            "controls": [
                {"id": "angle", "type": "slider", "min": 0, "max": 360, "value": angle},
            ],
        }

    @staticmethod
    def angle_rotation(params: dict[str, Any]) -> dict[str, Any]:
        angle = float(params.get("angle", 45.0))
        angle = max(0.0, min(360.0, angle))
        angle_rad = math.radians(angle)

        return {
            "viz_type": "rotation",
            "graph": {
                "origin": [0, 0],
                "radius": 1,
                "arm_end": [round(math.cos(angle_rad), 4), round(math.sin(angle_rad), 4)],
                "path": [[round(math.cos(math.radians(a)), 4), round(math.sin(math.radians(a)), 4)] for a in range(0, int(angle) + 1, 5)],
            },
            "simulation": {
                "angle": angle,
                "quadrant": TrigEngine._quadrant(angle),
            },
            "animation_steps": [
                "Start from 0° on the positive x-axis.",
                "Rotate anti-clockwise to the selected angle.",
                "Mark the final point and quadrant.",
            ],
            "controls": [
                {"id": "angle", "type": "slider", "min": 0, "max": 360, "value": angle},
            ],
        }

    @staticmethod
    def shadow_length(params: dict[str, Any]) -> dict[str, Any]:
        angle = float(params.get("sun_angle", 40.0))
        height = float(params.get("object_height", 6.0))
        angle = max(10.0, min(80.0, angle))
        height = max(1.0, min(12.0, height))

        shadow = round(height / math.tan(math.radians(angle)), 2)

        return {
            "viz_type": "shadow",
            "graph": {
                "object_height": height,
                "shadow_length": shadow,
                "sun_angle": angle,
                "triangle": [[0, 0], [shadow, 0], [0, height], [0, 0]],
            },
            "simulation": {
                "sun_angle": angle,
                "object_height": height,
                "shadow_length": shadow,
            },
            "animation_steps": [
                "Place a standing object on the ground.",
                "Move the sun angle slider.",
                "Watch the shadow grow or shrink instantly.",
            ],
            "controls": [
                {"id": "sun_angle", "type": "slider", "min": 10, "max": 80, "value": angle},
                {"id": "object_height", "type": "slider", "min": 1, "max": 12, "value": height},
            ],
        }

    @staticmethod
    def _quadrant(angle: float) -> str:
        if angle in (0, 90, 180, 270, 360):
            return "Axis"
        if 0 < angle < 90:
            return "Quadrant I"
        if 90 < angle < 180:
            return "Quadrant II"
        if 180 < angle < 270:
            return "Quadrant III"
        return "Quadrant IV"
