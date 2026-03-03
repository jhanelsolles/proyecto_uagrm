import psycopg2
import sys

try:
    psycopg2.connect(dbname='inscripcion_db', user='admin', password='admin123', host='localhost', port='5432')
    print("Success")
except Exception as e:
    # Get the raw bytes
    try:
        raw = e.pgerror
        if raw is None: # Sometimes pgerror is None, fallback to str(e)
            raw = str(e).encode('cp1252', 'ignore')
        else:
            raw = raw.encode('cp1252', 'ignore')
        print("Raw error:", raw)
    except:
        pass
    import traceback
    traceback.print_exc()
