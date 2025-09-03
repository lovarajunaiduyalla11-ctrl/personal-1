# personal-1/Dockerfile
FROM nginx:alpine

# Copy all website files (HTML, CSS, JS, images) into nginx web root
COPY . /usr/share/nginx/html/

# Expose port 80 for web traffic
EXPOSE 80

# Start Nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
