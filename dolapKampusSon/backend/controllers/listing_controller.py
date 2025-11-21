from flask import jsonify
from models.listing import Listing
from extensions import db
from sqlalchemy import desc, or_

class ListingController:

    # ----------------------------------------------------------------------
    #  İLAN OLUŞTURMA
    # ----------------------------------------------------------------------
    @staticmethod
    def create_listing(data, user_id):
        listing = Listing(
            seller_id=user_id,
            title=data.get("title"),
            description=data.get("description"),
            category=data.get("category"),
            price=data.get("price"),
            location=data.get("location"),
            image_url=data.get("image_url"),
        )

        db.session.add(listing)
        db.session.commit()

        return jsonify({"message": "İlan oluşturuldu", "listing": listing.to_dict()}), 201

    # ----------------------------------------------------------------------
    #  TÜM İLANLAR (Arama + Filtreleme + Sıralama)
    # ----------------------------------------------------------------------
    @staticmethod
    def get_listings(filters):
        query = Listing.query

        # ⭐ 1) ARAMA — title veya description
        search_text = filters.get("query")
        if search_text:
            like = f"%{search_text}%"
            query = query.filter(
                or_(
                    Listing.title.ilike(like),
                    Listing.description.ilike(like)
                )
            )

        # ⭐ 2) KATEGORİ FİLTRESİ
        category = filters.get("category")
        if category:
            query = query.filter(Listing.category == category)

        # ⭐ 3) FİYAT FİLTRESİ
        min_price = filters.get("min_price")
        max_price = filters.get("max_price")
        if min_price:
            query = query.filter(Listing.price >= float(min_price))
        if max_price:
            query = query.filter(Listing.price <= float(max_price))

        # ⭐ 4) SIRALAMA
        sort_key = filters.get("sort")
        if sort_key == "price_asc":
            query = query.order_by(Listing.price.asc())
        elif sort_key == "price_desc":
            query = query.order_by(Listing.price.desc())
        elif sort_key == "newest":
            query = query.order_by(desc(Listing.created_at))
        else:
            # Default: en yeni
            query = query.order_by(desc(Listing.created_at))

        listings = [l.to_dict() for l in query.all()]
        return jsonify(listings), 200

    # ----------------------------------------------------------------------
    #  TEK İLAN GETİR
    # ----------------------------------------------------------------------
    @staticmethod
    def get_listing(listing_id):
        listing = Listing.query.get(listing_id)

        if not listing:
            return jsonify({"error": "İlan bulunamadı"}), 404

        return jsonify(listing.to_dict()), 200

    # ----------------------------------------------------------------------
    #  İLAN GÜNCELLE
    # ----------------------------------------------------------------------
    @staticmethod
    def update_listing(listing_id, data, user_id):
        listing = Listing.query.get(listing_id)

        if not listing:
            return jsonify({"error": "İlan yok"}), 404

        if listing.seller_id != user_id:
            return jsonify({"error": "Bu ilan size ait değil"}), 403

        listing.title = data.get("title", listing.title)
        listing.description = data.get("description", listing.description)
        listing.category = data.get("category", listing.category)
        listing.price = data.get("price", listing.price)
        listing.location = data.get("location", listing.location)

        db.session.commit()

        return jsonify({"message": "İlan güncellendi"}), 200

    # ----------------------------------------------------------------------
    #  İLAN SİL
    # ----------------------------------------------------------------------
    @staticmethod
    def delete_listing(listing_id, user_id):
        listing = Listing.query.get(listing_id)

        if not listing:
            return jsonify({"error": "İlan bulunamadı"}), 404

        if listing.seller_id != user_id:
            return jsonify({"error": "Yetkiniz yok"}), 403

        db.session.delete(listing)
        db.session.commit()

        return jsonify({"message": "İlan silindi"}), 200
