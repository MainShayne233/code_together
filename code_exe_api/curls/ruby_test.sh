curl -H "Content-Type: application/json" -X POST  -d '{
  "language": "ruby",
  "code": "puts \"hey!\"; [1,2,3,4].map {|i| i ** 2}"
}' 'http://localhost:8880/api/v1/code/execute'
