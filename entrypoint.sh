#!/bin/sh
set -e

# Wait for DB
echo "Waiting for database at $DB_HOST:$DB_PORT ..."
while ! nc -z "$DB_HOST" "$DB_PORT"; do
  sleep 1
done

# Apply migrations
echo "Applying database migrations..."
python manage.py migrate

# Create superuser if it does not exist
if [ -n "$DJANGO_SUPERUSER_USERNAME" ] && \
   [ -n "$DJANGO_SUPERUSER_EMAIL" ] && \
   [ -n "$DJANGO_SUPERUSER_PASSWORD" ]; then
  echo "Creating superuser if it doesn't exist..."
  python manage.py shell <<EOF
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username="${DJANGO_SUPERUSER_USERNAME}").exists():
    User.objects.create_superuser(
        username="${DJANGO_SUPERUSER_USERNAME}",
        email="${DJANGO_SUPERUSER_EMAIL}",
        password="${DJANGO_SUPERUSER_PASSWORD}",
    )
EOF
fi

# Start Gunicorn server
echo "Starting Gunicorn server..."
exec gunicorn conduit.wsgi:application --bind 0.0.0.0:8000
