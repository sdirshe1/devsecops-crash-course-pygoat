FROM python:3.11.0b1-buster

# Set work directory
WORKDIR /app

# Install dependencies for psycopg2
RUN apt-get update && apt-get install --no-install-recommends -y \
    dnsutils \
    libpq-dev \
    python3-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install pip and Python dependencies
RUN python -m pip install --no-cache-dir pip==22.0.4
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

# Copy project files
COPY . /app/

# Expose the port for the application
EXPOSE 8000

# Apply migrations and set up the application
RUN python3 manage.py migrate
WORKDIR /app/pygoat/

# Run the application using Gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "6", "pygoat.wsgi"]
