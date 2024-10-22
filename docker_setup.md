docker build -t order-sept-service .

docker run -d -p 7080:8000 --memory="1g" --cpus="1.5" order-service docker run -d -p 7081:8000 --memory="1g" --cpus="1.5" order-service docker run -d -p 7082:8000 --memory="1g" --cpus="1.5" order-service
