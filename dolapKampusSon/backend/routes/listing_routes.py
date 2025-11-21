from flask import Blueprint, request, jsonify, current_app, url_for
from controllers.listing_controller import ListingController
from flask_jwt_extended import jwt_required, get_jwt_identity
from werkzeug.utils import secure_filename
from uuid import uuid4
import os

listing_bp = Blueprint("listing_bp", __name__)

# ----------------------------------------------------------------------
# TÜM İLANLAR
# ----------------------------------------------------------------------
@listing_bp.get("/")
def get_listings():
    filters = request.args
    return ListingController.get_listings(filters)

# ----------------------------------------------------------------------
# TEK İLAN GETİR
# ----------------------------------------------------------------------
@listing_bp.get("/<int:listing_id>")
def get_listing(listing_id):
    return ListingController.get_listing(listing_id)

# ----------------------------------------------------------------------
# İLAN OLUŞTUR
# ----------------------------------------------------------------------
@listing_bp.post("/create")
@jwt_required()
def create_listing():
    user_id = int(get_jwt_identity())
    data = request.json
    return ListingController.create_listing(data, user_id)

# ----------------------------------------------------------------------
# ⭐ RESİM YÜKLEME (Berat’ın eklediği)
# ----------------------------------------------------------------------
@listing_bp.post("/upload")
@jwt_required()
def upload_image():
    if "image" not in request.files:
        return jsonify({"error": "Resim dosyası gerekli"}), 400

    file = request.files["image"]

    if not file or file.filename == "":
        return jsonify({"error": "Geçersiz dosya"}), 400

    filename = secure_filename(file.filename)
    unique_name = f"{uuid4().hex}_{filename}"

    save_path = os.path.join(current_app.config["UPLOAD_FOLDER"], unique_name)
    file.save(save_path)

    file_url = url_for("uploads_get_file", filename=unique_name, _external=True)

    return jsonify({"url": file_url}), 201

# ----------------------------------------------------------------------
# İLAN GÜNCELLE
# ----------------------------------------------------------------------
@listing_bp.put("/update/<int:listing_id>")
@jwt_required()
def update_listing(listing_id):
    user_id = int(get_jwt_identity())
    data = request.json
    return ListingController.update_listing(listing_id, data, user_id)

# ----------------------------------------------------------------------
# İLAN SİL
# ----------------------------------------------------------------------
@listing_bp.delete("/delete/<int:listing_id>")
@jwt_required()
def delete_listing(listing_id):
    user_id = int(get_jwt_identity())
    return ListingController.delete_listing(listing_id, user_id)
