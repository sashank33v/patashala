from typing import Any


class MensurationEngine:
    @staticmethod
    def build(topic_key: str, params: dict[str, Any]) -> dict[str, Any]:
        if topic_key == "rectangle_area":
            return MensurationEngine.rectangle_area(params)
        if topic_key == "square_area":
            return MensurationEngine.square_area(params)
        if topic_key == "perimeter":
            return MensurationEngine.perimeter(params)
        if topic_key == "grid_area":
            return MensurationEngine.grid_area(params)
        raise ValueError(f"Unsupported mensuration topic: {topic_key}")

    @staticmethod
    def rectangle_area(params: dict[str, Any]) -> dict[str, Any]:
        length = int(float(params.get("length", 6)))
        width = int(float(params.get("width", 4)))
        length = max(1, min(12, length))
        width = max(1, min(12, width))
        area = length * width
        perimeter = 2 * (length + width)

        return {
            "viz_type": "grid_rectangle",
            "graph": {
                "length": length,
                "width": width,
                "grid_cells": MensurationEngine._rectangle_grid(length, width),
            },
            "simulation": {
                "length": length,
                "width": width,
                "area": area,
                "perimeter": perimeter,
            },
            "animation_steps": [
                "Draw a rectangle on a square grid.",
                "Count rows and columns.",
                "Multiply length and width for area.",
            ],
            "controls": [
                {"id": "length", "type": "slider", "min": 1, "max": 12, "value": length},
                {"id": "width", "type": "slider", "min": 1, "max": 12, "value": width},
            ],
        }

    @staticmethod
    def square_area(params: dict[str, Any]) -> dict[str, Any]:
        side = int(float(params.get("side", 5)))
        side = max(1, min(12, side))

        return {
            "viz_type": "grid_square",
            "graph": {
                "side": side,
                "grid_cells": MensurationEngine._rectangle_grid(side, side),
            },
            "simulation": {
                "side": side,
                "area": side * side,
                "perimeter": 4 * side,
            },
            "animation_steps": [
                "Build a square with equal sides.",
                "Count one side length.",
                "Use side x side for area.",
            ],
            "controls": [
                {"id": "side", "type": "slider", "min": 1, "max": 12, "value": side},
            ],
        }

    @staticmethod
    def perimeter(params: dict[str, Any]) -> dict[str, Any]:
        shape = str(params.get("shape", "rectangle"))
        if shape == "square":
            side = int(float(params.get("side", 5)))
            side = max(1, min(12, side))
            perimeter = 4 * side
            graph = {"shape": "square", "points": [[0, 0], [side, 0], [side, side], [0, side], [0, 0]]}
            controls = [{"id": "side", "type": "slider", "min": 1, "max": 12, "value": side}]
            simulation = {"shape": "square", "side": side, "perimeter": perimeter}
        else:
            length = int(float(params.get("length", 7)))
            width = int(float(params.get("width", 3)))
            length = max(1, min(12, length))
            width = max(1, min(12, width))
            perimeter = 2 * (length + width)
            graph = {"shape": "rectangle", "points": [[0, 0], [length, 0], [length, width], [0, width], [0, 0]]}
            controls = [
                {"id": "length", "type": "slider", "min": 1, "max": 12, "value": length},
                {"id": "width", "type": "slider", "min": 1, "max": 12, "value": width},
            ]
            simulation = {"shape": "rectangle", "length": length, "width": width, "perimeter": perimeter}

        return {
            "viz_type": "perimeter_shape",
            "graph": graph,
            "simulation": simulation,
            "animation_steps": [
                "Trace the shape boundary.",
                "Add all side lengths.",
                "Show total perimeter instantly.",
            ],
            "controls": [{"id": "shape", "type": "choice", "options": ["rectangle", "square"], "value": simulation["shape"]}] + controls,
        }

    @staticmethod
    def grid_area(params: dict[str, Any]) -> dict[str, Any]:
        length = int(float(params.get("length", 6)))
        width = int(float(params.get("width", 5)))
        length = max(1, min(12, length))
        width = max(1, min(12, width))
        full_squares = length * width
        half_squares = int(params.get("half_squares", 2))
        half_squares = max(0, min(10, half_squares))

        return {
            "viz_type": "grid_area",
            "graph": {
                "length": length,
                "width": width,
                "full_squares": full_squares,
                "half_squares": half_squares,
                "grid_cells": MensurationEngine._rectangle_grid(length, width),
            },
            "simulation": {
                "full_squares": full_squares,
                "half_squares": half_squares,
                "estimated_area": full_squares + 0.5 * half_squares,
            },
            "animation_steps": [
                "Count all full squares in the grid.",
                "Group half squares into full squares.",
                "Add them for the final area.",
            ],
            "controls": [
                {"id": "length", "type": "slider", "min": 1, "max": 12, "value": length},
                {"id": "width", "type": "slider", "min": 1, "max": 12, "value": width},
                {"id": "half_squares", "type": "slider", "min": 0, "max": 10, "value": half_squares},
            ],
        }

    @staticmethod
    def _rectangle_grid(length: int, width: int) -> list[list[int]]:
        return [[1 for _ in range(length)] for _ in range(width)]
