curl -o /dev/null -w "%{http_code}\n" \
    -X POST http://127.0.0.1:8080/async-function/faas-test-1 \
    -H "Content-Type: application/json" \
    -d '{"current_len": 0, "max_len": 10, "request_id": "abcd"}'