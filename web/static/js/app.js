const page_name_field = document.getElementById('page-name')
const page_name       = page_name_field ? page_name_field.value : null

if (page_name === 'code_room')
  require('./code_room.js')
