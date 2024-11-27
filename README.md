# User Management Server

A server app built using [Shelf](https://pub.dev/packages/shelf), designed to handle user registration and login functionality. The server is configured to be easily run locally or with [Docker](https://www.docker.com/).

This project demonstrates a simple REST API that allows users to:
- Register (`POST /register`)
- Login (`POST /login`)

The user data is stored persistently in a JSON file on disk.

---

## Features

- **User Registration:** Users can register with a username and password.
- **Login Authentication:** Verify user credentials to authenticate requests.
- **Data Persistence:** User data is stored locally in a JSON file.
- **Error Handling:** Proper HTTP status codes for success and error responses.
- **Logging:** All incoming requests and responses are logged.

---

## Endpoints

### POST `/register`
Registers a new user with a username and password.

- **Request Body:** JSON with `username` and `password`.
- **Responses:**
  - `200 OK`: User successfully registered.
  - `400 Bad Request`: Missing or empty `username`.
  - `409 Conflict`: Username already exists.

Example:
```bash
$ curl -X POST http://0.0.0.0:8080/register \
  -H "Content-Type: application/json" \
  -d '{"username": "testuser", "password": "mypassword"}'
```

### POST `/login`
Authenticates a user by checking the provided credentials.

- **Request Body:** JSON with `username` and `password`.
- **Responses:**
  - `200 OK`: Login successful.
  - `400 Bad Request`: Missing or empty `username`.
  - `401 Unauthorized`: Invalid credentials.

Example:
```bash
$ curl -X POST http://0.0.0.0:8080/login \
  -H "Content-Type: application/json" \
  -d '{"username": "testuser", "password": "mypassword"}'
```

---

## Running the Server

### Running with the Dart SDK

You can run the server locally with the [Dart SDK](https://dart.dev/get-dart):

1. Start the server:
   ```bash
   $ dart run bin/server.dart
   Server listening on port 8080
   ```

2. Use `curl` or a similar tool to test the API:
   ```bash
   $ curl -X POST http://0.0.0.0:8080/register \
     -H "Content-Type: application/json" \
     -d '{"username": "testuser", "password": "mypassword"}'

   $ curl -X POST http://0.0.0.0:8080/login \
     -H "Content-Type: application/json" \
     -d '{"username": "testuser", "password": "mypassword"}'
   ```

### Running with Docker

If you have [Docker Desktop](https://www.docker.com/get-started) installed, you can build and run the server using Docker:

1. Build the Docker image:
   ```bash
   $ docker build . -t userserver
   ```

2. Run the Docker container:
   ```bash
   $ docker run -it -p 8080:8080 userserver
   Server listening on port 8080
   ```

3. Test the API from another terminal:
   ```bash
   $ curl -X POST http://0.0.0.0:8080/register \
     -H "Content-Type: application/json" \
     -d '{"username": "testuser", "password": "mypassword"}'

   $ curl -X POST http://0.0.0.0:8080/login \
     -H "Content-Type: application/json" \
     -d '{"username": "testuser", "password": "mypassword"}'
   ```

---

## Logging

You can observe logs of incoming requests in the terminal running the server. For example:
```
2024-11-27T15:47:04.620417  0:00:00.000158 POST    [200] /register
2024-11-27T15:47:08.392928  0:00:00.001216 POST    [401] /login
```

---

## Requirements

- **Dart SDK:** Version 3.0 or later.
- **Optional:** Docker for containerized deployment.

---

## Future Enhancements

- Add token-based authentication (e.g., JWT).
- Implement HTTPS for secure communication.
- Replace JSON file storage with a database (e.g., SQLite or PostgreSQL).
- Add rate limiting to prevent abuse of the endpoints.

---

This project is a simple starting point for understanding RESTful APIs in Dart and building user authentication systems.