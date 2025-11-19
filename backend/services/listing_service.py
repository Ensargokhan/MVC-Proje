from models.listing import Listing
from extensions import db

class ListingService:

    @staticmethod
    def create_listing(data, user_id):
        listing = Listing(
            seller_id=user_id,
            title=data.get("title"),
            description=data.get("description"),
            category=data.get("category"),
            price=data.get("price"),
            location=data.get("location"),
            image_url=data.get("image_url")
        )
        db.session.add(listing)
        db.session.commit()
        return listing

    @staticmethod
    def get_filtered_listings(filters):
        query = Listing.query

        if "category" in filters:
            query = query.filter_by(category=filters["category"])

        if "min_price" in filters:
            query = query.filter(Listing.price >= float(filters["min_price"]))

        if "max_price" in filters:
            query = query.filter(Listing.price <= float(filters["max_price"]))

        return query.all()

    @staticmethod
    def update_listing(listing, data):
        listing.title = data.get("title", listing.title)
        listing.description = data.get("description", listing.description)
        listing.category = data.get("category", listing.category)
        listing.price = data.get("price", listing.price)
        listing.location = data.get("location", listing.location)

        db.session.commit()
        return listing

    @staticmethod
    def delete_listing(listing):
        db.session.delete(listing)
        db.session.commit()

    @staticmethod
    def get_by_id(listing_id):
        return Listing.query.get(listing_id)
