# Stage 1: Build Flutter Web
FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app
COPY . .
RUN flutter pub get
RUN flutter pub run build_runner build --delete-conflicting-outputs
RUN flutter build web --release

# Stage 2: Serve with Nginx
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
