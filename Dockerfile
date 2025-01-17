# Auto-generated by Cloud Code AI

# Use Ubuntu as base image
FROM ubuntu:latest

# Update Ubuntu Software repository
RUN apt-get update

# Install python and pip
RUN apt-get install -y python3-pip

# Copy the current directory contents into the container at /app
COPY . /app

# Set the working directory to /app
WORKDIR /app

# Install any needed packages specified in requirements.txt
RUN pip3 install --no-cache-dir -r requirements.txt

# Make port 80 available to the world outside this container
EXPOSE 80

# Run app.py when the container launches
CMD ["python3", "app.py"]