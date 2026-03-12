# Use Nginx to serve the static files
FROM nginx:alpine

# Remove default nginx webpage
RUN rm -rf /usr/share/nginx/html/*

# Copy your built app into nginx's serving folder
COPY dist/ /usr/share/nginx/html

# Copy custom nginx config to run on port 3000
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 3000
EXPOSE 3000

# Start nginx
CMD ["nginx", "-g", "daemon off;"]