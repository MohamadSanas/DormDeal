from flask import Blueprint, make_response, jsonify
from .controller import ModelsController


models_bp = Blueprint('models', __name__)
models_controller = ModelsController()
@models_bp.route('/', methods=['GET'])
def index():
    """ Example endpoint with simple greeting.
    ---
    tags:
      - Example API
    responses:
      200:
        description: A simple greeting
        schema:
          type: object
          properties:
            data:
              type: object
              properties:
                message:
                  type: string
                  example: "Hello World!"
    """
    result=models_controller.index()
    return make_response(jsonify(data=result))
      