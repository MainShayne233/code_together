const axios = require('axios')

const code = "1+1"

axios.get('http://localhost:8080/api/ruby/run', {
    data: {
      code: code,
    }
  })
  .then(function (response) {
    console.log(response.data);
  })
  .catch(function (error) {
    console.log(error.response.data);
  });
