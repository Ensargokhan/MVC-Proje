"""
Conversation tablosuna iki taraflı onay alanlarını ekler.
"""
from app import create_app
from extensions import db
import sqlite3
import os

def add_approval_fields():
    app = create_app()
    with app.app_context():
        # Flask instance klasöründe veritabanı dosyası
        instance_path = app.instance_path
        db_path = os.path.join(instance_path, 'campus.db')
        
        if not os.path.exists(db_path):
            print(f"Veritabanı dosyası bulunamadı: {db_path}")
            print("Veritabanı henüz oluşturulmamış. Önce backend'i bir kez çalıştırın.")
            return
        
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        
        try:
            # Yeni kolonları ekle
            cursor.execute("""
                ALTER TABLE conversation 
                ADD COLUMN buyer_approved_appointment BOOLEAN DEFAULT 0
            """)
            cursor.execute("""
                ALTER TABLE conversation 
                ADD COLUMN seller_approved_appointment BOOLEAN DEFAULT 0
            """)
            cursor.execute("""
                ALTER TABLE conversation 
                ADD COLUMN buyer_approved_delivery BOOLEAN DEFAULT 0
            """)
            cursor.execute("""
                ALTER TABLE conversation 
                ADD COLUMN seller_approved_delivery BOOLEAN DEFAULT 0
            """)
            
            conn.commit()
            print("Onay alanlari basariyla eklendi!")
        except sqlite3.OperationalError as e:
            if "duplicate column name" in str(e).lower():
                print("Bazi kolonlar zaten mevcut, atlaniyor...")
            else:
                print(f"Hata: {e}")
        finally:
            conn.close()

if __name__ == "__main__":
    add_approval_fields()

