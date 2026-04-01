import unittest
import json

from app.modules.models.controller import ModelsController


def test_index():
    models_controller = ModelsController()
    result = models_controller.index()
    assert result == {'message': 'Hello, World!'}
